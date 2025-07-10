//
//  StatisticsView.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI
import CoreData

struct StatisticsView: View {
    @ObservedObject var medicineManager: MedicineManager
    
    var body: some View {
        NavigationView {
            ZStack {
                GradientBackgroundView(
                    colors: [Color.purple.opacity(0.1), Color.indigo.opacity(0.05), Color.white]
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Adherence Overview
                        AdherenceOverviewCard(adherenceRate: medicineManager.adherenceRate)
                        
                        // Categories
                        CategoriesCard(categories: medicineManager.getMedicinesByCategory())
                        
                        // Recent Activity
                        RecentActivityCard(history: medicineManager.getHistory())
                        
                        // Additional Stats
                        AdditionalStatsCard(medicineManager: medicineManager)
                    }
                    .padding()
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                // Refresh data
            }
        }
    }
}

struct AdherenceOverviewCard: View {
    let adherenceRate: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: ImageAssets.adherenceIcon)
                    .foregroundColor(.white)
                Text("Overall Adherence")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            
            HStack {
                Text("\(Int(adherenceRate * 100))%")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Adherence")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Text("Rate")
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

struct CategoriesCard: View {
    let categories: [String: Int]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "folder.fill")
                    .foregroundColor(.green)
                Text("Medicine Categories")
                    .font(.headline)
                Spacer()
            }
            
            if categories.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No medicines added yet")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(Array(categories.keys.sorted()), id: \.self) { category in
                    HStack {
                        ImageAssets.MedicineIconView(category: category, size: 20)
                        Text(category)
                            .font(.body)
                        Spacer()
                        Text("\(categories[category] ?? 0)")
                            .font(.body)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(CardBackgroundView())
    }
}

struct RecentActivityCard: View {
    let history: [MedicineHistory]
    
    var recentHistory: [MedicineHistory] {
        Array(history.prefix(5))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: ImageAssets.historyIcon)
                    .foregroundColor(.purple)
                Text("Recent Activity")
                    .font(.headline)
                Spacer()
            }
            
            if recentHistory.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No recent activity")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(recentHistory) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            if let medicine = entry.medicine {
                                ImageAssets.MedicineIconView(category: medicine.category ?? "General", size: 16)
                                Text(medicine.name ?? "")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
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
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding()
        .background(CardBackgroundView())
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AdditionalStatsCard: View {
    @ObservedObject var medicineManager: MedicineManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.indigo)
                Text("Additional Statistics")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Total Meds",
                    value: "\(medicineManager.getTotalMedicines())",
                    icon: ImageAssets.medicinesTabIcon,
                    color: .blue
                )
                
                StatItem(
                    title: "Overdue",
                    value: "\(medicineManager.getOverdueRefills().count)",
                    icon: ImageAssets.overdueIcon,
                    color: .red
                )
                
                StatItem(
                    title: "Upcoming",
                    value: "\(medicineManager.upcomingRefills.count)",
                    icon: ImageAssets.upcomingIcon,
                    color: .orange
                )
            }
        }
        .padding()
        .background(CardBackgroundView())
    }
}

#Preview {
    StatisticsView(medicineManager: MedicineManager())
} 