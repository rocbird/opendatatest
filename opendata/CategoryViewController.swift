//
//  CategoryViewController.swift
//  opendata
//
//  Created by PengFan Hsieh on 6/29/16.
//  Copyright © 2016 Rocbird. All rights reserved.
//

import UIKit

protocol CategoryViewDelegate: class {
  func didSelectCategory(category: String)
}
class CategoryViewController: UIViewController {

  var lastSelected: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
  weak var delegate: CategoryViewDelegate?
  @IBOutlet weak var tableView: UITableView!
  var items = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CategoryViewController: UITableViewDelegate {
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let cell = tableView.cellForRowAtIndexPath(lastSelected) {
      cell.accessoryType = UITableViewCellAccessoryType.None
    }
    
    if let cell = tableView.cellForRowAtIndexPath(indexPath) {
      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
    lastSelected = indexPath

    if let delegate = self.delegate {
      delegate.didSelectCategory(items[indexPath.row])
    }
  }
}
extension CategoryViewController: UITableViewDataSource{
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
    cell.textLabel?.text = items[indexPath.row]
    if indexPath == lastSelected {
      cell.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
  }
}