import UIKit
import CoreBluetooth

public struct Constants {

  public static let name = "raspberrypi"
  public static let peripheral = "E20A39F4-73F5-4BC4-A12F-17D1AD07A951"
  public static let service = "E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
  public static let characteristic = "08590F7E-DB05-467E-8757-72F6FAEB13D4"
  public static let advertiser = "7DAB9750-4510-410C-B030-D5597D3EBE6D"
  public static let information = [
    CBAdvertisementDataLocalNameKey : "Lights",
    CBAdvertisementDataServiceUUIDsKey : [CBUUID(string: Constants.peripheral)]
  ]
}
