//
//  ProfileView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 24.07.24.
//

import SwiftUI

/// View for displaying and editing the user profile.
struct ProfileView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            // Header
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            Form {
                // User Information Section
                Section(header: Text("User Information").font(.headline)) {
                    Text("Email: \(profileViewModel.email)")
                        .foregroundColor(.gray)
                    
                    TextField("Nickname", text: $profileViewModel.nickname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Phone Number", text: $profileViewModel.phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Street", text: $profileViewModel.street)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Postal Code", text: $profileViewModel.postalCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("City", text: $profileViewModel.city)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Save Profile Button
                Section {
                    Button(action: {
                        profileViewModel.saveProfile()
                    }) {
                        Text("Save Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.headline)
                    }
                }
                
                // Logout Button
                Section {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Text("Logout")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .font(.headline)
                    }
                }
            }
            .onAppear {
                profileViewModel.loadProfile()
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        }
        .padding()
    }
}

// MARK: - Previews

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
}
