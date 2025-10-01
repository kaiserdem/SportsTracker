import Foundation
import ComposableArchitecture
import CoreLocation

struct WorkoutFeature: Reducer {
    @Dependency(\.locationManager) var locationManager
    
    struct State: Equatable {
        var workoutState: WorkoutState = .idle
        var isShowingQuickStart = false
        var timer: Timer?
        var currentLocation: CLLocation?
        var isLocationEnabled = false
        var isLocationTracking = false
        var errorMessage: String?
        var timerTick: Int = 0 // Для форсування оновлення UI
        
        var isActive: Bool {
            workoutState.isActive
        }
        
        var currentWorkout: ActiveWorkout? {
            workoutState.currentWorkout
        }
    }
    
    enum Action: Equatable {
        case showQuickStart
        case hideQuickStart
        case selectSportType(SportType)
        case startWorkout(SportType)
        case pauseWorkout
        case resumeWorkout
        case finishWorkout
        case saveWorkout
        case workoutSaved
        case updateTimer
        case updateLocation(CLLocation)
        case locationPermissionChanged(Bool)
        case requestLocationPermission
        case startLocationTracking
        case stopLocationTracking
        case setErrorMessage(String?)
        case dismissError
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .showQuickStart:
                state.isShowingQuickStart = true
                return .none
                
            case .hideQuickStart:
                state.isShowingQuickStart = false
                return .none
                
            case let .selectSportType(sportType):
                state.isShowingQuickStart = false
                return .send(.startWorkout(sportType))
                
            case let .startWorkout(sportType):
                let workout = ActiveWorkout(sportType: sportType)
                state.workoutState = .active(workout)
                state.isShowingQuickStart = false
                
                // Запускаємо таймер та GPS-трекінг
                return .merge(
                    .run { send in
                        while true {
                            try await Task.sleep(for: .seconds(1))
                            await send(.updateTimer)
                        }
                    }
                    .cancellable(id: "workout-timer"),
                    
                    .send(.requestLocationPermission)
                )
                
            case .pauseWorkout:
                if case .active(var workout) = state.workoutState {
                    workout.pause()
                    state.workoutState = .paused(workout)
                }
                return .none
                
            case .resumeWorkout:
                if case .paused(var workout) = state.workoutState {
                    workout.resume()
                    state.workoutState = .active(workout)
                }
                return .none
                
            case .finishWorkout:
                if case .active(var workout) = state.workoutState {
                    workout.finish()
                    state.workoutState = .finished(workout)
                    return .merge(
                        .cancel(id: "workout-timer"),
                        .send(.stopLocationTracking),
                        .send(.saveWorkout)
                    )
                } else if case .paused(var workout) = state.workoutState {
                    workout.finish()
                    state.workoutState = .finished(workout)
                    return .merge(
                        .cancel(id: "workout-timer"),
                        .send(.stopLocationTracking),
                        .send(.saveWorkout)
                    )
                }
                return .none
                
            case .saveWorkout:
                guard let workout = state.currentWorkout else { return .none }
                let day = workout.toDay()
                return CoreDataEffects.saveDay(day)
                    .map { _ in .workoutSaved }
                
            case .workoutSaved:
                state.workoutState = .idle
                return .cancel(id: "workout-timer")
                
            case .updateTimer:
                // Форсуємо оновлення UI
                state.timerTick += 1
                return .none
                
            case let .updateLocation(location):
                state.currentLocation = location
                if case .active(var workout) = state.workoutState {
                    workout.addLocation(location)
                    state.workoutState = .active(workout)
                } else if case .paused(var workout) = state.workoutState {
                    workout.addLocation(location)
                    state.workoutState = .paused(workout)
                }
                return .none
                
            case .requestLocationPermission:
                return locationManager.requestPermission()
                    .map(Action.locationPermissionChanged)
                
            case let .locationPermissionChanged(enabled):
                state.isLocationEnabled = enabled
                if enabled && state.isActive {
                    return .send(.startLocationTracking)
                }
                return .none
                
            case .startLocationTracking:
                state.isLocationTracking = true
                return locationManager.startTracking()
                    .map(Action.updateLocation)
                
            case .stopLocationTracking:
                state.isLocationTracking = false
                return locationManager.stopTracking()
                    .map { _ in .dismissError }
                
            case let .setErrorMessage(message):
                state.errorMessage = message
                return .none
                
            case .dismissError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}

// MARK: - Location Effects

struct LocationEffects {
    static func startLocationTracking() -> Effect<CLLocation> {
        .run { send in
            // Тут буде логіка відстеження GPS
            // Поки що повертаємо тестову локацію
            let testLocation = CLLocation(
                latitude: 50.4501,
                longitude: 30.5234
            )
            await send(testLocation)
        }
    }
    
    static func requestLocationPermission() -> Effect<Bool> {
        .run { send in
            // Тут буде логіка запиту дозволу на локацію
            await send(true) // Поки що завжди true
        }
    }
}
