//
//  HistoryTableViewCell.swift
//  NiblSoftTestWork
//
//  Created by Kiryl Bukinevich on 4/18/18.
//  Copyright © 2018 Kiryl Bukinevich. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

   
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
