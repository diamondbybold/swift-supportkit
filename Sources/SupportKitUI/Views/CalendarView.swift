import Foundation
import SwiftUI

public struct CalendarView: UIViewRepresentable {
    @Binding private var date: Date?
    private let dateInterval: DateInterval
    private var availableDates: [Date]?
    
    public init(date: Binding<Date?>,
                dateInterval: DateInterval = DateInterval(start: .distantPast, end: .distantFuture),
                availableDates: [Date]? = nil) {
        self._date = date
        self.dateInterval = dateInterval
        self.availableDates = availableDates
    }
    
    private func updateSelectableDate(_ view: UICalendarView, coordinator: Coordinator) {
        let selectionBehavior = UICalendarSelectionSingleDate(delegate: coordinator)
        
        if let date {
            selectionBehavior.selectedDate = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        } else {
            selectionBehavior.selectedDate = nil
        }
        
        view.selectionBehavior = selectionBehavior
    }
    
    public func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        view.availableDateRange = dateInterval
        
        updateSelectableDate(view, coordinator: context.coordinator)
        
        return view
    }
    
    public func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parent = self
        updateSelectableDate(uiView, coordinator: context.coordinator)
    }
    
    public func makeCoordinator() -> Coordinator { Coordinator(self) }
}

extension CalendarView {
    public class Coordinator: NSObject, UICalendarSelectionSingleDateDelegate {
        var parent: CalendarView
        
        init(_ parent: CalendarView) {
            self.parent = parent
        }
        
        public func dateSelection(_ selection: UICalendarSelectionSingleDate,
                                  canSelectDate dateComponents: DateComponents?) -> Bool {
            guard let dateComponents else { return true }
            guard let availableDates = parent.availableDates else { return true }
            
            for date in availableDates {
                if Calendar.current.dateComponents(in: .current, from: date).isSameDay(as: dateComponents) {
                    return true
                }
            }
            
            return false
        }
        
        public func dateSelection(_ selection: UICalendarSelectionSingleDate,
                                  didSelectDate dateComponents: DateComponents?) {
            if let dateComponents,
               let date = Calendar.current.date(from: dateComponents) {
                parent.date = date
            } else {
                parent.date = nil
            }
        }
    }
}
