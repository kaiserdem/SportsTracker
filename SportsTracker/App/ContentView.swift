import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    var body: some View {
        AppView(store: Store(initialState: AppFeature.State()) {
            AppFeature()
        })
    }
}
