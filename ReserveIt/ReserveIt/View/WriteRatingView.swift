//
//  WriteRatingView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 13.08.24.
//

import SwiftUI

/// View for submitting a new rating and review for a place.
struct WriteRatingView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss // Dismiss the view when the rating is submitted
    
    @State private var stars: Int = 0 // Rating stars (1-5 range)
    @State private var text: String = "" // Review text
    
    var placeId: String
    var placeName: String
    @ObservedObject var ratingViewModel: RatingViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Write a Rating")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Form {
                // Rating Section
                Section(header: Text("Rating").font(.headline)) {
                    Picker("Rating", selection: $stars) {
                        ForEach(0..<5) { star in
                            Text("\(star + 1) Star\(star > 0 ? "s" : "")")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Review Section
                Section(header: Text("Review").font(.headline)) {
                    TextEditor(text: $text)
                        .frame(height: 150)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
            }
            
            // Submit Button
            Button(action: {
                submitRating()
            }) {
                Text("Submit Rating")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
    
    // MARK: - Methods
    
    /// Submit the rating and review, then dismiss the view.
    private func submitRating() {
        ratingViewModel.writeRating(for: placeId, placeName: placeName, stars: stars + 1, text: text)
        dismiss()
    }
}

// MARK: - Previews

#Preview {
    WriteRatingView(placeId: "examplePlaceId", placeName: "Example Place", ratingViewModel: RatingViewModel())
        .environmentObject(AuthenticationViewModel())
}
