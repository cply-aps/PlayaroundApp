import SwiftUI

struct PatientDashboardView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingNewEntrySheet = false
    
    var body: some View {
        List {
            Section {
                Button(action: { showingNewEntrySheet = true }) {
                    Label("New Entry", systemImage: "plus.circle.fill")
                }
            }
            
            Section(header: Text("Recent Entries")) {
                if userManager.getEntriesForCurrentUser().isEmpty {
                    Text("No entries yet")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(userManager.getEntriesForCurrentUser()) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.activity)
                                .font(.headline)
                            Text(entry.startTime, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("My Journal")
        .sheet(isPresented: $showingNewEntrySheet) {
            NewEntryView()
        }
    }
}

struct NewEntryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    
    @State private var startTime = Date()
    @State private var activity = ""
    @State private var experience: Experience = .basic
    @State private var mood: Mood?
    @State private var condition: Condition?
    @State private var stress: Double? = 5.0
    @State private var control: Double? = 5.0
    @State private var challenge: Challenge?
    @State private var energy: Double? = 5.0
    @State private var pain: Double? = 5.0
    @State private var comments = ""
    @State private var currentStep = 0
    
    var requiredFields: Set<EntryField> {
        userManager.currentUser?.requiredEntryFields ?? [.startTime, .activity, .experience]
    }
    
    var steps: [EntryField] {
        let orderedFields: [EntryField] = [
            .startTime,
            .activity,
            .experience,
            .mood,
            .condition,
            .stress,
            .control,
            .challenge,
            .energy,
            .pain,
            .comments
        ]
        return orderedFields.filter { requiredFields.contains($0) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Progress indicator
                ProgressView(value: Double(currentStep + 1), total: Double(steps.count))
                    .padding()
                
                TabView(selection: $currentStep) {
                    ForEach(Array(steps.enumerated()), id: \.element) { index, field in
                        Group {
                            switch field {
                            case .startTime:
                                StartTimeView(startTime: $startTime)
                            case .activity:
                                ActivityView(activity: $activity)
                            case .experience:
                                ExperienceView(experience: $experience)
                            case .mood:
                                MoodView(mood: $mood)
                            case .condition:
                                ConditionView(condition: $condition)
                            case .stress:
                                StressView(stress: $stress)
                            case .control:
                                ControlView(control: $control)
                            case .challenge:
                                ChallengeView(challenge: $challenge)
                            case .energy:
                                EnergyView(energy: $energy)
                            case .pain:
                                PainView(pain: $pain)
                            case .comments:
                                CommentsView(comments: $comments)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button("Previous") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if currentStep < steps.count - 1 {
                        Button("Next") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                    } else {
                        Button("Save") {
                            saveEntry()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("New Entry")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
        }
    }
    
    private func saveEntry() {
        guard let currentUser = userManager.currentUser else { return }
        
        let entry = Entry(
            userId: currentUser.id,
            startTime: startTime,
            activity: activity,
            experience: experience,
            mood: mood,
            condition: condition,
            stress: stress.map { Int($0) },
            control: control.map { Int($0) },
            challenge: challenge,
            energy: energy.map { Int($0) },
            pain: pain.map { Int($0) },
            comments: comments.isEmpty ? nil : comments
        )
        
        userManager.saveEntry(entry: entry)
        dismiss()
    }
}

// Individual view components for each entry field
struct StartTimeView: View {
    @Binding var startTime: Date
    
    var body: some View {
        VStack {
            Text("When did this activity start?")
                .font(.headline)
                .padding()
            
            DatePicker("Start Time",
                      selection: $startTime,
                      displayedComponents: [.hourAndMinute, .date])
                .datePickerStyle(.wheel)
                .padding()
        }
    }
}

struct ActivityView: View {
    @Binding var activity: String
    
    var body: some View {
        VStack {
            Text("What activity did you do?")
                .font(.headline)
                .padding()
            
            TextField("Activity", text: $activity)
                .textFieldStyle(.roundedBorder)
                .padding()
        }
    }
}

struct ExperienceView: View {
    @Binding var experience: Experience
    
    var body: some View {
        VStack {
            Text("How would you describe this experience?")
                .font(.headline)
                .padding()
            
            Picker("Experience", selection: $experience) {
                ForEach(Experience.allCases, id: \.self) { experience in
                    Text(experience.rawValue).tag(experience)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct MoodView: View {
    @Binding var mood: Mood?
    
    var body: some View {
        VStack {
            Text("How are you feeling?")
                .font(.headline)
                .padding()
            
            Picker("Mood", selection: Binding(
                get: { mood ?? .calmRelaxed },
                set: { mood = $0 }
            )) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Text(mood.rawValue).tag(mood)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct ConditionView: View {
    @Binding var condition: Condition?
    
    var body: some View {
        VStack {
            Text("What's your current condition?")
                .font(.headline)
                .padding()
            
            Picker("Condition", selection: Binding(
                get: { condition ?? .tolerance },
                set: { condition = $0 }
            )) {
                ForEach(Condition.allCases, id: \.self) { condition in
                    Text(condition.rawValue).tag(condition)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct StressView: View {
    @Binding var stress: Double?
    
    var body: some View {
        VStack {
            Text("Rate your stress level")
                .font(.headline)
                .padding()
            
            Text(String(format: "%.0f", stress ?? 5.0))
                .font(.title2)
                .padding(.bottom, 5)
            
            HStack {
                Text("0")
                    .font(.caption)
                Slider(value: Binding(
                    get: { stress ?? 5.0 },
                    set: { stress = $0 }
                ), in: 0...10, step: 1)
                Text("10")
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct ControlView: View {
    @Binding var control: Double?
    
    var body: some View {
        VStack {
            Text("How in control do you feel?")
                .font(.headline)
                .padding()
            
            Text(String(format: "%.0f", control ?? 5.0))
                .font(.title2)
                .padding(.bottom, 5)
            
            HStack {
                Text("0")
                    .font(.caption)
                Slider(value: Binding(
                    get: { control ?? 5.0 },
                    set: { control = $0 }
                ), in: 0...10, step: 1)
                Text("10")
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct ChallengeView: View {
    @Binding var challenge: Challenge?
    
    var body: some View {
        VStack {
            Text("How challenging was this?")
                .font(.headline)
                .padding()
            
            Picker("Challenge", selection: Binding(
                get: { challenge ?? .moderate },
                set: { challenge = $0 }
            )) {
                ForEach(Challenge.allCases, id: \.self) { challenge in
                    Text(challenge.rawValue).tag(challenge)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct EnergyView: View {
    @Binding var energy: Double?
    
    var body: some View {
        VStack {
            Text("Rate your energy level")
                .font(.headline)
                .padding()
            
            Text(String(format: "%.0f", energy ?? 5.0))
                .font(.title2)
                .padding(.bottom, 5)
            
            HStack {
                Text("0")
                    .font(.caption)
                Slider(value: Binding(
                    get: { energy ?? 5.0 },
                    set: { energy = $0 }
                ), in: 0...10, step: 1)
                Text("10")
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct PainView: View {
    @Binding var pain: Double?
    
    var body: some View {
        VStack {
            Text("Rate your pain level")
                .font(.headline)
                .padding()
            
            Text(String(format: "%.0f", pain ?? 5.0))
                .font(.title2)
                .padding(.bottom, 5)
            
            HStack {
                Text("0")
                    .font(.caption)
                Slider(value: Binding(
                    get: { pain ?? 5.0 },
                    set: { pain = $0 }
                ), in: 0...10, step: 1)
                Text("10")
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct CommentsView: View {
    @Binding var comments: String
    
    var body: some View {
        VStack {
            Text("Any additional comments?")
                .font(.headline)
                .padding()
            
            TextEditor(text: $comments)
                .frame(height: 100)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2))
                )
                .padding()
        }
    }
}
  