//
//  Extension.swift
//  APNSCenter
//
//  Created by hank.chen on 2021/11/9.
//

import UIKit


extension UIAlertController {
    // 只有ok的選項
    public static func showOKAlert(title: String?, text: String?, from vc: UIViewController) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        vc.present(alert, animated: true, completion: nil)
    }
    // 取消會dissmiss的選項
    public static func showCancelAlert(title: String?, text: String?, from vc: UIViewController) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { alertAction in
            vc.dismiss(animated: true, completion: nil)
        }))
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    
}

extension UIView {
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var bottom: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.origin.x + frame.self.width
    }
}

extension Data {
    
    var prettyPrintedJSONString: String { /// NSString gives us a nice sanitized debugDescription
        
        if let json = try? JSONSerialization.jsonObject(with: self, options: []),
            
            let data = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),

            let prettyPrinted = String(data: data, encoding: .utf8) {

            return prettyPrinted
  
        }
        
        return "❌ prettyPrintedJSONString converting failed"
    }

}

extension Dictionary {
    
    var jsonToData: Data? {
        if !JSONSerialization.isValidJSONObject(self) {
            return nil
        }

        let data = try? JSONSerialization.data(withJSONObject: self, options: [])

        return data
    }
    
}
