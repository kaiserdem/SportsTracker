import SwiftUI

struct Theme {
    struct Palette {
        // Основні кольори з градієнта
        static let teal = Color(red: 0.2, green: 0.5, blue: 0.5) // Середній теал
        static let darkTeal = Color(red: 0.1, green: 0.17, blue: 0.18) // Темний теал #1A2B2E
        static let deepTeal = Color(red: 0.15, green: 0.25, blue: 0.3) // Глибокий теал
        
        // Додаткові кольори
        static let lightTeal = Color(red: 0.4, green: 0.7, blue: 0.7) // Світлий теал
        static let accent = Color(red: 0.3, green: 0.8, blue: 0.8) // Акцентний теал
        
        // Нові кольори для фону екранів
        static let lightBlueGrey = Color(red: 0.867, green: 0.898, blue: 0.906) // #DDE5E7
        static let mediumBlueGrey = Color(red: 0.788, green: 0.820, blue: 0.827) // #C9D1D3
        
        // Системні кольори
        static let primary = teal
        static let secondary = darkTeal
        static let background = Color(red: 0.98, green: 0.99, blue: 0.99) // Дуже світлий теал
        static let surface = Color.white
        static let text = darkTeal
        static let textSecondary = Color(red: 0.4, green: 0.4, blue: 0.4)
        
        // Градієнтні кольори
        static let gradientColors = [teal, deepTeal, darkTeal]
        static let gradientStart = teal
        static let gradientEnd = darkTeal
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
    
    struct Gradients {
        // Основний градієнт для таббару
        static let primary = LinearGradient(
            colors: [Palette.teal, Palette.deepTeal, Palette.darkTeal],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Градієнт для карток
        static let card = LinearGradient(
            colors: [Palette.surface, Palette.lightTeal.opacity(0.1)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Градієнт для кнопок
        static let button = LinearGradient(
            colors: [Palette.teal, Palette.deepTeal],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Градієнт для фону екранів
        static let screenBackground = LinearGradient(
            colors: [Palette.lightBlueGrey, Palette.mediumBlueGrey],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Градієнт для фону
        static let background = LinearGradient(
            colors: [Palette.background, Palette.lightTeal.opacity(0.05)],
            startPoint: .top,
            endPoint: .bottom
        )
        
        // Радіальний градієнт
        static let radial = RadialGradient(
            colors: [Palette.teal.opacity(0.3), Palette.darkTeal.opacity(0.1)],
            center: .center,
            startRadius: 50,
            endRadius: 200
        )
    }
}
