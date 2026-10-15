# MockUp Mini iOS — Study Plan

Goal: explain every file in this project out loud, confidently, in three focused sessions that fit around other interview prep.

## Session 1 — Run the app and tell its story

- Build and run the app on an iPhone simulator (Xcode 15+, iOS 17).
- Sign in, open the question bank, run a timed practice session, save it, then check History and Profile.
- Prepare a 60-second project story: what the app does, who it is for, and the two hardest things you solved (offline fallback and the timer).
- One-sentence explanation per file:
  - Package.swift — the Swift Playground app manifest: bundle ID, iOS 17 target, and the Resources folder.
  - Models.swift — InterviewQuestion (Codable struct for the question bank) and SessionRecord (SwiftData model for saved practice sessions).
  - QuestionService.swift — an actor that fetches questions from the API and falls back to the bundled JSON when offline.
  - ViewModels.swift — @Observable view models plus the practice session timer built on a cancellable Task.
  - MockUpMiniApp.swift — the @main entry point, the SwiftData container, and the tab navigation behind the sign-in gate.
  - Views.swift — the five screens: sign in, question list, practice, history, and profile.
  - questions.json — the bundled offline question bank of 10 questions.

## Session 2 — Swift language core

- Optionals: if let, guard let, optional chaining, nil coalescing; what force-unwrapping nil does.
- Struct vs class: value vs reference semantics, inheritance, identity; why SessionRecord is a class and InterviewQuestion is a struct.
- let vs var, and why the view models use var for state.
- Closures: trailing closures in filter and map, capture lists.
- async/await and actors: how QuestionService keeps network code readable and how the actor guards shared state.
- Codable: decoding [InterviewQuestion] from the API and from the bundled file with JSONDecoder.
- ARC and [weak self]: why the timer Task captures self weakly and what a retain cycle would look like here.

## Session 3 — SwiftUI core

- Declarative UI: views as a function of state; the body re-renders when @Observable state changes.
- Property wrappers: @State for local view state, @Observable for view models, @AppStorage for the sign-in flag and user name, @Environment for dismiss and modelContext, @Query for the SwiftData history list.
- NavigationStack and navigationDestination with a Hashable question type.
- Identifiable: why List can iterate questions and records directly.
- Timer cancellation: stopping the timer in onDisappear so it never runs after leaving the practice screen.

## Likely interviewer follow-ups

- Offline behaviour: what happens when the API is unreachable (bundled fallback) and when the bundled file is missing (bundledDataMissing error).
- Testing: how you would unit test the view models and the JSON decoding.
- Scaling: what changes if the bank grows to 10,000 questions (pagination or search indexing, moving decoding off the main actor).
- Known bug to mention honestly: an early version kept the timer running after leaving the practice screen; fixed by cancelling in onDisappear.

## Honesty note

iOS is a recent personal project for me; my professional experience is in full-stack web development. I built this app to learn Swift and SwiftUI properly, and I can explain every line in it.
