import SwiftUI

struct UltraThinSearchBar: View {
    @Binding var searchText: String // Bindable property for the search text
    
    var placeholder: String = "Search Places" // Default placeholder text

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField(placeholder, text: $searchText)
                .font(.custom("Lexend-Regular", size: 16))
                .foregroundColor(.primary)
                .padding(.vertical, 8)

            if !searchText.isEmpty {
                Button(action: {
                    searchText = "" // Clear the search text
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 8)
        .background(.ultraThinMaterial) // Apply ultra-thin material
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top)
    }
}
