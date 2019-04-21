//
//  RatingView.swift
//  Test_RatingView
//
//  Created by Yiqiang Zeng on 2019/4/19.
//  Copyright © 2019 Yiqiang Zeng. All rights reserved.
//

import UIKit

class RatingView: UIView {
    
    //MARK: - 声明区域
    typealias Block_Action_Click = (CGFloat) -> Void
    open var block_action_click : Block_Action_Click?
    open var s_height           : CGFloat = 40                  //slider height
    open var s_cornerR          : CGFloat = 8                   //slider corder radius
    open var s_color            : UIColor = .white              //slider color
    open var s_thumb_color      : UIColor                       //slider thumb color
        = UIColor(red: 243/255, green: 35/255, blue: 0, alpha: 1)
    open var s_stripe_color     : UIColor = .blue               //slide stripe color
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupUI()
    }
    
    //MARK: - 私有成员
    fileprivate lazy var lay_slider: CAShapeLayer = {       //slider layer, 滑块视图
        return CAShapeLayer()
    }()
    fileprivate lazy var lay_thumb_w: CAShapeLayer = {      //slider thumb wrapper layer, 拇指包裹视图
        return CAShapeLayer()
    }()
    fileprivate lazy var lay_thumb: CAShapeLayer = {        //slider thumb layer, 拇指视图
        return CAShapeLayer()
    }()
    fileprivate lazy var lay_thumb_c: CAShapeLayer = {      //slider thumb cover layer for blink, 拇指覆盖视图
        return CAShapeLayer()
    }()
    fileprivate lazy var lay_thumb_c_b: CAGradientLayer = {  //slider thumb cover blink layer, 拇指闪扑视图
        return CAGradientLayer()
    }()
    fileprivate lazy var lay_slider_c: CAShapeLayer = {     //slider cover layer for stripe, 滑块覆盖视图
        return CAShapeLayer()
    }()
    fileprivate lazy var lay_slider_c_s: CAShapeLayer = {   //slider cover stripe layer, 滑块条纹视图
        return CAShapeLayer()
    }()
    fileprivate var s_progress: CGFloat = 0.0               //slider progress
    fileprivate var is_s_anim_f: Bool = true                //slider animation finish flag
    fileprivate var is_touch: Bool = false                  //touch flag
    fileprivate var is_pan: Bool = false                    //pangesture flag
    fileprivate var is_loaded: Bool = false                 //view loaded
}

//MARK: - 初始化
extension RatingView {
    
    fileprivate func setupUI() {
        layer.addSublayer(lay_slider)
        lay_slider.fillColor = s_color.cgColor
        lay_slider.addSublayer(lay_slider_c)
        lay_slider_c.masksToBounds = true
        lay_slider_c.fillColor = UIColor.init(white: 0, alpha: 0.1).cgColor
        lay_slider_c.addSublayer(lay_slider_c_s)
        lay_slider.addSublayer(lay_thumb_w)
        lay_thumb_w.addSublayer(lay_thumb)
        lay_thumb_w.fillColor = UIColor.clear.cgColor
        lay_thumb_w.masksToBounds = true
        lay_thumb.fillColor = s_thumb_color.cgColor
        lay_thumb.addSublayer(lay_thumb_c)
        lay_thumb_c.addSublayer(lay_thumb_c_b)
        lay_thumb_c.masksToBounds = true
        lay_thumb_c.fillColor = UIColor.clear.cgColor
        let g_tap = UITapGestureRecognizer(target: self,
                                           action: #selector(handler_tap))
        addGestureRecognizer(g_tap)
        let g_pan = UIPanGestureRecognizer(target: self,
                                           action: #selector(handler_pan))
        addGestureRecognizer(g_pan)
    }
    
    @objc func injected() {
        
    }
}

//MARK: - Touch Event
extension RatingView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        is_touch = true
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        is_touch = false
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        is_touch = false
    }
}

