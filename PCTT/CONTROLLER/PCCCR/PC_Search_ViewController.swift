//
//  PC_Search_ViewController.swift
//  PCTT
//
//  Created by Thanh Hai Tran on 1/13/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

import UIKit

class PC_Search_ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    var dataList: NSMutableArray!
    
    var option: NSMutableDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.withCell("Calendar_Cell")
        
        dataList = NSMutableArray.init(array: ["start", "stop", "description"])
        
        option = NSMutableDictionary.init(dictionary: ["start": "", "end": "", "description":""])
                
//        didRequestData()
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
       
//       for var dict in dataList {
//           if (dict as! NSMutableDictionary).getValueFromKey("res_id") == Id {
       option[Id] = textField.text
//           }
//       }

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
        
        contentRight.text = option.getValueFromKey(data as String)
        
        
        let dayLeft = self.withView(cell, tag: 14) as! UITextField
        
        dayLeft.addTarget(self, action: #selector(textIsChanging), for: .editingChanged)

        dayLeft.accessibilityLabel = data as String
            
        dayLeft.text = option.getValueFromKey(data as String)
        
        dayLeft.inputView = self.toolBar()
        
        
        let action = self.withView(cell, tag: 15) as! UIButton
        
        action.setWidth(indexPath.row == 2 ? 0 : 35, animated: false)
        
        action.action(forTouch: [:]) { (objc) in
            
        }
                
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        let data = dataList[indexPath.row] as! NSDictionary

//        switch indexing {
//        case 0 :
//            break
//        case 2:
//            break
//        case 3:
//            let resource = PC_Resource_ViewController.init()
//            resource.data = data
//            self.navigationController?.pushViewController(resource, animated: true)
//            break
//        case 4:
//            break
//        default:
//            break
//        }
    }
}
