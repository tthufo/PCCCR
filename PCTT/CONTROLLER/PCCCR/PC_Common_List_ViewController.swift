//
//  PC_Common_List_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/12/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import JSONKit_NoWarning

class PC_Common_List_ViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!
    
    var option: NSString!
    
    var indexing: Int = 0
    
    var titleOption: NSString!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("PC_Common_Cell")
        
        dataList = NSMutableArray.init()
        
        titleLabel.text = (titleOption as String).uppercased()
        
        didRequestData()
    }

    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
     @IBAction func didRequestData() {
        
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":option!,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":option!,
                                                    "host":self], withCache: { (cacheString) in
            if cacheString != "" {
                self.dataList.removeAllObjects()
                
                self.dataList.addObjects(from: (((cacheString! as NSString).objectFromJSONString() as! NSDictionary)["array"] as! NSArray) as! [Any] )
                
                self.tableView.reloadData()
            }
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            
            if error != nil {
                return
            }
            
            self.dataList.removeAllObjects()
        
            self.dataList.addObjects(from: (result["array"] as! NSArray) as! [Any])
            
            self.tableView.reloadData()
        })
    }
}


extension PC_Common_List_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "PC_Common_Cell", for: indexPath)
                
        let data = dataList[indexPath.row] as! NSDictionary
                
        
        let ava = self.withView(cell, tag: 11) as! UIImageView
        
        ava.image = UIImage.init(named: "ic_fire")
        
        
        let contentRight = self.withView(cell, tag: 12) as! UILabel
        
        contentRight.text = data.getValueFromKey("description") == "" ? "Đang cập nhật" : data.getValueFromKey("description")
        
        
        let dayLeft = self.withView(cell, tag: 14) as! UILabel
        
        dayLeft.text = data.getValueFromKey("time_received")
        
        
        let dayRight = self.withView(cell, tag: 15) as! UILabel
        
        dayRight.text = data.getValueFromKey("level")
        
    
        let bg = self.withView(cell, tag: 16) as! UIView
               
        if data.getValueFromKey("is_verified") == "1" {
            bg.backgroundColor = UIColor.systemYellow
        } else {
            bg.backgroundColor = UIColor.groupTableViewBackground
        }
                
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let data = dataList[indexPath.row] as! NSDictionary

        switch indexing {
        case 0 :
            break
        case 2:
            let mapBox = PC_Direction_ViewController.init()
//            mapBox.tempLocation = [["lat": self.latLng.getValueFromKey("lat"), "lng": self.latLng.getValueFromKey("lng")], ["lat": data.getValueFromKey("lat"), "lng": data.getValueFromKey("lon")]]
                    
             mapBox.information = data
            
             mapBox.isMulti = true
            
             mapBox.mutliType = "Polyline" // Point
            
             mapBox.isForShow = true
             
             self.navigationController?.pushViewController(mapBox, animated: true)
            break
        case 3:
            let resource = PC_Resource_ViewController.init()
            resource.data = data
            self.navigationController?.pushViewController(resource, animated: true)
            break
        case 4:
       
            break
        default:
            break
        }
    }
}
