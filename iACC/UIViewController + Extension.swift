//	
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

extension UIViewController {
    func select(friend: Friend) {
        let vc = FriendDetailsViewController()
        vc.friend = friend
        show(vc, sender: self)
    }
    
    func select(card: Card) {
        let vc = CardDetailsViewController()
        vc.card = card
        show(vc, sender: self)
    }
    
    func select(transfer: Transfer) {
        let vc = TransferDetailsViewController()
        vc.transfer = transfer
        show(vc, sender: self)
    }
    
    @objc func addCard() {
        let vc = AddCardViewController()
        show(vc, sender: self)
    }
    
    @objc func addFriend() {
        let vc = AddFriendViewController()
        show(vc, sender: self)
    }
    
    @objc func sendMoney() {
        let vc = SendMoneyViewController()
        show(vc, sender: self)
    }
    
    @objc func requestMoney() {
        let vc = RequestMoneyViewController()
        show(vc, sender: self)
    }
    
    func show(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.showDetailViewController(alert, sender: self)
    }
}
