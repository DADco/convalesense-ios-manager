//
//  APISession.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 27/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import Foundation

final class APISession {
  let urlSession: URLSession
  
  init() {
    urlSession = URLSession.shared
  }
  
  func fetchPlans(_ completionHandler: @escaping ([Plan]?, Error?) -> Void) {
    let url = URL(string: "http://172.16.8.24:8000/api/plans")!
    let urlRequest = URLRequest(url: url)
    
    let dataTask = urlSession.dataTask(with: urlRequest) { (data, urlResponse, error) in
      if let error = error {
        completionHandler(nil, error)
      } else if let data = data {
        let json = try! JSONSerialization.jsonObject(with: data, options: [])
        
        if let jsonCollection = json as? [[String: Any]] {
          var plans: [Plan] = []
          for jsonPlan in jsonCollection {
            if let plan =  Plan(json: jsonPlan) {
              plans.append(plan)
            }
          }
          
          completionHandler(plans, error)
        }
      }
    }
    
    dataTask.resume()
  }
  
  func finish(excercise: Exercise, count: Int, start: Date, end: Date, _ completionHandler: @escaping (Error?) -> Void) {
    let url = URL(string: "http://172.16.8.24:8000/api/exercise-records/")!
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let jsonObject: [String: Any] = [ "exercise_id": excercise.id, "count": count, "start": start.ISO8601, "end": end.ISO8601 ]
    urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: jsonObject, options: [])
    let dataTask = urlSession.dataTask(with: urlRequest) { (data, urlResponse, error) in
      if let error = error {
        completionHandler(error)
      } else {
        completionHandler(nil)
      }
    }
    
    dataTask.resume()
  }
}
