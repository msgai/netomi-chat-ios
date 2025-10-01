//
//  BotItemTableViewCell.swift
//  NetomiSampleApp
//
//  Created by Netomi on 20/12/24.
//

import UIKit

class BotItemTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var botNameLbl: UILabel!
    @IBOutlet weak var botDescriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 8
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
