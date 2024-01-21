
import FirebaseFirestoreSwift    // covert document data to User instance
import Foundation
import Firebase

struct User : Codable , Equatable {
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
    
    static func == (lhs: User , rhs: User) -> Bool{
        lhs.id == rhs.id
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



func createDummyUsers(){
    print("Creating dummy users")
    
    let names = ["Ahmad Qasem" , "Alaa Najmi" , "Oday Nassar" , "Bellingham" , "Modric"]
    var imageIndex = 1
    var userIndex = 1
    for i in 0..<5 {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { avatarLink in
            
            let user = User(id : id , userName: names[i], email: "user\(userIndex)@mail.com",pushId: "" , avatarLink: avatarLink ?? "",status: "No Status")
            
            userIndex += 1
            FUserListener.shared.saveUserToFierbase(user: user)
        }
        imageIndex += 1
        if imageIndex == 5{
            imageIndex = 1
        }
    }
}

