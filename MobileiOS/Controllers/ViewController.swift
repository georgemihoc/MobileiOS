//
//  ViewController.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import UIKit
import Starscream
import BRYXBanner

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let child = SpinnerViewController()
    
    var items: [Item] = []
    
    private let socketService = SocketService<MessageObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = UIRefreshControl()
        
        //        Clear defaults for testing
        //        resetDefaults()
        
        getUIReady()
        fetchData()
        
        listenToWebSocket()
        
    }
    
    private func listenToWebSocket() {
        socketService.didRecieveObject = {[weak self] object in
            guard let strongSelf = self else { return }
            strongSelf.items.append(object.payload.item)
            strongSelf.tableView.reloadData()
            
            AlertManager.manager.showBannerNotification(title: "New item received", message: object.payload.item.text)
            strongSelf.tableView.flashScrollIndicators()
        }
    }
}

//MARK: - UI Controls
extension ViewController{
    func showLoadingSpinner(){
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func hideLoadingSpinner(){
        // aici ascund spinner-ul, am pus 2 secunde ca sa fie vizibil
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.child.willMove(toParent: nil)
            self.child.view.removeFromSuperview()
            self.child.removeFromParent()
        }
    }
    
}

//MARK: - Networking & others
extension ViewController{
    
    func download(){
        Networking.download { [weak self] downloadedItems in
            self?.items = downloadedItems
            
            //            Defaults.store(downloadedItems)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func getReadableDate(timeStamp: TimeInterval) -> String? {
        let date = Date(timeIntervalSince1970: timeStamp)
        let dateFormatter = DateFormatter()
        
        if Calendar.current.isDateInToday(date){
            let returnString = String(Int((NSDate().timeIntervalSince1970 - timeStamp) / 3600))
            return returnString + "h ago"
        }
        else {
            dateFormatter.dateFormat = "d MMM"
            return dateFormatter.string(from: date)
        }
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalCell")
        cell?.textLabel?.text = items[indexPath.row].text
        cell?.detailTextLabel?.text = formatDate(str: items[indexPath.row].date)
        
        //        print(indexPath.row)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let viewController = storyboard?.instantiateViewController(identifier: "SecondViewController") as? SecondViewController {
            viewController.name = items[indexPath.row].text
            viewController.data = items[indexPath.row].date
            
            navigationController?.pushViewController(viewController,animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: -  Pull to refresh users table
    @objc func refresh(sender: AnyObject)
    {
        download()
        tableView.reloadData()
        tableView.refreshControl?.endRefreshing()
    }
}

extension ViewController {
    func fetchData() {
        if Defaults.get() != nil{
            //            tweets = Defaults.get()!
        } else{
            showLoadingSpinner()
            download()
            hideLoadingSpinner()
        }
        
    }
}

//MARK:- UITableViewCell
class TableViewCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handlerLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
}

extension ViewController {
    
    func getUIReady() {
        // Add pull to refresh functionality to tableview
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        // Add hide keyboard functionality to the view controller
        self.hideKeyboardWhenTappedAround()
    }
}

//MARK: - UIViewController extension for dismissing the keyboard when tapped around
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - Date extension
extension ViewController {
    func formatDate(str: String) -> String{

        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = dateFormatter.date(from: str) {
            return date.description  // "2015-05-15 21:58:00 +0000"
        }
        return ""
    }
}
