import SwiftUI
import SwiftData

@main
struct MockUpMiniApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: SessionRecord.self)
    }
}

struct RootView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("isSignedIn") private var isSignedIn = false

    var body: some View {
        if isSignedIn {
            MainTabView()
        } else {
            SignInView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            QuestionListView()
                .tabItem {
                    Label("Questions", systemImage: "list.bullet")
                }
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
}
