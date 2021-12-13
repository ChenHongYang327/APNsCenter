

import UIKit
import SnapKit


class DeviceConfigView: UIView, UITextFieldDelegate {
    
    private let devicekeyTextField: MainThemeTextField = {
        let textField = MainThemeTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "參數", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textField
    }()
    
    private let deviceValueTextField: MainThemeTextField = {
        let textField = MainThemeTextField()
        textField.attributedPlaceholder = NSAttributedString(string: "內容", attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray])
        return textField
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(devicekeyTextField)
        addSubview(deviceValueTextField)
        
        devicekeyTextField.delegate = self
        deviceValueTextField.delegate = self
        
        devicekeyTextField.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(snp.centerX).offset(-4)
            make.height.equalTo(50)
            make.bottom.equalToSuperview()
        }
        
        deviceValueTextField.snp.makeConstraints { make in
            make.left.equalTo(devicekeyTextField.snp.right).offset(8)
            make.top.equalTo(devicekeyTextField)
            make.trailing.equalToSuperview()
            make.leading.equalTo(snp.centerX).offset(4)
            make.height.equalTo(devicekeyTextField)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getTexts() -> (String, String) {
        return (devicekeyTextField.text ?? "", deviceValueTextField.text ?? "")
    }
    
    func configText(deviceKey: String, deviceValue: String ){
        devicekeyTextField.text = deviceKey
        deviceValueTextField.text = deviceValue
    }
    
    // 收鍵盤
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
