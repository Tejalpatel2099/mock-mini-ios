import SwiftUI
import SwiftData

struct SignInView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("userEmail") private var userEmail = ""
    @AppStorage("isSignedIn") private var isSignedIn = false
    @State private var name = ""
    @State private var email = ""
    @State private var errorMessage: String?

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        email.contains("@") && email.contains(".")
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mic.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.purple)
            Text("MockUp Mini")
                .font(.largeTitle.bold())
            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red).font(.footnote)
            }
            Button("Sign In") {
                guard isValid else {
                    errorMessage = "Enter your name and a valid email address."
                    return
                }
                userName = name.trimmingCharacters(in: .whitespaces)
                userEmail = email.trimmingCharacters(in: .whitespaces)
                isSignedIn = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || email.isEmpty)
        }
        .padding()
    }
}

struct QuestionListView: View {
    @State private var viewModel = QuestionListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading questions...")
                } else {
                    List(viewModel.filteredQuestions) { question in
                        NavigationLink(value: question) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(question.prompt).font(.headline)
                                HStack {
                                    Text(question.category).font(.caption)
                                    Text(question.difficulty).font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Questions")
            .searchable(text: $viewModel.searchText)
            .toolbar {
                Menu("Filter") {
                    Button("All") { viewModel.selectedCategory = nil }
                    ForEach(viewModel.categories, id: \.self) { category in
                        Button(category) { viewModel.selectedCategory = category }
                    }
                }
            }
            .navigationDestination(for: InterviewQuestion.self) { question in
                PracticeView(question: question)
            }
            .task {
                await viewModel.load()
            }
        }
    }
}

struct PracticeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: PracticeSessionViewModel

    init(question: InterviewQuestion) {
        _viewModel = State(initialValue: PracticeSessionViewModel(question: question))
    }

    var body: some View {
        Form {
            Section("Question") {
                Text(viewModel.question.prompt).font(.headline)
                Text(viewModel.question.hint).font(.subheadline).foregroundStyle(.secondary)
            }
            Section("Timer") {
                HStack {
                    Text(viewModel.elapsedText).font(.title2.monospacedDigit())
                    Spacer()
                    Button(viewModel.isRunning ? "Pause" : "Start") {
                        viewModel.isRunning ? viewModel.stopTimer() : viewModel.startTimer()
                    }
                }
            }
            Section("Your answer") {
                TextEditor(text: $viewModel.answerDraft)
                    .frame(minHeight: 120)
            }
            Section("Self rating") {
                Picker("Rating", selection: $viewModel.selfRating) {
                    ForEach(1...5, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(.segmented)
            }
            Button("Save session") {
                modelContext.insert(viewModel.makeRecord())
                dismiss()
            }
        }
        .navigationTitle("Practice")
        .onDisappear {
            viewModel.stopTimer()
        }
    }
}

struct HistoryView: View {
    @Query(sort: \SessionRecord.completedAt, order: .reverse) private var records: [SessionRecord]

    var body: some View {
        NavigationStack {
            Group {
                if records.isEmpty {
                    ContentUnavailableView("No sessions yet", systemImage: "clock", description: Text("Practise a question to see it here."))
                } else {
                    List(records) { record in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.questionPrompt).font(.headline)
                            HStack {
                                Text(record.category).font(.caption)
                                Text("Rating: \(record.selfRating)/5").font(.caption)
                                Text(record.durationText).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

struct ProfileView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("isSignedIn") private var isSignedIn = false
    @Query private var records: [SessionRecord]

    private var averageRating: Double {
        guard !records.isEmpty else { return 0 }
        return Double(records.map(\.selfRating).reduce(0, +)) / Double(records.count)
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Text(userName.isEmpty ? "Guest" : userName).font(.headline)
                }
                Section("Stats") {
                    Text("Sessions: \(records.count)")
                    Text(String(format: "Average rating: %.1f / 5", averageRating))
                }
                Button("Sign Out", role: .destructive) {
                    isSignedIn = false
                }
            }
            .navigationTitle("Profile")
        }
    }
}
