//
//  WebViewViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/27.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController,WKNavigationDelegate
{

    var url:String = ""

    override func viewDidAppear(_ animated: Bool) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let webview = WKWebView(frame: self.view.bounds)
        webview.navigationDelegate = self
        let url = NSURL(string: self.url)
        let request = NSURLRequest(url: url as! URL)
        webview.load(request as URLRequest)
        self.view.addSubview(webview)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
