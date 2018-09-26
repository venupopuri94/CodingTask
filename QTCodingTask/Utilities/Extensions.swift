//
//  QTExtensions.swift
//  QTCodingTask
//
//  Created by Venu on 24/09/18.
//  Copyright © 2018 Venu. All rights reserved.
//

import Foundation
import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate

// MARK: - NSObject

public extension NSObject {
    
    public class var nameOfClass: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    
    public var nameOfClass: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
    func deallocMessage() -> String {
        
        return "Dealloc Called in \(nameOfClass)"
    }
    
    func showLog(logMessage: Any?) {
        print(logMessage ?? "")
    }
    
    func showAlertviewController(titleName: String = String(), messageName: String, cancelButtonTitle: String = "OK", otherButtonTitles: [String] = [], selectionHandler: ((Int) -> Void)? = nil) {
        let titleString = NSLocalizedString(titleName.isEmpty ? "Notice!" : titleName, comment: "")
        let alertController = UIAlertController(title: titleString, message: NSLocalizedString(messageName, comment: ""), preferredStyle: .alert)
        let alertActionOk = UIAlertAction(title: NSLocalizedString(cancelButtonTitle, comment: ""), style: .cancel, handler: { alert in
            
            selectionHandler?(alertController.actions.index(of: alert)!)
        })
        otherButtonTitles.forEach {
            
            let alertAction = UIAlertAction(title: NSLocalizedString($0, comment: ""), style: .default, handler: { alert in
                selectionHandler?(alertController.actions.index(of: alert)!)
            })
            alertController.addAction(alertAction)
            
        }
        
        alertController.addAction(alertActionOk)
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        
    }
    
}

// MARK: - UIApplication
extension UIApplication {
    
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}

extension UIViewController {
    
    func showGlobalHUD () {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: appDelegate.window!, animated: true)
            MBProgressHUD.showAdded(to: appDelegate.window!, animated: true)
        }
    }
    
    func dismissGlobalHUD () {
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: appDelegate.window!, animated: true)
            
        }
    }
    
    func isNetworkReachable() -> Bool {
        
        return appDelegate.reachabilityManager?.isReachable ?? false
    }
    
    func showNoNetworkAlert() {
        
        self.showAlertviewController(titleName: "no_network", messageName: "no_network_msg", cancelButtonTitle: "settings", otherButtonTitles: ["cancel"], selectionHandler: {
            if $0 == 1 {
                
                guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
                    return //be safe
                }
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
            }
        })
    }
    
    
}

extension Dictionary {
    
    mutating func mergeAnotherDictionary(other: Dictionary) {
        for (key, value) in other {
            self.updateValue(value, forKey: key)
        }
    }
}

extension Date {
    
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: self)
    }
}

extension UIView {
    
    func loadXib() {
        let viewfromXib = Bundle.main.loadNibNamed(self.nameOfClass, owner: self, options: nil)?[0] as! UIView
        
        viewfromXib.frame = self.bounds
        self.addSubview(viewfromXib)
    }
}
