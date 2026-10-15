import Foundation

enum QuestionServiceError: Error {
    case badResponse
    case bundledDataMissing
}

actor QuestionService {
    static let endpoint = URL(string: "https://mockup.example.com/api/questions")

    func loadQuestions() async throws -> [InterviewQuestion] {
        do {
            return try await fetchRemote()
        } catch {
            return try loadBundled()
        }
    }

    private func fetchRemote() async throws -> [InterviewQuestion] {
        guard let endpoint = Self.endpoint else {
            throw QuestionServiceError.badResponse
        }
        let (data, response) = try await URLSession.shared.data(from: endpoint)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw QuestionServiceError.badResponse
        }
        return try JSONDecoder().decode([InterviewQuestion].self, from: data)
    }

    private func loadBundled() throws -> [InterviewQuestion] {
        let bundle = Bundle.main.url(forResource: "questions", withExtension: "json") != nil ? Bundle.main : Bundle.module
        guard let url = bundle.url(forResource: "questions", withExtension: "json") else {
            throw QuestionServiceError.bundledDataMissing
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([InterviewQuestion].self, from: data)
    }
}
