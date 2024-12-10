//
//  AuthenticationView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 08.07.24.
//

import Foundation
import SwiftUI

/// View handling user authentication: registration, login, and verification.
struct AuthenticationView: View {
    
    // MARK: - Enum for Authentication Modes
    
    private enum Mode {
        case registration
        case login
        case verification
        
        var mainButtonText: String {
            switch self {
            case .registration:
                return "Registrieren"
            case .login:
                return "Anmelden"
            case .verification:
                return ""
            }
        }
        
        var alternativeButtonText: String {
            switch self {
            case .registration:
                return "Hast du schon einen Account?\nZur Anmeldung"
            case .login:
                return "Noch kein Account?\nJetzt Registrieren!"
            case .verification:
                return "Zurück zur Anmeldung"
            }
        }
        
        mutating func toggle() {
            switch self {
            case .registration:
                self = .login
            case .login:
                self = .registration
            case .verification:
                self = .login
            }
        }
    }
    
    // MARK: - Properties
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordCheck: String = ""
    @State private var hidePassword: Bool = true
    @State private var nickname: String = ""
    @State private var mode: Mode = .login
    
    var body: some View {
        ZStack {
            // Background image
            Image("globe_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
            
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // Email text field
                    if mode != .verification {
                        TextField("Email-Adresse", text: $email)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .frame(maxWidth: 300)
                    }
                    
                    // Nickname text field (registration mode)
                    if case .registration = mode {
                        TextField("Nickname", text: $nickname)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .frame(maxWidth: 300)
                    }
                    
                    // Password text field with toggle visibility
                    if mode != .verification {
                        HStack {
                            Group {
                                if hidePassword {
                                    SecureField("Passwort", text: $password)
                                } else {
                                    TextField("Passwort", text: $password)
                                }
                            }
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            
                            Button(action: {
                                hidePassword.toggle()
                            }) {
                                Image(systemName: hidePassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing)
                        }
                        .frame(maxWidth: 300)
                    }
                    
                    // Password confirmation text field (registration mode)
                    if case .registration = mode {
                        SecureField("Passwort (Wiederholung)", text: $passwordCheck)
                            .autocapitalization(.none)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(10)
                            .frame(maxWidth: 300)
                    }
                    
                    // Verification instructions (verification mode)
                    if mode == .verification {
                        Text("""
                            Damit wir dein Geschäft schnell und einfach in unsere Plattform aufnehmen können, bitten wir dich um folgende Unterlagen:
                            
                            Geschäftsname
                            Juristische Adresse
                            Steuer-ID oder Unternehmensregisternummer
                            
                            Zusätzlich benötigen wir Kopien deiner Geschäftslizenzen oder anderer offizieller Dokumente.
                            
                            Bitte sende alle Unterlagen an verification@reserveit.com
                            
                            Wir freuen uns darauf, dein Geschäft in unserem Netzwerk willkommen zu heißen!
                            """)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                        .multilineTextAlignment(.leading)
                    }
                    
                    // Password error message
                    if let passwordError = authViewModel.passwordError, mode != .verification {
                        Text(passwordError)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Terms of Service and Privacy Policy
                    if mode == .registration {
                        Text("Bei der Registrierung stimmen Sie den [Nutzungsbedingungen](https://policies.google.com/terms?hl=de) und der [Datenschutzerklärung](https://policies.google.com/terms?hl=de) zu.")
                            .font(.footnote)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .frame(maxWidth: 300)
                            .onTapGesture {
                                if let url = URL(string: "https://policies.google.com/terms?hl=de") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    
                    // Main action button
                    if mode != .verification {
                        Button(action: {
                            switch mode {
                            case .registration:
                                authViewModel.register(email: email, nickname: nickname, password: password, passwordCheck: passwordCheck)
                            case .login:
                                authViewModel.login(email: email, password: password)
                            case .verification:
                                break
                            }
                        }) {
                            Text(mode.mainButtonText)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .frame(maxWidth: 300)
                    }
                    
                    // Button to switch to verification mode
                    if mode == .registration {
                        Button(action: {
                            withAnimation {
                                mode = .verification
                            }
                        }) {
                            Text("Geschäft anmelden?")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: 300)
                    }
                    
                    // Toggle between login and registration
                    Divider()
                        .background(Color.white)
                    
                    Button(action: {
                        withAnimation {
                            mode.toggle()
                        }
                    }) {
                        Text(mode.alternativeButtonText)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: 300)
                }
                .padding()
                .background(Color.black.opacity(0.6))
                .cornerRadius(20)
                .padding()
                .frame(maxWidth: 300)
                
                Spacer()
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
}
