import Foundation
import Observation

@Observable
final class QuestionListViewModel {
    var questions: [InterviewQuestion] = []
    var isLoading = false
    var searchText = ""
    var selectedCategory: String?

    private let service = QuestionService()

    var categories: [String] {
        Array(Set(questions.map(\.category))).sorted()
    }

    var filteredQuestions: [InterviewQuestion] {
        questions.filter { question in
            let matchesSearch = searchText.isEmpty ||
                question.prompt.localizedCaseInsensitiveContains(searchText)
            let matchesCategory = selectedCategory == nil || question.category == selectedCategory
            return matchesSearch && matchesCategory
        }
    }

    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            questions = try await service.loadQuestions()
        } catch {
            questions = []
        }
    }
}

@Observable
final class PracticeSessionViewModel {
    let question: InterviewQuestion
    var answerDraft = ""
    var selfRating = 3
    var elapsedSeconds = 0
    var isRunning = false
    private var timer: Task<Void, Never>?

    init(question: InterviewQuestion) {
        self.question = question
    }

    func startTimer() {
        guard !isRunning else { return }
        isRunning = true
        timer = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    self?.elapsedSeconds += 1
                }
            }
        }
    }

    func stopTimer() {
        timer?.cancel()
        timer = nil
        isRunning = false
    }

    var elapsedText: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func makeRecord() -> SessionRecord {
        SessionRecord(
            questionPrompt: question.prompt,
            category: question.category,
            selfRating: selfRating,
            durationSeconds: elapsedSeconds
        )
    }
}
