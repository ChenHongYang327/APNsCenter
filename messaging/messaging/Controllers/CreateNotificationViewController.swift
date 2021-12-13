

import UIKit
import RealmSwift

class CreateNotificationViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    var reserveToken = ""
    var notificationItem: NotificationRealm?
    private var index = 1
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .blue
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = false
        return scrollView
    }()
    
    private let titleTextField: MainThemeTextField = {
        let textField = MainThemeTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "標題", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textField
    }()
    
    private let contentTextField: MainThemeTextField = {
        let textField = MainThemeTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "內容", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textField
    }()
    
    private let receiverLable: MainThemeLabel = {
        let label = MainThemeLabel()
        label.backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.7)
        label.textAlignment = .left
        return label
    }()
    
    private let userInfoTextView = MainThemeTextView()
    
    private let addDeviceButton: MainThemeButton = {
        let button = MainThemeButton()
        button.setTitle("+", for: .normal)
        return button
    }()
    
    private let sentButton: MainThemeButton = {
        let button = MainThemeButton()
        button.backgroundColor = .orange
        button.setTitle("Sent", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20)
        return button
    }()
    
    
    //MARK: LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .clear
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: UserKeys.notificationObserveKey.rawValue), object: nil, queue: nil, using: fetchToken)
        
        scrollView.delegate = self
        
        titleTextField.delegate = self
        contentTextField.delegate = self
        
        view.addSubview(scrollView)
        updateView()
        
        // 預跑一次，新增參數 內容格子
        didTapAddButton()
        isAddUserInfoLable(isShow: false)
                
        view.bringSubviewToFront(sentButton)
        
        // 如果前頁有帶值，先把資料顯示
        if let notificationItem = notificationItem {
            setNotificationInfo(notificationRealm: notificationItem)
        }
        receiverLable.text = "Receiver: \n\(reserveToken)"
    }

    // 如果前頁有帶值，先把資料顯示
    private func setNotificationInfo(notificationRealm: NotificationRealm) {
        
        // 把apns messageid 過濾掉 (notificationIdForIdentify)
        var deviceDictionary = [String:String]()
        for item in notificationRealm.notiPostRealm!.device {
   
            if item.key.contains("notificationIdForIdentify") {
                continue
            }
            deviceDictionary[item.key] = item.value
        }
        
        for (index, item) in deviceDictionary.enumerated() {
          
            // 新增格子
            didTapAddButton()
            // 顯示
            (stackView.arrangedSubviews[index] as! DeviceConfigView).configText(deviceKey: item.key, deviceValue: item.value)
        }
        // 刪除最後一個空格
        stackView.arrangedSubviews.last?.removeFromSuperview()
        
        
        titleTextField.text = notificationRealm.notiPostRealm?.title
        contentTextField.text = notificationRealm.notiPostRealm?.content
        reserveToken = notificationRealm.notiPostRealm!.receverToken
        isAddUserInfoLable(isShow: notificationRealm.isOwnRead)
        
    }
    
    private func updateView(){
        sentButtonConfigure()

//        scrollView.contentSize = CGSize(width: view.width, height: UIScreen.main.bounds.height+50)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addSubViewInScrollView()
        addButtonTarget()
        
    }
    
    private func sentButtonConfigure(){
        view.addSubview(sentButton)
        
        sentButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.size.equalTo(CGSize(width: view.width-32, height: view.height/10))
        }
        
    }
    
    private func addSubViewInScrollView(){
        
        scrollView.addSubview(titleTextField)
        scrollView.addSubview(contentTextField)
        scrollView.addSubview(receiverLable)
        scrollView.addSubview(addDeviceButton)
        scrollView.addSubview(stackView)
        
        titleTextField.snp.makeConstraints { make in
            make.leading.equalTo(view).offset(16)
            make.top.equalToSuperview().offset(16)
            make.trailing.equalTo(view).offset(-16)
            make.height.equalTo(50)
        }
        
        contentTextField.snp.makeConstraints { make in
            make.leading.equalTo(titleTextField)
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.width.equalTo(titleTextField)
            make.height.equalTo(titleTextField)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(contentTextField.snp.bottom).offset(16)
            make.left.equalTo(titleTextField)
            make.trailing.equalTo(addDeviceButton.snp.leading).offset(-16)
        }

        receiverLable.snp.makeConstraints { make in
            make.leading.equalTo(titleTextField)
            make.top.equalTo(stackView.snp.bottom).offset(16)
            make.width.equalTo(titleTextField)
            make.height.equalTo(80)
            make.bottom.equalToSuperview().offset(-100)
        }

        addDeviceButton.snp.makeConstraints { make in
            make.bottom.equalTo(receiverLable.snp.top).offset(-16)
            make.trailing.equalTo(titleTextField)
            make.height.equalTo(titleTextField)
            make.width.equalTo(addDeviceButton.snp.height)
        }
        
    }
    
    // 判斷是否有userInfo 有的話就顯示，沒有就隱藏
    private func isAddUserInfoLable(isShow: Bool){
        
        if isShow {
            userInfoTextView.text = "UserInfo:\n\(notificationItem!.userInfo)"
            
            scrollView.addSubview(userInfoTextView)
            
            receiverLable.snp.remakeConstraints() { make in
                make.top.equalTo(stackView.snp.bottom).offset(16)
                make.leading.equalTo(titleTextField)
                make.width.equalTo(titleTextField)
                make.height.equalTo(80)
            }
            
            userInfoTextView.snp.makeConstraints { make in
                make.top.equalTo(receiverLable.snp.bottom).offset(16)
                make.leading.equalTo(titleTextField)
                make.width.equalTo(titleTextField)
                make.height.equalTo(140)
                make.bottom.equalToSuperview().offset(-100)
            }
            
        }
        
    }
    
    
    //MARK: Button Action
    
    private func addButtonTarget(){
        sentButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        addDeviceButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }
    
    // 新建一個 View，並加到stackView 中
    @objc private func didTapAddButton(){
        
        let addView = DeviceConfigView()
        stackView.addArrangedSubview(addView)
//        print("receiverLable:::::::::\(stackView.height)")

    }
    
    // 發送推波
    // 成功後把直存起來
    // 回到上一頁
    @objc private func didTapSendButton(){
       
        // 準備資料送出去
        guard let title = titleTextField.text, let content = contentTextField.text else {
            print("Empty")
            return
        }

        var deviceDictionary = [String:String]()
        // apns token use Id
        deviceDictionary[UserKeys.notificationIdForIdentify.rawValue] = UUID().uuidString
        // 拿取 deviceTextField 的值
        for item in stackView.arrangedSubviews {
            if let deviceResult = (item as? DeviceConfigView)?.getTexts(){
                deviceDictionary[deviceResult.0] = deviceResult.1
            }
        }
        
        // 避免token重複存入 "DEV_"
        if !reserveToken.contains("DEV_") {
            reserveToken = "DEV_\(reserveToken)"
        }


        // 把所有的資料存到一個obj，再傳去後端發送
        let alert = ApsAlert(locArgs: ["不能註解"], locKey: content, titleLocKey: title)
        let aps = Aps(alert: alert, contentAvailable: 1)
        let apns = Apns(data: deviceDictionary, aps: aps)
        let notificationItem = NotificationItem(validityPeriod: 3, systemName: "Messaging", apns: apns, from: "1177Tech", to: [reserveToken], type: "apns")
        let notificationBody = NotificationBody(notifications: [notificationItem])

        // 發送至後端func
        NetWorkController.shard.pushNotificationToTestDevice(notificationBody: notificationBody) { data in
            guard let data = data else {
                print("No data")
                return
            }

            // 拿到資料存去Realm
            let realm = Secure.shard.openRealm()

            let notiPostRealm = NotiPostRealm()
            notiPostRealm.title = alert.titleLocKey
            notiPostRealm.content = alert.locKey

            for dicItem in deviceDictionary {
                notiPostRealm.device[dicItem.key] = dicItem.value
            }

            notiPostRealm.receverToken = notificationItem.to.first!

            let notiRespRealm  = NotiRespRealm()
            notiRespRealm.rc = data.rc
            notiRespRealm.rm = data.rm
            notiRespRealm.recordId = data.results.first!.recordId

            let notificationRealm = NotificationRealm(notiPostRealm: notiPostRealm, notiRespRralm: notiRespRealm)

            try! realm?.write {
                realm?.add(notificationRealm)
            }

            // 顯示rc rm
            let recordId = data.results.first!.recordId
            let rm = data.rm
            let text = "recordId : \(recordId)\nrm : \(rm)"
            DispatchQueue.main.async {
                self.showOKBackAlert(title: "API Responce", text: text, from: self)
            }

        }
        
    }
    
    // Alert 會回上一頁
    public func showOKBackAlert(title: String?, text: String?, from vc: UIViewController) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {alertAction in
            self.navigationController?.popViewController(animated: false)
        }))
        vc.present(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
