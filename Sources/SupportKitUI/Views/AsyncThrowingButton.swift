import SwiftUI
import SupportKit

public struct AsyncThrowingButton<Label, E: LocalizedError>: View where Label: View {
    private let label: Label
    private let role: ButtonRole?
    private let debounce: Bool
    private let action: () async throws -> Void
    
    @State private var waiting: Bool = false
    @State private var showAlert: Bool = false
    @State private var error: E? = nil
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                debounce: Bool = true,
                action: @escaping () async throws -> Void) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.debounce = debounce
        self.action = action
    }
    
    public init(role: ButtonRole? = nil,
                action: @escaping () async throws -> Void,
                debounce: Bool = true,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.debounce = debounce
        self.action = action
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                debounce: Bool = true,
                action: @escaping () async throws -> Void) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.debounce = debounce
        self.action = action
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                debounce: Bool = true,
                action: @escaping () async throws -> Void) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.debounce = debounce
        self.action = action
    }
    
    private func performTask() async {
        waiting = true
        do {
            try await action()
        } catch {
            self.error = error as? E
        }
        waiting = false
    }
    
    public var body: some View {
        Button(role: role) {
            if debounce {
                TaskLimiter.debounce { await performTask() }
            } else {
                Task { await performTask() }
            }
        } label: {
            if waiting {
                ProgressView()
            } else {
                label
            }
        }
        .allowsHitTesting(!waiting)
        .alert(isPresented: $showAlert, error: error) { _ in
            Button("OK") { }
        } message: { error in
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
            }
        }
    }
}
