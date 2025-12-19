//
//  BookCollectionViewModel.swift
//  Pager
//
//  Created by Pradheep G on 12/12/25.
//

@MainActor
class BookCollectionViewModel {
    let repository = CollectionRepository()

    func renameCollection(_ collection: BookCollection, to newName: String) -> Result<Void, Error> {
        switch repository.updateCollection(collection, name: newName, description: nil) {
        case .success():
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func deleteCollection(_ collection: BookCollection) -> Result<Void, Error> {
        switch repository.deleteCollection(collection) {
        case .success():
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func addNewCollection(as name: String,description: String? = nil) -> Result<BookCollection, Error> {
        guard let user = UserSession.shared.currentUser else {
            return .failure(UserError.userNotFound)
        }
        switch repository.createCollection(name: name, description: nil, owner: user) {
        case .success(let bookCollection):
            return .success(bookCollection)
        case .failure(let error):
            return .failure(error)
        }
    }
}
