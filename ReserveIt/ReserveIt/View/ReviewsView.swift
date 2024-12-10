//
//  ReviewsView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 23.07.24.
//

import SwiftUI

/// View displaying a list of reviews for a place.
struct ReviewsView: View {
    
    // MARK: - Properties
    
    let reviews: [Review]?

    var body: some View {
        VStack {
            if let reviews = reviews, !reviews.isEmpty {
                // Display a list of reviews
                List(reviews, id: \.author_name) { review in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            // Display the reviewer's name and rating
                            Text(review.author_name)
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Text("Rating: \(review.rating)/5")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Display the review text
                        Text(review.text)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
            } else {
                // Display message when no reviews are available
                Text("No reviews available")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .navigationTitle("Reviews")
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Previews

struct ReviewsView_Previews: PreviewProvider {
    static var previews: some View {
        ReviewsView(reviews: nil) 
    }
}
