//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

struct ReceivedTransfersAPIItemsServicesAdapter: ItemsServices {
    let api: TransfersAPI
    let select: (Transfer) -> ()
    
    func loadItems(completion: @escaping (Result<[ItemViewModel], Error>) -> Void) {
        api.loadTransfers { result in
            DispatchQueue.mainAsyncIfNeeded {
                completion(result.map{ transfers in
                    transfers
                        .filter{ !$0.isSender }
                        .map{ transfer in
                        ItemViewModel(transfer: transfer,
                                      longDateStyle: false,
                                      selection: {
                                        select(transfer)
                                      })
                    }
                })
            }
        }
    }
}
