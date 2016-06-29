//
//  UIImageExt.swift
//  opendata
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import UIKit

extension UIImage {
  
  var circle: UIImage {
    let square = size.width < size.height ? CGSize(width: size.width, height: size.width) : CGSize(width: size.height, height: size.height)
    let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.image = self
    imageView.layer.cornerRadius = square.width/2
    imageView.layer.masksToBounds = true
    
    // UIGraphicsBeginImageContext(imageView.bounds.size)
    // 這樣改圖才不會糊
    UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0)
    let context = UIGraphicsGetCurrentContext()!
    imageView.layer.renderInContext(context)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result
  }

}