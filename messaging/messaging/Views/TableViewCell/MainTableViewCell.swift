

import UIKit
import SnapKit

class MainTableViewCell: UITableViewCell {
    
    static let identfier = "MainTableViewCell"
    
    private let titleLabel: MainThemeLabel = {
        let label = MainThemeLabel()
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    private let contentLabel: MainThemeLabel = {
        let label = MainThemeLabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let didTabImg: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(didTabImg)
        
        contentView.backgroundColor = .white
        contentView.clipsToBounds = true
        
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(8)
            make.leading.equalTo(contentView).offset(16)
            make.width.equalTo(contentView.width/3)
//            make.height.equalTo(20)
        }

        
        contentLabel.snp.makeConstraints { make in
            make.leading.width.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        didTabImg.snp.makeConstraints { make in
            make.trailing.equalTo(contentView).offset(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(contentView.height/2)
        }
        
        
        // 選到的顏色
        selectionStyle = .default
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func configure (with notificationRealm: NotificationRealm){
        
        titleLabel.text = notificationRealm.notiPostRealm?.title
        contentLabel.text = notificationRealm.notiPostRealm?.content
        if notificationRealm.isOwnRead {
            didTabImg.image = UIImage(named: "mail")
        } else {
            didTabImg.image = nil
        }
        
    }

}
