//
//  Date+ISO8601.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import Foundation
extension Date {
  /**
   Initalize NSDate with ISO8601 formatted String
   **/
  public init?(ISO8601: String) {
    let dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    let timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.timeZone = timeZone
    if let date = dateFormatter.date(from: ISO8601) {
      self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    } else {
      return nil
    }
  }
  
  /**
   ISO8601 formatted String
   **/
  public var ISO8601: String {
    let dateFormatter = DateFormatter()
    let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = enUSPOSIXLocale
    let timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.timeZone = timeZone
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return dateFormatter.string(from: self)
  }
}
