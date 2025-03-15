//=============================================================================
// PROGRAMMER: Rafael Nieves
// PANTHER ID: 6326371
//
// CLASS: COP4655
// SECTION: RTEA RVC 1251
// SEMESTER: The current semester: Spring 2025
// CLASSTIME: Your COP4655 course meeting time :Online
//
// Assignment: Project 3
// DUE: 17 FEB 2025
//
// CERTIFICATION: I certify that this work is my own and that
// none of it is the work of any other person.
//=============================================================================
import UIKit
import ParseSwift

class SignUpViewController: UIViewController{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad(){
        super.viewDidLoad()
    
    }
    
    @IBAction func onSignupTapped(_ sender: Any) {
        
        guard let username = usernameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              let confirmPassword = confirmPasswordField.text,
              !username.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty,
              password == confirmPassword else{
                if(passwordField.text != confirmPasswordField.text){
                            showMismatchPasswordFieldsAlert()
                        }
                else{
                    showMissingFieldsAlert()
                }
                return
            
            }// guard let
        var newUser = User(username: username, email: email, password: password)
        var acl = ParseACL()
        acl.publicRead = true //always other users to see a users info (username)
        acl.publicWrite = false //restrict writing to other user values
        //ensure a user can read and write about their own user object
        acl.setReadAccess(user: newUser, value: true)
        acl.setWriteAccess(user: newUser, value: true)
        newUser.ACL = acl //assign the new user the established access values
        newUser.signup{ [weak self] result in
            switch result{
            case .success(let user):
                NotificationCenter.default.post(name: Notification.Name("login"), object: nil)
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }//end onSignupTapped
    
    private func showAlert(description: String?){
        let alertController = UIAlertController(title: "Unable to Sign up", message: description ?? "Unknown error", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    private func showMissingFieldsAlert(){
        let alertController = UIAlertController(title: "Oops...", message: "We need all fields filled out in order to Sign up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    private func showMismatchPasswordFieldsAlert(){
        let alertController = UIAlertController(title: "Oops...", message: "Password fields must match in order to Sign up.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}//end class
