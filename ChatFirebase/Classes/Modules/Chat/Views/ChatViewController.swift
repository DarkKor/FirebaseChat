//
//  ChatViewController.swift
//  ChatFirebase
//
//  Created by Dmitriy on 14.08.17.
//  Copyright © 2017 GrowApp Solutions. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    var presenter: ChatPresenter!
    
    fileprivate var messages = [ChatMessageViewModel]()
    fileprivate var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.senderDisplayName = UserDefaults.standard.object(forKey: "username") as! String
        
        if let senderId = presenter.uid {
            self.senderId = senderId
            
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
        
        self.title = presenter.channelName
        
        presenter.startObservingMessages()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        addBackButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//  MARK: - ChatViewProtocol
extension ChatViewController: ChatViewProtocol {
    func messageDidAdd(_ message: ChatMessageViewModel) {
        messages.append(message)
        
        if message.hasImage {
            loadImageIfNeeded(message)
        }
        else {
            finishReceivingMessage()
        }
    }
    
    func messageDidUpdate(_ message: ChatMessageViewModel) {
        if let index = messages.index(of: message) {
            messages[index] = message
        }
        if message.hasImage {
            loadImageIfNeeded(message)
        }
    }
    
    func imageWasUploaded() {
        
    }
}

//  MARK: - JSQMessagesViewController
extension ChatViewController {
    func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item].jsqMessage!
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item].jsqMessage!
        if message.senderId == senderId {
            return outgoingBubbleImageView
        }
        else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item].jsqMessage!
        
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        print("\(message)")
    }
    
    override func didPressSend(_ button: UIButton!,
                               withMessageText text: String!,
                               senderId: String!,
                               senderDisplayName: String!,
                               date: Date!) {
        presenter.addMessage(text, date: date)
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let picker = UIImagePickerController()
        picker.delegate = self
//        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
//            picker.sourceType = .camera
//        } else {
            picker.sourceType = .photoLibrary
//        }
        
        present(picker, animated: true, completion:nil)
    }
}

// MARK: - Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        guard let photo = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        guard let key = presenter.addFakePhotoMessage(date: Date()) else {
            return
        }
        
        guard let data = UIImageJPEGRepresentation(photo, 1.0) else {
            return
        }
        
        self.presenter.uploadImage(data, completion: { (path) in
            if let path = path {
                self.presenter.updatePhotoMessage(key, with: path)
            }
        })
        
        finishSendingMessage()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

// MARK: - Private Methods
private extension ChatViewController {
    func addBackButton() {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0))
        button.setTitle("Back", for: .normal)
        button.showsTouchWhenHighlighted = true
        button.addTarget(self, action: #selector(backButtonTouched(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        
        navigationController?.navigationBar.backgroundColor = UIColor.black
        navigationController?.navigationBar.barStyle = .black
    }
    
    @objc func backButtonTouched(_ button: UIBarButtonItem) {
        presenter.finishObservingMessages()
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func loadImageIfNeeded(_ message: ChatMessageViewModel) {
        if !message.isImageDownloaded {
            message.loadImage { (image) in
                
//                if let image = image {
//                    print("this = \(message.jsqMessage!.messageHash())")
//                    print("last = \(self.messages.last!.messageHash())")
//                    print("--------")
//                }
//                else {
//                    print("trying load NOTSET")
//                }
                
                self.collectionView.reloadData()
            }
        }
    }
}

extension ChatViewController: ViewControllerProtocol {
    static func storyBoardName() -> String {
        return "Messaging"
    }
}
