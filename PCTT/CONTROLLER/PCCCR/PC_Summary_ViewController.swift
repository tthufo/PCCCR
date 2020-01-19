//
//  PC_Summary_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/13/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Summary_ViewController: UIViewController {

    @IBOutlet var month: DropButton!

    @IBOutlet var quarter: DropButton!

    @IBOutlet var year: DropButton!

    @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!
    
    var option: NSMutableDictionary!
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("Calendar_Cell")
        
        dataList = []
        
        option = NSMutableDictionary.init()
    }
    
    func getMonthList() -> [Any] {
        let array = NSMutableArray()
        
        for i in stride(from: 1, to: 13, by: 1) {
            array.add(["title": "%i".format(parameters: i), "time": i])
        }
        
        return array as! [Any]
    }

    @IBAction func didPressMonth(menu: DropButton) {
        month.didDropDown(withData: getMonthList()) { (objc) in
            if objc != nil {
                let result = ((objc as! NSDictionary)["data"] as! NSDictionary)["title"]
                
                let time = ((objc as! NSDictionary)["data"] as! NSDictionary)["time"]
                           
                self.option["month"] = time
                    
                menu.setTitle(result as? String, for: .normal)
            }
        }
    }
    
    func getQuarterList() -> [Any] {
        let array = NSMutableArray()
        
        for i in stride(from: 1, to: 5, by: 1) {
            array.add(["title": "%i".format(parameters: i), "time": i])
        }
        
        return array as! [Any]
    }

    @IBAction func didPressQuarter(menu: DropButton) {
        quarter.didDropDown(withData: getQuarterList()) { (objc) in
            if objc != nil {
                let result = ((objc as! NSDictionary)["data"] as! NSDictionary)["title"]
                
                let time = ((objc as! NSDictionary)["data"] as! NSDictionary)["time"]
                                
                self.option["quarter"] = time

                menu.setTitle(result as? String, for: .normal)
            }
        }
    }
    
    func getYearList() -> [Any] {
        let array = NSMutableArray()
        
        for i in stride(from: 2013, to: 2031, by: 1) {
            array.add(["title": "%i".format(parameters: i), "time": i])
        }
        
        return array as! [Any]
    }

    @IBAction func didPressYear(menu: DropButton) {
        year.didDropDown(withData: getYearList()) { (objc) in
            if objc != nil {
                let result = ((objc as! NSDictionary)["data"] as! NSDictionary)["title"]
                
                let time = ((objc as! NSDictionary)["data"] as! NSDictionary)["time"]
                                
                self.option["year"] = time

                menu.setTitle(result as? String, for: .normal)
            }
        }
    }
    
    @IBAction func didPressSearch() {
        
        if option.getValueFromKey("year") == "" {
            self.showToast("Chọn năm thống kê", andPos: 0)
            return
        }
        
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"GetDamageInfor",
                                                    "month":option.getValueFromKey("month") == "" ? "0" : option.getValueFromKey("month"),
                                                    "quarter":option.getValueFromKey("quarter") == "" ? "0": option.getValueFromKey("quarter"),
                                                    "year":option.getValueFromKey("year") as Any,
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":"GetDamageInfor",
                                                    "host":self], withCache: { (cacheString) in
               }, andCompletion: { (response, errorCode, error, isValid, object) in
                   let result = response?.dictionize() ?? [:]
                   
                   if error != nil {
                       self.showToast("Không có dữ liệu", andPos: 0)
                       return
                   }
                   
               })
        
    }
}

extension PC_Summary_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "Calendar_Cell", for: indexPath)
                
//        let data = dataList[indexPath.row] as! NSString
                
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}
