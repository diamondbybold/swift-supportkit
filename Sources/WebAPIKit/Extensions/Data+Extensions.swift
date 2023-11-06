import Foundation

extension Data {
    public func XORCipher(_ key: String) -> Data {
        let utf8key = Array<UInt8>(key.utf8)
        let utf8keyLength = utf8key.count
        var output: Data = Data()
        for (i, e) in self.enumerated() { output.append(e ^ utf8key[i % utf8keyLength]) }
        return output
    }
    
    public var base64URLEncodedString: String {
        base64EncodedString()
            .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
            .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
            .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
            .trimmingCharacters(in: .whitespaces)
    }
}
