//
//  AddNewSource.swift
//  SiteData
//
//  Created by Mark Lyons on 10/20/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit

class AddNewSource: UIViewController, UITableViewDataSource{
    @IBOutlet weak var modalUIView: UIView!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var addSourceTable: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var loginView: UIView!
    
    var selectSources : [UIImage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectSources = [UIImage(named: "Amazon-Associates")!, UIImage(named: "Ezoic")!, UIImage(named: "Google-Adsense")!]
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapGestureRecognizer)
        modalUIView.layer.cornerRadius = 8
        addSourceTable.rowHeight = 105
        addSourceTable.dataSource = self
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        bottomCornerRounding(toRound: nextButton)
    }
    
    func bottomCornerRounding(toRound : UIView) {
        let path = UIBezierPath(
            roundedRect:toRound.bounds,
            byRoundingCorners:[.bottomRight, .bottomLeft],
            cornerRadii: CGSize(width: 8, height:  8)
        )
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        toRound.layer.mask = maskLayer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectSources!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currCell = tableView.dequeueReusableCell(withIdentifier: "addSourceCell") as! AddSourceCell
        currCell.sourceImage.image = selectSources![indexPath.row]
        currCell.containingView.layer.cornerRadius = 10
        currCell.containingView.layer.shadowColor = hexStringToUIColor(hex: "C0C0C0").cgColor
        currCell.containingView.layer.shadowOpacity = 1
        currCell.containingView.layer.shadowOffset = CGSize.zero
        currCell.containingView.layer.shadowRadius = 5
        
        return currCell
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
