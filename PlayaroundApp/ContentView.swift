//
//  ContentView.swift
//  PlayaroundApp
//
//  Created by Casper Lykke Andersen on 19/11/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var userManager: UserManager
    
    init(modelContext: ModelContext) {
        _userManager = StateObject(wrappedValue: UserManager(modelContext: modelContext))
    }
    
    var body: some View {
        Group {
            if userManager.currentUser != nil {
                MainView()
                    .environmentObject(userManager)
            } else {
                LoginView()
                    .environmentObject(userManager)
            }
        }
    }
}

struct LoginView: View {
    @EnvironmentObject var userManager: UserManager
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @FocusState private var isUsernameFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome")
                    .font(.largeTitle)
                    .padding(.bottom, 30)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .focused($isUsernameFocused)
                    .submitLabel(.next)
                    .onSubmit {
                        isPasswordFocused = true
                    }
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isPasswordFocused)
                    .submitLabel(.go)
                    .onSubmit(attemptLogin)
                
                Button("Login", action: attemptLogin)
                    .buttonStyle(.borderedProminent)
                    .alert("Invalid Credentials", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    }
            }
            .padding()
            .navigationBarHidden(true)
            .onAppear {
                isUsernameFocused = true
            }
        }
    }
    
    private func attemptLogin() {
        if !userManager.login(username: username, password: password) {
            showError = true
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: User.self, Entry.self, configurations: config)
        
        return ContentView(modelContext: container.mainContext)
    } catch {
        return Text("Failed to create preview")
    }
}
