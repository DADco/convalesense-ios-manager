//
//  Patient.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 27/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import Foundation

struct Patient {
  let id: Int
  let name: String
  
  init?(json: [String: Any]) {
    guard let id = json["id"] as? Int,
      let name = json["name"] as? String else {
        return nil
    }
    
    self.id = id
    self.name = name
  }
  
  init(id: Int, name: String) {
    self.id = id
    self.name = name
  }
}

extension Patient: Equatable {
  static func == (_ lhs: Patient, _ rhs: Patient) -> Bool {
    return lhs.id == rhs.id
  }
}
