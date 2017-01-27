//
//  PeripheralScanner.swift
//  ConvalesenseManager
//
//  Created by Spencer MacDonald on 26/01/2017.
//  Copyright © 2017 AskDAD Ltd. All rights reserved.
//

import Foundation
import CoreBluetooth

enum PeripheralService: String {
  case accelerometer = "BF5FE877-828E-46A7-962A-3B5C773D6860"
  case tap = "3D3FDA8C-09EC-44F6-97B5-CF3EDF90382B"
}

protocol PeripheralScannerDelegate: class {
  func peripheralScanner(_ peripheralScanner: PeripheralScanner, peripheralDidChange peripheral: CBPeripheral)
  func peripheralScanner(_ peripheralScanner: PeripheralScanner, didReceiveInfo info: [String: AnyObject])
}

class PeripheralScanner: NSObject {
  var centralManager: CBCentralManager!
  var service: PeripheralService!
  var peripheral: CBPeripheral?
  
  weak var delegate: PeripheralScannerDelegate?
  
  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global(qos: .utility))
  }
  
  deinit {
    stopScanning()
    cancelPeripheralConnection()
  }
  
  func startScanning() {
    guard centralManager.isScanning == false else {
      return
    }
    
    centralManager.scanForPeripherals(withServices: [CBUUID(string: service.rawValue)], options: [:])
  }
  
  func stopScanning() {
    guard centralManager.isScanning else {
      return
    }
    
    centralManager.stopScan()
  }
  
  func cancelPeripheralConnection() {
    guard let peripheral = peripheral else {
      return
    }
    
    centralManager.cancelPeripheralConnection(peripheral)
  }
}

extension PeripheralScanner: CBCentralManagerDelegate {
  /*!
   *  @method centralManagerDidUpdateState:
   *
   *  @param central  The central manager whose state has changed.
   *
   *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
   *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
   *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
   *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
   *                  manager become invalid and must be retrieved or discovered again.
   *
   *  @see            state
   *
   */
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch  centralManager.state {
    case .poweredOn:
      startScanning()
    default:
      print("unhandled state")
    }
  }
  
  
  /*!
   *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
   *
   *  @param central              The central manager providing this update.
   *  @param peripheral           A <code>CBPeripheral</code> object.
   *  @param advertisementData    A dictionary containing any advertisement and scan response data.
   *  @param RSSI                 The current RSSI of <i>peripheral</i>, in dBm. A value of <code>127</code> is reserved and indicates the RSSI
   *								was not available.
   *
   *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. A discovered peripheral must
   *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager. For
   *                              a list of <i>advertisementData</i> keys, see {@link CBAdvertisementDataLocalNameKey} and other similar constants.
   *
   *  @seealso                    CBAdvertisementData.h
   *
   */
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("\(#function) \(peripheral) \(advertisementData)")
    self.peripheral = peripheral
    centralManager.connect(peripheral, options: [:])
  }
  
  
  /*!
   *  @method centralManager:didConnectPeripheral:
   *
   *  @param central      The central manager providing this information.
   *  @param peripheral   The <code>CBPeripheral</code> that has connected.
   *
   *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has succeeded.
   *
   */
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print(#function)
    
    guard let currentPeripheral = self.peripheral, currentPeripheral == peripheral else {
      return
    }
    
    peripheral.delegate = self
    peripheral.discoverServices(nil)
  }
  
  
  /*!
   *  @method centralManager:didFailToConnectPeripheral:error:
   *
   *  @param central      The central manager providing this information.
   *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
   *  @param error        The cause of the failure.
   *
   *  @discussion         This method is invoked when a connection initiated by {@link connectPeripheral:options:} has failed to complete. As connection attempts do not
   *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
   *
   */
  public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    print(#function)
    
    guard let currentPeripheral = self.peripheral, currentPeripheral == peripheral else {
      return
    }
    
    self.peripheral = nil
  }
  
  
  /*!
   *  @method centralManager:didDisconnectPeripheral:error:
   *
   *  @param central      The central manager providing this information.
   *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
   *  @param error        If an error occurred, the cause of the failure.
   *
   *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by {@link connectPeripheral:options:}. If the disconnection
   *                      was not initiated by {@link cancelPeripheralConnection}, the cause will be detailed in the <i>error</i> parameter. Once this method has been
   *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
   *
   */
  public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    print(#function)
    
    guard let currentPeripheral = self.peripheral, currentPeripheral == peripheral else {
      return
    }
    
    self.peripheral = nil
  }
}

