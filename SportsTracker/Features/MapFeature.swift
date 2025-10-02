import ComposableArchitecture
import Foundation
import CoreLocation

@Reducer
struct MapFeature {
    struct State: Equatable {
        var userLocation: CLLocation?
        var routes: [Route] = []
        var isTracking = false
        var currentRoute: Route?
        var isLoading = false
        var hasLocationPermission = false
        var isWorkoutActive = false  // Чи активне тренування
    }
    
    enum Action: Equatable {
        case onAppear
        case permissionGranted(Bool)
        case getCurrentLocation
        case locationReceived(CLLocation?)
        case startTracking
        case stopTracking
        case updateLocation(CLLocation)
        case loadRoutes
        case routesLoaded([Route])
        case goToHomeScreen
        case updateWorkoutState(Bool)  // Оновити стан тренування
    }
    
    @Dependency(\.locationManager) var locationManager
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return locationManager.requestPermission()
                    .map(Action.permissionGranted)
                
            case .permissionGranted(let granted):
                state.hasLocationPermission = granted
                if granted {
                    return .send(.getCurrentLocation)
                }
                return .none
                
            case .getCurrentLocation:
                return locationManager.getCurrentLocation()
                    .map(Action.locationReceived)
                
            case .locationReceived(let location):
                state.userLocation = location
                return .none
                
            case .startTracking:
                state.isTracking = true
                state.currentRoute = Route()
                return locationManager.startTracking()
                    .map(Action.updateLocation)
                
            case .stopTracking:
                state.isTracking = false
                if var route = state.currentRoute {
                    route.finish()
                    state.routes.append(route)
                    state.currentRoute = nil
                }
                return locationManager.stopTracking()
                    .map { .routesLoaded([]) }
                
            case let .updateLocation(location):
                state.userLocation = location
                if state.isTracking {
                    state.currentRoute?.addPoint(location)
                }
                return .none
                
            case .loadRoutes:
                state.isLoading = true
                return .send(.routesLoaded([]))
                
            case let .routesLoaded(routes):
                state.routes = routes
                state.isLoading = false
                return .none
                
            case .goToHomeScreen:
                return .none
                
            case .updateWorkoutState(let isActive):
                state.isWorkoutActive = isActive
                return .none
            }
        }
    }
}

struct Route: Equatable, Identifiable {
    let id = UUID()
    var points: [CLLocation] = []
    let startTime = Date()
    var endTime: Date?
    var totalDistance: Double = 0
    var totalDuration: TimeInterval = 0
    
    mutating func addPoint(_ location: CLLocation) {
        points.append(location)
        if points.count > 1 {
            let lastPoint = points[points.count - 2]
            totalDistance += location.distance(from: lastPoint)
        }
        totalDuration = Date().timeIntervalSince(startTime)
    }
    
    mutating func finish() {
        endTime = Date()
        totalDuration = endTime?.timeIntervalSince(startTime) ?? 0
    }
}
