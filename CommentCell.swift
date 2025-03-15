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
import Alamofire
import AlamofireImage

class CommentCell: UITableViewCell{
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    func configure(with comment: Comment){
        if let user = comment.user{
            usernameLabel.text = user.username
        }
        commentLabel.text = comment.message
        print("PoST = : \(comment.post)")
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMMM d, HH:mm a"
        
        if let time = comment.createdAt{
            
            timeLabel.text = dateFormat.string(from: time)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
