import SwiftUI
import SupportKit

public struct AsyncButton<Label>: View where Label: View {
    public typealias SuccessMessage = (title: LocalizedStringKey, description: LocalizedStringKey)
    
    private let label: Label
    private let role: ButtonRole?
    private let debounce: Bool
    private let ignoreState: Bool
    private let successMessage: SuccessMessage?
    private let action: () async throws -> Void
    
    @State private var waiting: Bool = false
    
    @EnvironmentObject private var navigationContext: NavigationContext
    
    @Environment(\.analyticsContextIdentifier) private var analyticsContextIdentifier: String
    @Environment(\.analyticsScreenIdentifier) private var analyticsScreenIdentifier: String
    @Environment(\.analyticsActionLog) private var analyticsActionLog: AnalyticsActionLog?
    
    public init(_ titleKey: LocalizedStringKey,
                role: ButtonRole? = nil,
                ignoreState: Bool = false,
                successMessage: SuccessMessage? = nil,
                debounce: Bool = true,
                action: @escaping () async throws -> Void) where Label == Text {
        self.label = Text(titleKey)
        self.role = role
        self.ignoreState = ignoreState
        self.successMessage = successMessage
        self.debounce = debounce
        self.action = action
    }
    
    public init(role: ButtonRole? = nil,
                ignoreState: Bool = false,
                successMessage: SuccessMessage? = nil,
                action: @escaping () async throws -> Void,
                debounce: Bool = true,
                @ViewBuilder label: () -> Label) {
        self.label = label()
        self.role = role
        self.ignoreState = ignoreState
        self.successMessage = successMessage
        self.debounce = debounce
        self.action = action
    }
    
    public init(image: String,
                role: ButtonRole? = nil,
                ignoreState: Bool = false,
                successMessage: SuccessMessage? = nil,
                debounce: Bool = true,
                action: @escaping () async throws -> Void) where Label == Image {
        self.label = Image(image)
        self.role = role
        self.ignoreState = ignoreState
        self.successMessage = successMessage
        self.debounce = debounce
        self.action = action
    }
    
    public init(systemImage: String,
                role: ButtonRole? = nil,
                ignoreState: Bool = false,
                successMessage: SuccessMessage? = nil,
                debounce: Bool = true,
                action: @escaping () async throws -> Void) where Label == Image {
        self.label = Image(systemName: systemImage)
        self.role = role
        self.ignoreState = ignoreState
        self.successMessage = successMessage
        self.debounce = debounce
        self.action = action
    }
    
    @MainActor
    private func performTask() async {
        waiting = true
        
        do {
            try await action()
            
            if !ignoreState, let successMessage {
                navigationContext.alert(title: successMessage.title,
                                        message: successMessage.description,
                                        confirmation: false) {
                    Button("OK") { }
                }
            }
        } catch let e as LocalizedError {
            if !ignoreState {
                navigationContext.alert(title: LocalizedStringKey(e.failureReason ?? ""),
                                        message: LocalizedStringKey(e.recoverySuggestion ?? ""),
                                        confirmation: false) {
                    Button("OK") { }
                }
            }
        } catch { }
        
        waiting = false
    }
    
    public var body: some View {
        Button(role: role) {
            if let analyticsActionLog {
                logActionEvent(analyticsActionLog.name,
                               identifier: analyticsActionLog.identifier,
                               screenIdentifier: analyticsScreenIdentifier,
                               parameters: analyticsActionLog.parameters)
            }
            
            if debounce {
                TaskLimiter.shortDebounce { await performTask() }
            } else {
                Task { await performTask() }
            }
        } label: {
            if !ignoreState, waiting {
                ProgressView()
            } else {
                label
            }
        }
        .allowsHitTesting(!waiting)
    }
}
