//
//  Parser.swift
//  SiteData
//
//  Created by Mark Lyons on 10/14/18.
//  Copyright © 2018 Mark Lyons. All rights reserved.
//

import Foundation
import UIKit
import WebKit

protocol Parser {
    var webView : WKWebView! { get set }
    
    func loadView()
}
