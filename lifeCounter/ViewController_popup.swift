//
//  ViewController_popup.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2021/08/16.
//  Copyright © 2021 kurachi. All rights reserved.
//

import UIKit

class ViewController_popup: UIViewController {
    let DISPLAYTIME: TimeInterval = 2
//    @IBOutlet weak var text: UILabel!
//    @IBOutlet weak var popUpImage: UIImageView!
//    @IBOutlet weak var popUpView: UIView!
//    static var dispText: String = ""
    @IBOutlet weak var diceImage: UIImageView!
    static var dispDiceImage:UIImage!
    override func viewDidLoad() {
        super.viewDidLoad()
//        text.adjustsFontSizeToFitWidth = true
//        text.text = ViewController_popup.dispText
//        //ダイナミックカラーの設定（ダークモード対応）
//        text.textColor=UIColor.dynamicColor(light: UIColor.white, dark: UIColor.black)
//        //トーストのイメージの設定（ダークモード対応）
//        popUpImage.image=UITraitCollection.isDarkMode ? UIImage(named: Consts.TOAST_WHITE_IMAGE)! : UIImage(named: Consts.TOAST_BLACK_IMAGE)!
        diceImage.image=ViewController_popup.dispDiceImage
        DispatchQueue.main.asyncAfter(deadline: .now() + DISPLAYTIME) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            if tag == 1 || tag == 2 || tag == 3{
                dismiss(animated: true, completion: nil)
            }
        }
    }
}
