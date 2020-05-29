//
//  PC_Search_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/13/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

import DatePickerDialog

class PC_Search_ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!
    
    var option: NSMutableDictionary!
    
    var titles = ["Thời gian bắt đầu cháy", "Thời gian kết thúc cháy", "Nội dung tìm kiếm"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("Calendar_Cell")
        
        dataList = NSMutableArray.init(array: ["start", "end", "description"])
        
        option = NSMutableDictionary.init(dictionary: ["start": "", "end": "", "description":""])
    }
    
    func toolBar() -> UIToolbar {
             
         let toolBar = UIToolbar.init(frame: CGRect.init(x: 0, y: 0, width: Int(self.screenWidth()), height: 50))
         
         toolBar.barStyle = .default
         
         toolBar.items = [UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                          UIBarButtonItem.init(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                          UIBarButtonItem.init(title: "Thoát", style: .done, target: self, action: #selector(disMiss))]
         return toolBar
    }
     
     @objc func disMiss() {
         self.view.endEditing(true)
     }
    
    @objc func textIsChanging(_ textField:UITextField) {
       let Id = textField.accessibilityLabel
        option[Id as Any] = textField.text
   }
    
    @IBAction func didRequestSearch() {
        
        self.view.endEditing(true)
        
        for dict in option.allKeys {
            if option.getValueFromKey((dict as! String)) == "" {
                self.showToast("%@ trống".format(parameters: (dict as! String) == "start" ? "Thời gian bắt đầu" : (dict as! String) == "end" ? "Thời gian kết thúc" : "Nội dung mô tả") , andPos: 0)
                return
            }
        }
        
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"SearchFireInfor",
                                                    "date_start": option.getValueFromKey("start") ?? "",
                                                    "date_end": option.getValueFromKey("end") ?? "",
                                                    "keyword": option.getValueFromKey("description") ?? "",
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "host":self,
                                                    "postFix":"SearchFireInfor"
                                                    ], withCache: { (cacheString) in
        }, andCompletion: { (response, errorCode, error, isValid, object) in
             let result = response?.dictionize() ?? [:]
                                     
            if error != nil {
                self.showToast("Lỗi xảy ra, mời bạn thử  lại", andPos: 0)

                return
            }
            
            if ((result["array"] as? NSArray) != nil) && (result["array"] as? NSArray)!.count == 0 {
                self.showToast("Không có dữ liệu tìm kiếm", andPos: 0)
                
                return
            }
            
            
        })
    }
}


extension PC_Search_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 86
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "Calendar_Cell", for: indexPath)
                
        let data = dataList[indexPath.row] as! NSString
          
        let ava = self.withView(cell, tag: 11) as! UIImageView
        
        ava.image = UIImage.init(named: indexPath.row == 2 ? "ic_region" : "ic_time")
        
        
        let contentRight = self.withView(cell, tag: 12) as! UILabel
        
        contentRight.text = titles[indexPath.row]
        
        
        let dayLeft = self.withView(cell, tag: 14) as! UITextField
                
        dayLeft.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

        dayLeft.placeholder = indexPath.row == 2 ? "Nội dung tìm kiếm" : "mm/dd/yyyy"
        
        dayLeft.accessibilityLabel = data as String
            
        dayLeft.text = option.getValueFromKey(data as String)
        
        dayLeft.inputAccessoryView = self.toolBar()
        
        dayLeft.keyboardType = indexPath.row == 2 ? .default : .default
        
        
        let action = self.withView(cell, tag: 15) as! UIButton
                
        action.widthConstaint?.constant = indexPath.row == 2 ? 0 : 35
        
        action.action(forTouch: [:]) { (objc) in
            
            DatePickerDialog(showCancelButton: false).show("Chọn ngày " + (indexPath.row == 0 ? "bắt đầu" : "kết thúc"), doneButtonTitle: "Chọn", datePickerMode: .date) {
                (date) -> Void in
                if let dt = date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd/MM/yyyy"
                    self.option[data] = formatter.string(from: dt)
                    tableView.reloadData()
                }
            }
        }
        
        let actionButton = self.withView(cell, tag: 16) as! UIButton
        
        actionButton.isHidden = true

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

    }
}
