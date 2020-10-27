//
//  Symbols.swift
//  NetworkingTask
//
//  Created by George on 30/07/2020.
//  Copyright © 2020 George. All rights reserved.
//

import UIKit

class Symbols{
    
    static func detectSymbols(text: String) -> NSMutableAttributedString {
        
        let stringConstruction = NSMutableAttributedString()
        let text = text.replacingOccurrences(of: "#", with: " #")
        let words = text.components(separatedBy: " ")
        let attrs = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor : UIColor.gray] as [NSAttributedString.Key : Any]
        for word in words{
            if word.hasPrefix("#"){
                let attrs1 = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor : UIColor.blue] as [NSAttributedString.Key : Any]

                let attributedString1 = NSMutableAttributedString(string:word, attributes:attrs1)
                
                stringConstruction.append(attributedString1)
                
            }
            else if word.hasPrefix("@"){
                let attrs1 = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20), NSAttributedString.Key.foregroundColor : UIColor.blue] as [NSAttributedString.Key : Any]

                let attributedString1 = NSMutableAttributedString(string:word, attributes:attrs1)
                
                stringConstruction.append(attributedString1)
            }
            else{
                stringConstruction.append(NSMutableAttributedString(string: word, attributes: attrs))
            }
            stringConstruction.append(NSMutableAttributedString(string: " "))
        }
        
        return stringConstruction
    }
}
