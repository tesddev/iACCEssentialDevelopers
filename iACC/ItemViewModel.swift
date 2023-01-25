//	
// Copyright © Essential Developer. All rights reserved.
//

import Foundation

struct ItemViewModel {
    let title: String
    let subtitle: String
    let select: () -> ()
    
    init(transfer: Transfer, longDateStyle: Bool, selection: @escaping () -> ()) {
        let numberFormatter = Formatters.number
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = transfer.currencyCode
        
        let amount = numberFormatter.string(from: transfer.amount as NSNumber)!
        title = "\(amount) • \(transfer.description)"
        
        let dateFormatter = Formatters.date
        if longDateStyle {
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            subtitle = "Sent to: \(transfer.recipient) on \(dateFormatter.string(from: transfer.date))"
        } else {
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            subtitle = "Received from: \(transfer.sender) on \(dateFormatter.string(from: transfer.date))"
        }
        select = selection
    }
    
    init(friend: Friend, selection: @escaping () -> ()){
        title = friend.name
        subtitle = friend.phone
        select = selection
    }
    
    init(card: Card, selection: @escaping () -> ()){
        title = card.number
        subtitle = card.holder
        select = selection
    }
}

