//
//  DataRowCell.swift
//  opendata
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import UIKit
import SDWebImage

class DataRowCell: UITableViewCell {
  
  @IBOutlet weak var cover: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var desc: UILabel!
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setEntity(entity: ResultEntity) {
    title.text = entity.stitle
    desc.text = entity.xbody

    if let file = entity.files.first {
      let url = NSURL(string: file)
      cover.sd_setImageWithURL(url, placeholderImage: UIImage(named:"logo"))
      
    }

  }
}
