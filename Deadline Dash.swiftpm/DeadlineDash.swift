import SwiftUI

@main
struct DeadlineDash: App {
    @StateObject var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            HostingControllerWrapper(gameViewModel: gameViewModel)
        }
    }
}
