import Foundation

struct Day: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let sportType: SportType
    let comment: String?
    let duration: TimeInterval // в секундах
    let distance: Double? // в метрах
    let steps: Int?
    let calories: Int?
    let supplements: [Supplement]?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        sportType: SportType,
        comment: String? = nil,
        duration: TimeInterval,
        distance: Double? = nil,
        steps: Int? = nil,
        calories: Int? = nil,
        supplements: [Supplement]? = nil
    ) {
        self.id = id
        self.date = date
        self.sportType = sportType
        self.comment = comment
        self.duration = duration
        self.distance = distance
        self.steps = steps
        self.calories = calories
        self.supplements = supplements
    }
    
    // MARK: - Computed Properties
    
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
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
    
    var formattedDateOnly: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "uk_UA")
        return formatter.string(from: date)
    }
    
    var formattedDistance: String {
        guard let distance = distance else { return "—" }
        if distance >= 1000 {
            return String(format: "%.2f км", distance / 1000)
        } else {
            return String(format: "%.0f м", distance)
        }
    }
    
    var hasSupplements: Bool {
        return supplements?.isEmpty == false
    }
    
    var supplementsCount: Int {
        return supplements?.count ?? 0
    }
    
    // MARK: - Static Methods
}

// MARK: - Supplement Model

struct Supplement: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let amount: String
    let time: String // "до тренування", "під час", "після тренування"
    
    init(name: String, amount: String, time: String) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.time = time
    }
    
    var icon: String {
        switch name.lowercased() {
        case let name where name.contains("протеїн"):
            return "drop.fill"
        case let name where name.contains("креатин"):
            return "pills.fill"
        case let name where name.contains("bcaa"):
            return "capsule.fill"
        case let name where name.contains("вітамін"):
            return "pills"
        case let name where name.contains("омега"):
            return "fish.fill"
        default:
            return "pills"
        }
    }
}

// MARK: - Day Extensions

extension Day {
    var intensity: WorkoutIntensity {
        let durationInMinutes = duration / 60
        
        switch sportType {
        case .running, .cycling, .swimming:
            if durationInMinutes > 60 {
                return .high
            } else if durationInMinutes > 30 {
                return .medium
            } else {
                return .low
            }
        case .gym, .crossfit:
            if durationInMinutes > 90 {
                return .high
            } else if durationInMinutes > 45 {
                return .medium
            } else {
                return .low
            }
        case .walking, .yoga, .pilates:
            return .low
        default:
            return .medium
        }
    }
    
    var totalCalories: Int {
        return calories ?? 0
    }
    
    var totalSteps: Int {
        return steps ?? 0
    }
}

enum WorkoutIntensity: String, CaseIterable {
    case low = "Низька"
    case medium = "Середня"
    case high = "Висока"
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
}
