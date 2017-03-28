//
//  ViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/25.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import Alamofire

class DVMessageModel: NSObject {
    var id:NSNumber = 0
    var sortid:String = ""
    var title:String = ""
    var titlesub:String = ""
    var type:NSNumber = 0
    var source:String = ""
    var date:String = ""
    var datefolder:String = ""
    var url:String = ""
    var pic:String = ""
    var piclarge:String = ""
    var picmore:String = ""
    var iscommend:NSNumber = 0
    var istop:NSNumber = 0
    var summary:String = ""
}
class DVBannerModel: NSObject {
    var newsid:String = ""
    var datefolder:String = ""
    var praise:NSNumber = 0
    var title:String = ""
    var newstitle:String = ""
    var url:String = ""
    var pic:String = ""
    var summary:String = ""
}

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    private let TableViewHeaderHeight:CGFloat = 200.0
    @IBOutlet weak var searchButton: UIBarButtonItem!
 
//    private var photoUrlArray = [String]()
//    private var textArray = [String]()
    
    private var bannerArray = [DVBannerModel]()
    private var listArray = [DVMessageModel]()
    private var searchBar = UISearchBar()
    
    //MARK:懒加载
    lazy var mainTableView: UITableView = {
       let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    lazy var bannerView: DVBannerView = {
        let view = DVBannerView.init(viewHeight:200.0)
        view.myFunc = {(index) -> Void in
            let web = WebViewViewController()
            let model = self.bannerArray[index]
            web.url = model.url
            self.navigationController!.pushViewController(web, animated: true)
        }
        return view
    }()
    //MARK:内部方法
    override func viewWillDisappear(_ animated: Bool) {
        self.searchBar.text = ""
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = UIColor.init(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1)
        self.setupView()
        self.setupData()
    }
    func setupView() {
        
        self.searchBar = UISearchBar.init()
        self.view.addSubview(self.searchBar)
        self.searchBar.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(44)
        }
        self.searchBar.placeholder = "search"
        self.searchBar.delegate = self
        self.searchBar.setShowsCancelButton(true, animated: true)
        self.searchBar.backgroundColor = UIColor.white
        self.searchBar.backgroundImage = self.imageWithColor(color: UIColor.init(colorLiteralRed: 245/255.0, green: 245/255.0, blue: 245/255.0, alpha: 1), size: self.searchBar.bounds.size)
        
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(0)
            make.top.equalTo(self.searchBar.snp.bottom).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
    }
    func imageWithColor(color:UIColor,size:CGSize) -> UIImage
    {
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size);
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect);
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return image;
    }
    func setupData(){
        
        let request = DVNewworkRequest()
        request.getRequest(urlString: MSG_pathList as String, params:[:], success: { (response) in
            let dataArray = response["data"] as! [Dictionary<String,AnyObject>]
            self.listArray.removeAll()
            for dataDic in dataArray{
                let model = DVMessageModel()
                model.id = dataDic ["id"] as! NSNumber
                model.sortid = dataDic["sortid"] as! String
                model.title = dataDic["title"] as! String
                model.titlesub = dataDic["titlesub"] as! String
                model.type = dataDic["type"] as! NSNumber
                model.source = dataDic["source"] as! String
                model.date = dataDic["date"] as! String
                model.datefolder = dataDic["datefolder"] as! String
                model.url = dataDic["url"] as! String
                model.pic = dataDic["pic"] as! String
                model.piclarge = dataDic["piclarge"] as! String
                model.picmore = dataDic["picmore"] as! String
                model.iscommend = dataDic["iscommend"] as! NSNumber
                model.istop = dataDic["istop"] as! NSNumber
                model.summary = dataDic["summary"] as! String
                self.listArray.append(model)
            }
            self.mainTableView.reloadData()
        }) { (error) in
            
        }
        
        request.getRequestReturnArray(urlString: MSG_pathSlide as String, params: [:], success: { (response) in
            self.bannerArray.removeAll()
            for dataDic in response{
                let model = DVBannerModel()
                model.newsid = dataDic["newsid"] as! String
                model.datefolder = dataDic["datefolder"] as! String
                model.praise = dataDic["praise"] as! NSNumber
                model.title = dataDic["title"] as! String
                model.newstitle = dataDic["newstitle"] as! String
                model.url = dataDic["url"] as! String
                model.pic = dataDic["pic"] as! String
                model.summary = dataDic["summary"] as! String
                self.bannerArray.append(model)
            }
            self.bannerView.setBanner(self.bannerArray)
        }) { (error) in
            
        }
    }
    //MARK:点击方法
    @IBAction func searchAction(_ sender: Any)
    {
        self.searchBar.becomeFirstResponder()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    //MARK:代理方法
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchBar.resignFirstResponder()
        self.searchBar.text = ""
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("result clicked")
        let searchView = DVSearchViewController()
        searchView.ListArray = self.listArray
        self.navigationController!.pushViewController(searchView, animated: true)
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.bannerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listArray.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let web = WebViewViewController()
        let model = self.listArray[indexPath.row]
        web.url = model.url
        self.navigationController!.pushViewController(web, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let initIdentifier = "reuseID"
        var cell:DVMessageTableViewCell! = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as? DVMessageTableViewCell
        if cell == nil {
            cell = DVMessageTableViewCell(style:.default,reuseIdentifier:initIdentifier)
        }
        let model = self.listArray[indexPath.row]
        cell.setModel(model)
        
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

