

import UIKit



class MainThemeButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .green
        titleLabel?.textAlignment = .center
        clipsToBounds = true
        layer.cornerRadius = Corner.radius.rawValue
        titleLabel?.font = .systemFont(ofSize: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class MainThemeLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textAlignment = .center
        layer.cornerRadius = Corner.radius.rawValue
        clipsToBounds = true
        textColor = .black
        numberOfLines = 0
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class MainThemeTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = .black
        backgroundColor = .white
        layer.cornerRadius = Corner.radius.rawValue
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainThemeTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.7)
        layer.masksToBounds = true
        layer.cornerRadius = Corner.radius.rawValue
        isSelectable = false
        textColor = .black
        font = .systemFont(ofSize: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
