import SwiftUI

struct ReviewRow: View {
    let review: Review
    @State private var isExpanded: Bool = false // Tracks if the review is expanded

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Profile Picture and Author Info
            HStack(spacing: 16) {
                if let profilePhotoUrl = review.profilePhotoUrl, let url = URL(string: profilePhotoUrl) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                    }
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                }

                VStack(alignment: .leading) {
                    Text(review.authorName ?? "Unknown User")
                        .font(.custom("Lexend-SemiBold", size: 16)) // Use your custom font
                        .foregroundColor(.primary)
                    
                    if let timeDescription = review.timeDescription {
                        Text(timeDescription)
                            .font(.custom("Lexend-Regular", size: 14)) // Use your custom font
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Review Text with "More" Button
            if let text = review.text {
                HStack {
                    VStack(alignment: .leading) {
                        if isExpanded {
                            Text(text)
                                .font(.custom("Lexend-Light", size: 14)) // Use your custom font
                                .foregroundColor(.primary.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        } else {
                            Text(text)
                                .font(.custom("Lexend-Light", size: 14)) // Use your custom font
                                .foregroundColor(.primary.opacity(0.8))
                                .lineLimit(5) // Limit to 5 lines when collapsed
                                .multilineTextAlignment(.leading)
                        }

                        Button(action: {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }) {
                            Text(isExpanded ? "Less" : "More")
                                .font(.custom("Lexend-Light", size: 14)) // Use your custom font
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(8)
        .shadow(radius: 2)
    }
}
