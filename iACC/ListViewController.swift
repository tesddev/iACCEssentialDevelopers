//
// Copyright © Essential Developer. All rights reserved.
//

import UIKit

protocol FriendsServices {
    func loadFriends(completion: @escaping (Result<[Friend], Error>) -> Void)
}
protocol CardsServices {
    func loadCards(completion: @escaping (Result<[Card], Error>) -> Void)
}
protocol TransferServices {
    func loadTransfers(completion: @escaping (Result<[Transfer], Error>) -> Void)
}

class ListViewController: UITableViewController {
    var items = [ItemViewModel]()
    var friendServices: FriendsServices?
    var cardsServices: CardsServices?
    var transferServices: TransferServices?
    
    var retryCount = 0
    var maxRetryCount = 0
    var shouldRetry = false
    
    var longDateStyle = false
    
    var fromReceivedTransfersScreen = false
    var fromSentTransfersScreen = false
    var fromCardsScreen = false
    var fromFriendsScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        if fromFriendsScreen {
            shouldRetry = true
            maxRetryCount = 2
            
            title = "Friends"
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
            
        } else if fromCardsScreen {
            shouldRetry = false
            
            title = "Cards"
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCard))
            
        } else if fromSentTransfersScreen {
            shouldRetry = true
            maxRetryCount = 1
            longDateStyle = true
            
            navigationItem.title = "Sent"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(sendMoney))
            
        } else if fromReceivedTransfersScreen {
            shouldRetry = true
            maxRetryCount = 1
            longDateStyle = false
            
            navigationItem.title = "Received"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Request", style: .done, target: self, action: #selector(requestMoney))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if tableView.numberOfRows(inSection: 0) == 0 {
            refresh()
        }
    }
    
    @objc private func refresh() {
        refreshControl?.beginRefreshing()
        if fromFriendsScreen {
            friendServices?.loadFriends { [weak self] result in
                DispatchQueue.mainAsyncIfNeeded {
                    self?.handleAPIResult(result.map{ friends in
                        if User.shared?.isPremium == true {
                            (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).cache.save(friends)
                        }
                        return friends.map{ friend in
                            ItemViewModel(friend: friend, selection: {
                                self?.select(friend: friend)
                            })
                        }
                    })
                }
            }
        } else if fromCardsScreen {
            cardsServices?.loadCards { [weak self] result in
                DispatchQueue.mainAsyncIfNeeded {
                    self?.handleAPIResult(result.map{ cards in
                        cards.map{ card in
                            ItemViewModel(card: card, selection: {
                                self?.select(card: card)
                            })
                        }
                    })
                }
            }
        } else if fromSentTransfersScreen || fromReceivedTransfersScreen {
            transferServices?.loadTransfers { [weak self, longDateStyle] result in
                DispatchQueue.mainAsyncIfNeeded {
                    self?.handleAPIResult(result.map{ transfers in
                        transfers
                            .filter{
                                self?.fromSentTransfersScreen ?? false ? $0.isSender : !$0.isSender
                            }
                            .map{ transfer in
                            ItemViewModel(transfer: transfer,
                                          longDateStyle: longDateStyle,
                                          selection: {
                                            self?.select(transfer: transfer)
                                          })
                        }
                    })
                }
            }
        } else {
            fatalError("unknown context")
        }
    }
    
    private func handleAPIResult(_ result: Result<[ItemViewModel], Error>) {
        switch result {
        case let .success(items):
            self.retryCount = 0
            
            self.items = items
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
            
        case let .failure(error):
            if shouldRetry && retryCount < maxRetryCount {
                retryCount += 1
                
                refresh()
                return
            }
            
            retryCount = 0
            
            if fromFriendsScreen && User.shared?.isPremium == true {
                (UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate).cache.loadFriends { [weak self] result in
                    DispatchQueue.mainAsyncIfNeeded {
                        switch result {
                        case let .success(items):
                            self?.items = items.map{ friend in
                                ItemViewModel(friend: friend, selection: { [weak self] in
                                        self?.select(friend: friend)
                                })
                            }
                            self?.tableView.reloadData()
                            
                        case let .failure(error):
                            self?.show(error: error)
                        }
                        self?.refreshControl?.endRefreshing()
                    }
                }
            } else {
                show(error: error)
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "ItemCell")
        cell.configure(item)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        item.select()
    }
}
