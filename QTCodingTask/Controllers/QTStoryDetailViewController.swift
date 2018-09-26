//
//  QTStoryDetailViewController.swift
//  QTCodingTask
//
//  Created by Venu on 26/09/18.
//  Copyright © 2018 Venu. All rights reserved.
//

import UIKit

class QTStoryDetailViewController: UIViewController {

    @IBOutlet weak var imageViewStory: UIImageView!
    private var imageUrl: URL!
    
    init(imageUrl: URL) {
        super.init(nibName: nil, bundle: nil)
        self.imageUrl = imageUrl
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imageViewStory.kf.setImage(with: self.imageUrl,
                                   placeholder: #imageLiteral(resourceName: "placeholder"),
                                   progressBlock: nil,
                                   completionHandler: nil)
        /*
         DispatchQueue.global().async {
            let data = try? Data(contentsOf: self.imageUrl) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                self.imageViewStory.image = UIImage(data: data!)
            }
        }
         */

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
