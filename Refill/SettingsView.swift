//
//  SettingsView.swift
//  Refill
//
//  Created by Karuturi Siva Rama Krishna on 17/06/25.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reminderTime") private var reminderTime = Date()
    @AppStorage("userName") private var userName = ""
    @AppStorage("emergencyContact") private var emergencyContact = ""
    @StateObject private var medicineManager = MedicineManager()
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Beautiful gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.indigo.opacity(0.1),
                        Color.purple.opacity(0.05),
                        Color.white
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("Personal Information") {
                        TextField("Your Name", text: $userName)
                        TextField("Emergency Contact", text: $emergencyContact)
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section("Notifications") {
                        Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        
                        if notificationsEnabled {
                            DatePicker("Daily Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section("App Information") {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("Build")
                            Spacer()
                            Text("1")
                                .foregroundColor(.gray)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section("Support") {
                        Button("Privacy Policy") {
                            // Open privacy policy
                        }
                        .foregroundColor(.blue)
                        
                        Button("Terms of Service") {
                            // Open terms of service
                        }
                        .foregroundColor(.blue)
                        
                        Button("Contact Support") {
                            // Open support contact
                        }
                        .foregroundColor(.blue)
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                    
                    Section {
                        Button("Reset All Data") {
                            showResetAlert = true
                        }
                        .foregroundColor(.red)
                    }
                    .listRowBackground(Color.white.opacity(0.8))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset All Data", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    medicineManager.resetAllData()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will permanently delete all your medicines, dosages, and history. This action cannot be undone.")
            }
        }
    }
}

#Preview {
    SettingsView()
} 