//
//  PlansController.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import UIKit

class PlansController: UITableViewController, APISessionConsumer {
  var currentPlan: Plan?
  var previousPlans: [Plan] = []
  
  var apiSession: APISession!
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    title = "Plans"
    apiSession = APISession()
    
    currentPlan = Plan(id: 1, name: "name", notes: "notes", start: Date(), end: Date(), exercises: [Exercise(id: 1, name: "Name", notes: "Notes", count: 1, excerciseType: "Finger Strength", repetitions: 20, duration: nil)])
    previousPlans = [Plan(id: 2, name: "Previous", notes: "notes", start: Date(), end: Date(), exercises: [])]
  }
  
  func refersh(_ sender: AnyObject?) {
    refreshData()
  }
  
  func refreshData() {
    apiSession.fetchPlans { (plans, error) in      
      DispatchQueue.main.async {
        if let refreshControl = self.tableView.refreshControl, refreshControl.isRefreshing {
          refreshControl.endRefreshing()
        }
        if let plans = plans {
          self.currentPlan = plans.first!
          self.previousPlans = plans
          
          self.reloadData()
        }
      }
    }
  }
  
  func reloadData() {
    if isViewLoaded {
      tableView.reloadData()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refersh(_:)), for: .valueChanged)
    tableView.refreshControl = refreshControl
    refreshData()
    reloadData()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if let refreshControl = tableView.refreshControl, refreshControl.isRefreshing {
      refreshControl.endRefreshing()
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      if let _ = currentPlan {
        return 1
      } else {
        return 0
      }
    } else {
      return previousPlans.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PlanTableViewCell.reuseIdentifier, for: indexPath) as! PlanTableViewCell
    let plan: Plan
    
    if indexPath.section == 0 {
      plan = currentPlan!
    } else {
      plan = previousPlans[indexPath.row]
    }
    cell.configure(with: plan)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let plan: Plan
    
    if indexPath.section == 0 {
      plan = currentPlan!
    } else {
      plan = previousPlans[indexPath.row]
    }
    
    performSegue(withIdentifier: "PlanController", sender: plan)
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "Current Plan"
    } else {
      return "Previous Plans"
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "PlanController", let plan = sender as? Plan, let destination = segue.destination as? PlanController {
      destination.plan = plan
    }
    
    if var apiSessionConsumer = segue.destination as? APISessionConsumer {
      apiSessionConsumer.apiSession = apiSession
    }
  }
}

class PlanTableViewCell: UITableViewCell {
  static let reuseIdentifier: String = "PlanTableViewCell"
  
  @IBOutlet var dateIntervalLabel: UILabel!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var exercisesLabel: UILabel!
  @IBOutlet var todayLabel: UILabel!
  
  func configure(with plan: Plan) {
    let dateIntervalFormatter = DateIntervalFormatter()
    dateIntervalLabel.text = dateIntervalFormatter.string(from: plan.start, to: plan.end)
    nameLabel.text = plan.name
    exercisesLabel.text = "Exercises \(plan.exercises.count)"
    todayLabel.text = "0 / \(plan.exercises.count)"
  }
}
