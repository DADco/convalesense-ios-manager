//
//  PlanController.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import UIKit

class PlanController: UITableViewController, APISessionConsumer {
  var plan: Plan!
  var apiSession: APISession!
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    title = "Session"
  }
    
  func reloadData() {
    if isViewLoaded {
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return plan.exercises.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseTableViewCell.reuseIdentifier, for: indexPath) as! ExerciseTableViewCell
    let exercise = plan.exercises[indexPath.row]
    cell.configure(with: exercise)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let exercise = plan.exercises[indexPath.row]
    performSegue(withIdentifier: "MakeItRain", sender: exercise)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "MakeItRain", let exercise = sender as? Exercise, let destination = segue.destination as? MakeItRainController {
      destination.exercise = exercise
    }
    
    if var apiSessionConsumer = segue.destination as? APISessionConsumer {
      apiSessionConsumer.apiSession = apiSession
    }
  }
}

class ExerciseTableViewCell: UITableViewCell {
  static let reuseIdentifier: String = "ExerciseTableViewCell"
  
  @IBOutlet var nameLabel: UILabel!
  
  func configure(with exercise: Exercise) {
    nameLabel.text = exercise.name
  }
}
