import UIKit

final class RootViewController: UIViewController {
    private var currentController: UIViewController?

    private let keychain =  KeychainWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoginState()
    }

    private func checkLoginState() {
        do {
            let token = try keychain.readToken()
            token == nil ? showLogin() : showMainApplication()
        } catch {
            currentController?.showAlert(title: "Error", message: error.localizedDescription)
        }
        

    }
    
    private func showLogin() {
        let controller = LoginViewController()

        controller.onLogin = { [weak self] in
            self?.login()
        }
        replaceCurrentController(with: controller)
    }
    
    private func login(){
        do {
            try keychain.saveToken(_token: "demo_auth_token")
            showMainApplication()
        }catch {
            currentController?.showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    private func logout(){
        do {
            try keychain.deleteToken()
            showLogin()
        }catch{
            currentController?.showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    private func showMainApplication() {
        let notes = UINavigationController(rootViewController: NotesViewController())
        notes.tabBarItem = UITabBarItem(title: "Notes", image: UIImage(systemName: "note.text"), tag: 0)

        let jsonLab = UINavigationController(rootViewController: JSONLabViewController())
        jsonLab.tabBarItem = UITabBarItem(title: "JSON", image: UIImage(systemName: "curlybraces"), tag: 1)

        let settingsController = SettingsViewController()
        settingsController.onLogout = { [weak self] in
            self?.logout()
        }
        let settings = UINavigationController(rootViewController: settingsController)
        settings.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 2)
          
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [notes, jsonLab, settings]
        replaceCurrentController(with: tabBarController)
    }

    private func replaceCurrentController(with controller: UIViewController) {
        currentController?.willMove(toParent: nil)
        currentController?.view.removeFromSuperview()
        currentController?.removeFromParent()

        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        currentController = controller
    }
}
