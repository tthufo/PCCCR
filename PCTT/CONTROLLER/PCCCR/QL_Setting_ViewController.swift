//
//  QL_Setting_ViewController.swift
//  QLDT
//
//  Created by Thanh Hai Tran on 9/2/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

import UIKit

class QL_Setting_ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var menu: DropButton!
    
    @IBOutlet var phone: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        if self.getObject("timer") == nil {
            self.add(["title":"    10 phút", "time": 10], andKey:"timer")
        }
        
        let setting = self.getObject("timer")["title"]
        
        menu.setTitle(setting as? String, for: .normal)
        
        if self.getValue("phone") == nil {
            self.addValue("", andKey:"phone")
        }
        
        phone.text = self.getValue("phone")
        
        phone.inputAccessoryView = toolBar()
        
        self.view.action(forTouch: [:]) { (obj) in
            self.view.endEditing(true)
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
    
    func getMenuList() -> [Any] {
        let array = NSMutableArray()
        
        for i in stride(from: 10, to: 65, by: 5) {
            array.add(["title":"    %i phút".format(parameters: i == 0 ? i : i), "time": i == 0 ? i : i])
        }
        
        return array as! [Any]
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func didPressSave() {
        self.view.endEditing(true)
        self.showToast("Cập nhật thành công", andPos: 0)
        self.addValue(phone.text, andKey: "phone")
    }
    
    @IBAction func didPressMenu(menu: DropButton) {
        menu.didDropDown(withData: getMenuList()) { (objc) in
            if objc != nil {
                let result = ((objc as! NSDictionary)["data"] as! NSDictionary)["title"]
                
                let time = ((objc as! NSDictionary)["data"] as! NSDictionary)["time"]
                                
                menu.setTitle(result as? String, for: .normal)
                
                self.add(["title": result ?? "", "time": time], andKey: "timer")
                
                self.showToast("Cập nhật thành công", andPos: 0)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
