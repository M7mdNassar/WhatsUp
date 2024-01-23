
import Foundation
import Firebase

class FtypingListener{
    
    static let shared = FtypingListener()
    
    var typingListener: ListenerRegistration!
    
    private init(){}
    
    func createTypingObserver(chatRoomId: String , completion: @escaping (_ isTyping: Bool) -> Void){
        
        typingListener = FirestoreReference(collectionReference: .Typing).document(chatRoomId).addSnapshotListener({
            (documentSnapshot , error) in
            
            guard let snapshot = documentSnapshot else {return}
            
            if snapshot.exists{
                
                for data in snapshot.data()! {
                    if data.key != User.currentId{
                        completion(data.value as! Bool)
                    }
                }
            }else{
                completion(false)
                FirestoreReference(collectionReference: .Typing).document(chatRoomId).setData([User.currentId : false])
                
            }
        })
    }
    
    
    class func saveTypingCounter(typing:Bool , chatRoomId: String){
        FirestoreReference(collectionReference: .Typing).document(chatRoomId).updateData([User.currentId :typing])
    }
    
    func removeTypingListener(){
        self.typingListener.remove()
    }
    
    
}
