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
    var title:String = ""
    var year:String = ""
    var image:String = ""
    var alt:String = ""
}

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {

    @IBOutlet weak var searchButton: UIBarButtonItem!
    public let MainBounds:CGRect = UIScreen.main.bounds
    private let TableViewHeaderHeight:CGFloat = 200.0
    /*
     * Banner 图片和文字数组
     */
    private var photoUrlArray = [String]()
    private var textArray = [String]()
    private var ListArray = [DVMessageModel]()
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
        let view = DVBannerView.init(photoArray: self.photoUrlArray, textArray: self.textArray ,viewHeight:200.0)
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
        for i in 1...6 {
            let strA = String(format:"https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/kingfisher-\(i).jpg")
            self.photoUrlArray.append(strA)
            self.textArray.append("\(i)")
        }
        Alamofire.request("https://api.douban.com/v2/movie/top250?start=100", method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result
            {
            case.success(let json):
                let subjectsArray = (json as! Dictionary<String,AnyObject>)["subjects"] as! NSArray
                for d in subjectsArray
                {
                    let model = DVMessageModel()
                    model.title = (d as! Dictionary<String,AnyObject>)["original_title"] as! String
                    model.image = ((d as! Dictionary<String,AnyObject>)["images"] as! Dictionary<String,AnyObject>)["small"] as! String
                    model.year = (d as! Dictionary<String,AnyObject>)["year"] as! String
                    self.ListArray.append(model)
                    model.alt = (d as! Dictionary<String,AnyObject>)["alt"] as! String
                }
            case.failure(let error):
                print("\(error)")
            }
            self.mainTableView.reloadData()
        }
        
        
    }
    @IBAction func searchAction(_ sender: Any)
    {
        self.searchBar.becomeFirstResponder()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    //MARK:代理方法
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {

        self.searchBar.text = ""
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.ListArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let initIdentifier = "reuseID"
        var cell:DVMessageTableViewCell! = tableView.dequeueReusableCell(withIdentifier: initIdentifier) as? DVMessageTableViewCell
        if cell == nil {
            cell = DVMessageTableViewCell(style:.default,reuseIdentifier:initIdentifier)
        }
        let model = self.ListArray[indexPath.row]
        let url = URL(string:model.image)
        cell.leftImageView.kf.setImage(with:url)
        cell.titleLabel.text = model.title
        let iconImage = UIImage(named:"Baby-icon")?.withRenderingMode(.alwaysOriginal)
        cell.collectionButton.setImage(iconImage, for: .normal)
        cell.collectionButton.setTitle(model.year, for: .normal)
        
        
        print(model.title)
        
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.bannerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return TableViewHeaderHeight
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let web = WebViewViewController()
        let model = self.ListArray[indexPath.row]
        web.url = model.alt
        self.navigationController!.pushViewController(web, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

