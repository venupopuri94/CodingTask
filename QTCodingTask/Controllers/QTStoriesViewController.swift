//
//  QTStoriesViewController.swift
//  QTCodingTask
//
//  Created by Venu on 24/09/18.
//  Copyright © 2018 Venu. All rights reserved.
//

import UIKit
import CoreData

final class QTStoriesViewController: UIViewController {

    @IBOutlet weak var tableViewStories: UITableView!
    
    let managedContext = appDelegate.persistentContainer.viewContext
    var arrayCategories = [Category]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = QTConstants.collections
        registerTableView()
        if USER_DEFAULTS.bool(forKey: QTConstants.isAlreadyFetched) {
            fetchCollections()
            fetchStories()
        } else {
            collectionsApi()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    deinit {
        showLog(logMessage: "\(deallocMessage())")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func registerTableView() {
        self.automaticallyAdjustsScrollViewInsets = false
        tableViewStories.registerNib(QTStoryCell.self)
        tableViewStories.separatorStyle = .none
        tableViewStories.estimatedRowHeight = 200
        tableViewStories.rowHeight = UITableViewAutomaticDimension
    }

    private func collectionsApi() {
        getCollections(completion: { status in
            guard status else {
                self.dismissGlobalHUD()
                return
            }
            self.fetchCollections()
           
            let myGroup = DispatchGroup()

            for (index, _) in self.arrayCategories.enumerated() {
                myGroup.enter()
                self.getStories(itemIndex: index, completion: { status in
                    guard status else {
                        self.dismissGlobalHUD()
                        return
                    }
                    myGroup.leave()


                })
            }
            
            myGroup.notify(queue: .main) {
                self.fetchStories()
                self.dismissGlobalHUD()
                USER_DEFAULTS.set(true, forKey: QTConstants.isAlreadyFetched)
                USER_DEFAULTS.set(Date().toString(), forKey: QTConstants.today)
                USER_DEFAULTS.synchronize()
            }

        })
    }
    
    
    // MARK: API Calls
    private func getCollections(completion: @escaping (_ status: Bool) -> (Void)) {
        
        guard isNetworkReachable() else {
            showNoNetworkAlert()
            completion(false)
            return
        }
        showGlobalHUD()
        QTNetworkManager.sharedInstance.performGetMethod(serviceResponse: { (status, response) in
            
            guard status else {
                self.showLog(logMessage: response)
                self.showAlertviewController(messageName: "\(response ?? "")")
                completion(false)
                return
            }
            guard let responseObject = JSON(response ?? [: ]).dictionaryValue[QTConstants.items]?.arrayObject as? [DICTIONARY_STRING_ANY] else {
                completion(false)
                return
            }
            
            let categoryEntity = NSEntityDescription.entity(forEntityName: Category.nameOfClass, in: self.managedContext)!

            responseObject.filter { ($0[QTConstants.type] as? String ?? "") == QTConstants.collection }.forEach {
                let collection = NSManagedObject(entity: categoryEntity, insertInto: self.managedContext)
                collection.setValue($0[QTConstants.id] as? Int64 ?? 0, forKeyPath: QTConstants.id)
                collection.setValue($0[QTConstants.name] as? String ?? "", forKeyPath: QTConstants.name)
                collection.setValue($0[QTConstants.url] as? String ?? "", forKeyPath: QTConstants.url)

                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    completion(false)
                    self.showAlertviewController(messageName: error.localizedDescription)
               }

            }
            completion(true)
            
        })
        
    }
    
    private func getStories(itemIndex: Int, completion: @escaping (_ status: Bool) -> (Void)) {
        
        guard isNetworkReachable() else {
            showNoNetworkAlert()
            completion(false)
            return
        }
        let urlString = arrayCategories[itemIndex].url ?? ""
        
        QTNetworkManager.sharedInstance.performGetMethod(requestURL: urlString, serviceResponse: { (status, response) in
            
            guard status else {
                self.showLog(logMessage: response)
                self.showAlertviewController(messageName: "\(response ?? "")")
                completion(false)
                return
            }
            guard let responseObject = JSON(response ?? [: ]).dictionaryValue[QTConstants.items]?.arrayObject as? [DICTIONARY_STRING_ANY] else {
                completion(false)
                return
            }
            
            let storyItemEntity = NSEntityDescription.entity(forEntityName: StoryItem.nameOfClass, in: self.managedContext)!
            let storyEntity = NSEntityDescription.entity(forEntityName: Story.nameOfClass, in: self.managedContext)!

            responseObject.forEach {
                let storyItem = NSManagedObject(entity: storyItemEntity, insertInto: self.managedContext)
                let story = NSManagedObject(entity: storyEntity, insertInto: self.managedContext)
                
                let storyObject = $0[QTConstants.story] as? DICTIONARY_STRING_ANY ?? [: ]
                
                story.setValue(storyObject[QTConstants.author_name] as? String ?? "", forKeyPath: QTConstants.authorName)
                story.setValue(storyObject[QTConstants.headline] as? String ?? "", forKeyPath: QTConstants.headline)
                story.setValue(storyObject[QTConstants.summary] as? String ?? "", forKeyPath: QTConstants.summary)
                story.setValue(storyObject[QTConstants.hero_image] as? String ?? "", forKeyPath: QTConstants.heroImage)

                
                storyItem.setValue(self.arrayCategories[itemIndex].id, forKeyPath: QTConstants.collectionId)
                storyItem.setValue($0[QTConstants.id] as? String ?? "", forKeyPath: QTConstants.id)
                storyItem.setValue($0[QTConstants.type] as? String ?? "", forKeyPath: QTConstants.type)
                storyItem.setValue(story, forKeyPath: QTConstants.story)

                
                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    completion(false)
                    self.showAlertviewController(messageName: error.localizedDescription)
                }
                
            }
            completion(true)
            
        })
        
    }
    // MARK: Fetch Request

