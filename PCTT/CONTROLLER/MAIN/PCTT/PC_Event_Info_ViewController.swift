//
//  PC_Event_Info_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 12/13/19.
//  Copyright © 2019 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Event_Info_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    @IBOutlet var cell: UITableViewCell!

    @IBOutlet var titleText: InsetLabel!

    @IBOutlet var descText: InsetLabel!

    var dataList: NSMutableArray!
    
    @objc var eventInfo = NSDictionary()

    override func viewDidLoad() {
        super.viewDidLoad()

        print(eventInfo)
        
        tableView.withCell("PC_Event_Info_Cell")
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }

}


extension PC_Event_Info_ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? UITableView.automaticDimension : CGFloat(self.screenWidth() * 9 / 16)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellCell = indexPath.row == 0 ? cell! : tableView.dequeueReusableCell(withIdentifier:"PC_Event_Info_Cell", for: indexPath)
        
//        let data = dataList![indexPath.row] as! NSDictionary

        if indexPath.row == 0 {
            self.titleText.text = eventInfo.getValueFromKey("event_name")
            self.descText.text = eventInfo.getValueFromKey("event_description")
        } else {
            (self.withView(cellCell, tag: 11) as! UIImageView).imageUrl(url: "https://www.google.com/url?sa=i&rct=j&q=&esrc=s&source=images&cd=&ved=2ahUKEwjMibiP37HmAhWl7nMBHWr9ARgQjRx6BAgBEAQ&url=http%3A%2F%2Fwww.dotnetmart.com%2FHowTo%2FWebsitePanel_Create_Temp_URL.aspx&psig=AOvVaw13NFRBqO5vkluEe8Oc0OMa&ust=1576296186255883")
        }
//
//        let image = self.withView(cell, tag: 11) as! UIImageView
//
//        image.image = UIImage(named: "event")
//
//        let title = self.withView(cell, tag: 1) as! UILabel
//
//        title.text = data["event_name"] as? String
//
//        let des = self.withView(cell, tag: 2) as! UILabel
//
//        des.text = data["event_description"] as? String
//
        return cellCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let data = dataList![indexPath.row] as! NSDictionary

//        DropAlert.shareInstance()?.alert(withInfor: ["title":"Thông báo", "message": "Bạn có chắc chắn muốn xóa sự kiện " + data.getValueFromKey("event_name"), "buttons": ["Có"], "cancel":"Không"], andCompletion: { (index, obj) in
//            
//            if index == 0 {
//                self.requestDeleteEvent(id: data.getValueFromKey("id"))
//            }
//        })
    }
}

class InsetLabel: UILabel {
    let topInset = CGFloat(10)
    let bottomInset = CGFloat(10)
    let leftInset = CGFloat(10)
    let rightInset = CGFloat(10)

    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}
