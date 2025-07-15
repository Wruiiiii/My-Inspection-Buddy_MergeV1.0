import SwiftUI


@main   // creates the main entry point
struct MyInspectionBuddyApp: App {
    
    @State private var isLaunching = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // If launching, show the LaunchView
                if isLaunching {
                    LaunchView()
                        .transition(.opacity) // Smooth fade transition
                } else {
                    // Otherwise, show your main home page
                    HomePageView()
                }
            }
            .onAppear {
                // Set a timer to hide the launch screen after 2.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    withAnimation {
                        self.isLaunching = false
                    }
                }
            }
        }

    }
}
