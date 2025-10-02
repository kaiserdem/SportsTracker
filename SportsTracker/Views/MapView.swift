import SwiftUI
import ComposableArchitecture
import MapKit

struct MapView: View {
    let store: StoreOf<MapFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Map(
                coordinateRegion: .constant(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )),
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
