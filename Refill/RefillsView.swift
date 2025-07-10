//
//  RefillsView.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI
import CoreData

struct RefillsView: View {
    @ObservedObject var medicineManager: MedicineManager
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView(
                    colors: [Color.orange.opacity(0.1), Color.yellow.opacity(0.05), Color.white]
                )
                
                List {
                    if medicineManager.upcomingRefills.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "cart")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No upcoming refills")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Text("All your medicines are well stocked")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(medicineManager.upcomingRefills) { medicine in
                            RefillRow(medicine: medicine)
                        }
                        .listRowBackground(Color.white.opacity(0.8))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Refills")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                medicineManager.fetchUpcomingRefills()
            }
        }
    }
}

struct RefillRow: View {
    let medicine: Medicine
    @State private var isPressed = false
    
    var daysUntilRefill: Int {
        guard let refillDate = medicine.refillDate else { return 0 }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: refillDate).day ?? 0
    }
    
    var statusColor: Color {
        if daysUntilRefill < 0 {
            return .red
        } else if daysUntilRefill <= 2 {
            return .orange
        } else {
            return .green
        }
    }
    
    var statusText: String {
        if daysUntilRefill < 0 {
            return "Overdue"
        } else if daysUntilRefill == 0 {
            return "Today"
        } else if daysUntilRefill == 1 {
            return "Tomorrow"
        } else {
            return "\(daysUntilRefill) days"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ImageAssets.MedicineIconView(category: medicine.category ?? "General", size: 32)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(medicine.name ?? "")
                        .font(.headline)
                    Spacer()
                    Text(statusText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(statusColor.opacity(0.2))
                        )
                        .foregroundColor(statusColor)
                }
                
                HStack(spacing: 12) {
                    Text("Quantity: \(medicine.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    if let refillDate = medicine.refillDate {
                        Text(formatDate(refillDate))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: statusColor.opacity(0.2), radius: 4, x: 0, y: 2)
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    RefillsView(medicineManager: MedicineManager())
} 