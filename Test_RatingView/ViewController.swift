//
//  ViewController.swift
//  Test_RatingView
//
//  Created by Yiqiang Zeng on 2019/4/19.
//  Copyright © 2019 Yiqiang Zeng. All rights reserved.
//

import UIKit

let isIPhoneX: Bool = (
    (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 375, height:812), UIScreen.main.bounds.size) : false) ||
        (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 812, height:375), UIScreen.main.bounds.size) : false) ||
        (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 414, height:896), UIScreen.main.bounds.size) : false) ||
        (UIScreen.instancesRespond(to: #selector(getter: UIScreen.main.currentMode)) ? __CGSizeEqualToSize(CGSize(width: 896, height:414), UIScreen.main.bounds.size) : false))

let kScreenW = UIScreen.main.bounds.size.width
let kScreenH = UIScreen.main.bounds.size.height

let kNavBar_Height: CGFloat = isIPhoneX ? 88.0:64.0
let kStatusBar_Height: CGFloat = isIPhoneX ? 44.0:20.0

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    //MARK: - 私有成员
    fileprivate lazy var v_rating: RatingView = {
        return RatingView()
    }()
    fileprivate lazy var v_bottom: UIView = {
        return UIView()
    }()
    fileprivate lazy var labl_hint: UILabel = {
        let labl = UILabel()
        labl.textAlignment = .center
        labl.font = UIFont.systemFont(ofSize: 15)
        labl.text = "滑动评价"
        labl.textColor = UIColor.gray
        return labl
    }()
    fileprivate lazy var lay_gradient: CAGradientLayer = {
        return CAGradientLayer()
    }()
}

//MARK: - 初始化
extension ViewController {
    
    fileprivate func setupUI() {
        view.addSubview(v_bottom)
        v_bottom.frame = .init(x: 0, y: view.bounds.height - 50 - 34, width: view.bounds.width, height: 50)
        v_bottom.backgroundColor = .white
        v_bottom.addSubview(labl_hint)
        labl_hint.frame = .init(x: 0, y: 14, width: 100, height: 20)
        v_bottom.addSubview(v_rating)
        v_rating.frame = .init(x: 100, y: 0, width: view.bounds.width - 120, height: 50)
        v_rating.s_height = 14
        v_rating.s_stripe_color = UIColor.cyan
        v_rating.block_action_click = { progress in
            self.alert_progress(progress)
        }
        view.layer.insertSublayer(lay_gradient, at: 0)
        lay_gradient.frame = view.bounds
        lay_gradient.colors = [UIColor(rgb: 0x7b4397).cgColor, UIColor(rgb: 0xdc2430).cgColor]
        lay_gradient.locations = [0, 1]
        lay_gradient.startPoint = .init(x: 0, y: 0.3)
        lay_gradient.endPoint = .init(x: 1, y: 0.7)
    }
}

//MARK: - Alert
extension ViewController {
    
    fileprivate func alert_progress(_ progress: CGFloat) {
        let v = UIView()
        v.frame.size = .init(width: 100, height: 40)
        v.layer.cornerRadius = 8
        v.backgroundColor = .init(white: 1, alpha: 1)
        let labl = UILabel(frame: .init(x: 0, y: 0, width: 100, height: 40))
        labl.textAlignment = .center
        labl.font = UIFont.systemFont(ofSize: 15)
        labl.text = "进度: \(String(format: "%0.02f", progress))"
        labl.textColor = UIColor.black
        v.addSubview(labl)
        labl.center = v.center
        view.addSubview(v)
        v.center = view.center
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            v.removeFromSuperview()
        })
    }
}

extension UIColor {
    
    convenience init(rgb: UInt, a:CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: a
        )
    }
    
    convenience init(rgb: UInt) {
        self.init(rgb: rgb, a:1.0)
    }
}
