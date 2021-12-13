

import UIKit
import SnapKit
import RealmSwift

class MainViewController: UIViewController, UITextFieldDelegate {

    private var takenStr = ""
    private var searchModels = [Results<NotificationRealm>]()
    private var modelsRealm: Results<NotificationRealm>?
    
    // realm observe use
    private var notificationToken: NotificationToken?
    
    private let searchTextField: MainThemeTextField = {
        let textField = MainThemeTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "關鍵字搜尋列", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        textField.font = .systemFont(ofSize: 25)
        return textField
    }()
    
    private let addiconButton: MainThemeButton = {
        let button = MainThemeButton()
        button.setTitle("+", for: .normal)
        return button
    }()
    
    private let deviceButton: MainThemeButton = {
        let button = MainThemeButton()
        button.setTitle("Own", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.backgroundColor = .gray
        return button
    }()
    
    private let tokenLabel: MainThemeLabel = {
        let label = MainThemeLabel()
        label.isUserInteractionEnabled = true
        label.textColor = .white
        label.backgroundColor = .orange
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.identfier)
        tableView.backgroundColor = .blue
//        tableView.rowHeight = 60
        
        return tableView
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view.backgroundColor = .white
        navigationController?.navigationBar.backgroundColor = .gray
        
        // 註冊 obser
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: UserKeys.notificationObserveKey.rawValue), object: nil, queue: nil, using: fetchToken)
        
        // 更新TOKEN
        UIApplication.shared.registerForRemoteNotifications()
        
        searchTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.tableHeaderView = createHeaderView()
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.centerX.centerY.top.leading.trailing.bottom.equalToSuperview()
        }
        
        // searchTextField func
        searchTextField.addTarget(self, action: #selector(didTapSearchTextField), for: .editingChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 從掃描qrcode 回來的資料
        if let tmpScan = UserDefaults.standard.object(forKey: UserKeys.scanStr.rawValue) as? String {
            takenStr = tmpScan
            tokenLabel.text = "APNS Token:\n\(takenStr)"
        }
        
        searchTextField.text = ""
        
        searchModels = getDateUseRealmFilter()
        tableView.reloadData()
        
    }
    
    // MARK: function
    
    func fetchToken(notification: Notification) -> Void {
        guard let token = notification.userInfo!["tokenStr"] as? String else {
            return
        }
        takenStr = token
        tokenLabel.text = "APNS Token:\n\(token)"
    }
    
    private func createHeaderView()-> UIView{
        
        // headerView 只能用frameLayout
        headerView.frame.size.height = view.height/3
//        headerView.frame.size.width = view.width
//        headerView.frame = CGRect(x: 0, y: 0, width: view.height/3, height: view.width)

        headerView.addSubview(tokenLabel)
        headerView.addSubview(searchTextField)
        headerView.addSubview(addiconButton)
        
        tokenLabel.addSubview(deviceButton)
        
        tokenLabel.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(didTaptokenLabel)))
        addiconButton.addTarget(self, action: #selector(didTapAddIconButton), for: .touchUpInside)
        deviceButton.addTarget(self, action: #selector(didTapDeviceButton), for: .touchUpInside)
        
        configureheaderView()
        
        return headerView
    }
    
    private func configureheaderView(){
        let headerheight = view.frame.height / 3
        
        tokenLabel.snp.makeConstraints { make in
            make.width.equalTo(view.width-32)
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(16)
            make.height.equalTo((headerheight-48)/2)
        }
                
        addiconButton.snp.makeConstraints { make in
            make.trailing.equalTo(tokenLabel.snp.trailing)
            make.top.equalTo(tokenLabel.snp.bottom).offset(16)
            make.width.height.equalTo(tokenLabel.snp.height)
            make.bottom.lessThanOrEqualToSuperview()
        }

        searchTextField.snp.makeConstraints { make in
            make.leading.equalTo(tokenLabel)
            make.top.equalTo(addiconButton)
            make.trailing.equalTo(addiconButton.snp.leading).offset(-16)
            make.height.equalTo(tokenLabel)

        }

        deviceButton.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(44)
            make.bottom.lessThanOrEqualToSuperview()
        }
        
    }
    
    
    // MARK: Button Action
    
    // 搜尋
    @objc private func didTapSearchTextField(){
        
        if searchTextField.text!.isEmpty {
            searchModels = getDateUseRealmFilter()
            
        } else {
            
            searchModels.removeAll()
            // 搜尋程式
            let searchText = searchTextField.text
            let searxhModelsRealm = modelsRealm?.where {
                $0.notiPostRealm.title.contains(searchText!)
            }
            
            if searxhModelsRealm?.count == 0 {
                print("search Element is Empty")
            } else {
//                let notis = transRealmToNotificationArray(itemsRealm: searxhModelsRealm!)
                searchModels.append(searxhModelsRealm!)
            }
            
        }
        tableView.reloadData()
        
    }
    
    @objc private func didTapDeviceButton(){
        
        // 更新TOKEN
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    @objc private func didTapAddIconButton(){
        let vc = CreateNotificationViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.reserveToken = takenStr
        navigationController?.pushViewController(vc, animated: false)
    }
    
    @objc private func didTaptokenLabel (_ gester: UITapGestureRecognizer){
        
        let vc = ScanViewController()
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // TextField Delegate func // 收鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }

}

// MARK: TableView Delegate func
extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchModels[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identfier, for: indexPath) as! MainTableViewCell
        let model = searchModels[indexPath.section][indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    // 跳頁 (CreateNotificationViewController)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = searchModels[indexPath.section][indexPath.row]
        
        let vc = CreateNotificationViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.notificationItem = model
        vc.title = "ID: \(String(model.notiRespRealm?.recordId ?? 0))"
        navigationController?.pushViewController(vc, animated: false)
        
    }
    
    // section 顯示字 or View 只能擇一
    // 一個section 就會有一個 header (func viewForHeaderInSession)
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if searchTextField.text!.isEmpty {
            
            let items = searchModels[section]
            let date = items.first?.createDate ?? Date()
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY/MM/dd"
            let itemDateStr = dateFormatter.string(from: date)
            
            return itemDateStr
            
        } else {
            return "SearchResult"
        }
        
    }
    
    // section background & text color
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let headerView = view as! UITableViewHeaderFooterView
        headerView.tintColor = .clear
        headerView.textLabel?.textColor = .white
        
    }
    
    // 左滑
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { action, view, bool in
            
            // 刪除物件
            let realm = Secure.shard.openRealm()

            let model = self.searchModels[indexPath.section][indexPath.row]
            let modelid = model.id
            
            // realm 移掉
            let modelsRealm = realm!.objects(NotificationRealm.self)
            
            let deleteRealmobj = modelsRealm.where {
                $0.id == "\(modelid)"
            }

            try! realm!.write {
                realm!.delete(deleteRealmobj)
            }
            
            // searchBar 重抓
            self.searchModels = self.getDateUseRealmFilter()
            
            // tableView 移掉se
//            tableView.deleteRows(at:[indexPath], with: .fade)
            
            tableView.reloadData()
        }
        delete.backgroundColor = .red
        
        
        // 添加Action 有順序性
        let swiipeActions = UISwipeActionsConfiguration(actions: [delete])
        // 左滑直接觸action發否？
        swiipeActions.performsFirstActionWithFullSwipe = false
        
        return swiipeActions
    }
    
}


