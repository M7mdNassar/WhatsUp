
import Foundation
import Firebase
import FirebaseFirestoreSwift


struct Channel: Codable{
    
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
    
    
    enum CodingKeys: String , CodingKey{
        // if the name in model different that on firebase //
        case id
        case name
        case adminId
        case memberIds
        case avatarLink
        case aboutChannel
        case createDate
        // the above .. assume in the model the same in firebase
        case lastMessageDate = "date"   // this mean in the firebase is date
    }
    
}














