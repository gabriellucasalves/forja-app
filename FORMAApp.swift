import SwiftUI

@main
struct FORMAApp: App {
    @StateObject private var store = FormaStore()
    var body: some Scene {
        WindowGroup { ContentView().environmentObject(store) }
    }
}
