//
//  MedicineManager.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import Foundation
import CoreData
import SwiftUI

class MedicineManager: ObservableObject {
    private let context: NSManagedObjectContext
    @Published var todayDosages: [MedicineDosage] = []
    @Published var upcomingRefills: [Medicine] = []
    @Published var adherenceRate: Double = 0.0
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        generateTodayDosages()
        fetchUpcomingRefills()
    }
    
    // MARK: - Medicine Management
    
    func addMedicine(name: String, dosage: String, dosageForm: String, frequency: String, 
                    category: String, prescribedBy: String, instructions: String, 
                    sideEffects: String, quantity: Int32, refillDate: Date?) {
        let medicine = Medicine(context: context)
        medicine.id = UUID()
        medicine.name = name
        medicine.dosage = dosage
        medicine.dosageForm = dosageForm
        medicine.frequency = frequency
        medicine.category = category
        medicine.prescribedBy = prescribedBy
        medicine.instructions = instructions
        medicine.sideEffects = sideEffects
        medicine.quantity = quantity
        medicine.refillDate = refillDate
        medicine.createdAt = Date()
        medicine.isActive = true
        
        save()
        
        // Add to history
        addHistoryEntry(medicine: medicine, action: "Medicine added", notes: "Added \(medicine.name ?? "") to medication list")
        
        generateTodayDosages()
        fetchUpcomingRefills()
        updateAdherenceRate()
    }
    
    func updateMedicine(_ medicine: Medicine) {
        save()
        
        // Add to history
        addHistoryEntry(medicine: medicine, action: "Medicine updated", notes: "Updated details for \(medicine.name ?? "")")
        
        generateTodayDosages()
        fetchUpcomingRefills()
        updateAdherenceRate()
    }
    
    func deleteMedicine(_ medicine: Medicine) {
        // Add to history before deletion
        addHistoryEntry(medicine: medicine, action: "Medicine deleted", notes: "Removed \(medicine.name ?? "") from medication list")
        
        context.delete(medicine)
        save()
        
        generateTodayDosages()
        fetchUpcomingRefills()
        updateAdherenceRate()
    }
    
    func toggleDosageTaken(_ dosage: MedicineDosage) {
        dosage.isTaken.toggle()
        dosage.takenTime = dosage.isTaken ? Date() : nil
        
        save()
        
        // Add to history
        if let medicine = dosage.medicine {
            let action = dosage.isTaken ? "Dosage taken" : "Dosage marked as not taken"
            let notes = "Dosage at \(formatTime(dosage.scheduledTime ?? Date()))"
            addHistoryEntry(medicine: medicine, action: action, notes: notes)
        }
        updateAdherenceRate()
    }
    
    // MARK: - Dosage Management
    
    private func generateDosages(for medicine: Medicine) {
        let times = parseFrequency(medicine.frequency ?? "once daily")
        
        for time in times {
            let dosage = MedicineDosage(context: context)
            dosage.id = UUID()
            dosage.medicine = medicine
            dosage.scheduledTime = time
            dosage.isTaken = false
            dosage.takenTime = nil
        }
    }
    
    private func parseFrequency(_ frequency: String) -> [Date] {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        switch frequency.lowercased() {
        case "once daily":
            return [calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today]
        case "twice daily":
            return [
                calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today,
                calendar.date(bySettingHour: 21, minute: 0, second: 0, of: today) ?? today
            ]
        case "three times daily":
            return [
                calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today) ?? today,
                calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today) ?? today,
                calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) ?? today
            ]
        case "four times daily":
            return [
                calendar.date(bySettingHour: 6, minute: 0, second: 0, of: today) ?? today,
                calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today) ?? today,
                calendar.date(bySettingHour: 18, minute: 0, second: 0, of: today) ?? today,
                calendar.date(bySettingHour: 22, minute: 0, second: 0, of: today) ?? today
            ]
        case "as needed":
            return [calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today]
        default:
            return [calendar.date(bySettingHour: 9, minute: 0, second: 0, of: today) ?? today]
        }
    }
    
    func generateTodayDosages() {
        // Clear existing dosages for today
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        let request: NSFetchRequest<MedicineDosage> = MedicineDosage.fetchRequest()
        request.predicate = NSPredicate(format: "scheduledTime >= %@ AND scheduledTime < %@", today as NSDate, tomorrow as NSDate)
        
        do {
            let existingDosages = try context.fetch(request)
            for dosage in existingDosages {
                context.delete(dosage)
            }
        } catch {
            print("Error fetching existing dosages: \(error)")
        }
        
        // Generate dosages for all active medicines
        let medicineRequest: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        medicineRequest.predicate = NSPredicate(format: "isActive == YES")
        
        do {
            let medicines = try context.fetch(medicineRequest)
            for medicine in medicines {
                generateDosages(for: medicine)
            }
        } catch {
            print("Error fetching medicines: \(error)")
        }
        
        save()
        
        // Update today's dosages
        do {
            todayDosages = try context.fetch(request)
            todayDosages.sort { ($0.scheduledTime ?? Date()) < ($1.scheduledTime ?? Date()) }
            updateAdherenceRate()
        } catch {
            print("Error fetching today's dosages: \(error)")
        }
    }
    
    // MARK: - Data Fetching
    
    func fetchUpcomingRefills() {
        let calendar = Calendar.current
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) ?? today
        
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "refillDate >= %@ AND refillDate <= %@ AND isActive == YES", today as NSDate, nextWeek as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Medicine.refillDate, ascending: true)]
        
        do {
            upcomingRefills = try context.fetch(request)
        } catch {
            print("Error fetching upcoming refills: \(error)")
        }
    }
    
    // MARK: - Refill Alert Methods
    
    func getRefillsDueWithinDays(_ days: Int) -> [Medicine] {
        let calendar = Calendar.current
        let today = Date()
        let targetDate = calendar.date(byAdding: .day, value: days, to: today) ?? today
        
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "refillDate <= %@ AND refillDate >= %@ AND isActive == YES", targetDate as NSDate, today as NSDate)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching refills due within days: \(error)")
            return []
        }
    }
    
    func getOverdueRefills() -> [Medicine] {
        let today = Date()
        
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "refillDate < %@ AND isActive == YES", today as NSDate)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching overdue refills: \(error)")
            return []
        }
    }
    
    func getOverdueRefillsCount() -> Int {
        return getOverdueRefills().count
    }
    
    func getRefillsDueToday() -> [Medicine] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "refillDate >= %@ AND refillDate < %@ AND isActive == YES", today as NSDate, tomorrow as NSDate)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching refills due today: \(error)")
            return []
        }
    }
    
    func getRefillsDueTomorrow() -> [Medicine] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today
        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today) ?? tomorrow
        
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "refillDate >= %@ AND refillDate < %@ AND isActive == YES", tomorrow as NSDate, dayAfterTomorrow as NSDate)
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching refills due tomorrow: \(error)")
            return []
        }
    }
    
    // MARK: - Statistics
    
    func getAdherenceRate() -> Double {
        return adherenceRate
    }
    
    func getMedicinesByCategory() -> [String: Int] {
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        
        do {
            let medicines = try context.fetch(request)
            var categories: [String: Int] = [:]
            for medicine in medicines {
                let category = medicine.category ?? "Unknown"
                categories[category, default: 0] += 1
            }
            return categories
        } catch {
            print("Error fetching medicines by category: \(error)")
            return [:]
        }
    }
    
    func getTotalMedicines() -> Int {
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        
        do {
            return try context.count(for: request)
        } catch {
            print("Error counting total medicines: \(error)")
            return 0
        }
    }
    
    func getAllMedicines() -> [Medicine] {
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        request.predicate = NSPredicate(format: "isActive == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Medicine.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching all medicines: \(error)")
            return []
        }
    }
    
    func getHistory() -> [MedicineHistory] {
        let request: NSFetchRequest<MedicineHistory> = MedicineHistory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \MedicineHistory.date, ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching history: \(error)")
            return []
        }
    }
    
    // MARK: - History Management
    
    private func addHistoryEntry(medicine: Medicine, action: String, notes: String) {
        let historyEntry = MedicineHistory(context: context)
        historyEntry.id = UUID()
        historyEntry.medicine = medicine
        historyEntry.action = action
        historyEntry.date = Date()
        historyEntry.notes = notes
        
        save()
    }
    
    // MARK: - Utility Functions
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func save() {
        PersistenceController.shared.save()
    }
    
    private func updateAdherenceRate() {
        let takenCount = todayDosages.filter { $0.isTaken }.count
        let totalCount = todayDosages.count
        adherenceRate = totalCount > 0 ? Double(takenCount) / Double(totalCount) : 0.0
    }
    
    // MARK: - Data Management
    
    func resetAllData() {
        let medicineRequest: NSFetchRequest<NSFetchRequestResult> = Medicine.fetchRequest()
        let dosageRequest: NSFetchRequest<NSFetchRequestResult> = MedicineDosage.fetchRequest()
        let historyRequest: NSFetchRequest<NSFetchRequestResult> = MedicineHistory.fetchRequest()
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: medicineRequest)
        let deleteDosageRequest = NSBatchDeleteRequest(fetchRequest: dosageRequest)
        let deleteHistoryRequest = NSBatchDeleteRequest(fetchRequest: historyRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.execute(deleteDosageRequest)
            try context.execute(deleteHistoryRequest)
            save()
            
            todayDosages.removeAll()
            upcomingRefills.removeAll()
            adherenceRate = 0.0
        } catch {
            print("Error resetting data: \(error)")
        }
    }
    
    func exportData() -> String {
        let medicines = getAllMedicines()
        var csv = "Name,Dosage,Category,Frequency,Prescribed By,Quantity,Refill Date\n"
        for medicine in medicines {
            let refillDate = medicine.refillDate?.description ?? "Not set"
            csv += "\(medicine.name ?? ""),\(medicine.dosage ?? ""),\(medicine.category ?? ""),\(medicine.frequency ?? ""),\(medicine.prescribedBy ?? ""),\(medicine.quantity),\(refillDate)\n"
        }
        return csv
    }
    
    // MARK: - Sample Data
    
    func addSampleData() {
        // Check if we already have data
        let request: NSFetchRequest<Medicine> = Medicine.fetchRequest()
        do {
            let count = try context.count(for: request)
            if count > 0 {
                return // Already has data
            }
        } catch {
            print("Error checking existing data: \(error)")
        }
        
        // Add sample medicines
        addMedicine(
            name: "Aspirin",
            dosage: "100mg",
            dosageForm: "tablet",
            frequency: "once daily",
            category: "Pain Relief",
            prescribedBy: "Dr. Smith",
            instructions: "Take with food to avoid stomach upset",
            sideEffects: "May cause stomach irritation",
            quantity: 30,
            refillDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())
        )
        
        addMedicine(
            name: "Vitamin D",
            dosage: "1000 IU",
            dosageForm: "capsule",
            frequency: "once daily",
            category: "Vitamins",
            prescribedBy: "Dr. Johnson",
            instructions: "Take in the morning with breakfast",
            sideEffects: "Generally well tolerated",
            quantity: 60,
            refillDate: Calendar.current.date(byAdding: .day, value: 14, to: Date())
        )
        
        addMedicine(
            name: "Metformin",
            dosage: "500mg",
            dosageForm: "tablet",
            frequency: "twice daily",
            category: "Diabetes",
            prescribedBy: "Dr. Brown",
            instructions: "Take with meals to reduce side effects",
            sideEffects: "May cause nausea or diarrhea initially",
            quantity: 60,
            refillDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()) // This will trigger the alert
        )
    }
} 