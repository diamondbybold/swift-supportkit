import Foundation

extension Locale {
    // pt-PT, pt-BR, en-GB, en-US
    public var languageAndRegionCode: String {
        var result = language.languageCode?.identifier ?? ""
        
        if let region = language.region?.identifier {
            result += "-\(region)"
        }
        
        return result
    }
}
