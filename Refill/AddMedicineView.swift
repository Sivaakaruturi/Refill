//
//  AddMedicineView.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI
import CoreData

struct AddMedicineView: View {
    @ObservedObject var medicineManager: MedicineManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var dosageForm = "tablet"
    @State private var frequency = "once daily"
    @State private var category = "General"
    @State private var prescribedBy = ""
    @State private var instructions = ""
    @State private var sideEffects = ""
    @State private var quantity: Int32 = 30
    @State private var refillDate = Date()
    @State private var hasRefillDate = false
    
    let dosageForms = ["tablet", "capsule", "liquid", "injection", "cream", "inhaler"]
    let frequencies = ["once daily", "twice daily", "three times daily", "four times daily", "as needed"]
    let categories = ["General", "Pain Relief", "Antibiotics", "Vitamins", "Heart", "Diabetes", "Other"]
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView(
                    colors: [Color.orange.opacity(0.1), Color.red.opacity(0.05), Color.white]
                )
                
                Form {
                    Section("Medicine Information") {
                        TextField("Medicine Name", text: $name)
                        TextField("Dosage (e.g., 500mg)", text: $dosage)
                        Picker("Dosage Form", selection: $dosageForm) {
                            ForEach(dosageForms, id: \.self) { form in
                                HStack {
                                    ImageAssets.DosageFormIconView(form: form, size: 16)
                                    Text(form.capitalized)
                                }
                                .tag(form)
                            }
                        }
                        Picker("Frequency", selection: $frequency) {
                            ForEach(frequencies, id: \.self) { freq in
                                Text(freq.capitalized).tag(freq)
                            }
                        }
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                HStack {
                                    ImageAssets.MedicineIconView(category: cat, size: 16)
                                    Text(cat)
                                }
                                .tag(cat)
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section("Prescription Details") {
                        TextField("Prescribed By", text: $prescribedBy)
                        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...1000)
                        Toggle("Set Refill Date", isOn: $hasRefillDate)
                        if hasRefillDate {
                            DatePicker("Refill Date", selection: $refillDate, displayedComponents: .date)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section("Additional Information") {
                        TextField("Instructions", text: $instructions, axis: .vertical)
                            .lineLimit(3...6)
                        TextField("Side Effects", text: $sideEffects, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedicine()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                    .foregroundColor(.green)
                }
            }
        }
    }
    
    private func saveMedicine() {
        medicineManager.addMedicine(
            name: name,
            dosage: dosage,
            dosageForm: dosageForm,
            frequency: frequency,
            category: category,
            prescribedBy: prescribedBy,
            instructions: instructions,
            sideEffects: sideEffects,
            quantity: quantity,
            refillDate: hasRefillDate ? refillDate : nil
        )
        dismiss()
    }
}

struct EditMedicineView: View {
    let medicine: Medicine
    @ObservedObject var medicineManager: MedicineManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var dosage: String
    @State private var dosageForm: String
    @State private var frequency: String
    @State private var category: String
    @State private var prescribedBy: String
    @State private var instructions: String
    @State private var sideEffects: String
    @State private var quantity: Int32
    @State private var refillDate: Date
    @State private var hasRefillDate: Bool
    
    let dosageForms = ["tablet", "capsule", "liquid", "injection", "cream", "inhaler"]
    let frequencies = ["once daily", "twice daily", "three times daily", "four times daily", "as needed"]
    let categories = ["General", "Pain Relief", "Antibiotics", "Vitamins", "Heart", "Diabetes", "Other"]
    
    init(medicine: Medicine, medicineManager: MedicineManager) {
        self.medicine = medicine
        self.medicineManager = medicineManager
        
        _name = State(initialValue: medicine.name ?? "")
        _dosage = State(initialValue: medicine.dosage ?? "")
        _dosageForm = State(initialValue: medicine.dosageForm ?? "tablet")
        _frequency = State(initialValue: medicine.frequency ?? "once daily")
        _category = State(initialValue: medicine.category ?? "General")
        _prescribedBy = State(initialValue: medicine.prescribedBy ?? "")
        _instructions = State(initialValue: medicine.instructions ?? "")
        _sideEffects = State(initialValue: medicine.sideEffects ?? "")
        _quantity = State(initialValue: medicine.quantity)
        _refillDate = State(initialValue: medicine.refillDate ?? Date())
        _hasRefillDate = State(initialValue: medicine.refillDate != nil)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView(
                    colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.05), Color.white]
                )
                
                Form {
                    Section("Medicine Information") {
                        TextField("Medicine Name", text: $name)
                        TextField("Dosage (e.g., 500mg)", text: $dosage)
                        Picker("Dosage Form", selection: $dosageForm) {
                            ForEach(dosageForms, id: \.self) { form in
                                HStack {
                                    ImageAssets.DosageFormIconView(form: form, size: 16)
                                    Text(form.capitalized)
                                }
                                .tag(form)
                            }
                        }
                        Picker("Frequency", selection: $frequency) {
                            ForEach(frequencies, id: \.self) { freq in
                                Text(freq.capitalized).tag(freq)
                            }
                        }
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { cat in
                                HStack {
                                    ImageAssets.MedicineIconView(category: cat, size: 16)
                                    Text(cat)
                                }
                                .tag(cat)
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section("Prescription Details") {
                        TextField("Prescribed By", text: $prescribedBy)
                        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...1000)
                        Toggle("Set Refill Date", isOn: $hasRefillDate)
                        if hasRefillDate {
                            DatePicker("Refill Date", selection: $refillDate, displayedComponents: .date)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section("Additional Information") {
                        TextField("Instructions", text: $instructions, axis: .vertical)
                            .lineLimit(3...6)
                        TextField("Side Effects", text: $sideEffects, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Edit Medicine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveMedicine()
                    }
                    .disabled(name.isEmpty || dosage.isEmpty)
                    .foregroundColor(.green)
                }
            }
        }
    }
    
    private func saveMedicine() {
        medicine.name = name
        medicine.dosage = dosage
        medicine.dosageForm = dosageForm
        medicine.frequency = frequency
        medicine.category = category
        medicine.prescribedBy = prescribedBy
        medicine.instructions = instructions
        medicine.sideEffects = sideEffects
        medicine.quantity = quantity
        medicine.refillDate = hasRefillDate ? refillDate : nil
        
        medicineManager.updateMedicine(medicine)
        dismiss()
    }
}

#Preview {
    AddMedicineView(medicineManager: MedicineManager())
} 