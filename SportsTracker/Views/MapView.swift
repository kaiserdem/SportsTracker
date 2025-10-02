import SwiftUI
import ComposableArchitecture
import MapKit

struct MapView: View {
    let store: StoreOf<MapFeature>
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234), // Київ
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Map(
                    coordinateRegion: $mapRegion,
                    showsUserLocation: true,
                    userTrackingMode: .none
                )
                .ignoresSafeArea()
                
                
                if viewStore.isWorkoutActive {
                    // Кнопка центрування на поточну точку (завжди видима)
                    VStack {
                        
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                // Одноразове центрування на поточну точку
                                if let location = viewStore.userLocation {
                                    mapRegion = MKCoordinateRegion(
                                        center: location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                }
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
                            .padding(.bottom, 20) // Відступ від нижнього краю
                        }
                    }
                }
                
                // Overlay попап коли тренування не розпочато
                if !viewStore.isWorkoutActive {
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            // Іконка тренування
                            Image(systemName: "figure.run")
                                .font(.system(size: 50, weight: .medium))
                                .foregroundColor(Theme.Palette.primary)
                                .padding(.bottom, 10)
                            
                            // Заголовок
                            Text("Workout Not Started")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.Palette.text)
                                .multilineTextAlignment(.center)
                            
                            // Опис
                            Text("Go to the main screen to start your workout and track your route on the map")
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(Theme.Palette.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            // Кнопка переходу на головний екран щоб розпочати тренування  
                            Button(action: {
                                viewStore.send(.goToHomeScreen)
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "house.fill")
                                        .font(.system(size: 20, weight: .medium))
                                    
                                    Text("Go to Home")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 16)
                                .background(Theme.Gradients.tealCoral)
                                .cornerRadius(25)
                                .shadow(color: Theme.Palette.coral.opacity(0.4), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 50)
                        .padding(.horizontal, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
                
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .onChange(of: viewStore.userLocation) { location in
                if let location = location {
                    mapRegion = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
    }
}
