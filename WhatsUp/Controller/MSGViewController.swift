
import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift
import MapKit

class MSGViewController: MessagesViewController{

    // MARK: Variables
    
    var chatId = ""
    var recipientId = ""
    var recipientName = ""
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()

    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.userName)
    let mkMessage : [MKMessage] = []
    
    // MARK: Init
    
    init(chatId: String = "", recipientId: String = "", recipientName: String = "") {
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
        // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollection()
        configureMessageInputBar()

    }

        // MARK: Methods
    
    func configureMessageCollection(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.refreshControl = refreshController
    }
    
    func configureMessageInputBar(){
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "paperclip" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            print("attaching")
        }
        
        
        micButton.image = UIImage(systemName: "mic.fill" ,withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        //add gesture recognizer
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        //update mic status
        updateMicButtonStatus(show: false)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    func updateMicButtonStatus(show : Bool){
        if show{
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        }
            else{
                messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
                messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
            }
    }
    
    
    // MARK: Actions
    
    func send(text: String? , photo: UIImage? , video: Video? , audioUrl: String? ,location: String? , audioDuration: Float = 0.0){
        
        Outgoing.sendMessage(chatId: chatId, text: text, photo: photo, video: video, audioUrl: audioUrl, audioDuration: audioDuration, location: location, memberIds: [User.currentId , recipientId])
        
        
        // code for print the local database
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
}
