//
//  Plan.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import UIKit

struct Plan {
  let id: Int
  let name: String
  let notes: String
  let start: Date
  let end: Date
  
  let patient: Patient

  let exercises: [Exercise]
  
  init(id: Int, name: String, notes: String, start: Date, end: Date, patient: Patient, exercises: [Exercise]) {
    self.id = id
    self.name = name
    self.notes = notes
    self.start = start
    self.end = end
    self.patient = patient
    self.exercises = exercises
  }
  
  init?(json: [String: Any]) {
    guard let id = json["id"] as? Int, let name = json["name"] as? String, let notes = json["description"] as? String else {
      return nil
    }
    
    guard let startRawValue = json["start"] as? String, let start = Date(ISO8601: startRawValue) else {
      return nil
    }
    
    guard let endRawValue = json["end"] as? String, let end = Date(ISO8601: endRawValue) else {
      return nil
    }
    
    guard let patientJson = json["patient"] as? [String: Any], let patient = Patient(json: patientJson) else {
      return nil
    }
    
    self.id = id
    self.name = name
    self.notes = notes
    self.start = start
    self.end = end
    
    self.patient = patient
    
    var exercises: [Exercise] = []
    
    if let excerciesJsonCollection = json["exercises"] as? [[String: Any]] {
      for jsonExercise in excerciesJsonCollection {
        if let exercise =  Exercise(json: jsonExercise) {
          exercises.append(exercise)
        }
      }
    }
    
    self.exercises = exercises
  }
}

extension Plan: Equatable {
  static func == (_ lhs: Plan, _ rhs: Plan) -> Bool {
    return lhs.id == rhs.id
  }
}
