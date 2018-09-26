//
//  QTStoryCell.swift
//  QTCodingTask
//
//  Created by Venu on 24/09/18.
//  Copyright © 2018 Venu. All rights reserved.
//

import UIKit

final class QTStoryCell: UITableViewCell {

    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var imageViewStory: UIImageView!
    @IBOutlet weak var labelStoryName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewBorder.layer.cornerRadius = 10.0
        viewBorder.layer.masksToBounds = true
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(story: Story?) {
        /*

        let url = URL(string: story?.heroImage ?? "")
         DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.imageViewStory.image = UIImage(data: data!)
            }
        }
 
         */
        let url = URL(string: story?.heroImage ?? "")
        imageViewStory.kf.setImage(with: url,
                                   placeholder: #imageLiteral(resourceName: "placeholder"),
                                   progressBlock: nil,
                                   completionHandler: nil)

        labelStoryName.text = story?.headline ?? ""
    }

}
