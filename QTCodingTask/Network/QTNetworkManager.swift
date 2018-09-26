//
//  QTNetworkManager.swift
//  QTCodingTask
//
//  Created by Venu on 24/09/18.
//  Copyright © 2018 Venu. All rights reserved.
//

import Foundation
import UIKit

let baseURL                             =       "https://demo9639618.mockable.io/collection"


class QTNetworkManager: NSObject {
    static let sharedInstance: QTNetworkManager = QTNetworkManager()
    
    func performGetMethod(requestURL: String = baseURL, serviceResponse: @escaping (_ status: Bool, _ response: Any?) -> (Void)) {
        
        DispatchQueue.global(qos: .background).async {
            
            let url = NSURL(string: requestURL)
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            let session = URLSession(configuration: sessionConfig)
            let request = NSMutableURLRequest(url: url! as URL)
            request.httpMethod = "GET" //set http method as GET
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                
                
                guard error == nil, let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode   else {
                    DispatchQueue.main.async {
                        serviceResponse(false, self.getResponseFromJSONObject(response: data))
                    }
                    return
                }
                DispatchQueue.main.async {
                    serviceResponse(true, self.getResponseFromJSONObject(response: data))
                }
                
            })
            
            task.resume()
            
        }
    }

    func getResponseFromJSONObject(response: Data?) -> Any? {
        if let jsonResponseData = try? JSON(data: response ?? Data()) {
            switch jsonResponseData.type {
            case .dictionary:
                return jsonResponseData.dictionaryObject
            case .array:
                return jsonResponseData.arrayObject
            case .string:
                return jsonResponseData.stringValue
            default:
                return nil
            }
        }
        return nil
        
    }
}


