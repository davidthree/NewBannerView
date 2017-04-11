//
//  DVSearchViewController.swift
//  DVBannerView
//
//  Created by David on 2017/3/28.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit

class DVSearchViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var listArray = [DVMessageModel]()
    var searchString: String = ""
    
    lazy var mainTableView: UITableView = {
        let tableView = UITableView.init(frame: CGRect.zero, style: UITableViewStyle.grouped)
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMainView()
        loadData()
    }
    func loadMainView() {
        self.view.addSubview(self.mainTableView)
        self.mainTableView.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(0)
            make.top.equalTo(self.view).offset(0)
            make.right.equalTo(self.view).offset(0)
            make.bottom.equalTo(self.view).offset(0)
        }
    }
    func loadData() {
        let request = DVNewworkRequest()
        request.getRequest(urlString: MSG_pathSearch, params: ["keyword":self.searchString], success: { (json) in
            self.listArray.removeAll()
            
            if let dataArray = json["data"].array{
                if dataArray.count != 0{
                    let praiseDic = json["praise"]
                    for dataDic in dataArray{
                        let model = DVMessageModel()
                        if let id = dataDic["id"].int{
                            model.id = id
                        }
                        if let sortid = dataDic["sortid"].int{
                            model.sortid = sortid
                        }
                        if let title = dataDic["title"].string{
                            model.title = title
                        }
                        if let titlesub = dataDic["titlesub"].string{
                            model.titlesub = titlesub
                        }
                        if let type = dataDic["type"].int{
                            model.type = type
                        }
                        if let datefolder = dataDic["datefolder"].string{
                            model.datefolder = datefolder
                        }
                        if let url = dataDic["url"].string{
                            model.url = url
                        }
                        if let pic = dataDic["pic"].string{
                            model.pic = pic
                        }
                        if let piclarge = dataDic["piclarge"].string{
                            model.piclarge = piclarge
                        }
                        if let picmore = dataDic["picmore"].string{
                            model.picmore = picmore
                        }
                        if let iscommend = dataDic["iscommend"].int{
                            model.iscommend = iscommend
                        }
                        if let istop = dataDic["istop"].int{
                            model.istop = istop
                        }
                        if let summary = dataDic["summary"].string{
                            model.summary = summary
                        }
                        if let praise = praiseDic["\(model.id)"].int {
                            model.praise = praise
                        }
                        try! realm.write {
                            realm.create(DVMessageModel.self, value:["id":model.id,"sortid":model.sortid,"title":model.title,"titlesub":model.titlesub,"type":model.type,"datefolder":model.datefolder,"url":model.url,"pic":model.pic,"piclarge":model.piclarge,"picmore":model.picmore,"iscommend":model.iscommend,"istop":model.istop,"summary":model.summary,"praise":model.praise], update: true)
                        }
                        self.listArray.append(model)
                    }
                }
            }
            self.mainTableView.reloadData()
        }) { (error) in
            
        }
    }
    // MARK: -UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listArray.count
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.listArray[indexPath.row]
        let webview = WebViewViewController()
        webview.url = model.url
        self.navigationController?.pushViewController(webview, animated: true)
        
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
