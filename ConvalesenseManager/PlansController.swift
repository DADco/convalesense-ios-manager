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
          if let firstPlan = plans.first {
            self.currentPlan = firstPlan
          } else {
            self.currentPlan = nil
          }
          
          if plans.count > 1 {
            self.previousPlans = Array(plans.dropFirst(1))
          } else {
            self.previousPlans = []
          }
          
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
    //navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "LakkiReddy", size: 20)!]

    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(refersh(_:)), for: .valueChanged)
    tableView.refreshControl = refreshControl
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 106
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
  
  @IBOutlet var patientNameLabel: UILabel!
  @IBOutlet var dateIntervalLabel: UILabel!
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var notesLabel: UILabel!
  @IBOutlet var exercisesLabel: UILabel!
  
  func configure(with plan: Plan) {
    patientNameLabel.text = plan.patient.name
    let dateIntervalFormatter = DateIntervalFormatter()
    dateIntervalLabel.text = dateIntervalFormatter.string(from: plan.start, to: plan.end)
    nameLabel.text = plan.name
    notesLabel.text = plan.notes
    exercisesLabel.text = "Exercises: \(plan.exercises.count)"
  }
}
