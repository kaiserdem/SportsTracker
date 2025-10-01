import SwiftUI

struct Theme {
    struct Palette {
        static let primary = Color(red: 0.2, green: 0.6, blue: 0.9) // Синій
        static let secondary = Color(red: 0.9, green: 0.3, blue: 0.2) // Червоний
        static let accent = Color(red: 0.1, green: 0.8, blue: 0.3) // Зелений
        static let background = Color(red: 0.95, green: 0.95, blue: 0.97) // Світло-сірий
        static let surface = Color.white
        static let text = Color.black
        static let textSecondary = Color.gray
    }
    
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let headline = Font.headline.weight(.medium)
        static let body = Font.body
        static let caption = Font.caption
    }
    
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
    }
}
