//
//  ImageAssets.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI

struct ImageAssets {
    
    // MARK: - Medicine Icons
    static func medicineIcon(for category: String) -> String {
        switch category.lowercased() {
        case "pain relief":
            return "pills.fill"
        case "antibiotics":
            return "cross.fill"
        case "vitamins":
            return "leaf.fill"
        case "heart":
            return "heart.fill"
        case "diabetes":
            return "drop.fill"
        case "general":
            return "pills"
        default:
            return "pills.fill"
        }
    }
    
    static func medicineIconColor(for category: String) -> Color {
        switch category.lowercased() {
        case "pain relief":
            return .red
        case "antibiotics":
            return .blue
        case "vitamins":
            return .green
        case "heart":
            return .pink
        case "diabetes":
            return .orange
        case "general":
            return .gray
        default:
            return .blue
        }
    }
    
    // MARK: - Dosage Form Icons
    static func dosageFormIcon(for form: String) -> String {
        switch form.lowercased() {
        case "tablet":
            return "circle.fill"
        case "capsule":
            return "capsule.fill"
        case "liquid":
            return "drop.fill"
        case "injection":
            return "syringe"
        case "cream":
            return "tube"
        case "inhaler":
            return "lungs.fill"
        default:
            return "pills.fill"
        }
    }
    
    // MARK: - Status Icons
    static let takenIcon = "checkmark.circle.fill"
    static let notTakenIcon = "circle"
    static let overdueIcon = "exclamationmark.triangle.fill"
    static let upcomingIcon = "clock.fill"
    
    // MARK: - Tab Icons
    static let todayTabIcon = "calendar"
    static let medicinesTabIcon = "pills"
    static let refillsTabIcon = "cart"
    static let statsTabIcon = "chart.bar"
    static let settingsTabIcon = "gear"
    
    // MARK: - Action Icons
    static let addIcon = "plus.circle.fill"
    static let editIcon = "pencil.circle.fill"
    static let deleteIcon = "trash.circle.fill"
    static let shareIcon = "square.and.arrow.up"
    static let exportIcon = "square.and.arrow.down"
    
    // MARK: - Feature Icons
    static let adherenceIcon = "chart.pie.fill"
    static let historyIcon = "clock.arrow.circlepath"
    static let notificationIcon = "bell.fill"
    static let reminderIcon = "alarm.fill"
    static let emergencyIcon = "phone.fill"
    
    // MARK: - Custom Image Views
    struct MedicineIconView: View {
        let category: String
        let size: CGFloat
        
        init(category: String, size: CGFloat = 24) {
            self.category = category
            self.size = size
        }
        
        var body: some View {
            Image(systemName: ImageAssets.medicineIcon(for: category))
                .font(.system(size: size))
                .foregroundColor(ImageAssets.medicineIconColor(for: category))
        }
    }
    
    struct DosageFormIconView: View {
        let form: String
        let size: CGFloat
        
        init(form: String, size: CGFloat = 16) {
            self.form = form
            self.size = size
        }
        
        var body: some View {
            Image(systemName: ImageAssets.dosageFormIcon(for: form))
                .font(.system(size: size))
                .foregroundColor(.blue)
        }
    }
    
    struct StatusIconView: View {
        let isTaken: Bool
        let size: CGFloat
        
        init(isTaken: Bool, size: CGFloat = 24) {
            self.isTaken = isTaken
            self.size = size
        }
        
        var body: some View {
            Image(systemName: isTaken ? ImageAssets.takenIcon : ImageAssets.notTakenIcon)
                .font(.system(size: size))
                .foregroundColor(isTaken ? .green : .gray)
        }
    }
    
    struct RefillStatusView: View {
        let daysUntilRefill: Int
        let size: CGFloat
        
        init(daysUntilRefill: Int, size: CGFloat = 16) {
            self.daysUntilRefill = daysUntilRefill
            self.size = size
        }
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: statusIcon)
                    .font(.system(size: size))
                    .foregroundColor(statusColor)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(statusColor)
            }
        }
        
        private var statusIcon: String {
            if daysUntilRefill < 0 {
                return ImageAssets.overdueIcon
            } else if daysUntilRefill == 0 {
                return ImageAssets.upcomingIcon
            } else {
                return ImageAssets.upcomingIcon
            }
        }
        
        private var statusColor: Color {
            if daysUntilRefill < 0 {
                return .red
            } else if daysUntilRefill <= 2 {
                return .orange
            } else {
                return .green
            }
        }
        
        private var statusText: String {
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
    }
}

// MARK: - Custom Background Views
struct GradientBackgroundView: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(colors: [Color] = [Color.blue.opacity(0.1), Color.purple.opacity(0.05), Color.white], 
         startPoint: UnitPoint = .topLeading, 
         endPoint: UnitPoint = .bottomTrailing) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
    }
}

struct CardBackgroundView: View {
    let cornerRadius: CGFloat
    let shadowRadius: CGFloat
    let shadowColor: Color
    
    init(cornerRadius: CGFloat = 16, shadowRadius: CGFloat = 8, shadowColor: Color = .gray.opacity(0.2)) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.shadowColor = shadowColor
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.white)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 4)
    }
}

// MARK: - Animated Icons
struct AnimatedMedicineIcon: View {
    let category: String
    let isAnimating: Bool
    
    @State private var isAnimatingState = false
    
    var body: some View {
        ImageAssets.MedicineIconView(category: category)
            .scaleEffect(isAnimatingState ? 1.2 : 1.0)
            .animation(
                isAnimating ? 
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) : 
                    .default,
                value: isAnimatingState
            )
            .onAppear {
                isAnimatingState = isAnimating
            }
    }
}

struct PulsingNotificationIcon: View {
    @State private var isPulsing = false
    
    var body: some View {
        Image(systemName: ImageAssets.notificationIcon)
            .font(.title2)
            .foregroundColor(.red)
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.7 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
} 