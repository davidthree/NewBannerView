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
    let ImageWidth: CGFloat = UIScreen.main.bounds.width
    var ImageHeight: CGFloat = 0.0
    let ShadowHeight: CGFloat = 40.0
    let PageControlHeight: CGFloat = 20.0
    let TitleLabelHeight: CGFloat = 20.0
    let WidthEdge: CFloat = 10.0
    let HeightEdge: CFloat = 5.0
    
    var currentIndex: Int = 0
    var timer: DispatchSourceTimer?
    typealias callbackfunc = (Int) -> Void
    var myFunc:callbackfunc?

    //MARK: -可选属性
    /// 是否自动滚动，默认为YES
    var autoScroll: Bool? {
        didSet{
            if autoScroll == false{
                self.timer?.cancel()
            }
        }
    }
    /// 是否显示分页控件，默认为YES
    var showPageControl: Bool? {
        didSet{
            if showPageControl == false {
                self.pageControlView.isHidden = true
            }
        }
    }
    /// 是否在只有一张图时隐藏pagecontrol，默认为YES
    var hidesForSinglePage: Bool? {
        didSet{
            if hidesForSinglePage == false {
                self.pageControlView.isHidden = false
            }
        }
    }
    var imageURLGroup: [String]? {
        didSet{
            self.createImageList()
            self.pageControlView.numberOfPages = imageURLGroup?.count ?? 0

        }
    }
    // 不设置则不显示文字
    var imageNameGroup: [String]? {
        didSet{
            self.shadowView.isHidden = false
            self.titleLabel.isHidden = false
            self.titleLabel.text = imageNameGroup?.first
        }
    }
    // MARK: -init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.ImageHeight = frame.size.height
        initialization()
        setupMainView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
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
    //文字阴影
    lazy var shadowView: UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.black
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(imageTap))
        view.addGestureRecognizer(tap)
        view.alpha = 0.3
        view.isHidden = true
        
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.isHidden = true
        
        return label
    }()
    
    lazy var pageControlView: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = UIColor.white
        return pageControl
    }()

    
    ///初始化参数
    func initialization() {
        self.backgroundColor = UIColor.clear
        self.autoScroll = true
        self.showPageControl = true
        self.hidesForSinglePage = true
        startTimer()
    }
    ///初始化视图
    func setupMainView()
    {
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
        
        self.addSubview(self.titleLabel)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(WidthEdge)
            make.bottom.equalToSuperview().offset(-10)
            make.height.equalTo(TitleLabelHeight)
            make.width.lessThanOrEqualTo(MainBounds.width-120.0)
        }
        
        self.addSubview(pageControlView)
        pageControlView.snp.makeConstraints { (make) -> Void in
            make.right.equalToSuperview().offset(-WidthEdge)
            make.bottom.equalToSuperview().offset(-HeightEdge)
            make.height.equalTo(PageControlHeight)
        }
    }
    // MARK: -私有方法
        func createImageList() {
            guard (imageURLGroup?.count ?? 0) > 0 else {
                return
            }
            if self.imageURLGroup!.count==1{
                self.bannerView.contentSize = CGSize.init(width: ImageWidth*1, height: ImageHeight)
            }else if self.imageURLGroup!.count > 1{
                self.bannerView.contentSize = CGSize.init(width: ImageWidth*(CGFloat(self.imageURLGroup!.count)+2), height: ImageHeight)
            }
            if self.imageURLGroup!.count == 1 {
                let imageView = UIImageView()
                self.bannerView.addSubview(imageView)
                
                let url = URL(string:self.imageURLGroup!.first!)
                imageView.kf.setImage(with: url)
                imageView.snp.makeConstraints({ (make)->Void in
                    make.left.equalToSuperview().offset(0)
                    make.top.equalToSuperview().offset(0)
                    make.width.equalTo(ImageWidth)
                    make.height.equalTo(ImageHeight)
                })
            }else if self.imageURLGroup!.count > 1
            {
                for i in 0...self.imageURLGroup!.count+1 {
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
                        let url = URL(string:self.imageURLGroup!.last!)
                        imageView.kf.setImage(with: url)
                    case 1...self.imageURLGroup!.count:
                        let url = URL(string:self.imageURLGroup![i-1])
                        imageView.kf.setImage(with: url)
                    case self.imageURLGroup!.count+1 :
                        let url = URL(string:self.imageURLGroup!.first!)
                        imageView.kf.setImage(with:url)
                    default:
                        break
                    }
                }
            }
        
    }
    func startTimer() {
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.scheduleRepeating(deadline: .now() + 5, interval: 5)
        timer?.setEventHandler {
            self.autoSlide()
        }
        // 启动定时器
        timer?.resume()
    }
    
    func autoSlide() {
        self.bannerView.setContentOffset(CGPoint.init(x: self.bannerView.contentOffset.x+MainBounds.width, y: 0), animated: true)
    }
    
    func imageTap() {
        if self.myFunc != nil {
            self.myFunc!(self.currentIndex)
        }
        
    }
    func nowIndex(_ offset:CGFloat) -> Int {
        var index = 0
        index = Int((offset + MainBounds.width * 0.5) / MainBounds.width)
        return(index)
    }
    
    func pageControlIndexWithNowIndex(_ index:Int) -> Int {
        var correctIndex = index % self.imageURLGroup!.count
        if correctIndex != 0{
            correctIndex = correctIndex-1
        }else{
            correctIndex = self.imageURLGroup!.count - 1
        }
        return correctIndex
    }
    //MARK: -代理方法
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        guard (self.imageURLGroup?.count ?? 0) > 0 else {
            return
        }
        let offset = scrollView.contentOffset.x
        let itemIndex = self.nowIndex(offset)
        let pageControllViewIndex = self.pageControlIndexWithNowIndex(itemIndex)
        
        self.currentIndex = pageControllViewIndex
        self.pageControlView.currentPage = pageControllViewIndex
        if (self.imageNameGroup?.count ?? 0) > 0 {
            self.titleLabel.text = self.imageNameGroup![pageControllViewIndex]
        }
        
        if offset >= MainBounds.width*CGFloat(self.imageURLGroup!.count+1){
            scrollView.setContentOffset(CGPoint.init(x: MainBounds.width, y: 0), animated: false)
        }else if offset <= 0{
            scrollView.setContentOffset(CGPoint.init(x: MainBounds.width*CGFloat(self.imageURLGroup!.count), y: 0), animated: false)
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.bannerView{
            timer?.cancel()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool){
        if scrollView == self.bannerView && self.autoScroll == true{
            self.startTimer()
        }
    }


}
