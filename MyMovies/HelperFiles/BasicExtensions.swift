//
//  BasicExtensions.swift
//  MyMovies
//
//  Created by Abdul Hoque Nuri on 27/09/19.
//  Copyright © 2019 Abdul Hoque Nuri. All rights reserved.
//

import UIKit
extension UIView {
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
    func shadow(forViews view: UIView, cRadius CRadius: CGFloat, offset_X Offset_X: CGFloat, offset_Y Offset_Y: CGFloat, opacity Opacity: CGFloat, shadowRadius: CGFloat) {
        view.layer.cornerRadius = CRadius
        view.layer.shadowOffset = CGSize(width: Offset_X, height: Offset_Y)
        view.layer.shadowOpacity = Float(Opacity)
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.masksToBounds = false
    }
    
    func setViewRound() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height/2+1
        self.clipsToBounds = true
    }
}
