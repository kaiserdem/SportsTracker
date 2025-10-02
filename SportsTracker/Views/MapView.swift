import SwiftUI
import ComposableArchitecture
import MapKit

struct MapView: View {
    let store: StoreOf<MapFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Map(
                coordinateRegion: Binding(
                    get: {
                        if let location = viewStore.userLocation {
                            return MKCoordinateRegion(
                                center: location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        } else {
                            return MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        }
                    },
                    set: { _ in }
                ),
                showsUserLocation: true,
                userTrackingMode: .none
            )
            .ignoresSafeArea()
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
