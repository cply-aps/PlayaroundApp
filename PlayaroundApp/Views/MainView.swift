import SwiftUI

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
    MainView()
        .environmentObject(UserManager())
} 
