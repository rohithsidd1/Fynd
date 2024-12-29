import SwiftUI

struct CustomPicker: View {
    @Binding var selectedValue: Int
    let options: [Int]
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    Text("\(option / 1000) km")
                        .font(.custom("Lexend-Light", size: selectedValue == option ? 16 : 12))
                        .fontWeight(selectedValue == option ? .bold : .regular)
                        .padding(.vertical, selectedValue == option ? 10 : 8)
                        .padding(.horizontal, selectedValue == option ? 10 : 8)
                        .background(
                            Group {
                                if selectedValue == option {
                                    Color(red: 37 / 255, green: 71 / 255, blue: 116 / 255, opacity: 1.0)
                                } else {
                                    Color.gray.opacity(0.2)
                                }
                            }
                        )
                        .foregroundColor(selectedValue == option ? .white : .primary)
                        .cornerRadius(8)
                        .contentShape(Rectangle()) // Improves tap area
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                generateHapticFeedback() // Trigger haptic feedback
                                selectedValue = option
                            }
                        }
                }
            }
        }
        .animation(nil, value: selectedValue) // Prevent redundant animations
    }

    private func generateHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
