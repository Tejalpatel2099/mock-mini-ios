import Foundation
import SwiftData

struct InterviewQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let category: String
    let prompt: String
    let hint: String
    let difficulty: String
    let suggestedMinutes: Int

    var difficultyColourName: String {
        switch difficulty.lowercased() {
        case "easy":
            return "green"
        case "medium":
            return "orange"
        case "hard":
            return "red"
        default:
            return "gray"
        }
    }
}

@Model
final class SessionRecord {
    var questionPrompt: String
    var category: String
    var selfRating: Int
    var durationSeconds: Int
    var completedAt: Date

    init(questionPrompt: String, category: String, selfRating: Int, durationSeconds: Int, completedAt: Date = Date()) {
        self.questionPrompt = questionPrompt
        self.category = category
        self.selfRating = selfRating
        self.durationSeconds = durationSeconds
        self.completedAt = completedAt
    }

    var durationText: String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
