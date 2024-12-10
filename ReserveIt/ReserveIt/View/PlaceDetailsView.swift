//
//  PlaceDetailsView.swift
//  ReserveIt
//
//  Created by Julian Niemann on 23.07.24.
//

import SwiftUI

/// View displaying detailed information about a place.
struct PlaceDetailsView: View {
    
    // MARK: - Properties
    
    let placeDetails: PlaceDetails
    @State private var showingReviews = false
    @State private var showingReservationForm = false
    @State private var showingWriteRating = false
    @StateObject private var reservationViewModel = ReservationViewModel()
    @StateObject private var ratingViewModel = RatingViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Display the place's photo
                if let photos = placeDetails.photos, let photoReference = photos.first?.photo_reference {
                    let photoUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=\(photoReference)&key=\(ApiKeys.googleAPIkey)"
                    
                    AsyncImage(url: URL(string: photoUrl)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .clipped()
                        case .empty, .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 250)
                                .background(Color.gray.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                // Place name and rating
                Text(placeDetails.name)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.vertical, 5)
                
                if let rating = placeDetails.rating {
                    HStack {
                        Text("Rating: \(String(format: "%.1f", rating))/5")
                            .font(.subheadline)
                        
                        if let userRatingsTotal = placeDetails.user_ratings_total {
                            Text("(\(userRatingsTotal) ratings)")
                                .font(.subheadline)
                        }
                    }
                    .padding(.bottom, 5)
                }
                
                // Opening hours
                if let openingHours = placeDetails.opening_hours {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Opening Hours")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        if let weekdayText = openingHours.weekday_text {
                            ForEach(weekdayText, id: \.self) { text in
                                Text(text)
                                    .font(.subheadline)
                            }
                        } else {
                            Text("No opening hours available")
                                .font(.subheadline)
                        }
                    }
                }
                
                // Address and phone number
                if let formattedAddress = placeDetails.formatted_address {
                    Text("Address: \(formattedAddress)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                if let formattedPhoneNumber = placeDetails.formatted_phone_number {
                    Text("Phone: \(formattedPhoneNumber)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }
                
                // Action buttons
                HStack {
                    if let website = placeDetails.website, let url = URL(string: website) {
                        Link("Website", destination: url)
                            .font(.subheadline)
                            .padding(.trailing, 10)
                    }
                    
                    Button(action: {
                        showingReviews.toggle()
                    }) {
                        Text("Show Reviews")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                    
                    Button(action: {
                        showingWriteRating.toggle()
                    }) {
                        Text("Write a Rating")
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(radius: 5)
                    }
                }
                .padding(.top, 10)
            }
            .padding()
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
        .navigationTitle("Place Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingReservationForm.toggle()
                }) {
                    Text("Reserve")
                        .foregroundColor(.blue)
                        .bold()
                }
            }
        }
        .sheet(isPresented: $showingReviews) {
            ReviewsView(reviews: placeDetails.reviews)
        }
        .sheet(isPresented: $showingWriteRating) {
            WriteRatingView(
                placeId: placeDetails.place_id,
                placeName: placeDetails.name,
                ratingViewModel: ratingViewModel
            )
        }
        .sheet(isPresented: $showingReservationForm) {
            ReservationView(placeId: placeDetails.place_id) { date, notes, numberOfPeople in
                reservationViewModel.createReservation(
                    for: placeDetails.place_id,
                    placeName: placeDetails.name,
                    date: date,
                    notes: notes,
                    numberOfPeople: numberOfPeople
                )
                showingReservationForm = false
            }
        }
    }
}
