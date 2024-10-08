import Foundation
import SwiftUI

public struct CalendarView: UIViewRepresentable {
    @Binding private var date: Date?
    private let dateInterval: DateInterval
    private let availableDates: [Date]?
    @Binding private var visibleDate: Date?
    
    public init(date: Binding<Date?>,
                dateInterval: DateInterval = DateInterval(start: .distantPast, end: .distantFuture),
                availableDates: [Date]? = nil,
                visibleDate: Binding<Date?> = .constant(nil)) {
        self._date = date
        self.dateInterval = dateInterval
        self.availableDates = availableDates
        self._visibleDate = visibleDate
    }
    
    public func makeUIView(context: Context) -> UICalendarView {
        let view = UICalendarView()
        
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        view.wantsDateDecorations = false
        
        view.availableDateRange = dateInterval
        
        let selectionBehavior = UICalendarSelectionSingleDate(delegate: context.coordinator)
        
        if let date {
            selectionBehavior.selectedDate = Calendar.current.dateComponents(in: TimeZone.current, from: date)
        } else {
            selectionBehavior.selectedDate = nil
        }
        
        view.selectionBehavior = selectionBehavior
        
        if let visibleDate {
            view.visibleDateComponents = Calendar.current.dateComponents(in: .current, from: visibleDate)
        }
        
        view.delegate = context.coordinator
        
        return view
    }
    
    public func updateUIView(_ uiView: UICalendarView, context: Context) {
        if context.coordinator.availableDates != availableDates {
            context.coordinator.availableDates = availableDates
            uiView.availableDateRange = dateInterval
        }
        
        if let selectionBehavior = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            var selectedDate: DateComponents? = nil
            if let date {
                selectedDate = Calendar.current.dateComponents(in: .current, from: date)
            }
            
            if selectionBehavior.selectedDate != selectedDate {
                selectionBehavior.selectedDate = selectedDate
            }
            
            selectionBehavior.updateSelectableDates()
        }
        
        if let visibleDate {
            let visibleDateComponents = Calendar.current.dateComponents(in: .current, from: visibleDate)
            
            if uiView.visibleDateComponents != visibleDateComponents {
                uiView.visibleDateComponents = visibleDateComponents
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(date: $date,
                    availableDates: availableDates,
                    visibleDate: $visibleDate)
    }
}

extension CalendarView {
    public class Coordinator: NSObject, @preconcurrency UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        @Binding var date: Date?
        var availableDates: [Date]?
        @Binding private var visibleDate: Date?
        
        init(date: Binding<Date?>,
             availableDates: [Date]?,
             visibleDate: Binding<Date?>) {
            self._date = date
            self.availableDates = availableDates
            self._visibleDate = visibleDate
        }
        
        @MainActor
        public func calendarView(_ calendarView: UICalendarView,
                                 didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            if let date = Calendar.current.date(from: calendarView.visibleDateComponents) {
                visibleDate = date
            }
        }
        
        public func dateSelection(_ selection: UICalendarSelectionSingleDate,
                                  canSelectDate dateComponents: DateComponents?) -> Bool {
            guard let dateComponents else { return true }
            guard let availableDates else { return true }
            
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
                self.date = date
            } else {
                date = nil
            }
        }
    }
}
