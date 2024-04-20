import Foundation
import CryptoKit

extension String {
    public func find(_ string: String) -> Bool { range(of: string, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    
    public var base64Encoded: String {
        data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    public var base64Decoded: String {
        guard let data = Data(base64Encoded: self) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public var MD5: String {
        let data = data(using: .utf8) ?? Data()
        let hashed = Insecure.MD5.hash(data: data)
        return hashed.map { String(format: "%02hhx", $0) }.joined()
    }
    
    public var SHA256: String {
        let data = data(using: .utf8) ?? Data()
        let hashed = CryptoKit.SHA256.hash(data: data)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    // Returns a percent-escaped string following RFC 3986, e.g. for a query string key or value
    public var escaped: String {
        let generalDelimitersToEncode = ":#[]@"
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? self
    }
    
    public var removingSpaces: String { replacingOccurrences(of: " ", with: "") }
    
    public var contentOrNil: String? { self.isEmpty ? nil : self }
    
    public func XORCipher(_ key: String) -> String {
        let utf8String = Array<UInt8>(self.utf8)
        let utf8key = Array<UInt8>(key.utf8)
        let utf8keyLength = utf8key.count
        var utf8Output = Array<UInt8>()
        for (i, e) in utf8String.enumerated() { utf8Output.append(e ^ utf8key[i % utf8keyLength]) }
        return String(bytes: utf8Output, encoding: .utf8) ?? self
    }
}
