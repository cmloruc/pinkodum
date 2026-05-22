import Flutter
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func sceneDidBecomeActive(_ scene: UIScene) {
    AppDelegate.clearNotificationBadge(UIApplication.shared)
    super.sceneDidBecomeActive(scene)
  }
}