//MARK: - draw
extension RatingView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        update_position()
    }
    
    fileprivate func update_position() {
        
        update_frame()
        update_anim_slide()
        update_anim_touch()
        update_anim_blink()
        update_stripe()
    }
    
    fileprivate func update_frame() {
        var frame = CGRect(x: 0, y: 0, width: bounds.width, height: s_height)
        var path = UIBezierPath(roundedRect: frame, cornerRadius: s_cornerR)
        lay_slider.path = path.cgPath
        lay_slider.frame = frame
        lay_slider.frame.origin.y = (bounds.height - s_height)/2
        lay_thumb_w.path = path.cgPath
        lay_thumb_w.frame = frame
        lay_thumb_w.cornerRadius = s_cornerR - 1
        frame = CGRect(x: 0, y: 0, width: bounds.width*s_progress, height: s_height)
        path = UIBezierPath(roundedRect: frame, cornerRadius: s_cornerR)
        lay_thumb.frame = frame
        
        lay_thumb_c.path = lay_thumb.path
        lay_thumb_c.frame = lay_thumb.frame
        lay_thumb_c.cornerRadius = s_cornerR
        
        lay_slider_c.frame = .init(x: 0, y: 0, width: lay_slider.bounds.width, height: lay_slider.bounds.height)
        lay_slider_c.path = lay_slider.path
        lay_slider_c.cornerRadius = s_cornerR
    }
    
    fileprivate func update_anim_slide() {
        let frame = CGRect(x: 0, y: 0, width: bounds.width*s_progress, height: s_height)
        let path = UIBezierPath(roundedRect: frame, cornerRadius: s_cornerR)
        let anim = CAKeyframeAnimation(keyPath: "path")
        anim.values = [lay_thumb.path ?? path.cgPath, path.cgPath]
        anim.keyTimes = [0, 1]
        anim.duration = 0.25
        anim.timingFunctions = [.init(name: .easeIn)]
        anim.delegate = self
        is_s_anim_f = false
        lay_thumb.add(anim, forKey: "slide")
        lay_thumb.path = path.cgPath
        if !is_loaded {
            is_loaded = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                let frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.s_height)
                let path = UIBezierPath(roundedRect: frame, cornerRadius: self.s_cornerR)
                let anim = CAKeyframeAnimation(keyPath: "path")
                let _frame = CGRect(x: 0, y: 0, width: 0, height: self.s_height)
                let _path = UIBezierPath(roundedRect: _frame, cornerRadius: self.s_cornerR)
                anim.values = [path.cgPath, _path.cgPath]
                anim.keyTimes = [0, 1]
                anim.duration = 0.25
                anim.timingFunctions = [.init(name: .linear)]
                self.lay_thumb.add(anim, forKey: "slide")
            })
        }
    }
    
    fileprivate func update_anim_touch() {
        if is_touch || is_pan {
            lay_slider.shadowOffset = .init(width: 1, height: 1)
            lay_slider.shadowOpacity = 0.5
            lay_slider.shadowRadius = 2
            lay_slider.shadowColor = s_thumb_color.cgColor
            //lay_slider.shadowPath = UIBezierPath(rect: lay_slider.bounds.insetBy(dx: 2, dy: 2)).cgPath
        } else {
            lay_slider.shadowOpacity = 0
        }
    }
    
    fileprivate func update_anim_blink() {
        if lay_thumb_c_b.frame == .zero {
            lay_thumb_c_b.frame = .init(x: -lay_thumb_c.bounds.height, y: -lay_thumb_c.bounds.height/2, width: lay_thumb_c.bounds.height, height: lay_thumb_c.bounds.height*2)
            lay_thumb_c_b.colors = [UIColor(white: 1, alpha: 0).cgColor, UIColor(white: 1, alpha: 0.9).cgColor, UIColor(white: 1, alpha: 0).cgColor]
            lay_thumb_c_b.locations = [0, 0.5, 1]
            lay_thumb_c_b.startPoint = .init(x: 0, y: 0.5)
            lay_thumb_c_b.endPoint = .init(x: 1, y: 0.5)
            lay_thumb_c_b.transform = CATransform3DMakeRotation(radians(210), 0, 0, 1)
            
            let anim_b = CABasicAnimation(keyPath: "position.x")
            anim_b.fromValue = lay_thumb_c_b.frame.origin.x
            anim_b.toValue = lay_slider.frame.width
            anim_b.duration = 1.25
            anim_b.timingFunction = .init(name: .linear)
            let anim_g = CAAnimationGroup()
            anim_g.beginTime = CACurrentMediaTime() + 2.5
            anim_g.duration = 3.75
            anim_g.repeatCount = Float.infinity
            anim_g.animations = [anim_b]
            lay_thumb_c_b.add(anim_g, forKey: "blink")
        }
    }
    
    fileprivate func update_stripe() {
        if lay_slider_c_s.frame == .zero {
            let x: CGFloat = lay_slider_c.bounds.width
            let y: CGFloat = lay_slider_c.bounds.height
            let w: CGFloat = x/cos(radians(30)) + y/2
            let h: CGFloat = sin(radians(60))*y + x/2
            let path_c = UIBezierPath()
            path_c.move(to: .init(x: 0, y: h/2))
            path_c.addLine(to: .init(x: w, y: h/2))
            lay_slider_c_s.frame = .init(x: (x - w)/2, y: (y - h)/2, width: w, height: h)
            lay_slider_c_s.path = path_c.cgPath
            lay_slider_c_s.lineDashPhase = 0
            lay_slider_c_s.lineDashPattern = [6, 6]
            lay_slider_c_s.lineWidth = h
            lay_slider_c_s.strokeColor = s_stripe_color.cgColor
            lay_slider_c_s.anchorPoint = .init(x: 0.5, y: 0.5)
            lay_slider_c_s.opacity = 0.5
            let t1 = CATransform3DMakeRotation(CGFloat(radians(30)), 0, 0, 1)
            //let t2 = CATransform3DTranslate(t1, -(cos(radians(30))*w - x)/2, -((h - cos(radians(30))*y)*sin(radians(60))), 0)
            lay_slider_c_s.transform = t1
        }
    }
    
    fileprivate func radians(_ degrees: CGFloat) -> CGFloat {
        return CGFloat.pi*degrees/180
    }
}

//MARK: - 句柄处理
extension RatingView {
    
    @objc fileprivate func handler_tap(sender: UITapGestureRecognizer) {
        s_progress = sender.location(in: self).x/bounds.width
        self.setNeedsDisplay()
        self.block_action_click?(s_progress)
    }
    
    @objc fileprivate func handler_pan(sender: UIPanGestureRecognizer) {
        s_progress = sender.location(in: self).x/bounds.width
        switch sender.state {
        case .began:
            is_pan = true
            setNeedsDisplay()
        case .changed:
            if is_s_anim_f { setNeedsDisplay() }
        case .ended:
            is_pan = false
            setNeedsDisplay()
            self.block_action_click?(s_progress)
        default:
            break
        }
    }
}

//MARK: - CAAnimationDelegate
extension RatingView: CAAnimationDelegate {
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let _anim = anim as? CAKeyframeAnimation, _anim.keyPath == "path" {
            is_s_anim_f = true
        }
    }
}
