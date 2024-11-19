import Foundation

enum UserType: String, Codable {
    case admin
    case therapist
    case patient
}

struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var password: String // Note: In production, implement proper password hashing
    var userType: UserType
    var requiredEntryFields: Set<EntryField>
    
    init(id: UUID = UUID(), username: String, password: String, userType: UserType, 
         requiredEntryFields: Set<EntryField> = [.startTime, .activity, .experience, .comments]) {
        self.id = id
        self.username = username
        self.password = password
        self.userType = userType
        self.requiredEntryFields = requiredEntryFields
    }
}

enum EntryField: String, Codable, CaseIterable {
    case startTime = "Start Time"
    case activity = "Activity"
    case experience = "Experience"
    case mood = "Mood"
    case condition = "Condition"
    case stress = "Stress"
    case control = "Control"
    case challenge = "Challenge"
    case energy = "Energy"
    case pain = "Pain"
    case comments = "Comments"
} 