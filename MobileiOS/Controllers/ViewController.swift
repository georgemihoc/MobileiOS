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
import SwipeCellKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let child = SpinnerViewController()
    
//    var items: [Item] = []
    var notes: [Note] = []
    private var filtered: [Note] = []
    private var searchActive : Bool = false
    
    @IBOutlet weak var searchController: UISearchBar!
    var timer, timer2: Timer?
    @IBOutlet weak var internetStatusLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
//    private var socketService = SocketService<MessageObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        tableView.refreshControl = UIRefreshControl()
        
//        Clear defaults for testing
//        Defaults.manager.resetDefaults()
        
        getUIReady()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        checkConnection()
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        Defaults.manager.resetToken()
        Defaults.manager.resetDefaults()
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
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkConnection), userInfo: nil, repeats: true)
        
        usernameLabel.text = Defaults.manager.getCurrentUsername()
    }
    
}

//MARK: - Networking & others
extension ViewController{
    
    @objc func download(){
        IHProgressHUD.show()
        Networking.shared.download { [weak self] downloadedItems in
            guard let strongSelf = self else { return }
            print(downloadedItems)
            let downloadedItemsSorted = downloadedItems.sorted { !$0.completed && $1.completed }
            strongSelf.notes = downloadedItemsSorted
            
            // reset defaults before downloading
            Defaults.manager.resetDefaults()
            Defaults.store(downloadedItemsSorted)
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
            if notes[indexPath.row].completed {
                cell?.textLabel?.attributedText = notes[indexPath.row].text.strikeThrough()
                cell?.textLabel?.textColor = .systemGray
            } else {
                cell?.textLabel?.attributedText = nil
                cell?.textLabel?.textColor = .label
                cell?.textLabel?.text = notes[indexPath.row].text
            }
        } else {
            if filtered[indexPath.row].completed {
                cell?.textLabel?.attributedText = filtered[indexPath.row].text.strikeThrough()
                cell?.textLabel?.textColor = .systemGray
            } else {
                cell?.textLabel?.attributedText = nil
                cell?.textLabel?.textColor = .label
                cell?.textLabel?.text = filtered[indexPath.row].text
            }
        }
        
        return cell!
    }
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
//            // delete item at indexPath
//            print("DELETE")
//        }
//
//        return [delete]
//    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var updatedNote: Note?
        if !self.searchActive {
            updatedNote = self.notes[indexPath.row]
        } else {
            updatedNote = self.filtered[indexPath.row]
        }
        
        guard var safeUpdatedNote = updatedNote else { return nil }
        var title: String?
        if !safeUpdatedNote.completed {
            title = "Complete"
        } else {
            title = "Restore"
        }
        if tableView.cellForRow(at: indexPath) != nil {
            let delete = UIContextualAction(style: .normal, title: title) { (action, view, nil)  in
                
                safeUpdatedNote.completed = !safeUpdatedNote.completed
            
                Networking.shared.updateNote(note: safeUpdatedNote)
                let seconds = 0.2
                IHProgressHUD.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.download()
                    IHProgressHUD.dismiss()
                }
                
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }
       
        return nil
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if tableView.cellForRow(at: indexPath) != nil {
            let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil)  in
                
                var updatedNote: Note?
                if !self.searchActive {
                    updatedNote = self.notes[indexPath.row]
                } else {
                    updatedNote = self.filtered[indexPath.row]
                }
                
                guard let safeUpdatedNote = updatedNote else { return }
                
                // Delete item from server
                Networking.shared.deleteNote(note: safeUpdatedNote)
                // Remove also the Firebase picture
                DatabaseManager.manager.deletePreviousPicture(itemId: safeUpdatedNote._id)
                            
                let seconds = 0.2
                IHProgressHUD.show()
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.download()
                    IHProgressHUD.dismiss()
                }
            }
            return UISwipeActionsConfiguration(actions: [delete])
        }
       
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let viewController = storyboard?.instantiateViewController(identifier: ViewControllerNames.secondViewController) as? SecondViewController {
            if !searchActive {
                viewController.name = notes[indexPath.row].text
                viewController.data = notes[indexPath.row].userId
                viewController.itemId = notes[indexPath.row]._id
            } else {
                viewController.name = filtered[indexPath.row].text
                viewController.data = filtered[indexPath.row].userId
                viewController.itemId = filtered[indexPath.row]._id
            }
            
            navigationController?.pushViewController(viewController,animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Cell Animation
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.6) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    //MARK: -  Pull to refresh users table
    @objc func refresh(sender: AnyObject)
    {
//        self.socketService = SocketService<MessageObject>()
        listenToWebSocket()
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
            
            let seconds = 0.2
            IHProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.download()
                IHProgressHUD.dismiss()
            }
        }

        //Step : 3
        //For first TF
        alert.addTextField { (textField) in
            textField.placeholder = "Enter text"
            textField.autocapitalizationType = .sentences
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

//MARK: - Offline support & network status
extension ViewController{
    @objc func checkConnection() {
        if Reachability.isConnectedToNetwork() {
            internetStatusLabel.text = "Online"
            internetStatusLabel.textColor = UIColor.green
            print("Network status: CONNECTED")
            
            guard let offlineNotes = Defaults.manager.getOfflineAddedItems() else { return }
            if offlineNotes.count > 0 {
                Networking.shared.uploadOfflineAddedItems(items: offlineNotes)
                AlertManager.manager.showGeneralAlert(currentViewController: self, title: "Upload Succesful", message: "Uploaded \(offlineNotes.count) offline added items to the server")
                Defaults.manager.resetDefaults()
                download()
//                AlertManager.manager.showBannerNotification(title: "Uploaded successfully", message: "Offline items added to server")
            }
            
            //        if toBeSent.count > 0 {
            //            for item in toBeSent {
            //                viewModel.postOrder(order: item)
            ////                    orderTableView.reloadData()
            //            }
            //            toBeSent.removeAll()
            //        }
        } else {
            internetStatusLabel.text = "Disconnected"
            internetStatusLabel.textColor = UIColor.red
            print("Network status: DISCONNECTED")
        }
    }
}

//MARK: - String extensios
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(
            NSAttributedString.Key.strikethroughStyle,
               value: NSUnderlineStyle.single.rawValue,
                   range:NSMakeRange(0,attributeString.length))
        return attributeString
    }
}
