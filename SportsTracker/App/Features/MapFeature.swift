import ComposableArchitecture
import Foundation
import CoreLocation

struct MapFeature: Reducer {
    struct State: Equatable {
        var userLocation: CLLocation?
        var routes: [Route] = []
        var isTracking = false
        var currentRoute: Route?
        var isLoading = false
    }
    
    enum Action: Equatable {
        case onAppear
        case startTracking
        case stopTracking
        case updateLocation(CLLocation)
        case loadRoutes
        case routesLoaded([Route])
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadRoutes)
                
            case .startTracking:
                state.isTracking = true
                state.currentRoute = Route()
                return .none
                
            case .stopTracking:
                state.isTracking = false
                if let route = state.currentRoute {
                    state.routes.append(route)
                    state.currentRoute = nil
                }
                return .none
                
            case let .updateLocation(location):
                state.userLocation = location
                if state.isTracking {
                    state.currentRoute?.addPoint(location)
                }
                return .none
                
            case .loadRoutes:
                state.isLoading = true
                // Тут буде завантаження маршрутів
                return .send(.routesLoaded([]))
                
            case let .routesLoaded(routes):
                state.routes = routes
                state.isLoading = false
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
