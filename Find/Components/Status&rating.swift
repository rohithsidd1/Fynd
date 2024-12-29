import SwiftUI

struct StatusAndRatingView: View {
    let isOpenNow: Bool?
    let rating: Double?

    var body: some View {
        HStack {
            HStack(spacing: 2) {
                // Clock image next to the text
                Image(systemName: "clock.fill")
                    .foregroundColor(
                        // Set the clock color based on the status
                        (isOpenNow ?? false) ? .green.opacity(0.7) : .primary.opacity(0.7)
                    )
                    .font(.subheadline) // Adjust size of the clock icon
                
                // Open/Closed status with color change for open and closed
                if let openingStatus = isOpenNow {
                    Text(openingStatus ? "Open Now." : "Closed.")
                        .foregroundColor(openingStatus ? .green.opacity(0.7) : .primary.opacity(0.7)) // Green if open, red if closed
                        .font(.custom("Lexend-Regular", size: 14)) // Apply your custom font
                } else {
                    Text("Opening hours data not available")
                        .foregroundColor(.primary.opacity(0.7)) // Gray for unavailable data
                        .font(.custom("Lexend-Regular", size: 14)) // Apply your custom font
                }
            }
            
            Spacer()
            
            if let rating = rating {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.footnote)
                    Text(String(format: "%.1f", rating))
                        .foregroundColor(.primary)
                        .font(.custom("Lexend-Regular", size: 14)) // Use your custom font
                }
            }
        }
//        .padding(8)
//        .background(.ultraThinMaterial)
//        .cornerRadius(8)
        .padding(.horizontal)
    }
}
