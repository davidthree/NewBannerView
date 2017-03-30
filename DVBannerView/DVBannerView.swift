//
//  DVBannerView.swift
//  ForthProject
//
//  Created by David on 2017/3/23.
//  Copyright © 2017年 David. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import RealmSwift

class DVBannerView: UIView ,UIScrollViewDelegate{
    typealias callbackfunc = (Int) -> Void
    var myFunc:callbackfunc?
    private var ImageHeight: CGFloat = 0.0
    private let ImageWidth: CGFloat = UIScreen.main.bounds.width
    private let ShadowHeight: CGFloat = 40.0
    private let PageControlHeight: CGFloat = 20.0
    private let TitleLabelHeight: CGFloat = 20.0
    private let WidthEdge: CFloat = 10.0
    private let HeightEdge: CFloat = 5.0
    private var currentIndex: Int = 0
    private var bannerArray: Results<DVBannerModel>?
    private var timer: DispatchSourceTimer?
    
    convenience init(viewHeight:CGFloat)
    {
        self.init()
        
        self.frame = CGRect.init(x: 0, y: 0, width: MainBounds.width, height: viewHeight)
        self.backgroundColor = UIColor.clear
        self.ImageHeight = viewHeight
        
    }
    // MARK: -懒加载
    lazy var bannerView: UIScrollView = {
            let scrollView = UIScrollView()
            scrollView.isPagingEnabled = true
            scrollView.delegate = self
            scrollView.decelerationRate = 1
            scrollView.setContentOffset(CGPoint.init(x: UIScreen.main.bounds.width, y: 0), animated: false)
            scrollView.showsHorizontalScrollIndicator = false
            return scrollView
    }()
    
    lazy var shadowView: UIView = {
            let view = UIView.init()
            view.backgroundColor = UIColor.black
            view.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(imageTap))
            view.addGestureRecognizer(tap)
            view.alpha = 0.3
            return view
    }()
    
    lazy var titleLabel: UILabel = {
            let label = UILabel.init()
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 15)
            
            return label
    }()
    
    lazy var pageControlView: UIPageControl = {
            let pageControl = UIPageControl()
            pageControl.isUserInteractionEnabled = false
            pageControl.currentPageIndicatorTintColor = UIColor.white
            return pageControl
    }()
    // MARK: -外部方法
    public func setBanner(_ listArray:Results<DVBannerModel>) -> Void{
        self.bannerArray = listArray
        self.createBannerView()
        self.createImageList()
        self.startTimer()
    }
    // MARK: -私有方法
    private func startTimer() {
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.scheduleRepeating(deadline: .now() + 5, interval: 5)
        timer?.setEventHandler {
            self.autoSlide()
        }
        // 启动定时器
        timer?.resume()
    }
    
    
    private func autoSlide() {
        self.bannerView.setContentOffset(CGPoint.init(x: self.bannerView.contentOffset.x+MainBounds.width, y: 0), animated: true)
    }
    
    private func createBannerView() {
        if self.bannerArray?.count==1{
            self.bannerView.contentSize = CGSize.init(width: ImageWidth*1, height: ImageHeight)
        }else if (self.bannerArray?.count)!>1{
            self.bannerView.contentSize = CGSize.init(width: ImageWidth*(CGFloat(self.bannerArray!.count)+2), height: ImageHeight)
        }else{
            //without banner
        }
        
        self.addSubview(self.bannerView)
        self.bannerView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(ImageHeight)
        }
        self.addSubview(self.shadowView)
        self.shadowView.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(ShadowHeight)
        }
        
        let model = self.bannerArray?.first
        titleLabel.text = model?.title
        self.addSubview(self.titleLabel)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(shadowView).offset(WidthEdge)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(TitleLabelHeight)
            make.width.lessThanOrEqualTo(MainBounds.width-120.0)
        }
        pageControlView.numberOfPages = (self.bannerArray?.count)!
        self.addSubview(pageControlView)
        pageControlView.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-WidthEdge)
            make.bottom.equalToSuperview().offset(-HeightEdge)
            make.height.equalTo(PageControlHeight)
        }
        
    }
    private func createImageList() {
        if self.bannerArray?.count == 1 {
            let imageView = UIImageView()
            self.bannerView.addSubview(imageView)
            let model = self.bannerArray?.first
            let url = URL(string:(model?.pic)!)
            imageView.kf.setImage(with: url)
            imageView.snp.makeConstraints({ (make)->Void in
                make.left.equalToSuperview().offset(0)
                make.top.equalToSuperview().offset(0)
                make.width.equalTo(ImageWidth)
                make.height.equalTo(ImageHeight)
            })
        }else {
            for i in 0...(self.bannerArray?.count)!+1 {
                let imageView = UIImageView()
                imageView.isUserInteractionEnabled = true
                let ges = UITapGestureRecognizer.init(target: self, action: #selector(imageTap))
                self.bannerView.addGestureRecognizer(ges)
                self.bannerView.addSubview(imageView)
                imageView.snp.makeConstraints({ (make)->Void in
                    make.left.equalToSuperview().offset(Int(ImageWidth)*i)
                    make.top.equalToSuperview().offset(0)
                    make.width.equalTo(ImageWidth)
                    make.height.equalTo(ImageHeight)
                })
                switch i {
                case 0:
                    let model = self.bannerArray?.last
                    let url = URL(string:(model!.pic))
                    imageView.kf.setImage(with: url)
                case 1...(self.bannerArray?.count)!:
                    let model = self.bannerArray?[i-1]
                    let url = URL(string:(model?.pic)!)
                    imageView.kf.setImage(with: url)
                case (self.bannerArray?.count)!+1 :
                    let model = self.bannerArray?.first
                    let url = URL(string:(model?.pic)!)
                    imageView.kf.setImage(with:url)
                default:
                    break
                }
                
            }
        }
    }
    func imageTap() {
        self.myFunc!(self.currentIndex)
    }
    //MARK: -代理方法
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        let offset = scrollView.contentOffset.x
        let index = scrollView.contentOffset.x/MainBounds.width
        if offset >= MainBounds.width*CGFloat((self.bannerArray?.count)!+1){
            scrollView.setContentOffset(CGPoint.init(x: MainBounds.width, y: 0), animated: false)
            self.currentIndex = 0
        }else if offset <= 0{
            scrollView.setContentOffset(CGPoint.init(x: MainBounds.width*CGFloat((self.bannerArray?.count)!), y: 0), animated: false)
            self.currentIndex = (self.bannerArray?.count)!-1
        }else if offset >= MainBounds.width {
            let model = self.bannerArray?[Int(offset/MainBounds.width)-1]
            self.titleLabel.text = model?.title
            self.pageControlView.currentPage = Int(offset/MainBounds.width)-1
            self.currentIndex = Int(index)-1
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.cancel()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool){
        self.startTimer()
    }
    
}


