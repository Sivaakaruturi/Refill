//
//  DashboardView.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI
import CoreData

struct DashboardView: View {
    @StateObject private var medicineManager = MedicineManager()
    @State private var selectedTab = 0
    @State private var showRefillAlert = false
    @State private var refillAlertMedicines: [Medicine] = []
    @State private var showHistoryView = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(
                medicineManager: medicineManager,
                selectedTab: $selectedTab,
                showHistoryView: $showHistoryView
            )
                .tabItem {
                    Image(systemName: ImageAssets.todayTabIcon)
                    Text("Today")
                }
                .tag(0)
            
            MedicinesView(medicineManager: medicineManager)
                .tabItem {
                    Image(systemName: ImageAssets.medicinesTabIcon)
                    Text("Medicines")
                }
                .tag(1)
            
            RefillsView(medicineManager: medicineManager)
                .tabItem {
                    Image(systemName: ImageAssets.refillsTabIcon)
                    Text("Refills")
                }
                .tag(2)
            
            StatisticsView(medicineManager: medicineManager)
                .tabItem {
                    Image(systemName: ImageAssets.statsTabIcon)
                    Text("Stats")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: ImageAssets.settingsTabIcon)
                    Text("Settings")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .onAppear {
            medicineManager.addSampleData()
            checkRefillAlerts()
        }
        .alert("Refill Reminder", isPresented: $showRefillAlert) {
            Button("View Refills") {
                selectedTab = 2 // Switch to Refills tab
            }
            Button("Dismiss", role: .cancel) { }
        } message: {
            Text(refillAlertMessage)
        }
    }
    
    private func checkRefillAlerts() {
        refillAlertMedicines = medicineManager.getRefillsDueWithinDays(4)
        
        if !refillAlertMedicines.isEmpty {
            showRefillAlert = true
        }
    }
    
    private var refillAlertMessage: String {
        if refillAlertMedicines.count == 1 {
            let medicine = refillAlertMedicines[0]
            let daysUntilRefill = daysUntilRefill(for: medicine.refillDate!)
            if daysUntilRefill == 0 {
                return "\(medicine.name ?? "") needs to be refilled today!"
            } else if daysUntilRefill == 1 {
                return "\(medicine.name ?? "") needs to be refilled tomorrow."
            } else {
                return "\(medicine.name ?? "") needs to be refilled in \(daysUntilRefill) days."
            }
        } else {
            let overdueCount = refillAlertMedicines.filter { medicine in
                guard let refillDate = medicine.refillDate else { return false }
                return refillDate < Date()
            }.count
            
            let upcomingCount = refillAlertMedicines.count - overdueCount
            
            var message = "You have "
            if overdueCount > 0 {
                message += "\(overdueCount) overdue refill\(overdueCount == 1 ? "" : "s")"
                if upcomingCount > 0 {
                    message += " and "
                }
            }
            if upcomingCount > 0 {
                message += "\(upcomingCount) upcoming refill\(upcomingCount == 1 ? "" : "s")"
            }
            message += " within 4 days."
            
            return message
        }
    }
    
    private func daysUntilRefill(for date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
}

struct TodayView: View {
    @ObservedObject var medicineManager: MedicineManager
    @Binding var selectedTab: Int
    @Binding var showHistoryView: Bool
    @State private var showAddMedicine = false
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05), Color.white]
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with notification
                        if medicineManager.getOverdueRefillsCount() > 0 {
                            OverdueRefillsAlert(overdueCount: medicineManager.getOverdueRefillsCount())
                        }
                        
                        // Adherence Card
                        AdherenceCard(adherenceRate: medicineManager.adherenceRate)
                        
                        // Today's Dosages
                        TodayDosagesCard(medicineManager: medicineManager)
                        
                        // Quick Actions
                        QuickActionsCard(
                            showAddMedicine: $showAddMedicine,
                            onCheckRefills: { selectedTab = 2 },
                            onViewHistory: { showHistoryView = true }
                        )
                        
                        // Summary Stats
                        SummaryStatsCard(medicineManager: medicineManager)
                    }
                    .padding()
                }
            }
            .navigationTitle("Today's Schedule")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddMedicine = true }) {
                        Image(systemName: ImageAssets.addIcon)
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddMedicine) {
                AddMedicineView(medicineManager: medicineManager)
            }
            .sheet(isPresented: $showHistoryView) {
                HistoryView(medicineManager: medicineManager)
            }
        }
    }
}

