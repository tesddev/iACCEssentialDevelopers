//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

struct CardsAPIItemsServicesAdapter: ItemsServices {
    let api: CardAPI
    let select: (Card) -> ()
    
    func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void) {
        api.loadCards { result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map{ cards in
                    cards.map{ card in
                        ItemViewModel(card: card, selection: {
                            select(card)
                        })
                    }
                })
            }
        }
    }
}
