//
//  ItemTableViewCell.swift
//  ZZDigidentity
//
//  Created by Zeljko Zivkovic on 07/04/2019.
//  Copyright © 2019 Digidentity. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var itemTextLabel: UILabel!
    @IBOutlet var confidenceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        self.itemImageView.layer.borderColor = UIColor.black.cgColor
        self.itemImageView.layer.borderWidth = 1.0/UIScreen.main.scale
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.itemImageView.image = nil
        self.idLabel.text = nil
        self.confidenceLabel.text = nil
        self.textLabel?.text = nil
    }

    func setApiItem(_ item: APIItem) {
        self.itemImageView.image = item.image()
        self.idLabel.text = item.id
        self.confidenceLabel.text = "Confidence: " + String(format: "%.3f", item.confidence)
        self.itemTextLabel?.text = item.text
    }    
}
