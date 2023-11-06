import Foundation

public struct APIEmpty: Decodable { }

public struct APIData<Data: Decodable>: Decodable {
    public let data: Data?
}

public struct APIDataMeta<Data: Decodable, Meta: Decodable>: Decodable {
    public let data: Data?
    public let meta: Meta?
}

public struct APIDataMetaErrors<Data: Decodable, Meta: Decodable, Error: Decodable>: Decodable {
    public let data: Data?
    public let meta: Meta?
    public let errors: [Error]?
}
