//
//  ViewController.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    let child = SpinnerViewController()
    
    var tweets: [Tweet] = []
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
//        Clear defaults for testing
//        resetDefaults()
        
        if Defaults.get() != nil{
            tweets = Defaults.get()!
        } else{
            showLoadingSpinner()
            download()
            hideLoadingSpinner()
        }
        
        tableView.reloadData()
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
    
       @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
           switch segmentedControl.selectedSegmentIndex {
           case 0:
               tweets = tweets.sorted(by: { $0.from.lowercased() < $1.from.lowercased() })
           case 1:
               tweets = tweets.sorted(by: { $0.message.count < $1.message.count })
           default:
                tweets = tweets.sorted(by: { $0.timestamp > $1.timestamp })
           }
           tableView.reloadData()
       }
}

//MARK: - Networking & others
extension ViewController{
    
    func download(){
        Networking.download { [weak self] downloadedTweets in
            self?.tweets = downloadedTweets

            Defaults.store(downloadedTweets)

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
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "generalCell") as? TableViewCell
        cell?.nameLabel.text = tweets[indexPath.row].from
        cell?.handlerLabel.text = tweets[indexPath.row].handler
        
        if let intervalData = TimeInterval(tweets[indexPath.row].timestamp){
            cell?.dataLabel.text = getReadableDate(timeStamp: intervalData)
        }
        
        let textData = Symbols.detectSymbols(text: tweets[indexPath.row].message)
        cell?.messageLabel.attributedText = textData
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableViewCell
        
        if let viewController = storyboard?.instantiateViewController(identifier: "SecondViewController") as? SecondViewController {
            viewController.name = cell.nameLabel.text ?? ""
            viewController.handler = cell.handlerLabel.text ?? ""
            viewController.data = cell.dataLabel.text ?? ""
            viewController.message = cell.messageLabel.text ?? ""
            
            navigationController?.pushViewController(viewController,animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK:- UITableViewCell
class TableViewCell: UITableViewCell{
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handlerLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
}
