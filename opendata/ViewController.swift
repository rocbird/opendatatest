//
//  ViewController.swift
//  opendata
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import UIKit
import SVPullToRefresh

class ViewController: UIViewController {

  @IBOutlet weak var mask: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var filterTop: NSLayoutConstraint!
  @IBOutlet weak var filter: UILabel!
  var filterIsShown = false
  weak var vcFilter: CategoryViewController?
  
  var provider: ViewProvider!

  var syncTask: AsyncTask!
  var reloadAction: Action!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  
    provider = ViewProvider()
    
    var nib = UINib(nibName: "SectionHeaderView", bundle: nil)
    tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "header")
    nib = UINib(nibName: "DataRowCell", bundle: nil)
    tableView.registerNib(nib, forCellReuseIdentifier: "cell")
    
    tableView.estimatedRowHeight = 120
    tableView.rowHeight = UITableViewAutomaticDimension

    syncTask = provider.synchronize

    reloadAction = syncTask |>| switchToMainThread |>| {
      [weak self] () -> () in
      
      if let strongSelf = self {
        strongSelf.tableView.pullToRefreshView.stopAnimating()
        strongSelf.tableView.reloadData()
      }
    }

    tableView.addPullToRefreshWithActionHandler {
      [weak self] in
      
      self?.reloadAction()
    }

    self.reloadAction()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "embedFilter" {
      vcFilter = segue.destinationViewController as? CategoryViewController
      vcFilter?.delegate = self
    }
  }

}

extension ViewController {
  @IBAction func showFilter(sender: AnyObject) {
    if provider.items.count == 0 {
      return
    }
    if filterIsShown {
      hideFilter(sender)
    }
    else {
      if vcFilter?.items.count == 0 {
        var items = provider.allSections()
        items.insert("所有分類", atIndex: 0)
        vcFilter?.items = items
        vcFilter?.tableView.reloadData()
      }
      UIView.animateWithDuration(1, animations: {
        self.mask.hidden = false
        self.filterTop.constant = 0
        }, completion: { _ in
          self.filterIsShown = true
      })
    }
  }
  @IBAction func hideFilter(sender: AnyObject) {
    UIView.animateWithDuration(1, animations: { 
      self.mask.hidden = true
      self.filterTop.constant = -284
      }) { _ in
        self.filterIsShown = false
    }

  }
  
}
extension ViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 44
  }
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("header") as! SectionHeaderView
    header.title.text = provider.titleOfSection(section)
    return header
  }
  
}

extension ViewController: UITableViewDataSource {
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return provider.numberOfSections()
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return provider.numberOfRowsInSection(section)
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DataRowCell
    if let item = provider.itemAtIndexPath(indexPath) {
      cell.setEntity(item)
    }
    return cell
  }
}

extension ViewController: CategoryViewDelegate {
  func didSelectCategory(category: String) {
    hideFilter(self)
    filter.text = category
    if category != "所有分類" {
      provider.filter = category
    }
    else {
      provider.filter = nil
    }
    tableView.reloadData()
    tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0) , atScrollPosition: UITableViewScrollPosition.Top, animated: true)
  }
}