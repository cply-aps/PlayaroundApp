import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var showingCreateUserSheet = false
    @State private var sortOption: SortOption = .name
    
    enum SortOption {
        case name, type
    }
    
    var sortedUsers: [User] {
        switch sortOption {
        case .name:
            return userManager.users.sorted { $0.username < $1.username }
        case .type:
            return userManager.users.sorted { $0.userType.rawValue < $1.userType.rawValue }
        }
    }
    
    var body: some View {
        List {
            Section {
                Picker("Sort by", selection: $sortOption) {
                    Text("Name").tag(SortOption.name)
                    Text("Type").tag(SortOption.type)
                }
                .pickerStyle(.segmented)
            }
            
            ForEach(sortedUsers) { user in
                NavigationLink(destination: UserDetailView(user: user)) {
                    HStack {
                        Text(user.username)
                        Spacer()
                        Text(user.userType.rawValue.capitalized)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        if let index = userManager.users.firstIndex(where: { $0.id == user.id }) {
                            userManager.deleteUser(at: index)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    .tint(.red)
                }
                .confirmationDialog(
                    "Are you sure you want to delete this user?",
                    isPresented: Binding(
                        get: { userManager.userToDelete?.id == user.id },
                        set: { if !$0 { userManager.userToDelete = nil } }
                    ),
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        if let userToDelete = userManager.userToDelete,
                           let index = userManager.users.firstIndex(where: { $0.id == userToDelete.id }) {
                            userManager.deleteUser(at: index)
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        userManager.userToDelete = nil
                    }
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Users")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateUserSheet = true }) {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateUserSheet) {
            CreateUserView()
        }
    }
}

struct CreateUserView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    
    @State private var username = ""
    @State private var password = ""
    @State private var userType: UserType = .patient
    @State private var selectedFields: Set<EntryField> = [.startTime, .activity, .experience, .comments]
    @State private var showError = false
    @State private var errorMessage = ""
    @FocusState private var isUsernameFocused: Bool
    
    init() {
        _selectedFields = State(initialValue: [.startTime, .activity, .experience, .comments])
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Username", text: $username)
                        .focused($isUsernameFocused)
                    SecureField("Password", text: $password)
                    Picker("User Type", selection: $userType) {
                        Text("Patient").tag(UserType.patient)
                        Text("Therapist").tag(UserType.therapist)
                        Text("Admin").tag(UserType.admin)
                    }
                }
                
                if userType == .patient {
                    Section(header: Text("Required Entry Fields")) {
                        ForEach(Array(EntryField.allCases), id: \.self) { field in
                            if field == .startTime || field == .activity || 
                               field == .experience || field == .comments {
                                Toggle(field.rawValue, isOn: .constant(true))
                                    .disabled(true)
                            } else {
                                Toggle(field.rawValue, isOn: Binding(
                                    get: { selectedFields.contains(field) },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedFields.insert(field)
                                        } else {
                                            selectedFields.remove(field)
                                        }
                                    }
                                ))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create User")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveUser() }
            )
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                isUsernameFocused = true
            }
        }
    }
    
    private func saveUser() {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            showError = true
            return
        }
        guard !password.isEmpty else {
            errorMessage = "Password cannot be empty"
            showError = true
            return
        }
        
        // Always include required fields
        selectedFields.insert(.startTime)
        selectedFields.insert(.activity)
        selectedFields.insert(.experience)
        selectedFields.insert(.comments)
        
        if userManager.createUser(
            username: username,
            password: password,
            userType: userType,
            requiredFields: selectedFields
        ) {
            dismiss()
        } else {
            errorMessage = "Failed to create user. Username may already exist."
            showError = true
        }
    }
}

struct UserDetailView: View {
    @EnvironmentObject var userManager: UserManager
    @State var user: User
    @State private var showingEditSheet = false
    
    var body: some View {
        List {
            Section(header: Text("User Information")) {
                LabeledContent("Username", value: user.username)
                LabeledContent("User Type", value: user.userType.rawValue.capitalized)
            }
            
            if user.userType == .patient {
                Section(header: Text("Required Entry Fields")) {
                    ForEach(Array(EntryField.allCases), id: \.self) { field in
                        if user.requiredEntryFields.contains(field) {
                            Text(field.rawValue)
                        }
                    }
                }
            }
        }
        .navigationTitle("User Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditUserView(user: $user)
        }
    }
}

struct EditUserView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @Binding var user: User
    
    @State private var username: String
    @State private var selectedFields: Set<EntryField>
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var newPassword = ""
    @State private var isChangingPassword = false
    
    init(user: Binding<User>) {
        self._user = user
        self._username = State(initialValue: user.wrappedValue.username)
        self._selectedFields = State(initialValue: user.wrappedValue.requiredEntryFields)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Username", text: $username)
                    Text(user.userType.rawValue.capitalized)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Password Management")) {
                    Toggle("Change Password", isOn: $isChangingPassword)
                    if isChangingPassword {
                        SecureField("New Password", text: $newPassword)
                    }
                }
                
                if user.userType == .patient {
                    Section(header: Text("Required Entry Fields")) {
                        ForEach(Array(EntryField.allCases), id: \.self) { field in
                            if field == .startTime || field == .activity || 
                               field == .experience || field == .comments {
                                Toggle(field.rawValue, isOn: .constant(true))
                                    .disabled(true)
                            } else {
                                Toggle(field.rawValue, isOn: Binding(
                                    get: { selectedFields.contains(field) },
                                    set: { isSelected in
                                        if isSelected {
                                            selectedFields.insert(field)
                                        } else {
                                            selectedFields.remove(field)
                                        }
                                    }
                                ))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit User")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveUser() }
            )
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveUser() {
        guard !username.isEmpty else {
            errorMessage = "Username cannot be empty"
            showError = true
            return
        }
        
        if isChangingPassword && newPassword.isEmpty {
            errorMessage = "New password cannot be empty"
            showError = true
            return
        }
        
        // Always include required fields
        selectedFields.insert(.startTime)
        selectedFields.insert(.activity)
        selectedFields.insert(.experience)
        selectedFields.insert(.comments)
        
        var updatedUser = user
        updatedUser.username = username
        updatedUser.requiredEntryFields = selectedFields
        if isChangingPassword {
            updatedUser.password = newPassword
        }
        
        if userManager.updateUser(updatedUser) {
            user = updatedUser
            dismiss()
        } else {
            errorMessage = "Failed to update user"
            showError = true
        }
    }
}

#Preview {
    NavigationView {
        AdminDashboardView()
            .environmentObject(UserManager())
    }
} 