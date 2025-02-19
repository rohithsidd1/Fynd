import SwiftUI

struct DetailsView: View {
    let phone: String?
    let website: String?

    var body: some View {
        HStack() {
            if let phone = phone {
                Button(action: {
                    // Action to call the phone number
                    if let url = URL(string: "tel://\(phone)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4){
                        Image(systemName: "phone")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        Text("Call Now")
                            .font(.custom("Lexend-Regular", size: 16)) // Apply your custom font
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                    }
                    .padding(8)
                    .frame(maxWidth: 108, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                }
            }

            if let website = website {
                Button(action: {
                    // Action to open the website
                    if let url = URL(string: website), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4){
                        Image(systemName: "link")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                        Text("Website")
                            .font(.custom("Lexend-Regular", size: 16)) // Apply your custom font
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                    }
                    .padding(8)
                    .frame(maxWidth: 104, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
                }
            }
                Spacer()
        }
        .padding(.horizontal)
    }
}
