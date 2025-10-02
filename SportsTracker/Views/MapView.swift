import SwiftUI
import ComposableArchitecture
import MapKit

struct MapView: View {
    let store: StoreOf<MapFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Map(
                    coordinateRegion: Binding(
                        get: {
                            if let location = viewStore.userLocation {
                                return MKCoordinateRegion(
                                    center: location.coordinate,
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            } else {
                                // Просто встановлюємо карту в центр карти без хардкоду конкретних координат
                                return MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                                    span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
                                )
                            }
                        },
                        set: { _ in }
                    ),
                    showsUserLocation: true,
                    userTrackingMode: .none
                )
                .ignoresSafeArea()
                
                // Кнопка центрування на поточну точку (завжди видима)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            // Одноразове центрування на поточну точку
                            viewStore.send(.getCurrentLocation)
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Theme.Palette.primary)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 100) // Відступ від нижнього краю
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}
