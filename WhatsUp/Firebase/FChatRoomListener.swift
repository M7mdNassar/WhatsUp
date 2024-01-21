

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
    
}
