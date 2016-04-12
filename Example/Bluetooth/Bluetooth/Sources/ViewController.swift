import UIKit
import Bluetooth

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    let bluetooth = Bluetooth(central: false)
    bluetooth.delegate = self
  }
}

extension ViewController: BluetoothDelegate {

  func didDiscoverPeripheral() {  }

  func shouldShowMessage(message: String) {  }

  func showPairing() {  }
}
