import Foundation
import SwiftData

@Model
final class Entry {
    var id: UUID
    @Relationship var user: User?
    var startTime: Date
    var activity: String
    var experience: Experience
    var mood: Mood?
    var condition: Condition?
    var stress: Int?
    var control: Int?
    var challenge: Challenge?
    var energy: Int?
    var pain: Int?
    var comments: String?
    var createdAt: Date
    
    init(id: UUID = UUID(), user: User, startTime: Date = Date(), activity: String = "", 
         experience: Experience = .basic, mood: Mood? = nil, condition: Condition? = nil,
         stress: Int? = nil, control: Int? = nil, challenge: Challenge? = nil,
         energy: Int? = nil, pain: Int? = nil, comments: String? = nil) {
        self.id = id
        self.user = user
        self.startTime = startTime
        self.activity = activity
        self.experience = experience
        self.mood = mood
        self.condition = condition
        self.stress = stress
        self.control = control
        self.challenge = challenge
        self.energy = energy
        self.pain = pain
        self.comments = comments
        self.createdAt = Date()
    }
}

enum Experience: String, Codable, Hashable, CaseIterable {
    case engaging = "Engaging"
    case basic = "Basic"
    case social = "Social"
    case relaxing = "Relaxing"
    case regular = "Regular"
    case irregular = "Irregular"
    case pastime = "Pastime"
}

enum Mood: String, Codable, Hashable, CaseIterable {
    case calmRelaxed = "Calm and relaxed"
    case happyGood = "Happy and in a good mood"
    case nervousAnxious = "Nervous and anxious"
    case depressed = "Depressed"
}

enum Condition: String, Codable, Hashable, CaseIterable {
    case hyperarousal = "Hyperarousal"
    case tolerance = "Tolerance"
    case hypoarousal = "Hypoarousal"
}

enum Challenge: String, Codable, Hashable, CaseIterable {
    case notEnough = "Not Challenging Enough"
    case moderate = "Moderately Challenging"
    case tooMuch = "Too Challenging"
} 