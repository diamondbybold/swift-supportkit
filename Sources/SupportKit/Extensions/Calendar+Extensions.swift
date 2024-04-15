import Foundation

extension Calendar {
    public func endOfDay(for date: Date) -> Date {
        self.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
    }
    
    public func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    public func endOfMonth(for date: Date) -> Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1, hour: 23, minute: 59, second: 59), to: startOfMonth(for: date))!
    }
    
    public func dates(interval: DateInterval, matching: DateComponents) -> [Date] {
        var dates: [Date] = []
        dates.append(interval.start)
        enumerateDates(startingAfter: interval.start, matching: matching, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
    
    public func month(for date: Date) -> [[Date]] {
        var weeks: [[Date]] = []
        
        let startOfMonth = startOfMonth(for: date)
        
        let monthInterval = dateInterval(of: .month, for: startOfMonth)!
        let firstWeekdays = dates(interval: monthInterval,
                                  matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: firstWeekday))
        
        for w in firstWeekdays {
            let weekInterval = dateInterval(of: .weekOfYear, for: w)!
            let days = dates(interval: weekInterval,
                             matching: DateComponents(hour: 0, minute: 0, second: 0))
            
            var week: [Date] = []
            for d in days {
                week.append(d)
            }
            weeks.append(week)
        }
        
        return weeks
    }
    
    public func isDateInMonth(_ date: Date, startOfMonth: Date) -> Bool {
        isDate(startOfMonth, equalTo: date, toGranularity: .month)
    }
}
