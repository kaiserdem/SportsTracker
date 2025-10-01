import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            TabView(selection: viewStore.binding(
                get: \.selectedTab,
                send: { .selectTab($0) }
            )) {
                HomeView(
                    store: self.store.scope(
                        state: \.home,
                        action: { .home($0) }
                    )
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Головна")
                        .font(Theme.Typography.caption)
                }
                .tag(AppFeature.State.Tab.home)
                
                CalendarView(
                    store: self.store.scope(
                        state: \.calendar,
                        action: { .calendar($0) }
                    )
                )
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Календар")
                        .font(Theme.Typography.caption)
                }
                .tag(AppFeature.State.Tab.calendar)
                
                StatisticView(
                    store: self.store.scope(
                        state: \.statistic,
                        action: { .statistic($0) }
                    )
                )
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Статистика")
                        .font(Theme.Typography.caption)
                }
                .tag(AppFeature.State.Tab.statistic)
                
                MapView(
                    store: self.store.scope(
                        state: \.map,
                        action: { .map($0) }
                    )
                )
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Карта")
                        .font(Theme.Typography.caption)
                }
                .tag(AppFeature.State.Tab.map)
            }
            .accentColor(Theme.Palette.accent)
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [
                    UIColor(Theme.Palette.teal).cgColor,
                    UIColor(Theme.Palette.deepTeal).cgColor,
                    UIColor(Theme.Palette.darkTeal).cgColor
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0)
                gradientLayer.endPoint = CGPoint(x: 1, y: 1)
                gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
                UIGraphicsBeginImageContext(gradientLayer.frame.size)
                gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
                let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                appearance.backgroundImage = gradientImage
                appearance.backgroundColor = UIColor.clear
                
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.7)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.white.withAlphaComponent(0.7)
                ]
                
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor.white
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                
                UITabBar.appearance().layer.shadowColor = UIColor(Theme.Palette.darkTeal).cgColor
                UITabBar.appearance().layer.shadowOffset = CGSize(width: 0, height: -2)
                UITabBar.appearance().layer.shadowOpacity = 0.3
                UITabBar.appearance().layer.shadowRadius = 8
                UITabBar.appearance().clipsToBounds = false
                
                viewStore.send(.onAppear)
            }
        }
    }
}
