//
//  PaginationViewController.swift
//  MobileiOS
//
//  Created by George on 09.12.2020.
//

import UIKit
import PaginatedTableView

class PaginationViewController: UIViewController {

    var list = [Int]()
    
    // Assign custom class to table view in storyboard
    @IBOutlet weak var tableView: PaginatedTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add paginated delegates only
        tableView.paginatedDelegate = self
        tableView.paginatedDataSource = self
        
        // More settings
        tableView.enablePullToRefresh = true
        tableView.pullToRefreshTitle = NSAttributedString(string: "Pull to Refresh")
        
        tableView.loadData(refresh: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
// MARK: Paginated Delegate - Where magic happens
//
extension PaginationViewController: PaginatedTableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func loadMore(_ pageNumber: Int, _ pageSize: Int, onSuccess: ((Bool) -> Void)?, onError: ((Error) -> Void)?) {
        // Call your api here
        // Send true in onSuccess in case new data exists, sending false will disable pagination
        
        // If page number is first, reset the list
        if pageNumber == 1 { self.list = [Int]() }
        
        // else append the data to list
        let startFrom = (self.list.last ?? 0) + 1
        for number in startFrom..<(startFrom + pageSize) {
            self.list.append(number)
        }
        print("Fetching more items")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            onSuccess?(true)
        }
    }
}

//
// MARK: Paginated Data Source
//
extension PaginationViewController: PaginatedTableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalCell")
        cell?.textLabel?.text = "Cell Number: \(self.list[indexPath.row])"
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView.cellForRow(at: indexPath) != nil {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil)  in
                
                self.list.remove(at: indexPath.row)
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }
       
        return nil
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}

//
// MARK: Enable swipe in paginatedTableView
//
extension PaginationViewController {
    
    
    
    

}
