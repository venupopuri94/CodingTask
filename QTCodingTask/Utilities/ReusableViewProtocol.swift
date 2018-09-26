//
//  ReusableTableViewProtocol.swift
//  Revestar
//
//  Created by Rajesh Kollipara on 5/11/17.
//  Copyright © 2017 com.sparity. All rights reserved.
//

import Foundation
import UIKit

protocol Reusable {
    
}
extension Reusable where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UIView: Reusable {}

extension UITableView {
    
    func register<T: UITableViewCell>(_ :T.Type) where T: Reusable {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerNib<T: UITableViewCell>(_ :T.Type) where T: Reusable {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not deque cell")
        }
        return cell
    }
}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerNib<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerHeaderView<T: UICollectionReusableView>(_: T.Type) where T: Reusable {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: T.reuseIdentifier)
    }
    
    func registerFooterView<T: UICollectionReusableView>(_: T.Type) where T: Reusable {
        register(UINib(nibName: T.reuseIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableHeader<T: UICollectionReusableView>(forIndexPath indexPath: IndexPath, kind: String) -> T where T: Reusable {
        
        guard let headerView = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
            
        }
        return headerView
    }
}
