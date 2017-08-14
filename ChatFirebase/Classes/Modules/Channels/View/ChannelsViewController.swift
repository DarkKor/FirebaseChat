
//
//  ChannelsViewController.swift
//  ChatFirebase
//
//  Created by Dmitriy on 13.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit

class ChannelsViewController: UIViewController {

    var presenter: ChannelsPresenter!
    
    fileprivate var channelViewModels: [ChatChannelViewModel] = [ChatChannelViewModel]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        presenter.startObservingNewChannels()
        
        tableView.register(R.nib.channelTableViewCell)
        
        addNewChannelButton()
        addLogoutButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ChannelsViewController: ChannelsViewProtocol {
    func startLoading() {
        
    }
    
    func finishLoading() {
        
    }
    
    func newChannelDidAdd(_ channel: ChatChannelViewModel) {
        channelViewModels.append(channel)
        tableView.reloadData()
    }
    
    func openChannel(_ channel: ChatChannelViewModel) {
        
    }
}

private extension ChannelsViewController {
    func addNewChannelButton() {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        button.setTitle("+", for: .normal)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(addNewChannel(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        navigationController?.navigationBar.backgroundColor = UIColor.black
        navigationController?.navigationBar.barStyle = .black
    }
    
    func addLogoutButton() {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 84.0, height: 44.0))
        button.setTitle("Logout", for: .normal)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(logout(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        navigationController?.navigationBar.backgroundColor = UIColor.black
        navigationController?.navigationBar.barStyle = .black
    }
    
    @objc func addNewChannel(_ button: UIBarButtonItem) {
        let controller = UIAlertController(title: "Add new chat", message: "Enter title of new chat", preferredStyle: .alert)
        controller.addTextField { (textField) in
            textField.placeholder = "New chat title..."
            textField.tag = 0
        }
        controller.addTextField { (textField) in
            textField.placeholder = "Recipient name..."
            textField.tag = 1
        }
        controller.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            var channelName: String?
            var recipientName: String?
            if let text = controller.textFields?.first?.text, !text.isEmpty {
                channelName = text
            }
            if let text = controller.textFields?.last?.text, !text.isEmpty {
                recipientName = text
            }
            guard let user = recipientName, let channel = channelName else { return }
            self.presenter.createNewChannel(channel, with: user)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func logout(_ button: UIBarButtonItem) {
        presenter.logout()
    }
}

extension ChannelsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = R.reuseIdentifier.channelTableViewCellID
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)!
        cell.channelViewModel = channelViewModels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = channelViewModels[indexPath.row]
        presenter.openChannel(channel)
    }
}

extension ChannelsViewController: ViewControllerProtocol {
    static func storyBoardName() -> String {
        return "Messaging"
    }
}