// MARK: Get Data
extension MainViewController {
    
    // 去realm 拿全部值，且加上observe(Realm)
    private func getAllRealmModels(){
        
        let realm = Secure.shard.openRealm()
        
        modelsRealm = realm!.objects(NotificationRealm.self).sorted(byKeyPath: "createDate", ascending: false)
        
        // add observe
        self.notificationToken = modelsRealm!.observe { result in
            switch result{
                
            case .initial(_):
                print("observe init")
                
            case .update(_, deletions: let deletions, insertions: let insertions, modifications: let modifications):
//                print("observe update")
                self.searchModels = self.getDateUseRealmFilter()
                self.tableView.reloadData()
                
            case .error(_):
                print("observe error")
            }
        }
        
    }
    
    // 依時間排序 優化寫法
    private func getDateUseRealmFilter() -> [Results<NotificationRealm>] {
        
        var models = [Results<NotificationRealm>]()
       
        getAllRealmModels()
        
        // 先把current 抽出，為了以後測試時間非0:00，或許要從時區調整？
        var current = Calendar.current
        current.locale = Locale(identifier: "en_US")
        
        let dayStartDate = current.startOfDay(for: Date())
        let dayEndDate = current.date(byAdding: DateComponents(day: 1, second: -1), to: dayStartDate)
        
        // dayStartDate:: 2021-11-23 16:00:00 +0000
        // dayEndDate  :: 2021-11-24 15:59:59 +0000
//        print("dayStartDate::\(dayStartDate):dayEndDate::\(dayEndDate)")
        
        
        var index = 0
        
        /// 迴圈次數到底要幾次，待優化。
        for _ in modelsRealm! {
            
            let dateComponents = DateComponents(day: -index)
            
            let dayStart =  Calendar.current.date(byAdding: dateComponents, to: dayStartDate)
            let dayEnd = Calendar.current.date(byAdding: dateComponents, to: dayEndDate!)
            
//            print("dayStart::\(dayStart):dayEnd::\(dayEnd)")
            
            // 分組從今天開始遞減
            let modelsRealm = modelsRealm!.filter("createDate BETWEEN %@", [dayStart!, dayEnd!]).sorted(byKeyPath: "createDate", ascending: false)
            
//            let tmpArray = transRealmToNotificationArray(itemsRealm: modelsRealm)
            if modelsRealm.count != 0 {
                models.append(modelsRealm)
            }
            
            index += 1
        }
        
        return models
    }
    
