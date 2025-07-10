//
//  MedicinesView.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI
import CoreData

struct MedicinesView: View {
    @ObservedObject var medicineManager: MedicineManager
    @State private var showAddMedicine = false
    @State private var searchText = ""
    
    var filteredMedicines: [Medicine] {
        let medicines = medicineManager.getAllMedicines()
        if searchText.isEmpty {
            return medicines
        } else {
            return medicines.filter { medicine in
                (medicine.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                (medicine.category ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView(
                    colors: [Color.green.opacity(0.1), Color.blue.opacity(0.05), Color.white]
                )
                
                List {
                    ForEach(filteredMedicines) { medicine in
                        NavigationLink(destination: MedicineDetailView(medicine: medicine, medicineManager: medicineManager)) {
                            MedicineRow(medicine: medicine)
                        }
                        .listRowBackground(Color.white.opacity(0.8))
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteMedicines)
                }
                .listStyle(PlainListStyle())
            }
            .searchable(text: $searchText, prompt: "Search medicines...")
            .navigationTitle("Medicines")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button(action: { showAddMedicine = true }) {
                    Image(systemName: ImageAssets.addIcon)
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .sheet(isPresented: $showAddMedicine) {
                AddMedicineView(medicineManager: medicineManager)
            }
        }
    }
    
    private func deleteMedicines(offsets: IndexSet) {
        for index in offsets {
            let medicine = filteredMedicines[index]
            medicineManager.deleteMedicine(medicine)
        }
    }
}

struct MedicineRow: View {
    let medicine: Medicine
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            ImageAssets.MedicineIconView(category: medicine.category ?? "General", size: 28)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(medicine.name ?? "")
                        .font(.headline)
                    Spacer()
                    Text(medicine.category ?? "")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(ImageAssets.medicineIconColor(for: medicine.category ?? "General").opacity(0.2))
                        )
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        ImageAssets.DosageFormIconView(form: medicine.dosageForm ?? "tablet", size: 12)
                        Text("\(medicine.dosage ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text(medicine.frequency ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(4)
                }
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
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct MedicineDetailView: View {
    let medicine: Medicine
    @ObservedObject var medicineManager: MedicineManager
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            GradientBackgroundView(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.05), Color.white]
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            ImageAssets.MedicineIconView(category: medicine.category ?? "General", size: 40)
                            VStack(alignment: .leading) {
                                Text(medicine.name ?? "")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text(medicine.category ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(CardBackgroundView())
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(title: "Dosage", value: "\(medicine.dosage ?? "") \(medicine.dosageForm ?? "")")
                        DetailRow(title: "Frequency", value: medicine.frequency ?? "")
                        DetailRow(title: "Prescribed By", value: medicine.prescribedBy ?? "")
                        DetailRow(title: "Quantity", value: "\(medicine.quantity)")
                        if let refillDate = medicine.refillDate {
                            DetailRow(title: "Refill Date", value: formatDate(refillDate))
                        }
                    }
                    .padding()
                    .background(CardBackgroundView())
                    
                    // Instructions
                    if let instructions = medicine.instructions, !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Instructions")
                                    .font(.headline)
                            }
                            Text(instructions)
                                .font(.body)
                        }
                        .padding()
                        .background(CardBackgroundView())
                    }
                    
                    // Side Effects
                    if let sideEffects = medicine.sideEffects, !sideEffects.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Side Effects")
                                    .font(.headline)
                            }
                            Text(sideEffects)
                                .font(.body)
                        }
                        .padding()
                        .background(CardBackgroundView())
                    }
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button(action: { showEditSheet = true }) {
                            HStack {
                                Image(systemName: ImageAssets.editIcon)
                                Text("Edit")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { showDeleteAlert = true }) {
                            HStack {
                                Image(systemName: ImageAssets.deleteIcon)
                                Text("Delete")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(CardBackgroundView())
                }
                .padding()
            }
        }
        .navigationTitle("Medicine Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            EditMedicineView(medicine: medicine, medicineManager: medicineManager)
        }
        .alert("Delete Medicine", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                medicineManager.deleteMedicine(medicine)
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \(medicine.name ?? "")? This action cannot be undone.")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    MedicinesView(medicineManager: MedicineManager())
} 