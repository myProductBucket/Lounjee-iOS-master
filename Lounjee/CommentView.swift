//
//  CommentView.swift
//  Plop
//
//  Created by foOg on 12/12/14.
//  Copyright (c) 2014 ar-aubry. All rights reserved.
//

import UIKit

protocol CommentViewDelegate {
    func commentViewDidStartEditing(commentView: CommentView)
    func commentViewTextDidChange(commentView: CommentView)
    func commentViewDidHitSend(commentView: CommentView, message: String)
}

class CommentView: UIView {
    var delegate: CommentViewDelegate?

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.sendButton.setTitle(NSLocalizedString("Send", comment: "send button"), forState: UIControlState.Normal)
        //self.textView.layer.cornerRadius = 4.0
        //self.textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        //self.textView.layer.borderWidth = 1.0
        textView.text = "Type a message..."
        textView.textColor = UIColor.lightGrayColor()

        self.sendButton.enabled = false
    }

    @IBAction func sendAction(sender: AnyObject) {
        self.delegate?.commentViewDidHitSend(self, message: self.textView.text)
        self.textView.text = nil
        self.textView.resignFirstResponder()
    }
}

extension CommentView: UITextViewDelegate {
    func contentSizeForTextView(textView: UITextView) -> CGSize {
        textView.layoutManager.ensureLayoutForTextContainer(textView.textContainer)

        let textBounds = textView.layoutManager.usedRectForTextContainer(textView.textContainer)
        let width = ceil(textBounds.size.width + textView.textContainerInset.left + textView.textContainerInset.right)
        let height = ceil(textBounds.size.height + textView.textContainerInset.top + textView.textContainerInset.bottom)

        return CGSizeMake(width, height)
    }

    func textViewDidChange(textView: UITextView) {
        
        let textViewSize = self.contentSizeForTextView(textView)
        let viewHeight = textViewSize.height + 16.0
        let sizeDiff = viewHeight - self.frame.size.height

        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - sizeDiff, self.frame.size.width, viewHeight)
        self.layoutIfNeeded()

        self.sendButton.enabled = !textView.text.isEmpty
        self.delegate?.commentViewTextDidChange(self)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor(red: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
        }
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        self.delegate?.commentViewDidStartEditing(self)
        return true
    }
}