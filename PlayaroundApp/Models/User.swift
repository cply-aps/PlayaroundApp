import Foundation
import SwiftData

@Model
final class User {
    var id: UUID
    var username: String
    var password: String
    var userType: UserType
    var requiredEntryFields: Set<EntryField>
    @Relationship(deleteRule: .cascade) var entries: [Entry] = []
    
    init(id: UUID = UUID(), username: String, password: String, userType: UserType, 
         requiredEntryFields: Set<EntryField> = [.startTime, .activity, .experience, .comments]) {
        self.id = id
        self.username = username
        self.password = password
        self.userType = userType
        self.requiredEntryFields = requiredEntryFields
    }
}

enum UserType: String, Codable, Hashable {
    case admin
    case therapist
    case patient
}

enum EntryField: String, Codable, Hashable, CaseIterable {
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