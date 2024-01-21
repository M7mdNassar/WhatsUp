
import FirebaseFirestoreSwift    // covert document data to User instance
import Foundation
import Firebase

struct User : Codable {
    var id = ""
    var userName : String
    var email : String
    var pushId = ""
    var avatarLink = ""
    var status : String
    
    
    static var currentId : String {
        return Auth.auth().currentUser!.uid
    }
    
    
    static var currentUser : User? {
        if Auth.auth().currentUser != nil{
            
            if let data = userDefaults.data(forKey: kCURRENTUSER){
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: data)
                    
                    return userObject
                }catch {
                    print(error.localizedDescription)
                }
            }
            
        }
        return nil
    }
}



func saveUserLocally(user: User) {
    
    let encode = JSONEncoder()
    do{
        let data = try encode.encode(user)
        userDefaults.set(data, forKey: kCURRENTUSER)
    }catch{
        print(error.localizedDescription)
    }
}

