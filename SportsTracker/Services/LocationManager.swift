import Foundation
import CoreLocation
import ComposableArchitecture

// MARK: - Location Manager Service

struct LocationManager {
    var requestPermission: () -> Effect<Bool>
    var startTracking: () -> Effect<CLLocation>
    var stopTracking: () -> Effect<Void>
    var getCurrentLocation: () -> Effect<CLLocation?>
}

// MARK: - Location Manager Implementation

@MainActor
class LocationManagerImpl: NSObject, @unchecked Sendable {
    static let shared = LocationManagerImpl()
    
    private let locationManager = CLLocationManager()
    private var continuation: AsyncStream<CLLocation>.Continuation?
    private var isTracking = false
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5 // 5 метрів
    }
    
    func requestPermission() async -> Bool {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return true
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return await withCheckedContinuation { continuation in
                self.permissionContinuation = continuation
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    private var permissionContinuation: CheckedContinuation<Bool, Never>?
    
    func startTracking() -> AsyncStream<CLLocation> {
        guard !isTracking else {
            return AsyncStream { _ in }
        }
        
        isTracking = true
        locationManager.startUpdatingLocation()
        
        return AsyncStream { continuation in
            self.continuation = continuation
        }
    }
    
    func stopTracking() {
        isTracking = false
        locationManager.stopUpdatingLocation()
        continuation?.finish()
        continuation = nil
    }
    
    func getCurrentLocation() async -> CLLocation? {
        return locationManager.location
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManagerImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Фільтруємо неточні локації
        guard location.horizontalAccuracy <= 20 else { return }
        
        continuation?.yield(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionContinuation?.resume(returning: true)
        case .denied, .restricted:
            permissionContinuation?.resume(returning: false)
        case .notDetermined:
            break
        @unknown default:
            permissionContinuation?.resume(returning: false)
        }
        permissionContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        continuation?.finish()
    }
}

// MARK: - Dependency

extension LocationManager: DependencyKey {
    static let liveValue = LocationManager(
        requestPermission: {
            .run { send in
                let hasPermission = await LocationManagerImpl.shared.requestPermission()
                await send(hasPermission)
            }
        },
        
        startTracking: {
            .run { send in
                let stream = await LocationManagerImpl.shared.startTracking()
                
                for await location in stream {
                    await send(location)
                }
            }
        },
        
        stopTracking: {
            .run { send in
                await LocationManagerImpl.shared.stopTracking()
                await send(())
            }
        },
        
        getCurrentLocation: {
            .run { send in
                let location = await LocationManagerImpl.shared.getCurrentLocation()
                await send(location)
            }
        }
    )
}

extension DependencyValues {
    var locationManager: LocationManager {
        get { self[LocationManager.self] }
        set { self[LocationManager.self] = newValue }
    }
}

// MARK: - Location Utilities

struct LocationUtils {
    // Розрахунок дистанції між двома точками
    static func distance(from: CLLocation, to: CLLocation) -> Double {
        return from.distance(from: to)
    }
    
    // Розрахунок швидкості (м/с)
    static func speed(from: CLLocation, to: CLLocation) -> Double {
        let distance = distance(from: from, to: to)
        let timeInterval = to.timestamp.timeIntervalSince(from.timestamp)
        guard timeInterval > 0 else { return 0 }
        return distance / timeInterval
    }
    
    // Конвертація швидкості в км/год
    static func speedInKmh(_ speedInMs: Double) -> Double {
        return speedInMs * 3.6
    }
    
    // Конвертація швидкості в темп (хв/км)
    static func paceFromSpeed(_ speedInKmh: Double) -> Double {
        guard speedInKmh > 0 else { return 0 }
        return 60.0 / speedInKmh
    }
    
    // Форматування темпу
    static func formatPace(_ paceInMinutes: Double) -> String {
        let minutes = Int(paceInMinutes)
        let seconds = Int((paceInMinutes - Double(minutes)) * 60)
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Форматування швидкості
    static func formatSpeed(_ speedInKmh: Double) -> String {
        return String(format: "%.1f км/год", speedInKmh)
    }
    
    // Визначення чи рухається користувач
    static func isMoving(_ speed: Double, threshold: Double = 1.0) -> Bool {
        return speed > threshold // більше 1 м/с = 3.6 км/год
    }
}
