import UIKit
import CryptoKit

extension String {
    public var base64Encoded: String {
        data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    public var base64Decoded: String {
        guard let data = Data(base64Encoded: self) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    public var sha256: String {
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    public var addingPercentEncodingForURLQueryValue: String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)
    }
    
    public var addingPercentEncodingForURLFormValue: String? {
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._* ")
        return addingPercentEncoding(withAllowedCharacters: allowedCharacters)?.replacingOccurrences(of: " ", with: "+")
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
