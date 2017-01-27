//
//  GameController.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import UIKit
import CoreBluetooth
import AudioToolbox

class MakeItRainController: UIViewController, APISessionConsumer {
  @IBOutlet var imageView: UIImageView!
  
  var peripheralScanner: PeripheralScanner!
  
  var exercise: Exercise!
  
  var isFinished: Bool = false
  
  var apiSession: APISession!
  
  var start: Date?
  var end: Date?
  
  var tapCount: Int = 0 {
    didSet(oldValue) {
      let change = tapCount - oldValue
      
      for _ in 0..<change {
        addRainDrop()
      }
      
      tapCountDidChange()
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    navigationItem.titleView = UIImageView(image:#imageLiteral(resourceName: "convalesense"))
    navigationItem.setHidesBackButton(true, animated: false)
  }
  
  deinit {
    peripheralScanner = nil
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    peripheralScanner = PeripheralScanner()
    peripheralScanner.service = .tap
    peripheralScanner.delegate = self
    
    start = Date()

  }
  
  func updateTapCount(_ tapCount: Int) {
    guard isFinished == false else {
      return
    }
    
    guard tapCount > self.tapCount else {
      return
    }
    
    guard tapCount < exercise.repetitions! else {
      self.tapCount = exercise.repetitions!
      finish()
      return
    }
    
    self.tapCount = tapCount
  }
  
  func tapCountDidChange() {
    let completeRatio = Float(tapCount) / Float(exercise.repetitions!)
    if completeRatio < 0.1 {
      if imageView.image != #imageLiteral(resourceName: "plant 1") {
        imageView.image = #imageLiteral(resourceName: "plant 1")
        playPlantGrowSound()
      }
    } else if completeRatio < 0.3 {
      if imageView.image != #imageLiteral(resourceName: "plant 2") {
        imageView.image = #imageLiteral(resourceName: "plant 2")
        playPlantGrowSound()
      }
    } else if completeRatio < 0.4 {
      if imageView.image != #imageLiteral(resourceName: "plant 3") {
        imageView.image = #imageLiteral(resourceName: "plant 3")
      }
    } else if completeRatio < 0.6 {
      if imageView.image != #imageLiteral(resourceName: "plant 4") {
        imageView.image = #imageLiteral(resourceName: "plant 4")
      }
    } else if completeRatio < 0.8 {
      if imageView.image != #imageLiteral(resourceName: "plant 5") {
        imageView.image = #imageLiteral(resourceName: "plant 5")
      }
    } else {
      imageView.image = #imageLiteral(resourceName: "plant 6")
    }
  }
  
  func finish() {
    end = Date()
    isFinished = true
    peripheralScanner = nil
    performSegue(withIdentifier: "Finished", sender: self)
    
    guard let start = start, let end = end else {
      return
    }
    
    apiSession.finish(excercise: exercise, count: tapCount, start: start, end: end) { (error) in
      
    }
  }
  
  func playPlantGrowSound() {
    let filename = "PlantGrow"
    let ext = "mp3"
    
    if let soundUrl = Bundle.main.url(forResource: filename, withExtension: ext) {
      var soundId: SystemSoundID = 0
      
      AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
      
      AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
        AudioServicesDisposeSystemSoundID(soundId)
      }, nil)
      
      AudioServicesPlaySystemSound(soundId)
    }
  }
  
  func playRainDropSound() {
    let filename = "RainDrop"
    let ext = "wav"
    
    if let soundUrl = Bundle.main.url(forResource: filename, withExtension: ext) {
      var soundId: SystemSoundID = 0
      
      AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundId)
      
      AudioServicesAddSystemSoundCompletion(soundId, nil, nil, { (soundId, clientData) -> Void in
        AudioServicesDisposeSystemSoundID(soundId)
      }, nil)
      
      AudioServicesPlaySystemSound(soundId)
    }
  }
  
  func addRainDrop() {
    let raindropImageView = UIImageView(image: #imageLiteral(resourceName: "raindrop"))
    raindropImageView.frame = CGRect(x: CGFloat(arc4random_uniform(UInt32(view.frame.size.width))), y: -raindropImageView.image!.size.height, width: raindropImageView.image!.size.width, height: raindropImageView.image!.size.height)
    view.addSubview(raindropImageView)
    
    UIView.animate(withDuration: TimeInterval(arc4random_uniform(3) + 1), delay: 0, options: .curveEaseIn, animations: {
      raindropImageView.frame.origin.y = self.view.frame.size.height
    }) { (_) in
      raindropImageView.removeFromSuperview()
      self.playRainDropSound()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if var apiSessionConsumer = segue.destination as? APISessionConsumer {
      apiSessionConsumer.apiSession = apiSession
    }
  }
}

extension MakeItRainController: PeripheralScannerDelegate {
  func peripheralScanner(_ peripheralScanner: PeripheralScanner, peripheralDidChange peripheral: CBPeripheral) {
  }
  
  func peripheralScanner(_ peripheralScanner: PeripheralScanner, didReceiveInfo info: [String: AnyObject]) {
    guard let tapCount = info["tapCount"] as? Int else {
      return
    }
    
    DispatchQueue.main.async {
      self.updateTapCount(tapCount)
    }
  }
}
