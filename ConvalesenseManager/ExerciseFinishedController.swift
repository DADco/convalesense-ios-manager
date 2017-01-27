//
//  ExerciseFinishedController.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import UIKit

class ExerciseFinishedController: UIViewController {
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    navigationItem.titleView = UIImageView(image:#imageLiteral(resourceName: "convalesense"))
    navigationItem.setHidesBackButton(true, animated: false)
    
    modalTransitionStyle = .crossDissolve
    modalPresentationStyle = .overFullScreen
  }
  
  @IBAction func done(_ sender: AnyObject) {
    _ = navigationController?.popToRootViewController(animated: true)
  }
}
