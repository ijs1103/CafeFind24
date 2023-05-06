//
//  CategoryMapDataResponseModel.swift
//  FindCVS
//
//  Created by 이주상 on 2023/05/04.
//

import Foundation

struct CategoryMapData: Codable {
    let documents: [Cafe]
    let meta: Meta
}

struct Cafe: Codable, Hashable {
    let addressName: String
    let categoryGroupCode: CategoryGroupCode
    let categoryGroupName: CategoryGroupName
    let category, distance, id, phone: String
    let title: String
    let kakaoUrl: String
    let roadAddressName, x, y: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case category = "category_name"
        case distance, id, phone
        case title = "place_name"
        case kakaoUrl = "place_url"
        case roadAddressName = "road_address_name"
        case x, y
    }
}

enum CategoryGroupCode: String, Codable {
    case ce7 = "CE7"
}

enum CategoryGroupName: String, Codable {
    case 카페 = "카페"
}

struct Meta: Codable {
    let isEnd: Bool
    let pageableCount: Int
    let sameName: JSONNull?
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case isEnd = "is_end"
        case pageableCount = "pageable_count"
        case sameName = "same_name"
        case totalCount = "total_count"
    }
}

struct SameName: Codable {
    let keyword: String
    let region: JSONNull?
    let selectedRegion: String
    
    enum CodingKeys: String, CodingKey {
        case keyword, region
        case selectedRegion = "selected_region"
    }
}

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
