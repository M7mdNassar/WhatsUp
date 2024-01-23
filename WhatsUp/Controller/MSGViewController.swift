
import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift
import MapKit

class MSGViewController: MessagesViewController{
    
    // MARK: View Customized
    
    let leftBarButtonView : UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel : UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 25))
        
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 25, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let title = UILabel(frame: CGRect(x: 5, y: 22, width: 100, height: 24))
        title.font = UIFont.systemFont(ofSize: 13 , weight: .medium)
        
        title.textAlignment = .left
        title.adjustsFontSizeToFitWidth = true
        return title
            
            
        
    }()

    // MARK: Variables
    
    var chatId = ""
    var recipientId = ""
    var recipientName = ""
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()

    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.userName)
    var mkMessages : [MKMessage] = []
    var allLocalMessages : Results<LocalMessage>!
    let realm = try! Realm()
    
    var notificationToken : NotificationToken?  // listener to local db
    
    var displayingMessageCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
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
        configureCustomTitle()
        
        configureMessageCollection()
        configureMessageInputBar()

        //all messgaes from local db , but this called just when view load , after load not call , so we need notification
        loadMessages()
        listenForNewMessages()
        
        
        createTypingObserver()
        
        
        
        navigationItem.largeTitleDisplayMode = .never
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
            
            // to do attactch action
        }
        
        
        micButton.image = UIImage(systemName: "mic.fill" ,withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        //add gesture recognizer
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        //update mic status
        updateMicButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    
    // MARK: configure custom title
    
    private func configureCustomTitle(){
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        titleLabel.text = self.recipientName
        
    }
    
    @objc func backButtonPressed(){
        
        removeListeners()
        FChatRoomListener.shared.clearUnreadCounterUsingChatRoomId(chatRoomId: chatId)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: updating typing indicator
    func updateTypingIndicator(show: Bool){
        subTitleLabel.text = show ? "typing .." :""
    }
    
    func startTypingIndicator(){
        typingCounter += 1
        FtypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.stopTypingIndicator()
        }
    }
    
    func stopTypingIndicator(){
        typingCounter -= 1
        if typingCounter == 0{
            FtypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    
    func createTypingObserver(){
        FtypingListener.shared.createTypingObserver(chatRoomId: chatId) { isTyping in
            DispatchQueue.main.async {
                self.updateTypingIndicator(show: isTyping)
            }
        }
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
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
    
    // MARK: UISCROLLVIEWDELEGATE
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing{
            if displayingMessageCount < allLocalMessages.count{
                self.insertMoreMessages()
                messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
        refreshController.endRefreshing()
    }
    
    
    
    
    
    
    // MARK: Load messgaes form db
    private func loadMessages(){
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE ,ascending: true )
        
//        print(allLocalMessages.count)
//        insertMKMessages()
        
        if allLocalMessages.isEmpty{
            checkForOldMessage()
        }
        
        // load all messages that we git from db into screen
        notificationToken = allLocalMessages.observe({ (change : RealmCollectionChange) in
            switch change{
                
            case .initial:
                self.insertMKMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated:true)
                
            case .update(_, _, let insertions, _):
                for index in insertions{
                    self.insertMKMessage(localMessage: self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated:true)
                }
                
            case .error( let error):
                print("error on new insertions " , error.localizedDescription)
            }
            
        })
    }
    
    
    private func insertMKMessage(localMessage: LocalMessage){
        let incoming = Incoming(messageViewController: self)
        let mkMessage = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.append(mkMessage)
        displayingMessageCount += 1
    }
    
    private func insertOlderMessage(localMessage: LocalMessage){
        let incoming = Incoming(messageViewController: self)
        let mkMessage = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.insert(mkMessage, at: 0)
        displayingMessageCount += 1
    }
    
    
    private func insertMKMessages(){
        
        maxMessageNumber = allLocalMessages.count - displayingMessageCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSEGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber{
            insertMKMessage(localMessage: allLocalMessages[i])
        }
        
        
    }
    
    private func insertMoreMessages(){
        
        maxMessageNumber = minMessageNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSEGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed(){
            insertOlderMessage(localMessage: allLocalMessages[i])
        }
        
        
    }
    
    
    
    
    private func checkForOldMessage(){
        FMessageListener.shared.checkForOldMessage(documentId: User.currentId, collectionId: chatId)
    }
    
    private func listenForNewMessages(){
        FMessageListener.shared.listenForNewMessages(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate() )
    }
    
    
    // MARK: Helpers
    private func lastMessageDate() -> Date{
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    private func removeListeners(){
        FtypingListener.shared.removeTypingListener()
        FMessageListener.shared.removeNewMessegeListener()

    }
}