extension PeripheralScanner: CBPeripheralDelegate {
  /*!
   *  @method peripheralDidUpdateName:
   *
   *  @param peripheral	The peripheral providing this update.
   *
   *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
   */
  public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
    print(#function)
  }
  
  
  /*!
   *  @method peripheral:didModifyServices:
   *
   *  @param peripheral			The peripheral providing this update.
   *  @param invalidatedServices	The services that have been invalidated
   *
   *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed.
   *						At this point, the designated <code>CBService</code> objects have been invalidated.
   *						Services can be re-discovered via @link discoverServices: @/link.
   */
  public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
    print(#function)
  }
  
  /*!
   *  @method peripheral:didReadRSSI:error:
   *
   *  @param peripheral	The peripheral providing this update.
   *  @param RSSI			The current RSSI of the link.
   *  @param error		If an error occurred, the cause of the failure.
   *
   *  @discussion			This method returns the result of a @link readRSSI: @/link call.
   */
  public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
    print(#function)
  }
  
  
  /*!
   *  @method peripheral:didDiscoverServices:
   *
   *  @param peripheral	The peripheral providing this information.
   *	@param error		If an error occurred, the cause of the failure.
   *
   *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
   *						<i>peripheral</i>'s @link services @/link property.
   *
   */
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    print(#function)
    
    guard let peripheralServices = peripheral.services else {
      return
    }
    
    for service in peripheralServices {
      if service.uuid.uuidString == self.service.rawValue {
        peripheral.discoverCharacteristics(nil, for: service)
      }
    }
  }
  
  
  /*!
   *  @method peripheral:didDiscoverIncludedServicesForService:error:
   *
   *  @param peripheral	The peripheral providing this information.
   *  @param service		The <code>CBService</code> object containing the included services.
   *	@param error		If an error occurred, the cause of the failure.
   *
   *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
   *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
   */
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
    print(#function)
  }
  
  
  /*!
   *  @method peripheral:didDiscoverCharacteristicsForService:error:
   *
   *  @param peripheral	The peripheral providing this information.
   *  @param service		The <code>CBService</code> object containing the characteristic(s).
   *	@param error		If an error occurred, the cause of the failure.
   *
   *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
   *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
   */
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    print(#function)
    
    
    guard let peripheralServicesCharacteristics = service.characteristics else {
      return
    }
    
    for characteristic in peripheralServicesCharacteristics {
      peripheral.setNotifyValue(true, for: characteristic)
    }
  }
  
  
  /*!
   *  @method peripheral:didUpdateValueForCharacteristic:error:
   *
   *  @param peripheral		The peripheral providing this information.
   *  @param characteristic	A <code>CBCharacteristic</code> object.
   *	@param error			If an error occurred, the cause of the failure.
   *
   *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
   */
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    print("\(#function) \(characteristic.uuid) \(characteristic.value) \(error)")
    
    if let value = characteristic.value {
      let json = try! JSONSerialization.jsonObject(with: value, options: [])
      print(json)
      delegate?.peripheralScanner(self, didReceiveInfo: json as! [String : AnyObject])
    }
  }
  
  
  /*!
   *  @method peripheral:didWriteValueForCharacteristic:error:
   *
   *  @param peripheral		The peripheral providing this information.
   *  @param characteristic	A <code>CBCharacteristic</code> object.
   *	@param error			If an error occurred, the cause of the failure.
   *
   *  @discussion				This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
   */
  public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    print(#function)
  }
  
  
  /*!
   *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
   *
   *  @param peripheral		The peripheral providing this information.
   *  @param characteristic	A <code>CBCharacteristic</code> object.
   *	@param error			If an error occurred, the cause of the failure.
   *
   *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
   */
  public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    print("\(#function) \(characteristic.uuid) \(characteristic.value)")
    
    if let value = characteristic.value {
      let json = try! JSONSerialization.jsonObject(with: value, options: [])
      print(json)
      delegate?.peripheralScanner(self, didReceiveInfo: json as! [String : AnyObject])
    }
  }
  
  
  /*!
   *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
   *
   *  @param peripheral		The peripheral providing this information.
   *  @param characteristic	A <code>CBCharacteristic</code> object.
   *	@param error			If an error occurred, the cause of the failure.
   *
   *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
   *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
   */
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
    print(#function)
  }
  
  
  /*!
   *  @method peripheral:didUpdateValueForDescriptor:error:
   *
   *  @param peripheral		The peripheral providing this information.
   *  @param descriptor		A <code>CBDescriptor</code> object.
   *	@param error			If an error occurred, the cause of the failure.
   *
   *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
   */
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
    print(#function)
  }
  
  
  /*!
   *  @method peripheral:didWriteValueForDescriptor:error:
   *
   *  @param peripheral		The peripheral providing this information.
   *  @param descriptor		A <code>CBDescriptor</code> object.
   *	@param error			If an error occurred, the cause of the failure.
   *
   *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
   */
  public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?){
    print(#function)
  }
}
