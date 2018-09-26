//
//  QTHeaderView.swift
//  QTCodingTask
//
//  Created by Venu on 26/09/18.
//  Copyright © 2018 Venu. All rights reserved.
//

import UIKit

final class QTHeaderView: UIView {

    @IBOutlet weak var labelHeader: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }

}
