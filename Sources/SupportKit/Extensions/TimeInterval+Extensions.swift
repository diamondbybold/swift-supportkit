import Foundation

extension TimeInterval {
    public var hourMinuteSecond: (hour: Int, minute: Int, second: Int) {
        let (hr,  minf) = modf(self / 3600)
        let (min, secf) = modf(60 * minf)
        return (Int(hr), Int(min), Int(60 * secf))
    }
}

extension TimeInterval {
    public var durationHMString: String {
        DateComponentsFormatter.durationHM.string(from: self) ?? "-"
    }
    
    public var durationHMSString: String {
        DateComponentsFormatter.durationHMS.string(from: self) ?? "-"
    }
    
    public var countdownString: String {
        DateComponentsFormatter.countdown.string(from: self) ?? "-"
    }
}
