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
import Alamofire
import AlamofireImage

protocol PostCellDelegate: AnyObject {
    func didTapCommentButton(post: Post)
}

class PostCell: UITableViewCell{
    
   
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    private var imageDataRequest: DataRequest?
    var currentPost: Post!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var profileImageView: UIImageView!
    weak var delegate: PostCellDelegate?
    
    @IBAction func commentsButton(_ sender: Any) {
        delegate?.didTapCommentButton(post: currentPost)
    }
    
    
    
    func configure(with post: Post){
        currentPost = post
        if let user = post.user{
            let initials = getInitials(from: user.username)
            setProfileImage(with: initials)
            usernameLabel.text = user.username
            
        }
        else{
            setProfileImage(with: "NA")
            usernameLabel.text = "NA"
        }
        if let imageFile = post.imageFile,
           let imageUrl = imageFile.url{
            imageDataRequest = AF.request(imageUrl).responseImage{ [weak self] response in
                switch response.result{
                case .success(let image):
                    self?.postImage.image = image
                case .failure(let error):
                    print("Error fetching image: \(error.localizedDescription)")
                    break
                }
            }
        }
        usernameLabel.text = post.user?.username
        locationLabel.text = post.imageLocation ?? "Butts"
        print("Image Location \(String(describing: post.imageLocation))")
      //  locationLabel.text = postImage.image.
        captionLabel.text = post.caption
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMMM d, HH:mm a"
        
        if let time = post.createdAt{
            
            timeLabel.text = dateFormat.string(from: time)
        }
        
        //Hide image if too old
        if let currentUser = User.current,
           let lastPostedDate = currentUser.lastPostedDate,
           let postCreatedDate = post.createdAt,
           let diffHours = Calendar.current.dateComponents([.hour], from: postCreatedDate, to: lastPostedDate).hour{
            blurView.isHidden = abs(diffHours) < 24
        }
        else{
            blurView.isHidden = false
        }
    }// end configure
    override func prepareForReuse() {
        super.prepareForReuse()
        postImage.image = nil
        imageDataRequest?.cancel()
    }
    
    private func getInitials(from name: String?) -> String {
        let components = name!.split(separator: " ")
            var initials = ""
            for component in components {
                if let firstLetter = component.first {
                    initials.append(firstLetter)
                }
            }
            return initials.uppercased()
        }

    private func setProfileImage(with initials: String) {
            
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
            profileImageView.layer.masksToBounds = true
            profileImageView.layer.borderWidth = 2
            profileImageView.layer.borderColor = UIColor.white.cgColor
            
            // Set the background color and initials
            profileImageView.backgroundColor = .gray // You can change this color
            profileImageView.image = nil
            
            // Create and set the label with initials
            let label = UILabel(frame: profileImageView.bounds)
            label.text = initials
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 16) // Customize font size
            label.textColor = .white
            
            // Remove any previous label and add the new one
            profileImageView.subviews.forEach { $0.removeFromSuperview() }
            profileImageView.addSubview(label)
        }
}

