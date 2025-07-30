# 🏥 Refill - Medicine Reminder App

A comprehensive iOS medicine management and reminder app built with SwiftUI and Core Data. Never miss your medications or refills again!

![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-green.svg)
![Core Data](https://img.shields.io/badge/Core%20Data-Yes-purple.svg)

## 📱 Features

### 🎯 Core Functionality
- **Medicine Management**: Add, edit, delete, and categorize medicines
- **Daily Dosage Tracking**: Automatic scheduling and dose marking
- **Refill Alerts**: Smart notifications for upcoming refills
- **Adherence Monitoring**: Track medication compliance
- **Activity History**: Complete log of all medicine activities
- **Search & Filter**: Find medicines quickly by name or category

### 🎨 User Experience
- **Beautiful UI**: Modern design with gradients and animations
- **5-Tab Interface**: Organized navigation (Today, Medicines, Refills, Stats, Settings)
- **Visual Feedback**: Color-coded status indicators
- **Quick Actions**: Fast access to common tasks
- **Responsive Design**: Optimized for all iPhone screens

### 🔒 Privacy & Security
- **Local Storage**: All data stored on device using Core Data
- **No Internet Required**: Works completely offline
- **No Data Sharing**: Complete privacy, no cloud sync
- **Data Export**: Export medicine data as CSV

## 📋 Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+
- macOS 12.0+ (for development)

## 🚀 Installation

### Prerequisites
1. Install [Xcode](https://developer.apple.com/xcode/) from the App Store
2. Ensure you have a valid Apple Developer account (free for testing)

### Setup Steps
1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Refill.git
   cd Refill
   ```

2. **Open in Xcode**
   ```bash
   open Refill.xcodeproj
   ```

3. **Build and Run**
   - Select your target device (iPhone Simulator or physical device)
   - Press `Cmd + R` to build and run
   - The app will automatically create the Core Data store

## 📁 Project Structure

```
Refill/
├── RefillApp.swift                 # Main app entry point
├── DashboardView.swift             # Main tab-based interface
├── MedicinesView.swift             # Medicine list and details
├── AddMedicineView.swift           # Add/edit medicine forms
├── RefillsView.swift               # Refill tracking
├── StatisticsView.swift            # Analytics and statistics
├── SettingsView.swift              # App settings
├── MedicineManager.swift           # Core Data manager
├── PersistenceController.swift     # Core Data stack
├── SharedComponents.swift          # Shared UI components
├── ImageAssets.swift               # Icons and styling
├── RefillModel.xcdatamodeld/       # Core Data model
└── Assets.xcassets/                # App assets
```

## 🎯 Core Data Model

### Entities
- **Medicine**: Stores medicine information (name, dosage, frequency, category, etc.)
- **MedicineDosage**: Tracks daily dosages and their status
- **MedicineHistory**: Records all medicine-related activities

### Relationships
- Medicine → MedicineDosage (one-to-many)
- Medicine → MedicineHistory (one-to-many)

## 📱 App Screenshots

### Main Dashboard
- Today's dosage schedule
- Adherence tracking
- Quick action buttons
- Summary statistics

<img width="1171" height="606" alt="Screenshot 2025-07-30 at 1 13 54 PM" src="https://github.com/user-attachments/assets/e91254ce-b5e9-48a0-8273-009d4453e9ec" />



### Medicine Management
- Complete medicine list 
- Detailed medicine information
- Add/edit/delete functionality
<img width="788" height="554" alt="Screenshot 2025-07-30 at 1 18 04 PM" src="https://github.com/user-attachments/assets/f62f03e3-6e19-4e65-9e0d-3662945dbf76" />

### Refill Tracking
- Upcoming and overdue refills
- Color-coded status indicators
- Due date information

### Statistics
- Overall adherence rates
- Medicine categories breakdown
- Recent activity feed
<img width="532" height="560" alt="Screenshot 2025-07-30 at 1 22 03 PM" src="https://github.com/user-attachments/assets/5e93470a-7896-475a-afea-1c784988f0a8" />

## 🎮 Usage Guide

### Adding a Medicine
1. Tap the "+" button on any screen
2. Fill in medicine details (name, dosage, frequency, category)
3. Set refill date (optional)
4. Add instructions and side effects
5. Tap "Save"

### Tracking Dosages
1. Go to "Today" tab
2. See all scheduled dosages for today
3. Tap the circle next to each dosage to mark as taken
4. View adherence percentage at the top

### Managing Refills
1. Go to "Refills" tab
2. See all upcoming and overdue refills
3. Use "Check Refills" quick action from home screen
4. Get alerts for refills due within 4 days

### Viewing History
1. Use "View History" quick action from home screen
2. See complete activity log
3. Track all medicine-related activities

## 🔧 Development

### Architecture
- **MVVM Pattern**: Model-View-ViewModel architecture
- **Core Data**: Persistent data storage
- **SwiftUI**: Modern declarative UI framework
- **ObservableObject**: Reactive data binding

### Key Components
- **MedicineManager**: Handles all Core Data operations
- **PersistenceController**: Manages Core Data stack
- **DashboardView**: Main navigation hub
- **SharedComponents**: Reusable UI components

### Adding New Features
1. Create new SwiftUI views in separate files
2. Add Core Data entities if needed
3. Update MedicineManager for new functionality
4. Integrate with existing navigation

## 🧪 Testing

### Sample Data
The app includes sample medicines to demonstrate functionality:
- **Aspirin** (Pain Relief) - Due in 7 days
- **Vitamin D** (Vitamins) - Due in 14 days
- **Metformin** (Diabetes) - Due in 2 days (triggers alerts)

### Testing Scenarios
1. Add new medicines
2. Mark dosages as taken
3. Check refill alerts
4. View activity history
5. Test search functionality
6. Verify data persistence

## 🐛 Troubleshooting

### Common Issues
1. **Build Errors**: Clean build folder (`Cmd + Shift + K`)
2. **Core Data Issues**: Delete app and reinstall
3. **UI Issues**: Check device orientation and size classes

### Debug Tips
- Use Xcode's Core Data debugger
- Check console for Core Data errors
- Verify Core Data model is properly set up

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Karuturi Siva Rama Krishna**
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Apple for SwiftUI and Core Data frameworks
- SF Symbols for beautiful icons
- SwiftUI community for inspiration and guidance

## 📞 Support

If you have any questions or need help:
- Open an issue on GitHub
- Check the troubleshooting section
- Review the usage guide

---

⭐ **Star this repository if you find it helpful!**

Made with ❤️ using SwiftUI and Core Data 
