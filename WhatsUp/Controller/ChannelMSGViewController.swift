
import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift
import MapKit

class ChannelMSGViewController: MessagesViewController{
    
    // MARK: View Customized
    
    let leftBarButtonView : UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
//    let titleLabel : UILabel = {
//        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 25))
//        
//        title.textAlignment = .left
//        title.font = UIFont.systemFont(ofSize: 25, weight: .medium)
//        title.adjustsFontSizeToFitWidth = true
//        
//        return title
//    }()
//    
//    let subTitleLabel: UILabel = {
//        let title = UILabel(frame: CGRect(x: 5, y: 22, width: 100, height: 24))
//        title.font = UIFont.systemFont(ofSize: 13 , weight: .medium)
//        
//        title.textAlignment = .left
//        title.adjustsFontSizeToFitWidth = true
//        return title
//            
//            
//        
//    }()

    // MARK: Variables
    
    var chatId = ""
    var recipientId = ""
    var recipientName = ""
    
    var channel:Channel!
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
    
//    var typingCounter = 0
    
    var gallery: GalleryController!
    
    var longPressGesture : UILongPressGestureRecognizer!
    
    var audioFileName: String = ""
    var audioStartTime: Date = Date()
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    // MARK: Init
    
    init(channel: Channel) {
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
        // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCustomTitle()
        configureGestureRecognizer()
        
        configureMessageCollection()
        configureMessageInputBar()
    
        
        //all messgaes from local db , but this called just when view load , after load not call , so we need notification
        loadMessages()
        listenForNewMessages()
        
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
        
        messageInputBar.isHidden = channel.adminId != User.currentId
        
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "paperclip" , withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            self.actionAttachMessage()
        }
        
        
        micButton.image = UIImage(systemName: "mic.fill" ,withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        //add gesture recognizer
        micButton.addGestureRecognizer(longPressGesture)
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        //update mic status
        updateMicButtonStatus(show: true)
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    // MARK: Long Press Gesture
    
    private func configureGestureRecognizer(){
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAndSend))
    }
    
    
    // MARK: configure custom title
    
    private func configureCustomTitle(){
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
        
//        leftBarButtonView.addSubview(titleLabel)
//        leftBarButtonView.addSubview(subTitleLabel)
//        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
//        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
//        titleLabel.text = self.recipientName
        
        self.title = channel.name
        
    }
    
    @objc func backButtonPressed(){
        
        removeListeners()
        FChatRoomListener.shared.clearUnreadCounterUsingChatRoomId(chatRoomId: chatId)
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: markMessageAs READ
    
    private func markMessageAsRead(_ localMessage: LocalMessage){
        if localMessage.senderId != User.currentId{
            FMessageListener.shared.updateMessageStatus(localMessage, userId: recipientId)
        }
    }
    
    
//    // MARK: updating typing indicator
//    func updateTypingIndicator(show: Bool){
//        subTitleLabel.text = show ? "typing .." :""
//    }
//    
//    func startTypingIndicator(){
//        typingCounter += 1
//        FtypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
//            self.stopTypingIndicator()
//        }
//    }
//    
//    func stopTypingIndicator(){
//        typingCounter -= 1
//        if typingCounter == 0{
//            FtypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
//        }
//    }
//    
//    
//    func createTypingObserver(){
//        FtypingListener.shared.createTypingObserver(chatRoomId: chatId) { isTyping in
//            DispatchQueue.main.async {
//                self.updateTypingIndicator(show: isTyping)
//            }
//        }
//    }
    
    
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
//
//        Outgoing.sendMessage(chatId: chatId, text: text, photo: photo, video: video, audioUrl: audioUrl, audioDuration: audioDuration, location: location, memberIds: [User.currentId , recipientId])
//
        
        Outgoing.sendChannelMessage(channel: channel, text: text, photo: photo, video: video, audioUrl: audioUrl, audioDuration: audioDuration, location: location)
        
        
        
        // code for print the local database
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    // MARK: Record AND SEND
    @objc func recordAndSend(){
        switch longPressGesture.state {
      
        case .began:
            //record and start recording
            audioFileName = Date().stringDate()
            audioStartTime = Date()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            //stop and send
            AudioRecorder.shared.finishRecording()
            if fileExistsPath(path: audioFileName + ".m4a"){
                let audioDuration = audioStartTime.interval(ofComponent: .second, to: Date())
                
                send(text: nil, photo: nil, video: nil, audioUrl: audioFileName, location: nil, audioDuration: audioDuration)
            }
            
        @unknown default:
            print("UnKnown")
       
        }


    }
    
    
    
    private func actionAttachMessage(){
        
        //hide keyboard
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { alert in
            self.showImageGalery(camera: true)
        }
        
        let showMedia = UIAlertAction(title: "Library", style: .default) { alert in
            self.showImageGalery(camera: false)

        }
        
        let showLocation = UIAlertAction(title: "Location", style: .default) { alert in
            
            if let _ = LocationManager.shared.currentLocation{
                self.send(text: nil, photo: nil, video: nil, audioUrl: nil, location: kLOCATION)

            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel , handler: nil)
        
        
        // make some design
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        showMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        showLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(showMedia)
        optionMenu.addAction(showLocation)
        optionMenu.addAction(cancel)

        self.present(optionMenu, animated: true)
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
                self.messagesCollectionView.scrollToBottom(animated:true)

                
            case .update(_, _, let insertions, _):
                for index in insertions{
                    self.insertMKMessage(localMessage: self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated:true)
                    self.messagesCollectionView.scrollToBottom(animated:true)
                }
                
            case .error( let error):
                print("error on new insertions " , error.localizedDescription)
            }
            
        })
    }
    
    
    private func insertMKMessage(localMessage: LocalMessage){
        
//        markMessageAsRead(localMessage)
        
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
    
    
    
//    // MARK: Update Read Status
//    
//    private func updateReadStatus(_ updatedLocalMessage: LocalMessage){
//        for index in 0 ..< mkMessages.count{
//            
//            let tempMessage = mkMessages[index]
//            if updatedLocalMessage.id == tempMessage.messageId{
//                mkMessages[index].status = updatedLocalMessage.status
//                mkMessages[index].readDate = updatedLocalMessage.readDate
//                RealmManager.shared.save(updatedLocalMessage)
//                
//                if mkMessages[index].status == kREAD{
//                    self.messagesCollectionView.reloadData()
//                }
//            }
//        }
//    }
//    
//    private func listenForReadStatusUpdates(){
//        FMessageListener.shared.listenForReadStatus(User.currentId, collectionId: chatId) { updateMessage in
//            self.updateReadStatus(updateMessage)
//        }
//    }
//    
    
    
    
    // MARK: Helpers
    private func lastMessageDate() -> Date{
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    private func removeListeners(){
//        FtypingListener.shared.removeTypingListener()
        FMessageListener.shared.removeNewMessegeListener()

    }
    
    // MARK: Gallery
    
    private func showImageGalery(camera: Bool){
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab , .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true , completion: nil)
    }
}

extension ChannelMSGViewController: GalleryControllerDelegate{
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
        if images.count > 0 {
            images.first!.resolve { image in
                self.send(text: nil, photo: image, video: nil, audioUrl: nil, location: nil)

            }
        }
        
        
        controller.dismiss(animated: true)

    }
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        
        self.send(text: nil, photo: nil, video: video, audioUrl: nil, location: nil)

        controller.dismiss(animated: true)

    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true)

    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true)
    }
    
    
    
}

