//
//  RatingView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 13.08.24.
//

import SwiftUI

/// View displaying a list of user ratings with the option to delete individual ratings.
struct RatingView: View {
    
    // MARK: - Properties
    
    @ObservedObject var ratingViewModel: RatingViewModel // ViewModel for managing user ratings
    
    var body: some View {
        VStack {
            // Header
            Text("Ratings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            // List of Ratings
            List {
                ForEach(ratingViewModel.ratings) { rating in
                    VStack(alignment: .leading, spacing: 12) {
                        // Rating Header
                        HStack {
                            Text("Rating:")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(rating.stars) Stars")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        
                        // Rating Text
                        Text(rating.text)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        // Place Name
                        HStack {
                            Text("For Place:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(rating.placeName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            ratingViewModel.deleteRating(rating)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .onAppear {
            ratingViewModel.loadUserRatings()
        }
        .padding()
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Previews

#Preview {
    RatingView(ratingViewModel: RatingViewModel())
}
