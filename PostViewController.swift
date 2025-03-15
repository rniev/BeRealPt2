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
import PhotosUI
import ParseSwift

class PostViewController: UIViewController{
    
    
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var postImage: UIImageView!
    private var pickedImage: UIImage?
    
    //used to get
    private var locationToDisplay: String?
    private var imgLocation: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func selectPhoto(_ sender: Any) {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }// end selectPhoto
    
    @IBAction func createPost(_ sender: Any) {
        view.endEditing(true)
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else{
            return
        }
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        
        var post = Post()
        post.imageFile = imageFile
        post.caption = captionField.text
        post.user = User.current
        if(locationToDisplay == ""){
            post.imageLocation = "Location Unavailable"
        }
        else{
            post.imageLocation = locationToDisplay
        }
        
        post.save { [weak self] result in
            DispatchQueue.main.async{
                switch result {
                case .success(let post):
                    //self?.navigationController?.popViewController(animated: true)
                    if var currentUser = User.current{
                        currentUser.lastPostedDate = Date()
                        currentUser.save{ [weak self] result in
                            switch result{
                            case .success(let user):
                                DispatchQueue.main.async{
                                    self?.navigationController?.popViewController(animated: true)
                                }
                            case .failure(let error):
                                self?.showAlert(description: error.localizedDescription)
                            }}
                    }
                case .failure(let error):
                    self?.showAlert(description: error.localizedDescription)
                }
            }
        }
    } //end createPost
    
   
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}//end class

extension PostViewController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {return}
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            
            guard let image = object as? UIImage else{ //runs if object cannot cast to UIImage
                self?.showAlert()
                return
            }
            //get image location
            let result = results.first
            var locationText: String?
            guard let assetId = result?.assetIdentifier,
                  let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location
            else{
                print("Could not get location from PHAsset")
                return
            }
            self?.imgLocation = location
            print(location)
            let geocode = CLGeocoder()
            geocode.reverseGeocodeLocation(location){placemarks, error in
                guard let self = self else{
                    return
                }
                if let error = error{
                    self.showAlert(description: error.localizedDescription)
                    self.locationToDisplay = "Location not available"
                    return
                }
                if let placemark = placemarks?.first{
                    locationText = "\(placemark.locality ?? ""), \(placemark.subLocality ?? "")"
                    print("locationText == \(String(describing: locationText))")
                    if(locationText == ""){
                        locationText = "No Location"
                    }
                }
                if let error = error{ //check for and handle errors
                    self.showAlert(description: error.localizedDescription)
                    return
                } else { //if there is no error, preview and pick image
                    DispatchQueue.main.async {
                        self.postImage.image = image
                        self.pickedImage = image
                        self.locationToDisplay = locationText
                        print("LocationToDisplay = \(String(describing: self.locationToDisplay))")
                    }
                }
            }
            
            

        }
    }
}
