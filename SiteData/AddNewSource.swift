//
//  AddNewSource.swift
//  SiteData
//
//  Created by Mark Lyons on 10/20/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import UIKit

class AddNewSource: UIViewController {
    @IBOutlet weak var modalUIView: UIView!
    @IBOutlet weak var closeButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalUIView.layer.cornerRadius = 8
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        closeButton.isUserInteractionEnabled = true
        closeButton.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    


}
