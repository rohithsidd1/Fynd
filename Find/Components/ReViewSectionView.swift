import SwiftUI

struct ReviewsSectionView: View {
    let reviews: [Review]?

    var body: some View {
        if let reviews = reviews, !reviews.isEmpty {
            VStack(alignment: .leading) {
                Text("Reviews")
                    .font(.custom("Lexend-SemiBold", size: 24)) // Use your custom font
                    .padding(.horizontal)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(reviews, id: \.authorName) { review in
                            ReviewRow(review: review)
                                .frame(width: 330) // Set a fixed width for each review card
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        } else {
            Text("No reviews available.")
                .font(.custom("Lexend-SemiBold", size: 24)) // Use your custom font
                .foregroundColor(.primary.opacity(0.7))
                .padding()
        }
    }
}
