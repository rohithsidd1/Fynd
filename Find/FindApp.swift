import SwiftUI
import CoreLocation

@main
struct FindApp: App {
    @State private var showSplashScreen = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !showSplashScreen {
                    // Show ContentView directly
                    ContentView()
                } else {
                    // Splash Screen
                    SplashScreen()
                }
            }
            .onAppear {
                // Show splash screen for 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showSplashScreen = false
                    }
                }
            }
        }
    }
}
