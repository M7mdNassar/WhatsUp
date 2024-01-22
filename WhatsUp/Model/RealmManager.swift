
import Foundation
import RealmSwift

class RealmManager{
    
    static let shared = RealmManager()
    
    let realm = try! Realm()
    
    private init (){}
    
    func save<T: Object> (_ object: T){
        
        do {
           try realm.write {
                realm.add(object, update: .all)
            }
        }catch{
            print("error falid save locally ", error)
        }
    }
}
