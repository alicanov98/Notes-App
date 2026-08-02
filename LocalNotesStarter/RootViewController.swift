import UIKit

final class RootViewController: UIViewController {
    
    // MARK: - Properties

        private var currentController: UIViewController?

        private let keychain: KeychainWrapper
    
    // MARK: - Initialization

        init(keychain: KeychainWrapper = KeychainWrapper()) {
            self.keychain = keychain
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    
    // MARK: - Lifecycle

        override func viewDidLoad() {
            super.viewDidLoad()

            checkLoginState()
        }
    
    
    // MARK: - Authentication
    
    private func checkLoginState(){
        do{
            let token = try keychain.readToken()
            
            if token == nil {
                showLogin()
            }else{
                showMainApplication()
            }
        }catch{
            showError(error)
        }
    }
    
    private func login(){
        do{
            try keychain.saveToken(_token: "demo_auth_token")
        }catch{
            showError(error)
        }
    }
    
    private func logout(){
        do{
            try keychain.deleteToken()
            showLogin()
        }catch{
            showError(error)
        }
    }
    
    // MARK: - Navigation
    
    private func showLogin(){
        let loginViewController = LoginViewController()
        
        loginViewController.onLogin = { [weak  self] in
            self?.login()
        }
        
        replaceCurrentController(with: loginViewController)
    }
    
    
    
    private func showMainApplication() {
        
        // MARK: Notes
        
        let notesStorage = LocalNotesStorage()
        
        let notesViewModel = NotesViewModel(storage: notesStorage)
        
        let notesViewController = NotesViewController(viewModel: notesViewModel)
        
        let notesNavigationController = UINavigationController(rootViewController: notesViewController)
        
        notesViewController.tabBarItem = UITabBarItem(title: "Notes", image: UIImage(systemName: "note.text"), tag: 0)
        
        // MARK: JSON Lab
        
        let jsonLabViewController = JSONLabViewController()

            let jsonNavigationController = UINavigationController(
                rootViewController: jsonLabViewController
            )

            jsonNavigationController.tabBarItem = UITabBarItem(
                title: "JSON",
                image: UIImage(systemName: "curlybraces"),
                tag: 1
            )
        
        // MARK: Settings

        let settingsViewController = SettingsViewController()

            settingsViewController.onLogout = { [weak self] in
                self?.logout()
            }

            let settingsNavigationController = UINavigationController(
                rootViewController: settingsViewController
            )

            settingsNavigationController.tabBarItem = UITabBarItem(
                title: "Settings",
                image: UIImage(systemName: "gearshape"),
                tag: 2
            )
        
        // MARK: Tab Bar

           let tabBarController = UITabBarController()

           tabBarController.viewControllers = [
               notesNavigationController,
               jsonNavigationController,
               settingsNavigationController
           ]

           replaceCurrentController(with: tabBarController)
        
    }

    // MARK: - Child Controller Managment
    
    private func replaceCurrentController(with controller: UIViewController){
        currentController?.willMove(toParent: nil)
        currentController?.view.removeFromSuperview()
        currentController?.removeFromParent()
        
        addChild(controller)
        
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        currentController = controller
    }
    
    // MARK: - Error Handling
    private func showError(_ error: Error){
        showAlert(title: "Error", message: error.localizedDescription)
    }
   
}
