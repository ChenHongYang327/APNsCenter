

import Foundation


struct APNsReponce: Codable {
    var rc: String
    var rm: String
    var results: [APNsResult]
}

struct APNsResult: Codable {
//    var sentAt: Int
    var recordId: Int
    var receiver: String
    var statusDesc: String
//    var doneAt: Int
    var type: String
    var status: String

    enum CodingKeys: String, CodingKey {
//        case sentAt = "sent_at"
        case recordId = "record_id"
        case receiver
        case statusDesc = "status_desc"
//        case doneAt = "done_at"
        case type
        case status
    }
}

