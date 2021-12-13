import Foundation



// 推播body用

struct NotificationBody: Codable {
    var notifications: [NotificationItem]
    
}

struct NotificationItem: Codable {
    var validityPeriod: Int
    var systemName: String
    var apns: Apns
    var from: String
    var to: [String]
    var type: String
    
    enum CodingKeys: String, CodingKey {
        case validityPeriod = "validity_period"
        case systemName = "systemname"
        case from
        case apns
        case to
        case type
    }
}

struct Apns: Codable {
    var data: [String:String] //參數：設備
    var aps: Aps
}

struct Aps: Codable {
    var alert: ApsAlert
    var contentAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case alert
        case contentAvailable = "content-available"
    }
}

struct ApsAlert: Codable {
    var locArgs: [String] //"不能註解"
    var locKey: String // 推播內文
    var titleLocKey: String // 推播標題
    
    enum CodingKeys: String, CodingKey{
        case locArgs = "loc-args"
        case locKey = "loc-key"
        case titleLocKey = "title-loc-key"
    }
    
}
