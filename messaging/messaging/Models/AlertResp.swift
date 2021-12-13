


// 點擊推播解析用
struct AlertResp: Codable {
    
    var content: Int
    
    enum CodingKeys: String, CodingKey{
        case content = "content-available"
    }
    
}
