import SwiftUI
import ComposableArchitecture

struct AddActivityView: View {
    let store: StoreOf<AddActivityFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(spacing: Theme.Spacing.lg) {
                        // Header
                        VStack(spacing: Theme.Spacing.sm) {
                            Text("Add Activity")
                                .font(Theme.Typography.largeTitle)
                                .foregroundColor(Theme.Palette.text)
                            
                            Text("Fill in your workout details")
                                .font(Theme.Typography.body)
                                .foregroundColor(Theme.Palette.textSecondary)
                        }
                        .padding(.top, Theme.Spacing.lg)
                        
                        // Form
                        VStack(spacing: Theme.Spacing.lg) {
                            // Select sport
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Sport Type")
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
                            
                            // Date
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Date")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                DatePicker(
                                    "Workout date",
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
                            
                            // Start and end time
                            HStack(spacing: Theme.Spacing.md) {
                                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                    Text("Start Time")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Palette.text)
                                    
                                    DatePicker(
                                        "Start",
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
                                    Text("End Time")
                                        .font(Theme.Typography.headline)
                                        .foregroundColor(Theme.Palette.text)
                                    
                                    DatePicker(
                                        "End",
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
                            
                            // Duration (automatically calculated)
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Duration")
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
                            
                            // Distance
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Distance")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                HStack(spacing: Theme.Spacing.sm) {
                                    TextField("0.0", value: viewStore.binding(
                                        get: \.distance,
                                        send: AddActivityFeature.Action.setDistance
                                    ), format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .keyboardType(.decimalPad)
                                    
                                    Picker("Unit", selection: viewStore.binding(
                                        get: \.distanceUnit,
                                        send: AddActivityFeature.Action.setDistanceUnit
                                    )) {
                                        Text("m").tag(DistanceUnit.meters)
                                        Text("km").tag(DistanceUnit.kilometers)
                                    }
                                    .pickerStyle(.segmented)
                                    .frame(width: 80)
                                }
                            }
                            
                            // Calories
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Calories")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                TextField("0", value: viewStore.binding(
                                    get: \.calories,
                                    send: AddActivityFeature.Action.setCalories
                                ), format: .number)
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                            }
                            
                            // Comment
                            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                                Text("Comment")
                                    .font(Theme.Typography.headline)
                                    .foregroundColor(Theme.Palette.text)
                                
                                TextField("Add comment to workout...", text: viewStore.binding(
                                    get: \.comment,
                                    send: AddActivityFeature.Action.setComment
                                ), axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        
                        // Save button
                        Button(action: {
                            viewStore.send(.saveActivity)
                        }) {
                            Text("Save Activity")
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
                                Text("Back")
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
