//
//  PC_Resource_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/12/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Resource_ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!
    
    var data: NSDictionary!
        
    var kb: KeyBoard!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        kb = KeyBoard.shareInstance()

        tableView.withCell("PC_Resource_Cell")
        
        dataList = NSMutableArray.init()
                          
        didRequestData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        kb.keyboardOff()
     }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        kb.keyboard { (height, isOn) in
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: isOn ? (height - 50) : 0, right: 0)
        }
     }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
     @IBAction func didRequestData() {
        LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"GetResourceForFire",
                                                    "id": data.getValueFromKey("id"),
                                                    "overrideAlert":"1",
                                                    "overrideLoading":"1",
                                                    "postFix":"GetResourceForFire",
                                                    "host":self], withCache: { (cacheString) in
            if cacheString != "" {
                self.dataList.removeAllObjects()
                
                self.dataList.addObjects(from: (((cacheString! as NSString).objectFromJSONString() as! NSDictionary)["items"] as! NSArray).withMutable() as! [Any] )
                
                self.tableView.reloadData()
            }
        }, andCompletion: { (response, errorCode, error, isValid, object) in
            let result = response?.dictionize() ?? [:]
            
            if error != nil {
                return
            }
            
            self.dataList.removeAllObjects()

            self.dataList.addObjects(from: (result["items"] as! NSArray).withMutable() as! [Any])

            self.tableView.reloadData()
        })
    }
    
    @IBAction func didRequestUpdateResource() {
        
        var progress: Int = 0
        
        for dict in dataList {
            LTRequest.sharedInstance()?.didRequestInfo(["CMD_CODE":"UpdateResourcesAmount",
                                                        "fire_id": data.getValueFromKey("id"),
                                                        "res_id": (dict as! NSDictionary).getValueFromKey("res_id"),
                                                        "amount": (dict as! NSDictionary).getValueFromKey("amount") == "" ? "0" : (dict as! NSDictionary).getValueFromKey("amount"),
                                                        "overrideAlert":"1",
                                                        "postFix":"UpdateResourcesAmount"
                                                        ], withCache: { (cacheString) in
            }, andCompletion: { (response, errorCode, error, isValid, object) in
               progress += 1
                
                self.showSVHUD("Đang cập nhật", andOption: 0)

                if (progress == self.dataList.count) {
                    self.hideSVHUD()
                    self.navigationController?.popViewController(animated: true)
                    self.showToast("Cập nhật thành công", andPos: 0)
                }
            })
        }
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
        
        for var dict in dataList {
            if (dict as! NSMutableDictionary).getValueFromKey("res_id") == Id {
                (dict as! NSMutableDictionary)["amount"] = textField.text
            }
        }
    }
}

extension PC_Resource_ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "PC_Resource_Cell", for: indexPath)
                
        let data = dataList[indexPath.row] as! NSDictionary
                
        
        let ava = self.withView(cell, tag: 11) as! UIImageView
        
        ava.image = UIImage.init(named: "ic_fireman")
        
        
        let contentRight = self.withView(cell, tag: 12) as! UILabel
        
        contentRight.text = data.getValueFromKey("res_name") == "" ? "Đang cập nhật" : data.getValueFromKey("res_name")
        
        
        let dayLeft = self.withView(cell, tag: 14) as! UITextField
        
        dayLeft.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

        dayLeft.accessibilityLabel = data.getValueFromKey("res_id")
            
        dayLeft.text = data.getValueFromKey("amount")
        
        dayLeft.inputAccessoryView = self.toolBar()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
