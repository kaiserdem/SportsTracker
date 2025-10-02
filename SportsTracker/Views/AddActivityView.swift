import SwiftUI
import ComposableArchitecture

struct AddActivityView: View {
    let store: StoreOf<AddActivityFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Заголовок
                        VStack(spacing: Theme.Spacing.sm) {
                            Text("Додати активність")
                                .font(Theme.Typography.largeTitle)
                                .foregroundColor(Theme.Palette.text)
                            
                            Text("Заповніть деталі вашого тренування")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Palette.textSecondary)
                        }
                        .padding(.top, Theme.Spacing.lg)
                        
                        // Форма
                        VStack(spacing: Theme.Spacing.lg) {
                            // Вибрати спорт
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Вид спорту")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: Theme.Spacing.sm) {
                                    ForEach(SportType.distanceSports, id: \.self) { sport in
                                        SportTypeCard(
                                            sportType: sport,
                                            isSelected: viewStore.selectedSportType == sport
                                        ) {
                                            viewStore.send(.selectSportType(sport))
                                        }
                                    }
                                }
                            }
                            
                            // Дата
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Дата")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                DatePicker(
                                    "Дата тренування",
                                    selection: viewStore.binding(
                                        get: \.selectedDate,
                                        send: AddActivityFeature.Action.setDate
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .fill(Theme.Palette.surface)
                                        .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
                                )
                            }
                            
                            // Час початку та кінця
                            HStack(spacing: Theme.Spacing.md) {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Час початку")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Palette.text)
                                    
                                    DatePicker(
                                        "Початок",
                                        selection: viewStore.binding(
                                            get: \.startTime,
                                            send: AddActivityFeature.Action.setStartTime
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                            .fill(Theme.Palette.surface)
                                            .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                }
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Час кінця")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Palette.text)
                                    
                                    DatePicker(
                                        "Кінець",
                                        selection: viewStore.binding(
                                            get: \.endTime,
                                            send: AddActivityFeature.Action.setEndTime
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .datePickerStyle(.compact)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                            .fill(Theme.Palette.surface)
                                            .shadow(color: Theme.Palette.darkTeal.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                                }
                            }
                            
                            // Тривалість (автоматично розрахована)
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Тривалість")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                Text(viewStore.calculatedDuration)
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(Theme.Palette.primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                            .fill(Theme.Palette.primary.opacity(0.1))
                                    )
                            }
                            
                            // Дистанція
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Дистанція")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                HStack(spacing: Theme.Spacing.sm) {
                                    TextField("0.0", value: viewStore.binding(
                                        get: \.distance,
                                        send: AddActivityFeature.Action.setDistance
                                    ), format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    
                                    Picker("Одиниця", selection: viewStore.binding(
                                        get: \.distanceUnit,
                                        send: AddActivityFeature.Action.setDistanceUnit
                                    )) {
                                        Text("м").tag(DistanceUnit.meters)
                                        Text("км").tag(DistanceUnit.kilometers)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 80)
                                }
                            }
                            
                            // Калорії
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Калорії")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                TextField("0", value: viewStore.binding(
                                    get: \.calories,
                                    send: AddActivityFeature.Action.setCalories
                                ), format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            }
                            
                            // Коментар
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Коментар")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                TextField("Додайте коментар до тренування...", text: viewStore.binding(
                                    get: \.comment,
                                    send: AddActivityFeature.Action.setComment
                                ), axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        
                        // Кнопка збереження
                        Button(action: {
                            viewStore.send(.saveActivity)
                        }) {
                            Text("Зберегти активність")
                                .font(Theme.Typography.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .fill(Theme.Gradients.button)
                                )
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.bottom, Theme.Spacing.xl)
                    }
                }
                .background(Theme.Gradients.screenBackground)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            print("🔙 AddActivityView: Натиснуто кнопку назад")
                            viewStore.send(.dismiss)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Назад")
                                    .font(Theme.Typography.body)
                            }
                            .foregroundColor(Theme.Palette.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.Palette.primary, lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.clear)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}



#Preview {
    AddActivityView(
        store: Store(initialState: AddActivityFeature.State()) {
            AddActivityFeature()
        }
    )
}
