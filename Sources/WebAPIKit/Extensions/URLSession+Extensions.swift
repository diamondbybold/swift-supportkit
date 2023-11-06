import Foundation

extension URLSession {
    public static var defaultJSONAPI: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json",
                                               "Accept": "application/json"]
        return URLSession(configuration: configuration)
    }
}
