import SwiftUI
import ComposableArchitecture

struct QuickStartView: View {
    let store: StoreOf<WorkoutFeature>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                VStack(spacing: Theme.Spacing.lg) {
                    // Заголовок
                    VStack(spacing: Theme.Spacing.sm) {
                        Text("Почати тренування")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Theme.Palette.text)
                        
                        Text("Оберіть тип спорту")
                            .font(Theme.Typography.body)
                            .foregroundColor(Theme.Palette.textSecondary)
                    }
                    .padding(.top, Theme.Spacing.lg)
                    
                    // Сітка типів спорту
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: Theme.Spacing.md) {
                            ForEach(SportType.distanceSports) { sportType in
                                SportTypeCard(
                                    sportType: sportType,
                                    isSelected: false
                                ) {
                                    print("🎯 QuickStartView: Натиснуто на спорт: \(sportType.rawValue)")
                                    viewStore.send(.selectSportType(sportType))
                                }
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.md)
                    }
                    
                    Spacer()
                }
                .background(Theme.Gradients.screenBackground)
                .navigationTitle("Швидкий старт")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Назад") {
                            print("🔙 QuickStartView: Натиснуто кнопку назад")
                            viewStore.send(.hideQuickStart)
                        }
                        .foregroundColor(Theme.Palette.primary)
                    }
                }
                
            }
            .onAppear {
                print("📋 QuickStartView: Доступні спорти з дистанцією:")
                for sport in SportType.distanceSports {
                    print("   - \(sport.rawValue)")
                }
                viewStore.send(.showQuickStart)
            }
        }
    }
}

struct SportTypeCard: View {
    let sportType: SportType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: sportType.icon)
                    .font(.system(size: 40))
                    .foregroundColor(isSelected ? .white : Theme.Palette.primary)
                
                Text(sportType.rawValue)
                    .font(Theme.Typography.body)
                    .foregroundColor(isSelected ? .white : Theme.Palette.text)
                    .multilineTextAlignment(.center)
                
                Text(sportType.category.rawValue)
                    .font(Theme.Typography.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : Theme.Palette.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                isSelected ? 
                Theme.Gradients.button : 
                Theme.Gradients.card
            )
            .cornerRadius(Theme.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(
                        isSelected ? 
                        Theme.Palette.primary : 
                        Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? 
                Theme.Palette.primary.opacity(0.3) : 
                Theme.Palette.darkTeal.opacity(0.1),
                radius: isSelected ? 8 : 2,
                x: 0,
                y: isSelected ? 4 : 1
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Popular Sports View

struct PopularSportsView: View {
    let action: (SportType) -> Void
    
    private let popularSports: [SportType] = [
        .running,
        .walking,
        .cycling,
        .swimming,
        .hiking
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Популярні")
                .font(Theme.Typography.headline)
                .foregroundColor(Theme.Palette.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Theme.Spacing.md) {
                    ForEach(popularSports, id: \.self) { sport in
                        PopularSportCard(sport: sport) {
                            action(sport)
                        }
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
            }
        }
    }
}

struct PopularSportCard: View {
    let sport: SportType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.xs) {
                Image(systemName: sport.icon)
                    .font(.title2)
                    .foregroundColor(Theme.Palette.primary)
                
                Text(sport.rawValue)
                    .font(Theme.Typography.caption)
                    .foregroundColor(Theme.Palette.text)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80, height: 80)
            .background(Theme.Gradients.card)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuickStartView(
        store: Store(initialState: WorkoutFeature.State()) {
            WorkoutFeature()
        }
    )
}
