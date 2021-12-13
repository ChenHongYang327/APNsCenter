

import Foundation


struct NotificationModel: Codable {
    var id: String?
    var notiPost: NotiPost?
    var notiResp: NotiResp?
    var userInfo: String?
    var isOwnRead: Bool = false
    var ownToken: String?
    var createDate: Date?
}

struct NotiPost:Codable {
    var title: String
    var content: String
    var device: [String:String]
    var receiverToken: String
}

struct NotiResp:Codable {
    var rc: String
    var rm: String
    var recordId: Int
}

