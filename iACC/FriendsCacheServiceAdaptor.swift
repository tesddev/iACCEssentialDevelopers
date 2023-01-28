//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

struct FriendsCacheServiceAdaptor: ItemsServices {
    let cache: FriendsCache
    let select: (Friend) -> ()
    
    func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void) {
        cache.loadFriends { result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map{ friends in
                    friends.map{ friend in
                        ItemViewModel(friend: friend, selection: {
                            select(friend)
                        })
                    }
                })
            }
        }
    }
}
