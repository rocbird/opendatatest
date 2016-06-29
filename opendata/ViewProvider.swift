//
//  ViewProvider.swift
//  opendata
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import Foundation

extension CollectionType where Generator.Element : Hashable {
  func distinct() -> [Generator.Element] {
    return Array(Set(self))
  }
}

class ViewProvider: Synchronizable {
  typealias Element = ResultEntity
  
  private(set) var items = [String:[Element]]()

  private var offset = 0
  private var limit = 10
  
  var filter: String?
  deinit {
    print("deinit - \(#file)")
  }
  func synchronize(complete: Action) {
    
    APIClient.sharedInstance.requestTaipeiTravelPoi(offset, limit: limit) {
      [weak self] (items: [ResultEntity]?, error: NSError?) in
      
      if let e = error {
        debugPrint(e)
      }
      else {
        if let strongSelf = self, items = items {
          
          let sections = items.map({$0.cat2}).distinct()
          
          for section in sections {
            strongSelf.items[section] = items.filter({$0.cat2 == section})
          }
        }
      }
      
      complete()
      
    }
  }
  
  func numberOfSections() -> Int {
    if let _ = self.filter {
      return 1
    }

    return items.keys.count
  }
  func numberOfRowsInSection(section: Int) -> Int {
    if let filter = self.filter {
      return items[filter]?.count ?? 0
    }
    let key = Array(items.keys)[section]
    return items[key]?.count ?? 0
  }
  func titleOfSection(section: Int) -> String {
    if let filter = self.filter {
      return filter
    }
    return Array(items.keys)[section]
  }
  func itemAtIndexPath(indexPath: NSIndexPath) -> ResultEntity? {
    if let filter = self.filter {
      return items[filter]?[indexPath.row]
    }
    let key = Array(items.keys)[indexPath.section]
    return items[key]?[indexPath.row]
  }
  func allSections() -> [String] {
    return Array(items.keys)
  }
}