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

class DVBannerView: UIView ,UIScrollViewDelegate{
    
    public let MainBounds:CGRect = UIScreen.main.bounds

    private var ImageHeight:CGFloat = 0.0
    private let ImageWidth:CGFloat = UIScreen.main.bounds.width
    private let ShadowHeight:CGFloat = 40.0
    private let PageControlHeight:CGFloat = 20.0
    private let TitleLabelHeight:CGFloat = 20.0
    private let WidthEdge:CFloat = 10.0
    private let HeightEdge:CFloat = 5.0
    private let TimerInterval:Int = 5

    internal var currentIndex : Int = 0
    internal var photoList = [String]()
    internal var textList = [String]()
    internal var timer: Timer?
    
    convenience init(photoArray: [String],textArray: [String], viewHeight:CGFloat)
    {
        self.init()
        guard photoArray.count > 0 else {
            print("Invalid BannerArray")
            return
        }
        guard textArray.count > 0 else {
            print("Invalid BannerTextArray")
            return
        }
        self.frame = CGRect.init(x: 0, y: 0, width: MainBounds.width, height: viewHeight)
        self.backgroundColor = UIColor.clear
        
        self.ImageHeight = viewHeight
        self.photoList = photoArray
        self.textList = textArray
        self.createBannerView()
        self.createImageList()
        self.startTimer()
    }
    // MARK: -懒加载
    lazy var bannerView: UIScrollView =
        {
            let scrollView = UIScrollView()
            scrollView.isPagingEnabled = true
            scrollView.delegate = self
            scrollView.decelerationRate = 1
            scrollView.setContentOffset(CGPoint.init(x: UIScreen.main.bounds.width, y: 0), animated: false)
            scrollView.showsHorizontalScrollIndicator = false
            return scrollView
    }()
    
    lazy var shadowView: UIView =
        {
            let view = UIView.init()
            view.backgroundColor = UIColor.black
            view.alpha = 0.5
            return view
    }()
    
    lazy var titleLabel: UILabel =
        {
            let label = UILabel.init()
            label.textColor = UIColor.white
            label.font = UIFont.systemFont(ofSize: 15)

            return label
    }()
    
    lazy var pageControlView: UIPageControl =
        {
            let pageControl = UIPageControl()
            pageControl.currentPageIndicatorTintColor = UIColor.white
            return pageControl
    }()
    
    // MARK: -私有方法
    private func startTimer()
    {
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(TimerInterval), target: self, selector: #selector(DVBannerView.autoSlide), userInfo: nil, repeats: true)
    }
    
    
    @objc private func autoSlide()
    {
        self.bannerView.setContentOffset(CGPoint.init(x: self.bannerView.contentOffset.x+MainBounds.width, y: 0), animated: true)
    }
    
    private func createBannerView()
    {
        if self.photoList.count==1
        {
            self.bannerView.contentSize = CGSize.init(width: ImageWidth*CGFloat(self.photoList.count), height: ImageHeight)
        }else
        {
            self.bannerView.contentSize = CGSize.init(width: ImageWidth*(CGFloat(self.photoList.count)+2), height: ImageHeight)
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
        
        titleLabel.text = self.textList.first!
        self.addSubview(self.titleLabel)
        self.titleLabel.textColor = UIColor.red 
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(shadowView).offset(WidthEdge)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(TitleLabelHeight)
            make.width.lessThanOrEqualTo(MainBounds.width-120.0)
        }
        
        pageControlView.numberOfPages = self.photoList.count
        self.addSubview(pageControlView)
        pageControlView.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-WidthEdge)
            make.bottom.equalToSuperview().offset(-HeightEdge)
            make.height.equalTo(PageControlHeight)
        }
    }
    private func createImageList()
    {
        if self.photoList.count == 1
        {
            let imageView = UIImageView()
            self.bannerView.addSubview(imageView)
            let url = URL(string:self.photoList[0])
            imageView.kf.setImage(with: url)
            imageView.snp.makeConstraints({ (make)->Void in
                make.left.equalToSuperview().offset(0)
                make.top.equalToSuperview().offset(0)
                make.width.equalTo(ImageWidth)
                make.height.equalTo(ImageHeight)
            })
        }else
        {
            for i in 0...self.photoList.count+1
            {
                let imageView = UIImageView()
                self.bannerView.addSubview(imageView)
                imageView.snp.makeConstraints({ (make)->Void in
                    make.left.equalToSuperview().offset(Int(ImageWidth)*i)
                    make.top.equalToSuperview().offset(0)
                    make.width.equalTo(ImageWidth)
                    make.height.equalTo(ImageHeight)
                })
                switch i {
                case 0:
                    let url = URL(string:self.photoList.last!)
                    imageView.kf.setImage(with: url)
                case 1...self.photoList.count:
                    let url = URL(string:self.photoList[i-1])
                    imageView.kf.setImage(with: url)
                case self.photoList.count+1 :
                    let url = URL(string:self.photoList.first!)
                    imageView.kf.setImage(with: url)
                default:
                    break
                }
                
            }
        }
    }
    //MARK: -代理方法
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        let offset = scrollView.contentOffset.x
        
        if offset >= MainBounds.width*CGFloat(self.photoList.count+1){
            scrollView.setContentOffset(CGPoint.init(x: MainBounds.width, y: 0), animated: false)
        }else if offset <= 0{
            scrollView.setContentOffset(CGPoint.init(x: MainBounds.width*CGFloat(self.photoList.count), y: 0), animated: false)
        }else if offset >= MainBounds.width
        {
            self.titleLabel.text = self.textList[Int(offset/MainBounds.width)-1]
            self.pageControlView.currentPage = Int(offset/MainBounds.width)-1
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.timer?.invalidate()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool){
         self.startTimer()
    }
    
}


