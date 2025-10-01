import SwiftUI
import ComposableArchitecture
import MapKit

struct MapView: View {
    let store: StoreOf<MapFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ZStack {
                    // Карта
                    Map(coordinateRegion: .constant(MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 50.4501, longitude: 30.5234), // Київ
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )), showsUserLocation: true, userTrackingMode: .none)
                    .ignoresSafeArea()
                    .overlay(
                        Theme.Gradients.screenBackground
                            .opacity(0.3)
                            .ignoresSafeArea()
                    )
                    
                    VStack {
                        Spacer()
                        
                        // Кнопки управління
                        HStack(spacing: Theme.Spacing.md) {
                            if viewStore.isTracking {
                                Button("Зупинити") {
                                    viewStore.send(.stopTracking)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.Palette.secondary)
                            } else {
                                Button("Почати") {
                                    viewStore.send(.startTracking)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(Theme.Palette.primary)
                            }
                            
                            Spacer()
                            
                            Button("Маршрути") {
                                // Показати список маршрутів
                            }
                            .buttonStyle(.bordered)
                            .tint(Theme.Palette.accent)
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.bottom, Theme.Spacing.lg)
                    }
                    
                    // Інформація про поточне тренування
                    if viewStore.isTracking, let route = viewStore.currentRoute {
                        VStack {
                            HStack {
                                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                    Text("Поточне тренування")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                    
                                    Text(formatDuration(route.totalDuration))
                                        .font(Theme.Typography.title)
                                        .foregroundColor(Theme.Palette.text)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                                    Text("Дистанція")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(Theme.Palette.textSecondary)
                                    
                                    Text(String(format: "%.2f км", route.totalDistance / 1000))
                                        .font(Theme.Typography.title)
                                        .foregroundColor(Theme.Palette.text)
                                }
                            }
                            .padding(Theme.Spacing.md)
                            .background(Theme.Palette.surface.opacity(0.9))
                            .cornerRadius(Theme.CornerRadius.medium)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            Spacer()
                        }
                        .padding(.top, Theme.Spacing.lg)
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                }
                .navigationTitle("Карта")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Налаштування") {
                            // Показати налаштування
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
