//
//  ResultEntity.swift
//  poi
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import Foundation
import ObjectMapper
import MapKit

class ResultEntity: Mappable {
  var id: Int? = 0
  var rowNumber = 0
  var refWP = 0
  var cat1 = ""
  var cat2 = ""
  var serialNo = ""
  var memoTime = ""
  var stitle = ""
  var xbody = ""
  var avBegin: NSDate?
  var avEnd: NSDate?
  var idpt = ""
  var address = ""
  var xpostDate: NSDate?
  var files = [String]()
  var langinfo = 0
  var poi = true
  var info = ""
  var location = kCLLocationCoordinate2DInvalid
  var MRT = ""
  
  required convenience init?(_ map: Map) {
    self.init()
  }
  
  func mapping(map: Map) {
    id <- map["id"]
    rowNumber <- map["RowNumber"]
    refWP <- map["REF_WP"]
    cat1 <- map["CAT1"]
    cat2 <- map["CAT2"]
    serialNo <- map["SERIAL_NO"]
    memoTime <- map["MEMO_TIME"]
    stitle <- map["stitle"]
    xbody <- map["xbody"]
    
    avBegin <- (map["avBegin"], DateTransform())
    avEnd <- (map["avEnd"], DateTransform())
    
    idpt <- map["idpt"]
    address <- map["address"]
    xpostDate <- (map["xpostDate"], DateTransform())
    
    var file = ""
    file <- map["file"]
    
    let urls = file.componentsSeparatedByString("http://")
    for url in urls {
      if url.isEmpty {
        continue
      }
      files.append("http://\(url)")
    }
    
    langinfo <- map["langinfo"]
    poi <- map["POI"]
    info <- map["info"]
    
    var longitude = 0.0
    longitude <- map["longitude"]
    
    var latitude = 0.0
    latitude  <- map["latitude"]
    
    location = CLLocationCoordinate2DMake(longitude, latitude)
    MRT <- map["MRT"]
  }
  
  
}