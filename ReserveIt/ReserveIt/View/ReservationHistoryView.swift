//
//  ReservationHistoryView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 12.08.24.
//

import SwiftUI

/// View displaying the user's reservation history with options to delete reservations.
struct ReservationHistoryView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = ReservationViewModel() // ViewModel for managing reservations
    
    var body: some View {
        VStack {
            // Header
            Text("Reservations")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            // Reservations List
            List {
                ForEach(viewModel.reservations) { reservation in
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Place Name: \(reservation.placeName)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Date: \(reservation.date, formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Notes: \(reservation.notes.isEmpty ? "None" : reservation.notes)")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text("Number of People: \(reservation.numberOfPeople)")
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        Text("Status: \(reservation.status)")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(statusColor(for: reservation.status))
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            viewModel.deleteReservation(reservation)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            viewModel.loadReservations()
        }
        .padding()
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
    
    // MARK: - Private Properties
    
    /// Date formatter for displaying reservation dates.
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    /// Returns the color for the reservation status.
    /// - Parameter status: The reservation status.
    /// - Returns: The color associated with the reservation status.
    private func statusColor(for status: String) -> Color {
        switch status.lowercased() {
        case "confirmed":
            return .green
        case "pending":
            return .orange
        case "cancelled":
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - Previews

#Preview {
    ReservationHistoryView()
}
