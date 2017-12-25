//
//  CustomMessageCell.swift
//  TennisMe
//
//  Created by Виктория Бадисова on 07.12.2017.
//  Copyright © 2017 Виктория Бадисова. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {
    
    @IBOutlet weak var messageContainer: UIView!
    @IBOutlet weak var messageAvatarImageView: UIImageView!
    @IBOutlet weak var senderUserName: UILabel!
    @IBOutlet weak var messageBody: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
