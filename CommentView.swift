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

class CommentView: UIViewController, UITableViewDelegate{
    
    @IBOutlet weak var postComment: UIButton!
    @IBOutlet weak var commentField: UITextField!
    var post: Post!
    @IBOutlet weak var tableView: UITableView!
    private var comments = [Comment](){
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        print("current post: \(post)")
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        queryComments()
        
    }
    
    private func queryComments(){
        let query = Comment.query()
            .include("user")
           
            .order([.descending("createdAt")])
        query.find { [weak self] result in
            switch result{
            case .success(let comments):
                self?.comments = comments
            case .failure(let error):
                self?.showAlert(description: error.localizedDescription)
            }
        }
    }//end queryComments
    @IBAction func postComment(_ sender: Any) {
        var newComment = Comment();
        newComment.message = commentField.text
        newComment.user = User.current
        newComment.post = post //assigns comment's post to the post that was clicked on
        var acl = ParseACL()
        acl.publicRead = true //always other users to see a users info (username and message)
        acl.publicWrite = false //restrict writing to other user values
        //ensure a user can read and write about their own comment object
        acl.setReadAccess(user: User.current!, value: true)
        acl.setWriteAccess(user: User.current!, value: true)
        newComment.ACL = acl
        newComment.save { [weak self] result in
            DispatchQueue.main.async{
                switch result{
                case .success:
                    print("Comment made!")
                case .failure(let error):
                    print("Error making comment")
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
        commentField.text = ""
        tableView.reloadData()
    }

    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
extension CommentView: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.configure(with: comments[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)  // Add bottom padding
    }

}
