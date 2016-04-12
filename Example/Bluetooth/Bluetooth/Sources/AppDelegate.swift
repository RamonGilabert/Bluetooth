import UIKit
import Bluetooth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  lazy var controller: UIViewController = ViewController()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.rootViewController = controller
    window?.makeKeyAndVisible()

    return true
  }
}
