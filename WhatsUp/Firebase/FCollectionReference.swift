
import Foundation
import FirebaseFirestoreInternal


enum FCollectionReference : String{
    case User
    case Chat
    case Message
    case Typing
}

// get the refernce of specific collection

func FirestoreReference(collectionReference : FCollectionReference) -> CollectionReference
{
    return Firestore.firestore().collection(collectionReference.rawValue)
}


