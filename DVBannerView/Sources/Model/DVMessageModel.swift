//
//  DVMessageModel.swift
//  DVBannerView
//
//  Created by David on 2017/4/5.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import ObjectMapper

class DVMessageModel: Object {

    dynamic var id = 0      //新闻ID
    dynamic var sortid = 0 //新闻分类ID
    dynamic var type = 0    //新闻类型
    
    dynamic var title = ""  //新闻标题
    dynamic var titlesub = "" //新闻短标题
    dynamic var newstitle = "" //新闻轮显长标题
    
    dynamic var url = ""    //新闻地址
    dynamic var pic = ""    //新闻图片地址
    dynamic var piclarge = ""   //新闻大图片地址
    dynamic var source = "" //新闻来源
    
    dynamic var date = ""   //新闻日期
    dynamic var datefolder = ""  //新闻日期文件夹名

    dynamic var summary = "" //新闻简介
    dynamic var praise = 0   //新闻点赞数量

    dynamic var ispraise = false //新闻是否点赞
    dynamic var isHomepage = false //是否首页
    dynamic var isBanner = false //是否首页
    dynamic var picmore = ""
    dynamic var iscommend = 0
    dynamic var istop = 0
    
    convenience init(dataDic: JSON) {
        self.init()
        if let id = dataDic["id"].int{
            self.id = id
        }else if let newsid = dataDic["newsid"].string {
            let nid = Int(newsid)
            self.id = nid ?? 0
        }
        if let sortid = dataDic["sortid"].int{
            self.sortid = sortid
        }
        if let title = dataDic["title"].string{
            self.title = title
        }
        if let titlesub = dataDic["titlesub"].string{
            self.titlesub = titlesub
        }
        if let type = dataDic["type"].int{
            self.type = type
        }
        if let datefolder = dataDic["datefolder"].string{
            self.datefolder = datefolder
        }
        if let url = dataDic["url"].string{
            self.url = url
        }
        if let pic = dataDic["pic"].string{
            self.pic = pic
        }
        if let piclarge = dataDic["piclarge"].string{
            self.piclarge = piclarge
        }
        if let picmore = dataDic["picmore"].string{
            self.picmore = picmore
        }
        if let iscommend = dataDic["iscommend"].int{
            self.iscommend = iscommend
        }
        if let istop = dataDic["istop"].int{
            self.istop = istop
        }
        if let summary = dataDic["summary"].string{
            self.summary = summary
        }
        if let praise = dataDic["praise"].int {
            self.praise = praise
        }

    }

    override static func primaryKey() -> String?{
        return "id"
    }
}


