//
//  ViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/25.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import PageMenu



class ViewController: UIViewController,UISearchBarDelegate {
    
   
    @IBOutlet weak var searchButton: UIBarButtonItem!
    private var searchBar = UISearchBar()
    private var pageMenu: CAPSPageMenu?
    private var controllerArray : [UIViewController] = []
    private var controllerTitleArray = ["首页","国际足球","中国足球","赛前","转会状态","7M制造","彩票"]
    
    lazy var searchBackgroundView : UIView = {
        let view = UIView.init()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(searchFinished))
        view.backgroundColor = UIColor.black
        view.alpha = 0.3
        view.addGestureRecognizer(tap)
        view.isHidden = true
        return view
    }()
    override func viewWillDisappear(_ animated: Bool) {
        self.searchFinished()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        self.setupSearch()
        self.setupControllerArray()
    }
    func setupSearch(){
        self.searchBar = UISearchBar.init()
        self.view.addSubview(self.searchBar)
        self.searchBar.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(44)
        }
        self.searchBar.placeholder = "搜索"
        self.searchBar.delegate = self
        self.searchBar.setShowsCancelButton(true, animated: true)
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.backgroundImage = self.imageWithColor(color: UIColor.init(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1), size: self.searchBar.bounds.size)
        
        self.view.addSubview(self.searchBackgroundView)
        self.searchBackgroundView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(0)
            make.top.equalTo(self.searchBar.snp.bottom).offset(0)
            make.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
        }
    }
    func imageWithColor(color:UIColor,size:CGSize) -> UIImage {
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect);
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image;
    }
    
    func setupControllerArray(){
        
        for i in 0...controllerTitleArray.count-1 {
            let controller : UIViewController = DVMessageViewController()
            controller.title = controllerTitleArray[i]
            controllerArray.append(controller)
            
        }
        let parameters: [CAPSPageMenuOption] = [
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor.white),
            .selectionIndicatorColor(UIColor.blue),
            .menuItemFont(UIFont(name: "HelveticaNeue", size: 14.0)!),
            .menuItemWidth(60),
            .unselectedMenuItemLabelColor(UIColor.black),
            .menuHeight(30),
            .selectedMenuItemLabelColor(UIColor.blue)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect.init(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height-64.0), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }
    func searchFinished(){
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.searchBackgroundView.isHidden = true
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    @IBAction func searchAction(_ sender: Any) {
        self.searchBackgroundView.isHidden = false
        self.searchBar.becomeFirstResponder()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    //MARK:代理方法
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchFinished()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchView = DVSearchViewController()
        self.navigationController!.pushViewController(searchView, animated: true)
        self.searchFinished()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

