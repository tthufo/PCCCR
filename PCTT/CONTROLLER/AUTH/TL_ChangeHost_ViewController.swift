//
//  TL_ChangeHost_ViewController.swift
//  QLDT
//
//  Created by Thanh Hai Tran on 7/28/18.
//  Copyright © 2018 Thanh Hai Tran. All rights reserved.
//

import UIKit

class TL_ChangeHost_ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var host: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        host.text = self.getValue("url")
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return true
    }
    
    @IBAction func didPressSubmi() {
        if host.text == "" {
            self.showToast("Bạn chưa nhập địa chỉ máy chủ", andPos: 0)
            
            return
        }
        
        self.addValue(host.text, andKey: "url")
        
        LTRequest.sharedInstance()?.address = host.text
        
        self.showToast("Cập nhật thành công", andPos: 0)
    }
    
    @IBAction func didPressBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