    private func fetchCollections() {
        
        let requestCategory: NSFetchRequest<Category> = Category.fetchRequest()
        requestCategory.returnsObjectsAsFaults = false
        
        do {
            arrayCategories = try managedContext.fetch(requestCategory)
            
        } catch {
            showAlertviewController(messageName: error.localizedDescription)
        }
    }
    
    private func fetchStories() {
        
        let requestStoryItem: NSFetchRequest<StoryItem> = StoryItem.fetchRequest()
        requestStoryItem.returnsObjectsAsFaults = false
        
        do {
            let allItems = try managedContext.fetch(requestStoryItem)
            
            let categoryIds = arrayCategories.map { $0.id }
            categoryIds.forEach { categoryId in
                if let index = arrayCategories.index(where: { $0.id == categoryId }) {
                    arrayCategories[index].items = NSSet(array: allItems.filter { $0.collectionId == categoryId })
                }
            }
            
            
        } catch {
            showAlertviewController(messageName: error.localizedDescription)
        }
        self.tableViewStories.reloadData()
    }

}

// MARK: UITableview Delegate and Datasource
extension QTStoriesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayCategories.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCategories[section].items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getStoryCell(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let storyItem = (arrayCategories[indexPath.section].items)?.allObjects[indexPath.row] as? StoryItem {
            let detailViewController = QTStoryDetailViewController(imageUrl: URL(string: storyItem.story?.heroImage ?? "")!)
            navigationController?.pushViewController(detailViewController, animated: true)

        }

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewHeader = QTHeaderView(frame: CGRect(x: 0, y: 0, width: mainScreenWidth, height: 50))
        viewHeader.backgroundColor = UIColor.red
        viewHeader.labelHeader.text = arrayCategories[section].name
        return viewHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.000001 //removing section footers

    }
    // MARK: Render Cells
    func getStoryCell(indexPath: IndexPath) -> QTStoryCell {
        
        let storyCell = tableViewStories.dequeueReusableCell(forIndexPath: indexPath) as QTStoryCell
        if let storyItem = (arrayCategories[indexPath.section].items)?.allObjects[indexPath.row] as? StoryItem {
            storyCell.setupData(story: storyItem.story)
        }
        
        
        return storyCell
        
    }

}
