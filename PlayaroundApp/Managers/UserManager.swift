import Foundation
import SwiftData
import SwiftUI

@MainActor
class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var userToDelete: User?
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Create default admin user if no users exist
        let descriptor = FetchDescriptor<User>()
        if let count = try? modelContext.fetchCount(descriptor), count == 0 {
            let adminUser = User(
                username: "Admin",
                password: "Password",
                userType: .admin
            )
            modelContext.insert(adminUser)
            try? modelContext.save()
        }
    }
    
    func login(username: String, password: String) -> Bool {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.username == username && user.password == password
            }
        )
        
        if let user = try? modelContext.fetch(descriptor).first {
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
        
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate<User> { user in
                user.username == username
            }
        )
        
        guard (try? modelContext.fetchCount(descriptor)) == 0 else { return false }
        
        let newUser = User(
            username: username,
            password: password,
            userType: userType,
            requiredEntryFields: requiredFields
        )
        modelContext.insert(newUser)
        do {
            try modelContext.save()
            objectWillChange.send()
            return true
        } catch {
            print("Failed to create user: \(error)")
            return false
        }
    }
    
    func updateUser(_ user: User) -> Bool {
        guard currentUser?.userType == .admin else { return false }
        do {
            try modelContext.save()
            objectWillChange.send()
            return true
        } catch {
            print("Failed to update user: \(error)")
            return false
        }
    }
    
    func deleteUser(_ userToDelete: User) {
        guard currentUser?.userType == .admin else { return }
        guard userToDelete.id != currentUser?.id else { return }
        
        // Don't allow deleting the last admin
        let remainingAdmins = users.filter { $0.userType == .admin && $0.id != userToDelete.id }
        guard userToDelete.userType != .admin || remainingAdmins.count > 0 else { return }
        
        // Delete the user
        modelContext.delete(userToDelete)
        
        // Save changes
        do {
            try modelContext.save()
            objectWillChange.send()
            self.userToDelete = nil
        } catch {
            print("Failed to delete user: \(error)")
        }
    }
    
    var users: [User] {
        let descriptor = FetchDescriptor<User>()
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func saveEntry(entry: Entry) {
        guard let currentUser = currentUser else { return }
        currentUser.entries.append(entry)
        do {
            try modelContext.save()
            objectWillChange.send()
        } catch {
            print("Failed to save entry: \(error)")
        }
    }
    
    func getEntriesForCurrentUser() -> [Entry] {
        guard let currentUser = currentUser else { return [] }
        return currentUser.entries.sorted { $0.startTime > $1.startTime }
    }
} 