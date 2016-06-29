//
//  Synchronizable.swift
//  opendata
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import Foundation

infix operator |>| { associativity left precedence 140 }

typealias Action = () -> Void
typealias AsyncTask = (Action) -> Void

func |>|(lhs: AsyncTask, rhs: Action) -> AsyncTask {
  return { (action) -> Void in
    lhs { rhs(); action() }
  }
}
func |>|(lhs: AsyncTask, rhs: Action) -> Action {
  return {
    lhs { rhs(); }
  }
}
func |>|(lhs: AsyncTask, rhs: AsyncTask) -> AsyncTask {
  return { (action) -> Void in
    lhs { rhs(action); }
  }
}

let switchToMainThread: AsyncTask = {
  (action) -> Void in
  dispatch_async(dispatch_get_main_queue(), action)
}

protocol Synchronizable {
  func synchronize(complete: Action)
}
