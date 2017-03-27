//
//  DVMessageTableViewCell.swift
//  DVBannerView
//
//  Created by David on 2017/3/25.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit

class DVMessageTableViewCell: UITableViewCell {
    
    let ImageViewHeight:CGFloat = 100.0
    let LabelHeight:CGFloat = 40.0
    let ButtonHeight:CGFloat = 16.0
    
    var leftImageView = UIImageView()
    var titleLabel = UILabel()
    var collectionButton = UIButton()

    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style:UITableViewCellStyle, reuseIdentifier:String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.setupView()
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    func setupView()
    {
        self.leftImageView = UIImageView.init()
        self.contentView.addSubview(self.leftImageView)
        self.leftImageView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.equalTo(ImageViewHeight)
        }
        
        self.titleLabel = UILabel.init()
        self.titleLabel.numberOfLines = 0
        self.titleLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.leftImageView.snp.right).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.top.equalToSuperview().offset(5)
            make.height.equalTo(LabelHeight)
        }
        
        self.collectionButton = UIButton.init(type: .system)
        self.collectionButton.titleLabel?.font = UIFont.systemFont(ofSize:12)
        self.collectionButton.contentHorizontalAlignment = .right
        self.contentView.addSubview(self.collectionButton)
        
        self.collectionButton.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-5)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(ButtonHeight)
            make.width.equalTo(100)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