    // Results<NotificationRealm> -> [ Notification ]
    /*
    private func transRealmToNotificationArray (itemsRealm : Results<NotificationRealm>) -> [Notification] {
        
        var notifications = [Notification]()
        
        for item in itemsRealm {
            var tmpNoti = Notification()
            
            tmpNoti.createDate = item.createDate
            tmpNoti.id = item.id
            tmpNoti.isOwnRead = item.isOwnRead
            tmpNoti.userInfo = item.userInfo
            tmpNoti.ownToken = item.notiPostRealm?.senderToken
            tmpNoti.createDate = item.createDate
            
            let recordId = item.notiRespRealm!.recordId
            let rm = item.notiRespRealm!.rm
            let rc = item.notiRespRealm!.rc
            let notiResp = NotiResp(rc: rc, rm: rm, recordId: recordId)
            tmpNoti.notiResp = notiResp
            
            let title = item.notiPostRealm!.title
            let content = item.notiPostRealm!.content
            let receiverToken = item.notiPostRealm!.receverToken
            
            var device = [String:String]()
            for deviceMap in (item.notiPostRealm?.device)! {
                device[deviceMap.key] = deviceMap.value
            }
            
            let notiPost = NotiPost(title: title, content: content, device: device, receiverToken: receiverToken)
            tmpNoti.notiPost = notiPost
            
            notifications.append(tmpNoti)
        }
        
        return notifications
    }
    */
    
    // 第一版拿全部值寫法，可參考時間格式化寫法 ＆ 時間比較。但因計算量龐大，會導致資料順序亂跳，因此不建議使用
    /*
    private func getAllModels()->[[Notification]] {

        let notifications =  transRealmToNotificationArray(itemsRealm: modelsRealm!)

        // 排列
        var dates = [String]()

        for item in notifications {
            let tmpDate = item.createDate!

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
            let dateStr = dateFormatter.string(from: tmpDate)

            dates.append(dateStr)
        }

        let dateArray = Dictionary(grouping: dates) { item in item }

        // 組合
        var models = [[Notification]]()

        // 比對時間
        for i in dateArray.keys {
            var notiSection = [Notification]()

            for item in notifications {

                let itemDate = item.createDate!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "YYYY-MM-dd"
                let itemDateStr = dateFormatter.string(from: itemDate)

                if itemDateStr == i {
                    notiSection.append(item)
                }
            }
            models.append(notiSection)
        }

        models.append(notifications)

        return models

    }
    */
}
