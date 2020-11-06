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
import IHProgressHUD

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let child = SpinnerViewController()
    
    var items: [Item] = []
    var notes: [Note] = []
    private var filtered: [Note] = []
    private var searchActive : Bool = false
    
    @IBOutlet weak var searchController: UISearchBar!
    
//    private var socketService = SocketService<MessageObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        tableView.refreshControl = UIRefreshControl()
        
        //        Clear defaults for testing
        //                resetDefaults()
        
        getUIReady()
        fetchData()
    }
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        Defaults.manager.resetToken()
        NavigationManager.manager.navigateToLoginViewController(currentViewController: self)
    }
    
    @IBAction func newItemButtonPressed(_ sender: UIBarButtonItem) {
        alertWithTF()
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
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.child.willMove(toParent: nil)
            self.child.view.removeFromSuperview()
            self.child.removeFromParent()
        }
    }
    
    func getUIReady() {
        // Add pull to refresh functionality to tableview
        self.tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        // Add hide keyboard functionality to the view controller
        self.hideKeyboardWhenTappedAround()
    }
    
}

//MARK: - Networking & others
extension ViewController{
    
    func download(){
        IHProgressHUD.show()
        Networking.shared.download { [weak self] downloadedItems in
            guard let strongSelf = self else { return }
            print(downloadedItems)
            strongSelf.notes = downloadedItems
            
            // reset defaults before downloading
            Defaults.manager.resetDefaults()
            Defaults.store(downloadedItems)
            strongSelf.listenToWebSocket()
            DispatchQueue.main.async {
                strongSelf.tableView.reloadData()
            }
        }
        IHProgressHUD.dismiss()
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
        
    private func listenToWebSocket() {
        SocketService.socketService.didRecieveObject = {[weak self] object in
            guard let strongSelf = self else { return }
            strongSelf.notes.append(object.payload.note)
            strongSelf.tableView.reloadData()
            
//            Defaults.manager.resetDefaults()
//            Defaults.append(object.payload.item)
            
            AlertManager.manager.showBannerNotification(title: "New item received", message: object.payload.note.text)
            strongSelf.tableView.flashScrollIndicators()
            strongSelf.scrollToBottom()
        }
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return filtered.count
        }
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalCell")
        
        if !searchActive {
            cell?.textLabel?.text = notes[indexPath.row].text
            cell?.detailTextLabel?.text = notes[indexPath.row].userId
        } else {
            cell?.textLabel?.text = filtered[indexPath.row].text
            cell?.detailTextLabel?.text = filtered[indexPath.row].userId
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let viewController = storyboard?.instantiateViewController(identifier: ViewControllerNames.secondViewController) as? SecondViewController {
            viewController.name = notes[indexPath.row].text
            viewController.data = notes[indexPath.row].userId
            
            navigationController?.pushViewController(viewController,animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: -  Pull to refresh users table
    @objc func refresh(sender: AnyObject)
    {
//        self.socketService = SocketService<MessageObject>()
        download()
        tableView.refreshControl?.endRefreshing()
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.notes.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension ViewController {
    func fetchData() {
        if Defaults.get() != nil{
            notes = Defaults.get()!
            print("GOT INFO FROM USER DEFAULTS")
        }
        
        download()
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

extension ViewController {
    func alertWithTF() {
        //Step : 1
        let alert = UIAlertController(title: "New Item", message: "", preferredStyle: UIAlertController.Style.alert )
        //Step : 2
        let save = UIAlertAction(title: "Save", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField

            guard let text = textField.text else { return }
            guard text != "" else {
                AlertManager.manager.showAlert(currentViewController: self, message: "Please enter text")
                return
            }
            Networking.shared.createItem(text: text)
        }

        //Step : 3
        //For first TF
        alert.addTextField { (textField) in
            textField.placeholder = "Enter text"
        }

        //Step : 4
        alert.addAction(save)
        //Cancel action
        let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
        alert.addAction(cancel)
        //OR single line action
        //alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })

        self.present(alert, animated:true, completion: nil)

    }
}

//MARK: - SearchBar Controls
extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchActive = false
        } else {
            searchActive = true
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = notes.filter({ (note) -> Bool in
            
            // Search by First name
            let tmp = note.text
            let range = tmp.range(of: searchText, options: .caseInsensitive)
            
            
            return range != nil
        })
        
        if searchBar.text == "" {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
}
