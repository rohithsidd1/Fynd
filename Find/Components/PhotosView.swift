import SwiftUI

struct CollageView: View {
    @State private var isSplit = false
    let photos: [Photo]
    let apiKey: String

    var body: some View {
        VStack(alignment: .leading) {
            Text("Photos")
                .font(.custom("Lexend-SemiBold", size: 24)) // Use your custom font
                .padding(.horizontal)

            ScrollView {
                ZStack {
                    if isSplit {
                        LazyVGrid(columns: gridColumns, spacing: 10) {
                            ForEach(Array(photos.enumerated()), id: \.1.photoReference) { index, photo in
                                    AsyncImage(
                                        url: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(photo.photoReference)&key=\(apiKey)")
                                    ) { imagePhase in
                                        switch imagePhase {
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 160, height: 160)
                                                .clipped()
                                                .cornerRadius(10)
                                                .transition(.asymmetric(
                                                    insertion: .scale(scale: 0.5).combined(with: .opacity).animation(.interpolatingSpring(stiffness: 120, damping: 10).delay(Double(index) * 0.05)),
                                                    removal: .opacity
                                                ))
                                        case .failure(_):
                                            Rectangle()
                                                .foregroundColor(.gray.opacity(0.3))
                                                .frame(width: 160, height: 160)
                                                .cornerRadius(10)
                                                .transition(.asymmetric(
                                                    insertion: .scale(scale: 0.5).combined(with: .opacity).animation(.interpolatingSpring(stiffness: 120, damping: 10).delay(Double(index) * 0.05)),
                                                    removal: .opacity
                                                ))
                                        default:
                                            ProgressView()
                                                .frame(width: 160, height: 160)
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .animation(.spring(response: 0.10, dampingFraction: 1, blendDuration: 0.16), value: isSplit)
                    } else {
                        ForEach(Array(photos.enumerated()), id: \.1.photoReference) { index, photo in
                            AsyncImage(
                                url: URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=1600&photoreference=\(photo.photoReference)&key=\(apiKey)")
                            ) { imagePhase in
                                switch imagePhase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: CGFloat.random(in: 80...150),
                                               height: CGFloat.random(in: 80...150))
                                        .clipped()
                                        .cornerRadius(10)
                                        .offset(randomOffset(for: index))
                                        .onTapGesture {
                                            withAnimation {
                                                isSplit = true
                                            }
                                        }
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.5).combined(with: .opacity).animation(.interpolatingSpring(stiffness: 120, damping: 10).delay(Double(index) * 0.05)),
                                            removal: .opacity
                                        ))
                                case .failure(_):
                                    Rectangle()
                                        .foregroundColor(.gray.opacity(0.3))
                                        .frame(width: CGFloat.random(in: 80...150),
                                               height: CGFloat.random(in: 80...150))
                                        .cornerRadius(10)
                                        .offset(randomOffset(for: index))
                                        .onTapGesture {
                                            withAnimation {
                                                isSplit = true
                                            }
                                        }
                                        .transition(.asymmetric(
                                            insertion: .scale(scale: 0.5).combined(with: .opacity).animation(.interpolatingSpring(stiffness: 120, damping: 10).delay(Double(index) * 0.05)),
                                            removal: .opacity
                                        ))
                                default:
                                    ProgressView()
                                        .frame(width: CGFloat.random(in: 80...150),
                                               height: CGFloat.random(in: 80...150))
                                        .offset(randomOffset(for: index))
                                }
                            }
                            .zIndex(Double(index))
                        }
                        .padding()
                        .animation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0.8), value: isSplit)
                    }
                }
                .frame(maxWidth: .infinity, minHeight: 300)
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .onTapGesture {
            withAnimation {
                isSplit.toggle()
            }
        }
    }

    private func randomOffset(for index: Int) -> CGSize {
        let randomX = CGFloat.random(in: -50...50) * CGFloat((index % 2 == 0) ? 1 : -1)
        let randomY = CGFloat.random(in: -50...50) * CGFloat((index % 2 == 0) ? -1 : 1)
        return CGSize(width: randomX, height: randomY)
    }

    private var gridColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 150), spacing: 10)]
    }
}
