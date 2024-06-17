//
//  TableViewCell_list.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/30.
//

import UIKit
class TableViewCell_list: UITableViewCell {
    @IBOutlet weak var soineImg: UIImageView!
    @IBOutlet weak var soineImg2: UIImageView!
    @IBOutlet weak var voiceName: UILabel!
    @IBOutlet weak var btn: UIButton!
    func setCell(data: Data_list) {
//        voiceName.text = data.voiceName
        
        // 画像の縦横サイズを取得
        let imgWidth:CGFloat = data.soineImg.size.width
        let imgHeight:CGFloat = data.soineImg.size.height
        // 画像サイズをスクリーン幅に合わせる
        let width = imgWidth * data.scale
        let height = imgHeight * data.scale
    
        let rect:CGRect = CGRect(x:0, y:-(height/4), width:width, height:height)
        let myImageView = UIImageView(image:data.soineImg)
        
        myImageView.frame = rect;
                
        myImageView.alpha = 0.3
        
        //背景画像
        for subView in soineImg.subviews{
            subView.removeFromSuperview()
        }
        soineImg.addSubview(myImageView)
        
        soineImg2.image = data.soineImg
    }
}

class Data_list {
//    var voiceName: String
    var soineImg: UIImage
    var scale:CGFloat
    
    init(category: UIImage,scale:CGFloat) {
//        init(voiceName: String, category: UIImage,scale:CGFloat) {
//        self.voiceName = voiceName
        self.soineImg = category
        self.scale = scale
    }
}
