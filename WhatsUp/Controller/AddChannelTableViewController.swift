
import UIKit
import Gallery
import ProgressHUD

class AddChannelTableViewController: UITableViewController {
    
    // MARK: Outlets

    @IBOutlet weak var channelAvatarImageView: UIImageView!
    @IBOutlet weak var channelNameTextField: UITextField!
    @IBOutlet weak var aboutChannelTextView: UITextView!
    
    // MARK: Variables
    
    var channelId = UUID().uuidString
    var gallery : GalleryController!
    var avatarLink = ""
    var tapGesture = UITapGestureRecognizer()
    
    var channelToEdit : Channel?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        configureLeftBarButton()
        configureGestures()
        if channelToEdit != nil{
            configureEditView()
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if channelNameTextField.text != ""{
            saveChannel()
        }else{
            ProgressHUD.error("Chanel name required !")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 2
    }

    
    private func configureLeftBarButton(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector (backButtonPressed))
    }
    
     @objc func backButtonPressed(){
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Tap Gesture
    
    private func configureGestures(){
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        channelAvatarImageView.isUserInteractionEnabled = true
        channelAvatarImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func avatarImageTap(){
        showGallery()
    }
    
    private func showGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab , .cameraTab ]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        
        self.present(gallery , animated: true)
    }
    
    
    // MARK: Avatar
    
    private func uploadAvatarImage(_ image : UIImage){
        let fileDirectory = "Avatars/" + "_\(channelId)" + ".jpg"
        
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.7) as! NSData, fileName: self.channelId)
        FileStorage.uploadImage(image, directory: fileDirectory) { avatarLink in
            self.avatarLink = avatarLink ?? ""
        }
    }
    
    
    func saveChannel(){
        let channel = Channel(id: channelId, name: channelNameTextField.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutChannelTextView.text)
        
        //save channel in FS
        FChannelListener.shared.saveChannel(channel)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Configure Edit View
    
    private func configureEditView(){
        self.channelNameTextField.text = channelToEdit!.name
        self.channelId = channelToEdit!.id
        self.aboutChannelTextView.text = channelToEdit?.aboutChannel
        self.avatarLink = channelToEdit!.avatarLink
        self.title = "Editing Channel"
        
        if channelToEdit?.avatarLink != ""{
            FileStorage.downloadImage(imageUrl: avatarLink) { avatarImage in
                
                DispatchQueue.main.async {
                    self.channelAvatarImageView.image = avatarImage?.circleMasked

                }
            }
        }else{
            self.channelAvatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    
    
}

extension AddChannelTableViewController : GalleryControllerDelegate{
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        
        if images.count > 0 {
            images.first!.resolve { icon in
                if icon != nil{
                    //upload image
                    self.uploadAvatarImage(icon!)
                    //set avatar image
                    self.channelAvatarImageView.image = icon!.circleMasked
                }else{
                    ProgressHUD.failed("Could not select image")
                }
            }
        }
        
        controller.dismiss(animated: true , completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true , completion: nil)
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true , completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true , completion: nil)
    }
    
    
}
