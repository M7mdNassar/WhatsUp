
import UIKit
import Gallery
import ProgressHUD

class EditProfileTableViewController: UITableViewController {

    // MARK: Outlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: Variables
    
    var gallery: GalleryController!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        showUserInfo()
    }

    
    // MARK: Actions
   
    @IBAction func editProfileButton(_ sender: UIButton) {
        showGallery()
        
    }
    
    func showUserInfo(){
        if let user = User.currentUser{
            
            userNameTextField.text = user.userName
            statusLabel.text = user.status
            
            if user.avatarLink != ""{
                //TODO SHOW IMAGE  .. done
                FileStorage.downloadImage(imageUrl: user.avatarLink) { avatarImage in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
                
            }
           
        }
        
    }
    
    func uploadAvatarImage(image:UIImage){
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            if var user = User.currentUser{
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user: user)
                FUserListener.shared.saveUserToFierbase(user: user)
            }
            
            //todo .. save image loccally .. done
            
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.5)! as NSData, fileName: User.currentId)
        }
    }
    
    
    // MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 || section == 1 ? 0:15
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }
     
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNonzeroMagnitude
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0{
            performSegue(withIdentifier: "goToStatuses", sender: self)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)

    }
    
 
    
}

// MARK: TextField Delegate

extension EditProfileTableViewController: UITextFieldDelegate{
    func configureTextFields(){
        userNameTextField.delegate = self
        userNameTextField.clearButtonMode = .whileEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == userNameTextField{
            if textField.text != ""{
                if var user = User.currentUser{
                    user.userName = textField.text!
                    saveUserLocally(user: user)
                    FUserListener.shared.saveUserToFierbase(user: user)
                }
            }
            textField.resignFirstResponder() // hide keyboard
            return false
        }
        return true
    }
    
}

// MARK: Gallery

extension EditProfileTableViewController : GalleryControllerDelegate{
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        
        if images.count > 0{
            images.first!.resolve { (avatarImage) in
                if avatarImage != nil {
                    //todo ... uplaod image .. done
                    self.uploadAvatarImage(image: avatarImage!)
                    self.avatarImageView.image = avatarImage
                }
                else{
                    ProgressHUD.error("No Image")
                }
            }
        }
       
        
        controller.dismiss(animated: true, completion: nil)

    }
    
    
    // this methods i dont need , so dismiss it
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true, completion: nil)

    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true, completion: nil)

    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func showGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab , .cameraTab]
        Config.Camera.imageLimit = 1 // just chose one image
        Config.initialTab = .imageTab
        self.present(self.gallery, animated: true)
    }
}
