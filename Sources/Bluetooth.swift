import UIKit
import CoreBluetooth

public protocol BluetoothDelegate {

  func bluetoothLight()
  func shouldShowMessage(message: String)
  func showPairing()
}

public protocol BluetoothPairedDelegate {

  func pairedDevice()
  func characteristicFound(string: String)
}

public protocol BluetoothWriteDelegate {

  func receivedWrite(string: String)
}

public class Bluetooth: NSObject {

  public var log = false
  var manager: CBCentralManager?
  var peripheralManager: CBPeripheralManager?
  var characteristic: CBMutableCharacteristic?
  var service: CBMutableService?
  var light: CBPeripheral?
  var delegate: BluetoothDelegate?
  var pairedDelegate: BluetoothPairedDelegate?
  var writeDelegate: BluetoothWriteDelegate?

  init(central: Bool = true) {
    super.init()

    let queue = dispatch_queue_create("no.bluetooth", DISPATCH_QUEUE_SERIAL)

    if central {
      manager = CBCentralManager(delegate: self, queue: queue)
    } else {
      peripheralManager = CBPeripheralManager(delegate: self, queue: queue)
    }
  }

  func scan() {
    guard let central = manager else { return }
    central.scanForPeripheralsWithServices([CBUUID(string: Constants.service)], options: nil)
  }

  func advertise() {
    guard let central = peripheralManager else { return }
    central.startAdvertising(Constants.information)
  }
}

extension Bluetooth: CBCentralManagerDelegate {

  public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
    if peripheral.name == Constants.name {
      if log { print("Lights found.") } // Logs.

      manager?.stopScan()
      light = peripheral

      central.connectPeripheral(peripheral, options: nil)

      delegate?.bluetoothLight()
    }
  }

  public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
    light = peripheral

    peripheral.delegate = self
    peripheral.discoverServices([CBUUID(string: Constants.service)])
  }

  public func centralManagerDidUpdateState(central: CBCentralManager) {
    var message = ""

    switch central.state {
    case .Unauthorized:
      message = Text.Error.unauthorized
    case .PoweredOff:
      message = Text.Error.poweredOff
    case .PoweredOn:
      scan(); return
    default:
      message = Text.Error.unknown
    }

    delegate?.shouldShowMessage(message)
  }
}

extension Bluetooth: CBPeripheralDelegate {

  public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    guard let services = peripheral.services else { return }

    for service in services {
      peripheral.discoverCharacteristics([CBUUID(string: Constants.characteristic)], forService: service)
    }
  }

  public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    guard let characteristics = service.characteristics else { return }

    for characteristic in characteristics {
      if log { print("Characteristic found.") } // Logs.

      peripheral.setNotifyValue(true, forCharacteristic: characteristic)
    }
  }

  public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
    if let data = characteristic.value,
      string = String(data: data, encoding: NSUTF8StringEncoding) {

      pairedDelegate?.characteristicFound(string)

      manager?.cancelPeripheralConnection(peripheral)
      light = nil
      manager = nil

      pairedDelegate?.pairedDevice()
    }
  }
}

extension Bluetooth: CBPeripheralManagerDelegate {

  public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
    if log { print("Peripheral is advertising.") } // Logs.
  }

  public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
    guard peripheral.state == .PoweredOn else { return }

    service = CBMutableService(type: CBUUID(string: Constants.service), primary: true)

    peripheralManager = peripheral
    characteristic = CBMutableCharacteristic(
      type: CBUUID(string: Constants.advertiser), properties: [.Read, .Write], value: nil, permissions: [.Writeable, .Readable])

    guard let service = service, characteristic = characteristic else { return }

    service.characteristics = [characteristic]
    peripheral.addService(service)

    advertise()
  }

  public func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
    guard let request = requests.first else { return }

    peripheralManager?.stopAdvertising()
    delegate?.showPairing()

    if let data = request.value,
      string = String(data: data, encoding: NSUTF8StringEncoding) {

      writeDelegate?.receivedWrite(string)
    }
  }
}
