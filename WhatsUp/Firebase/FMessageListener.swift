
import Foundation
import Firebase
import FirebaseFirestoreSwift

class FMessageListener{
    
    static let shared = FMessageListener()
    
    private init(){}
    
    func addMessage(_ message : LocalMessage , memberId: String){
        do{
           try FirestoreReference(collectionReference: .Message).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
            
        }catch{
            print("error saving message to firebase", error.localizedDescription)
        }
    }
    
}
