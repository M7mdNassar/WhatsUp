

import Foundation
import Firebase


class FChannelListener{
    
    static let shared = FChannelListener()
    var userChannelsListener : ListenerRegistration!
    var subscribedChannelsListener : ListenerRegistration!
    private init(){}
    
    // MARK: add channels
    
    func saveChannel(_ channel: Channel){
        do {
            try FirestoreReference(collectionReference: .Channel).document(channel.id).setData(from: channel)
        }catch{
            print(error.localizedDescription)
        }
    }
    
    // MARK: Download Channels
    
    func downloadUserChanels(completion: @escaping (_ userChannels: [Channel]) -> Void){
        
        userChannelsListener = FirestoreReference(collectionReference: .Channel).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener({ QuerySnapshot, error in
            
            guard let documents = QuerySnapshot?.documents else{return}
            
            var userChannels = documents.compactMap {(queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            userChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(userChannels)
            
        })
        
    }
    
    
    
    func downloadSubscribedChanels(completion: @escaping (_ subscribedChannels: [Channel]) -> Void){
        
        subscribedChannelsListener = FirestoreReference(collectionReference: .Channel).whereField(kMEMBERSIDS, arrayContains: User.currentId).addSnapshotListener({ QuerySnapshot, error in
            
            guard let documents = QuerySnapshot?.documents else{return}
            
            var subscribedChannels = documents.compactMap {(queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            subscribedChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(subscribedChannels)

            
            
        })
        
    }
    
    
    func downloadAllChanels(completion: @escaping (_ allChannels: [Channel]) -> Void){
        
        FirestoreReference(collectionReference: .Channel).getDocuments { querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {return}
            
            var allChannels = documents.compactMap {queryDocumentSnapshot -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            allChannels = self.removeUserChannels(allChannels)
            allChannels.sort(by: {$0.memberIds.count > $1.memberIds.count})
            completion(allChannels)
            
            
        }
        
    }
    
    
    // MARK: Helper Function
    
    func removeUserChannels(_ allChannels : [Channel]) -> [Channel] {
        var newChannels : [Channel] = []
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId){
                newChannels.append(channel)
            }
        }
        return newChannels
    }
    
    
}
