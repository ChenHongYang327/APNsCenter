

import Foundation
import UIKit



enum APIsUrlStr: String {
    case userNotificationPush = "https://dev.1177pay.com.tw/pushserver/api/push"
    
}

class NetWorkController {
    
    static let shard = NetWorkController()
    

    func pushNotificationToTestDevice (notificationBody: NotificationBody, completion: @escaping (APNsReponce?) -> Void ){
        
        let url = URL(string: APIsUrlStr.userNotificationPush.rawValue)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let bodyData = try? JSONEncoder().encode(notificationBody)
            
            let dataformatStr = bodyData!.prettyPrintedJSONString
//            print("bodyData:\(dataformatStr)")
            
            request.httpBody = bodyData
            
        } catch let error{
            print("endode error: \(error)")
        }
        
        let session = URLSession(configuration: .ephemeral)
        let task = session.dataTask(with: request) { data, responce, error in
            guard error == nil else {
                print("fetch fail")
                print(error!.localizedDescription)
                completion(nil)
                return
            }
            if let data = data {
                
//                let dataDtr = String(data: data, encoding: .utf8)
//                print("dataDtr: \(dataDtr!)")
                
                do {
                    let decoder = JSONDecoder()
                    let apnsResponce = try decoder.decode(APNsReponce.self, from: data)
                    completion(apnsResponce)
                    
                } catch let error {
                    print("Analyze data fail")
                    print(error.localizedDescription)
                    completion(nil)
                }
            } else {
                print("Get Empty Data From URL!")
                completion(nil)
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
}

