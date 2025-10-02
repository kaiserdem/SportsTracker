import Foundation

enum SportType: String, CaseIterable, Identifiable, Codable {
    case running = "Running"
    case cycling = "Cycling"
    case swimming = "Swimming"
    case gym = "Gym"
    case walking = "Walking"
    case yoga = "Yoga"
    case pilates = "Pilates"
    case crossfit = "CrossFit"
    case boxing = "Boxing"
    case tennis = "Tennis"
    case football = "Football"
    case basketball = "Basketball"
    case volleyball = "Volleyball"
    case skiing = "Skiing"
    case snowboarding = "Snowboarding"
    case hiking = "Hiking"
    case climbing = "Climbing"
    case dancing = "Dancing"
    case martialArts = "Martial Arts"
    case other = "Other"
    
    var id: String { rawValue }
    
    // Визначає чи спорт має дистанцію
    var hasDistance: Bool {
        switch self {
        case .running, .cycling, .swimming, .walking, .hiking, .skiing, .snowboarding:
            return true
        case .gym, .yoga, .pilates, .crossfit, .boxing, .tennis, .football, .basketball, .volleyball, .climbing, .dancing, .martialArts, .other:
            return false
        }
    }
    
    // Визначає чи спорт має кроки
    var hasSteps: Bool {
        switch self {
        case .running, .walking, .hiking:
            return true
        case .cycling, .swimming, .skiing, .snowboarding, .gym, .yoga, .pilates, .crossfit, .boxing, .tennis, .football, .basketball, .volleyball, .climbing, .dancing, .martialArts, .other:
            return false
        }
    }
    
    var icon: String {
        switch self {
        case .running:
            return "figure.run"
        case .cycling:
            return "bicycle"
        case .swimming:
            return "figure.pool.swim"
        case .gym:
            return "dumbbell"
        case .walking:
            return "figure.walk"
        case .yoga:
            return "figure.yoga"
        case .pilates:
            return "figure.pilates"
        case .crossfit:
            return "figure.cross.training"
        case .boxing:
            return "figure.boxing"
        case .tennis:
            return "tennis.racket"
        case .football:
            return "soccerball"
        case .basketball:
            return "basketball"
        case .volleyball:
            return "volleyball"
        case .skiing:
            return "figure.skiing.downhill"
        case .snowboarding:
            return "figure.snowboarding"
        case .hiking:
            return "figure.hiking"
        case .climbing:
            return "figure.climbing"
        case .dancing:
            return "figure.dance"
        case .martialArts:
            return "figure.martial.arts"
        case .other:
            return "figure.mixed.cardio"
        }
    }
    
    var color: String {
        switch self {
        case .running:
            return "red"
        case .cycling:
            return "blue"
        case .swimming:
            return "cyan"
        case .gym:
            return "orange"
        case .walking:
            return "green"
        case .yoga:
            return "purple"
        case .pilates:
            return "pink"
        case .crossfit:
            return "brown"
        case .boxing:
            return "red"
        case .tennis:
            return "yellow"
        case .football:
            return "green"
        case .basketball:
            return "orange"
        case .volleyball:
            return "blue"
        case .skiing:
            return "white"
        case .snowboarding:
            return "blue"
        case .hiking:
            return "brown"
        case .climbing:
            return "gray"
        case .dancing:
            return "purple"
        case .martialArts:
            return "red"
        case .other:
            return "gray"
        }
    }
    
    var category: SportCategory {
        switch self {
        case .running, .walking, .cycling:
            return .cardio
        case .swimming:
            return .water
        case .gym, .crossfit:
            return .strength
        case .yoga, .pilates:
            return .flexibility
        case .boxing, .martialArts:
            return .combat
        case .tennis, .football, .basketball, .volleyball:
            return .team
        case .skiing, .snowboarding:
            return .winter
        case .hiking, .climbing:
            return .outdoor
        case .dancing:
            return .dance
        case .other:
            return .other
        }
    }
}

// MARK: - Extensions

extension SportType {
    // Види спорту з дистанцією для тренувань
    static var distanceSports: [SportType] {
        return SportType.allCases.filter { $0.hasDistance }
    }
    
    // Популярні види спорту з дистанцією
    static var popularDistanceSports: [SportType] {
        return [.running, .walking, .cycling, .swimming, .hiking]
    }
}

enum SportCategory: String, CaseIterable {
    case cardio = "Кардіо"
    case strength = "Силові"
    case water = "Водні"
    case flexibility = "Гнучкість"
    case combat = "Бойові"
    case team = "Командні"
    case winter = "Зимові"
    case outdoor = "На відкритому повітрі"
    case dance = "Танці"
    case other = "Інше"
}
