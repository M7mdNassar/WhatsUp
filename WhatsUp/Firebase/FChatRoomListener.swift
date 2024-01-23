

import Foundation
import Firebase


class FChatRoomListener{
    
    static let shared = FChatRoomListener()
    
    private init (){}
    
    func saveChatRoom(_ chatRoom: ChatRoom){
        
        do{
            try FirestoreReference(collectionReference: .Chat).document(chatRoom.id).setData(from: chatRoom)
        }catch{
            print("No able to save documents" , error.localizedDescription)
        }
    }
    
    
    // MARK: Remove chat
    
    func deleteChatRoom(chatRoom: ChatRoom){
        FirestoreReference(collectionReference: .Chat).document(chatRoom.id).delete()
    }
    
    
    
    
    // MARK: download all chat rooms
    
    func downloadChatRooms (completion : @escaping (_ allFBChatRooms : [ChatRoom]) -> Void){
        
        FirestoreReference(collectionReference: .Chat).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener { snapshot, error in
            var chatRooms:[ChatRoom] = []
            guard let documents = snapshot?.documents else{
                print("no documents found")
                return
            }
            
            let allFBChatRooms = documents.compactMap { snapshot -> ChatRoom? in
                return try? snapshot.data (as: ChatRoom.self)
                
            }
            // if user open the chat and close it .. we dont need create the room
            for chatRoom in allFBChatRooms{
                if chatRoom.lastMessage != ""{
                    chatRooms.append(chatRoom)
                }
            }
            
            chatRooms.sort(by: {$0.date! > $1.date! })
            
            completion(chatRooms)
        }
        
    }
    
    // MARK: Reset unread counter
    
    func clearUnreadCounter(chatRoom: ChatRoom){
        var newChatRoom = chatRoom
        newChatRoom.unreadCounter = 0
        self.saveChatRoom(newChatRoom)
    }
    
    func clearUnreadCounterUsingChatRoomId(chatRoomId: String){
        
        FirestoreReference(collectionReference: .Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {return}
            
            let allChatRooms = documents.compactMap { querySnapshot -> ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            
            if allChatRooms.count > 0{
                self.clearUnreadCounter(chatRoom: allChatRooms.first!)
            }
            
        }
    
    }
    
    
    // MARK: update chat room with new mesages
    
    private func updateChatRoomWithNewMessage(chatRoom: ChatRoom , lastMessage: String){
        var tempChatRoom = chatRoom
        
        if tempChatRoom.senderId != User.currentId{
            tempChatRoom.unreadCounter += 1
        }
        
        tempChatRoom.lastMessage = lastMessage
        tempChatRoom.date = Date()
        self.saveChatRoom(tempChatRoom)
    }
    
    func updateChatRoom(chatRoomId: String , lastMessage: String){
        FirestoreReference(collectionReference: .Chat).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {return}
            
            let allChatRooms = documents.compactMap { querySnapshot -> ChatRoom? in
                return try? querySnapshot.data(as: ChatRoom.self)
            }
            
            for chatRoom in allChatRooms{
                self.updateChatRoomWithNewMessage(chatRoom: chatRoom, lastMessage: lastMessage)
            }
        }
    }
    
    
}
