import Foundation
import CoreLocation

struct ActiveWorkout: Identifiable, Equatable {
    let id = UUID()
    let sportType: SportType
    let startTime: Date
    var endTime: Date?
    var isPaused = false
    var pauseDuration: TimeInterval = 0
    var pauseStartTime: Date?
    var locations: [CLLocation] = []
    var totalDistance: Double = 0
    var comment: String?
    var steps: Int?
    var calories: Int?
    var supplements: [Supplement]?
    
    // GPS-дані
    var currentSpeed: Double = 0 // м/с
    var averageSpeed: Double = 0 // м/с
    var maxSpeed: Double = 0 // м/с
    var activeTime: TimeInterval = 0 // час у русі
    var stoppedTime: TimeInterval = 0 // час у зупинках
    var lastLocationTime: Date?
    var isCurrentlyMoving = false
    
    init(sportType: SportType, startTime: Date = Date()) {
        self.sportType = sportType
        self.startTime = startTime
    }
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        let currentPauseDuration = isPaused && pauseStartTime != nil ? 
            Date().timeIntervalSince(pauseStartTime!) : 0
        return end.timeIntervalSince(startTime) - pauseDuration - currentPauseDuration
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var averageSpeedKmh: Double {
        return LocationUtils.speedInKmh(averageSpeed)
    }
    
    var currentSpeedKmh: Double {
        return LocationUtils.speedInKmh(currentSpeed)
    }
    
    var maxSpeedKmh: Double {
        return LocationUtils.speedInKmh(maxSpeed)
    }
    
    var formattedAverageSpeed: String {
        return LocationUtils.formatSpeed(averageSpeedKmh)
    }
    
    var formattedCurrentSpeed: String {
        return LocationUtils.formatSpeed(currentSpeedKmh)
    }
    
    var formattedMaxSpeed: String {
        return LocationUtils.formatSpeed(maxSpeedKmh)
    }
    
    var currentPace: Double {
        return LocationUtils.paceFromSpeed(currentSpeedKmh)
    }
    
    var averagePace: Double {
        return LocationUtils.paceFromSpeed(averageSpeedKmh)
    }
    
    var formattedCurrentPace: String {
        return LocationUtils.formatPace(currentPace)
    }
    
    var formattedAveragePace: String {
        return LocationUtils.formatPace(averagePace)
    }
    
    var formattedDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.2f км", totalDistance / 1000)
        } else {
            return String(format: "%.0f м", totalDistance)
        }
    }
    
    var isActive: Bool {
        return endTime == nil
    }
    
    var activeTimePercentage: Double {
        guard duration > 0 else { return 0 }
        return (activeTime / duration) * 100
    }
    
    var formattedActiveTime: String {
        let hours = Int(activeTime) / 3600
        let minutes = Int(activeTime) % 3600 / 60
        let seconds = Int(activeTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedStoppedTime: String {
        let hours = Int(stoppedTime) / 3600
        let minutes = Int(stoppedTime) % 3600 / 60
        let seconds = Int(stoppedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Methods
    
    mutating func pause() {
        isPaused = true
        pauseStartTime = Date()
    }
    
    mutating func resume() {
        if let pauseStart = pauseStartTime {
            pauseDuration += Date().timeIntervalSince(pauseStart)
        }
        isPaused = false
        pauseStartTime = nil
    }
    
    mutating func finish() {
        endTime = Date()
    }
    
    mutating func addLocation(_ location: CLLocation) {
        let now = Date()
        
        // Оновлюємо час активності/зупинки
        if let lastTime = lastLocationTime {
            let timeInterval = now.timeIntervalSince(lastTime)
            
            if isCurrentlyMoving {
                activeTime += timeInterval
            } else {
                stoppedTime += timeInterval
            }
        }
        
        locations.append(location)
        lastLocationTime = now
        
        if locations.count > 1 {
            let lastLocation = locations[locations.count - 2]
            let distance = LocationUtils.distance(from: lastLocation, to: location)
            totalDistance += distance
            
            // Розрахунок швидкості
            let speed = LocationUtils.speed(from: lastLocation, to: location)
            currentSpeed = speed
            
            // Оновлення максимальної швидкості
            if speed > maxSpeed {
                maxSpeed = speed
            }
            
            // Визначення чи рухається
            isCurrentlyMoving = LocationUtils.isMoving(speed)
            
            // Розрахунок середньої швидкості
            if duration > 0 {
                averageSpeed = totalDistance / duration
            }
        }
    }
    
    mutating func updatePauseDuration(_ duration: TimeInterval) {
        pauseDuration += duration
    }
    
    // MARK: - Conversion to Day
    
    func toDay() -> Day {
        print("🔄 ActiveWorkout: Конвертую в Day з sportType: \(sportType.rawValue)")
        let day = Day(
            id: id,
            date: startTime,
            sportType: sportType,
            comment: comment,
            duration: duration,
            steps: steps,
            calories: calories,
            supplements: supplements
        )
        print("✅ ActiveWorkout: Створено Day з sportType: \(day.sportType.rawValue) та ID: \(day.id)")
        return day
    }
}

// MARK: - Workout State

enum WorkoutState: Equatable {
    case idle
    case selecting
    case active(ActiveWorkout)
    case paused(ActiveWorkout)
    case finished(ActiveWorkout)
    
    var isActive: Bool {
        switch self {
        case .active, .paused:
            return true
        default:
            return false
        }
    }
    
    var currentWorkout: ActiveWorkout? {
        switch self {
        case .active(let workout), .paused(let workout), .finished(let workout):
            return workout
        default:
            return nil
        }
    }
}

// MARK: - Workout Statistics

struct WorkoutStatistics: Equatable {
    let totalWorkouts: Int
    let totalDuration: TimeInterval
    let totalDistance: Double
    let totalCalories: Int
    let favoriteSport: SportType?
    let averageWorkoutDuration: TimeInterval
    let longestWorkout: TimeInterval
    let currentStreak: Int
    
    var formattedTotalDuration: String {
        let hours = Int(totalDuration) / 3600
        let minutes = Int(totalDuration) % 3600 / 60
        return String(format: "%d год %d хв", hours, minutes)
    }
    
    var formattedTotalDistance: String {
        if totalDistance >= 1000 {
            return String(format: "%.1f км", totalDistance / 1000)
        } else {
            return String(format: "%.0f м", totalDistance)
        }
    }
    
    var formattedAverageDuration: String {
        let hours = Int(averageWorkoutDuration) / 3600
        let minutes = Int(averageWorkoutDuration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
    
    var formattedLongestDuration: String {
        let hours = Int(longestWorkout) / 3600
        let minutes = Int(longestWorkout) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}
