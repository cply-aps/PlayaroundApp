import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject var userManager: UserManager
    
    var body: some View {
        NavigationView {
            VStack {
                switch userManager.currentUser?.userType {
                case .admin:
                    AdminDashboardView()
                        .environmentObject(userManager)
                case .therapist:
                    TherapistDashboardView()
                case .patient:
                    PatientDashboardView()
                case .none:
                    Text("Error: No user type")
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        userManager.logout()
                    }
                }
            }
        }
    }
}

// Placeholder view - will be implemented in separate file
struct TherapistDashboardView: View {
    var body: some View {
        Text("Therapist Dashboard")
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Entry.self, configurations: config)
        
        return MainView()
            .environmentObject(UserManager(modelContext: container.mainContext))
    } catch {
        return Text("Failed to create preview")
    }
} 
