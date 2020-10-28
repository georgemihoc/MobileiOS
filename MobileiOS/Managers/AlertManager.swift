//
//  AlertManager.swift
//  MobileiOS
//
//  Created by George on 28/10/2020.
//

import Foundation
import BRYXBanner

class AlertManager {
    static let manager = AlertManager()
    
    private init() {}
    
    func showBannerNotification(title: String, message: String) {
        let banner = Banner(title:title, subtitle: message, backgroundColor: #colorLiteral(red: 0.2745098174, green: 0.5949271219, blue: 0.1411764771, alpha: 1))
        banner.dismissesOnTap = true
        banner.show(duration: 3.0)
    }
    
}
