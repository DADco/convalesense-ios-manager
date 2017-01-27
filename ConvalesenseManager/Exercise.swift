//
//  Exercise.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import UIKit

struct Exercise {
  let id: Int
  let name: String
  let notes: String
  let count: Int
  let excerciseType: String
  let repetitions: Int?
  let duration: TimeInterval?
  
  init?(json: [String: Any]) {
    guard let id = json["id"] as? Int,
      let name = json["name"] as? String,
      let notes = json["description"] as? String,
      let count = json["count"] as? Int,
      let excerciseType = json["type"] as? String else {
      return nil
    }
    
    self.id = id
    self.name = name
    self.notes = notes
    self.count = count
    self.excerciseType = excerciseType
    self.repetitions = json["repetitions"] as? Int
    
    if let duartionInt = json["duration"] as? Int {
      duration = TimeInterval(duartionInt)
    } else {
      duration = nil
    }
  }
  
  init(id: Int, name: String, notes: String, count: Int, excerciseType: String, repetitions: Int?, duration: TimeInterval?) {
    self.id = id
    self.name = name
    self.notes = notes
    self.count = count
    self.excerciseType = excerciseType
    self.repetitions = repetitions
    self.duration = duration
  }
}

extension Exercise: Equatable {
  static func == (_ lhs: Exercise, _ rhs: Exercise) -> Bool {
    return lhs.id == rhs.id
  }
}