struct OverdueRefillsAlert: View {
    let overdueCount: Int
    
    var body: some View {
        HStack {
            Image(systemName: ImageAssets.overdueIcon)
                .foregroundColor(.white)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Overdue Refills")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("\(overdueCount) medicine(s) need refilling")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.gradient)
        )
        .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

struct AdherenceCard: View {
    let adherenceRate: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: ImageAssets.adherenceIcon)
                    .foregroundColor(.white)
                Text("Today's Adherence")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack {
                Text("\(Int(adherenceRate * 100))%")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("Dosages")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [adherenceColor, adherenceColor.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: adherenceColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    private var adherenceColor: Color {
        if adherenceRate >= 0.8 { return .green }
        else if adherenceRate >= 0.6 { return .orange }
        else { return .red }
    }
}

struct TodayDosagesCard: View {
    @ObservedObject var medicineManager: MedicineManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
                Text("Today's Dosages")
                    .font(.headline)
                Spacer()
                
                Text("\(medicineManager.todayDosages.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
            
            if medicineManager.todayDosages.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "pills")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No dosages scheduled for today")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(medicineManager.todayDosages) { dosage in
                    DosageRow(dosage: dosage, medicineManager: medicineManager)
                }
            }
        }
        .padding()
        .background(CardBackgroundView())
    }
}

struct DosageRow: View {
    let dosage: MedicineDosage
    @ObservedObject var medicineManager: MedicineManager
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            if let medicine = dosage.medicine {
                ImageAssets.MedicineIconView(category: medicine.category ?? "General", size: 24)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(medicine.name ?? "")
                        .font(.headline)
                    HStack(spacing: 8) {
                        Text(formatTime(dosage.scheduledTime ?? Date()))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        ImageAssets.DosageFormIconView(form: medicine.dosageForm ?? "tablet", size: 12)
                        
                        Text("\(medicine.dosage ?? "")")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    medicineManager.toggleDosageTaken(dosage)
                }
            }) {
                ImageAssets.StatusIconView(isTaken: dosage.isTaken, size: 28)
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(dosage.isTaken ? Color.green.opacity(0.1) : Color.gray.opacity(0.05))
        )
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct QuickActionsCard: View {
    @Binding var showAddMedicine: Bool
    let onCheckRefills: () -> Void
    let onViewHistory: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.purple)
                Text("Quick Actions")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Add Medicine",
                    icon: ImageAssets.addIcon,
                    color: .blue
                ) {
                    showAddMedicine = true
                }
                
                QuickActionButton(
                    title: "Check Refills",
                    icon: ImageAssets.refillsTabIcon,
                    color: .orange
                ) {
                    onCheckRefills()
                }
                
                QuickActionButton(
                    title: "View History",
                    icon: ImageAssets.historyIcon,
                    color: .green
                ) {
                    onViewHistory()
                }
            }
        }
        .padding()
        .background(CardBackgroundView())
    }
}

struct SummaryStatsCard: View {
    @ObservedObject var medicineManager: MedicineManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.indigo)
                Text("Today's Summary")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Total",
                    value: "\(medicineManager.getTotalMedicines())",
                    icon: ImageAssets.medicinesTabIcon,
                    color: .blue
                )
                
                StatItem(
                    title: "Taken",
                    value: "\(medicineManager.todayDosages.filter { $0.isTaken }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatItem(
                    title: "Pending",
                    value: "\(medicineManager.todayDosages.filter { !$0.isTaken }.count)",
                    icon: "clock.fill",
                    color: .orange
                )
            }
        }
        .padding()
        .background(CardBackgroundView())
    }
}



struct HistoryView: View {
    @ObservedObject var medicineManager: MedicineManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView(
                    colors: [Color.purple.opacity(0.1), Color.indigo.opacity(0.05), Color.white]
                )
                
                List {
                    if medicineManager.getHistory().isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clock")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No history yet")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("Your medicine activities will appear here")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(medicineManager.getHistory()) { entry in
                            HistoryRow(entry: entry)
                        }
                        .listRowBackground(Color.white.opacity(0.8))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Activity History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HistoryRow: View {
    let entry: MedicineHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let medicine = entry.medicine {
                    ImageAssets.MedicineIconView(category: medicine.category ?? "General", size: 20)
                    Text(medicine.name ?? "")
                        .font(.headline)
                }
                Spacer()
                if let date = entry.date {
                    Text(formatTime(date))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            if let action = entry.action {
                Text(action)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            
            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    DashboardView()
} 