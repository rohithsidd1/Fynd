import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack{
            Color(red: 37/255, green: 71/255, blue: 116/255, opacity: 1.0)
           Image("Splash")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashScreen()
}
