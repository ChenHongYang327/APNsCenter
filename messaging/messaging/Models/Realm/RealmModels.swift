

import RealmSwift


class NotificationRealm: Object {
    @Persisted var id = UUID().uuidString
    @Persisted var notiPostRealm: NotiPostRealm?
    @Persisted var notiRespRealm: NotiRespRealm?
    @Persisted var userInfo: String = ""
    @Persisted var isOwnRead: Bool = false
    @Persisted var createDate: Date = Date()
    
    convenience init(notiPostRealm: NotiPostRealm?, notiRespRralm: NotiRespRealm?){
        self.init()
        self.notiPostRealm = notiPostRealm
        self.notiRespRealm = notiRespRralm
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

class NotiPostRealm: Object {
    @Persisted var title: String
    @Persisted var content: String
    @Persisted var device: Map<String,String>
    @Persisted var receverToken: String
    @Persisted var senderToken: String // 不需要存，需要再呼叫即可
}

class NotiRespRealm: Object {
    @Persisted var rc: String
    @Persisted var rm: String
    @Persisted var recordId: Int
}

