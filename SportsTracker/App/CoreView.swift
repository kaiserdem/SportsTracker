import SwiftUI
import ComposableArchitecture

struct CoreView: View {
    var body: some View {
        AppView(store: Store(initialState: AppFeature.State()) {
            AppFeature()
        })
    }
}
