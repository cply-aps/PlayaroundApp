import Foundation

@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    @Published var userToDelete: User?
    @Published var entries: [Entry] = []
    
    init() {
        // Create default admin user
        let adminUser = User(
            username: "Admin",
            password: "Password",
            userType: .admin
        )
        users.append(adminUser)
    }
    
    func login(username: String, password: String) -> Bool {
        if let user = users.first(where: { $0.username == username && $0.password == password }) {
            currentUser = user
            return true
        }
        return false
    }
    
    func logout() {
        currentUser = nil
    }
    
    func createUser(username: String, password: String, userType: UserType, requiredFields: Set<EntryField>) -> Bool {
        guard currentUser?.userType == .admin else { return false }
        guard !users.contains(where: { $0.username == username }) else { return false }
        
        let newUser = User(
            username: username,
            password: password,
            userType: userType,
            requiredEntryFields: requiredFields
        )
        users.append(newUser)
        return true
    }
    
    func updateUser(_ user: User) -> Bool {
        guard currentUser?.userType == .admin else { return false }
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return false }
        users[index] = user
        return true
    }
    
    func deleteUser(at index: Int) {
        guard currentUser?.userType == .admin else { return }
        guard index >= 0 && index < users.count else { return }
        
        // Don't allow deleting the current user
        guard users[index].id != currentUser?.id else { return }
        
        // Don't allow deleting the last admin
        let remainingAdmins = users.filter { $0.userType == .admin && $0.id != users[index].id }
        guard users[index].userType != .admin || remainingAdmins.count > 0 else { return }
        
        users.remove(at: index)
        userToDelete = nil
    }
    
    func saveEntry(entry: Entry) {
        entries.append(entry)
    }
    
    func getEntriesForCurrentUser() -> [Entry] {
        guard let currentUser = currentUser else { return [] }
        return entries.filter { $0.userId == currentUser.id }
            .sorted { $0.startTime > $1.startTime } // Sort newest first
    }
} 