
import Foundation
import Firebase

func startChat (sender: User , reciver: User) -> String {
    
    var chatRoomId = ""
    let value = sender.id.compare(reciver.id).rawValue
    chatRoomId = value < 0 ? (sender.id + reciver.id) : (reciver.id + sender.id)
    
    createChatRooms(chatRoomId: chatRoomId , users: [sender , reciver])
    return chatRoomId
    
}

func  createChatRooms(chatRoomId: String , users: [User]){
    // if user has already chatroom we will not create
    
    var usersToCreateChatsFor:[String]
    usersToCreateChatsFor = []
    
    for user in users {
        usersToCreateChatsFor.append(user.id)
    }
    
    FirestoreReference(collectionReference: .Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { QuerySnapshot, error in
        
        guard let snapshot = QuerySnapshot else {return}
        
        if !snapshot.isEmpty{
            for chatData in snapshot.documents {
                let currentChat = chatData.data() as Dictionary
                
                if let currentUserId = currentChat[kSENDERID]{
                    if usersToCreateChatsFor.contains(currentUserId as! String){
                        usersToCreateChatsFor.remove(at: usersToCreateChatsFor.firstIndex(of: currentUserId as! String)!)
                    }
                }
            }
        }
        
        for userId in usersToCreateChatsFor{
            
            let senderUser = userId == User.currentId ? User.currentUser! : getReciverFrom(users: users)
            
            let receiverUser = userId == User.currentId ? getReciverFrom(users: users) : User.currentUser!
                
            let ChatRoomObject = ChatRoom(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.userName, receiverId: receiverUser.id, receiverName: receiverUser.userName, date: Date(), memberIds: [senderUser.id , receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
            
            // todo .. save chat to firestore
            
            FChatRoomListener.shared.saveChatRoom(ChatRoomObject)
            
        }
        
        
        
        
    }
    
}


func getReciverFrom(users:[User]) -> User{
    var allUsers = users
    
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    
    return allUsers.first!
}
