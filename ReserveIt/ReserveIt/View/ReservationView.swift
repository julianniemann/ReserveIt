//
//  ReservationView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 12.08.24.
//

import SwiftUI

/// View for making a reservation with a selected date, number of people, and optional notes.
struct ReservationView: View {
    
    // MARK: - Properties
    
    @State private var date = Date() // The selected reservation date and time
    @State private var numberOfPeople = 1 // Number of people for the reservation
    @State private var notes = "" // Optional notes for the reservation
    
    var placeId: String // The ID of the place for the reservation
    var onSubmit: (Date, String, Int) -> Void // Closure to be called on form submission
    
    var body: some View {
        VStack {
            // Title
            Text("Reservierung")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            Form {
                // Reservation Details Section
                Section(header: Text("Reservierungsdetails").font(.headline)) {
                    // Date and Time Picker
                    DatePicker("Datum und Uhrzeit", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .padding(.vertical)
                    
                    // Number of People Stepper
                    Stepper("Anzahl der Personen: \(numberOfPeople)", value: $numberOfPeople, in: 1...20)
                        .padding(.vertical)
                    
                    // Optional Notes TextField
                    TextField("Notizen (optional)", text: $notes)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical)
                }
                
                // Submit Button
                Button(action: {
                    onSubmit(date, notes, numberOfPeople)
                }) {
                    Text("Reservierung abschicken")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGray6)) // Background color for the form
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .padding()
    }
}

// MARK: - Previews

#Preview {
    ReservationView(placeId: "examplePlaceId") { date, notes, numberOfPeople in
        print("Reservation Date: \(date), Notes: \(notes), Number of People: \(numberOfPeople)")
    }
}
