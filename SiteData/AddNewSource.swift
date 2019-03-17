//
//  AddNewSource.swift
//  SiteData
//
//  Created by Mark Lyons on 10/22/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit

class AddNewSource: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var amazonContainingView: UIView!
    @IBOutlet weak var amazonImage: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var loginButton: UIButton!
    
    var possibleSources : [String] = ["Amazon Associates"]
    var selectedSource : String = "Amazon Associates" //default set amazon
    var databaseMgr : DataActions?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 5
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let loginPage = segue.destination as! LoginViewController
        loginPage.selectedSource = self.selectedSource
        loginPage.databaseMgr = self.databaseMgr
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return possibleSources.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedSource = possibleSources[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view as? UILabel { label = v }
        label.font = UIFont (name: "Helvetica Neue", size: 24)
        label.textColor = hexStringToUIColor(hex: "0365D6")
        label.text =  possibleSources[row]
        label.textAlignment = .center
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 51.0
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
