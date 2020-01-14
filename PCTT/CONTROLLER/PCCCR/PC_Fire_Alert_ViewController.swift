//
//  PC_Fire_Alert_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/15/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Fire_Alert_ViewController: UIViewController {

   @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!
    
    var option: NSString!
    
    var indexing: Int = 0
    
    var titleOption: NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("Calendar_Cell")
        
        tableView.withCell("Map_Cell")

        dataList = NSMutableArray.init(array: [
            ["title":"Mô tả", "description":"", "input":"1", "img": "ic_des", "ident": "Calendar_Cell"],
            ["title":"Mức độ", "description":"", "img": "ic_level", "ident": "Calendar_Cell"],
            ["title":"Tọa độ", "x":"", "y":"", "img": "ic_location", "ident": "Map_Cell"],
        ])
        
        tableView.reloadData()
    }

    @IBAction func didPressBack() {
        tableView.reloadData()
    }
    
//     @IBAction func didRequestData() {
//
//        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":option!,
//                                                    "overrideAlert":"1",
//                                                    "overrideLoading":"1",
//                                                    "postFix":option!,
//                                                    "host":self], withCache: { (cacheString) in
//            if cacheString != "" {
//                self.dataList.removeAllObjects()
//
//                self.dataList.addObjects(from: (((cacheString! as NSString).objectFromJSONString() as! NSDictionary)["array"] as! NSArray) as! [Any] )
//
//                self.tableView.reloadData()
//            }
//        }, andCompletion: { (response, errorCode, error, isValid, object) in
//            let result = response?.dictionize() ?? [:]
//
//            if error != nil {
//                return
//            }
//
//            self.dataList.removeAllObjects()
//
//            self.dataList.addObjects(from: (result["array"] as! NSArray) as! [Any])
//
//            self.tableView.reloadData()
//        })
//    }
    
    func getMenuList() -> [Any] {
        return [
            ["title": "Chưa xác định", "id": "1"],
            ["title": "Có nguy cơ cháy cao", "id": "2"],
            ["title": "Đang cháy ở mức độ nhỏ", "id": "3"],
            ["title": "Đang cháy ở mức độ nguy hiểm", "id": "4"],
            ["title": "Đang cháy ở mức độ cực kỳ nguy hiểm", "id": "5"],
        ]
       }
}


extension PC_Fire_Alert_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row != 2 ? UITableView.automaticDimension : 222
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = dataList[indexPath.row] as! NSDictionary

        let cell  = tableView.dequeueReusableCell(withIdentifier: data.getValueFromKey("ident"), for: indexPath)
                
        let ava = self.withView(cell, tag: 11) as! UIImageView

        ava.image = UIImage.init(named: data.getValueFromKey("img"))


        let contentRight = self.withView(cell, tag: 12) as! UILabel

        contentRight.text = data.getValueFromKey("title")

        
        
        if data.getValueFromKey("ident") == "Calendar_Cell" {
            let input = self.withView(cell, tag: 14) as! UITextField

            input.text = data.getValueFromKey("description")

            input.isHidden = data.getValueFromKey("input") == ""
            
            
            
            let button = self.withView(cell, tag: 15) as! UIButton

            button.widthConstaint?.constant = 0
            
            
            
            let menu = self.withView(cell, tag: 16) as! DropButton
            
            menu.isHidden = data.getValueFromKey("input") != ""
            
            menu.action(forTouch: [:]) { (objc) in
                menu.didDropDown(withData: self.getMenuList()) { (objc) in
                    if objc != nil {
                        let title = ((objc as! NSDictionary)["data"] as! NSDictionary)["title"]
                        
                        let id = ((objc as! NSDictionary)["data"] as! NSDictionary)["id"]
                               
                        menu.setTitle((title as! String), for: .normal)
                    }
                }
            }
        } else {
            (cell as! Map_Cell).tempLocation = [["lat": self.latLng.getValueFromKey("lat"), "lng": self.latLng.getValueFromKey("lng")]]
        }
                
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
       
    }
}
