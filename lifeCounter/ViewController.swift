//
//  ViewController.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2019/06/04.
//  Copyright © 2019 kurachi. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var player1view: UIView!
    @IBOutlet weak var player2view: UIView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var clearBtn: CustomBtn!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var life1: UILabel!
    @IBOutlet weak var life2: UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    
    var _life1 :Int=20
    var _life2 : Int=20
    
    var timer1:Timer?
    var timer2:Timer?
    
    var passMin:Int = 0
    let formatter = DateComponentsFormatter()
    var gameStatus:GameStatus = GameStatus.ready
    var currentPlayer : Player!
    var selected : Player!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        player2view.transform=CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        startBtn.imageView?.contentMode = .scaleAspectFit
        startBtn.contentHorizontalAlignment = .fill
        startBtn.contentVerticalAlignment = .fill
        clearBtn.imageView?.contentMode = .scaleAspectFit
        clearBtn.contentHorizontalAlignment = .fill
        clearBtn.contentVerticalAlignment = .fill
        settingBtn.imageView?.contentMode = .scaleAspectFit
        settingBtn.contentHorizontalAlignment = .fill
        settingBtn.contentVerticalAlignment = .fill
        
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute,.hour,.second]
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }

    @IBAction func touchDown_startBtn(_ sender: Any) {
        switch gameStatus {
        case .ready:
            
            //ちょいバック回転(回転と言うよりはそれになるといった感じ。pi / 2   は画像の初期位置を0としてそれから45°き回転させた位置)
            let random = Int.random(in: 1 ... 10)
            UIView.animate(withDuration: 0.5 / 2) { () -> Void in
                self.startBtn.transform = CGAffineTransform(rotationAngle:  CGFloat.pi / 2 *    ((random % 2 == 0) ? -1.0 : 1.0))
            }
            player1view.backgroundColor = UIColor.clear
            player2view.backgroundColor = UIColor.clear
            if random % 2 == 0 {
                player2view.backgroundColor = UIColor.blue
                timer2 = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:  #selector(self.timerFunc2),userInfo: nil, repeats: true)
                //timer2.fire()
                currentPlayer = .player2
            }
            else{
                player1view.backgroundColor = UIColor.blue
                timer1 = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:  #selector(self.timerFunc),userInfo: nil, repeats: true)
                //timer1.fire()
                currentPlayer = .player1
            }
            gameStatus = .playing
            
        case .playing:
            startBtn.setImage(UIImage(named:"restart"), for: .normal)
            if Player.player1 == currentPlayer{
                if timer1 != nil{
                    timer1!.invalidate()
                }
            }
            else{
                if timer2 != nil{
                    timer2!.invalidate()
                }
            }
            gameStatus = .stop
        case .stop:
            startBtn.setImage(UIImage(named:"start"), for: .normal)
            if Player.player1 == currentPlayer{
                timer1 = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:  #selector(self.timerFunc),userInfo: nil, repeats: true)
                //timer1.fire()
            }
            else{
                timer2 = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:  #selector(self.timerFunc2),userInfo: nil, repeats: true)
                //timer2.fire()
            }
            gameStatus = .playing
        }
    }
    @IBAction func touchDown_clearBtn(_ sender: Any) {
        
        let t:CGFloat = 1.0
        self.clearBtn.spinAnim(self.clearBtn,t)
//        self.clearBtn.transform = CGAffineTransform(rotationAngle:  CGFloat.pi * t )//回転させたところで止めたい場合はこの行がいる
        
        //ちょいバック回転(回転と言うよりはそれになるといった感じ。pi / 2 は画像の初期位置を0としてそれから45°き回転させた位置)
        UIView.animate(withDuration: 0.5 / 2) { () -> Void in
            self.startBtn.transform = CGAffineTransform(rotationAngle:  0)
        }
        player1view.backgroundColor = UIColor.clear
        player2view.backgroundColor = UIColor.clear
        lifeReset()
        
        passMin = 0//経過時間
        time1.text = formatter.string(from: TimeInterval(0))!
        time2.text = formatter.string(from: TimeInterval(0))!
        if timer1 != nil{
            timer1!.invalidate()
        }
        if timer2 != nil{
            timer2!.invalidate()
        }
        startBtn.setImage(UIImage(named:"start"), for: .normal)
        gameStatus = .ready
    }
    @IBAction func touchDown_settingBtn(_ sender: Any) {
        
        // ①UIAlertControllerクラスのインスタンスを生成する
        // titleにタイトル, messegeにメッセージ, prefereedStyleにスタイルを指定する
        // preferredStyleにUIAlertControllerStyle.actionSheetを指定してアクションシートを表示する
        let actionSheet: UIAlertController = UIAlertController(
            title: "背景画像",
            message: "設定する位置を選択してください",
            preferredStyle: UIAlertController.Style.actionSheet)
        
        // ②選択肢の作成と追加
        // titleに選択肢のテキストを、styleに.defaultを
        // handlerにボタンが押された時の処理をクロージャで実装する
        actionSheet.addAction(
            UIAlertAction(title: "Player1",style: .default, handler: {
                            (action: UIAlertAction!) -> Void in
                            self.selected = .player1
                            self.callPhotoLibrary()
            })
        )
        
        // ②選択肢の作成と追加
        actionSheet.addAction(
            UIAlertAction(title: "Player2", style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.selected = .player2
                self.callPhotoLibrary()
            })
        )
        
        // ②選択肢の作成と追加
        actionSheet.addAction(
            UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        )
        
        // ③表示するViewと表示位置を指定する
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
        
        // ④アクションシートを表示
        present(actionSheet, animated: true, completion: nil)
    }
    func lifeReset(){
        let life:Int = 20
        //player1
        if _life1<life{
            for _ in 0..<abs(life-_life1) {
                lifeIncrement(.player1)
            }
        }
        else{
            for _ in 0..<abs(life-_life1) {
                lifeDecrement(.player1)
            }
        }
        //player2
        if _life2<life{
            for _ in 0..<abs(life-_life2) {
                lifeIncrement(.player2)
            }
        }
        else{
            for _ in 0..<abs(life-_life2) {
                lifeDecrement(.player2)
            }
        }
    }
    
    @IBAction func end(_ sender: Any){
        if GameStatus.playing == gameStatus{
            player1view.backgroundColor = Player.player1 == currentPlayer ? UIColor.clear: UIColor.blue
            player2view.backgroundColor = Player.player1 == currentPlayer ? UIColor.blue: UIColor.clear
            UIView.animate(withDuration: 0.5 / 2) { () -> Void in
                self.startBtn.transform = CGAffineTransform(rotationAngle:  CGFloat.pi / 2 *    (Player.player1 == self.currentPlayer ? -1.0 : 1.0))
            }
            passMin = 0
            if Player.player1 == currentPlayer {
                if timer1 != nil{
                    timer1!.invalidate()
                }
                timer2 = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:     #selector(self.timerFunc2),userInfo: nil, repeats: true)
                time2.text = formatter.string(from: TimeInterval(0))!
            }
            else{
                if timer2 != nil{
                    timer2!.invalidate()
                }
                timer1 = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:     #selector(self.timerFunc),userInfo: nil, repeats: true)
                time1.text = formatter.string(from: TimeInterval(0))!
            }
            currentPlayer = Player.player1 == currentPlayer ? .player2 : .player1
        }
    }
    
    @objc func timerFunc()  {
        updateDisp(passMin: &passMin ,time:time1)
    }
    @objc func timerFunc2()  {
        updateDisp(passMin: &passMin ,time:time2)
    }
    
    func updateDisp(passMin:inout Int,time : UILabel)  {
        passMin = passMin + 1
        time.text = formatter.string(from: TimeInterval(Double(passMin)))!
    }
    @IBAction func touchDown_plusBtn1(_ sender: Any) {
        lifeIncrement(.player1)
    }
    @IBAction func touchDown_centerPlusBtn1(_ sender: Any) {
        if GameStatus.ready == gameStatus {
            lifeIncrement(.player1)
        }
        else{
            end(sender)
        }
    }
    @IBAction func touchDown_plusBtn2(_ sender: Any) {
        lifeIncrement(.player2)
    }
    @IBAction func touchDown_centerPlusBtn2(_ sender: Any) {
        if GameStatus.ready == gameStatus {
            lifeIncrement(.player2)
        }
        else{
            end(sender)
        }
    }
    @IBAction func touchDown_minusBtn1(_ sender: Any) {
        lifeDecrement(.player1)
    }
    @IBAction func touchDown_centerMinusBtn1(_ sender: Any) {
        if GameStatus.ready == gameStatus {
            lifeDecrement(.player1)
        }
        else{
            end(sender)
        }
    }
    @IBAction func touchDown_minusBtn2(_ sender: Any) {
        lifeDecrement(.player2)
    }
    @IBAction func touchDown_centerMinusBtn2(_ sender: Any) {
        if GameStatus.ready == gameStatus {
            lifeDecrement(.player2)
        }
        else{
            end(sender)
        }
    }
    enum Player {
        case player1
        case player2
    }
    enum GameStatus{
        case ready
        case playing
        case stop
    }
    func lifeIncrement(_ p:Player){
        switch p {
        case .player1:
            _life1 += 1
            life1.text = String(_life1)
        case .player2:
            _life2 += 1
            life2.text = String(_life2)
        }
    }
    func lifeDecrement(_ p:Player)   {
        switch p {
        case .player1:
            _life1 -= 1
            life1.text = String(_life1)
        case .player2:
            _life2 -= 1
            life2.text = String(_life2)
        }
    }
    // 写真へのアクセスがOFFのときに使うメソッド
    func requestAuthorizationOn(){
        // authorization
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.denied) {
            //アクセス不能の場合。アクセス許可をしてもらう。snowなどはこれを利用して、写真へのアクセスを禁止している場合は先に進めないようにしている。
            //アラートビューで設定変更するかしないかを聞く
            let alert = UIAlertController(title: "写真へのアクセスを許可",
                                          message: "写真へのアクセスを許可する必要があります。設定を変更してください。",
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "設定変更", style: .default) { (_) -> Void in
                guard let _ = URL(string: UIApplication.openSettingsURLString ) else {
                    return
                }
            }
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel) { _ in
                // ダイアログがキャンセルされた。つまりアクセス許可は得られない。
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    //フォトライブラリを呼び出すメソッド
    func callPhotoLibrary(){
        //権限の確認
        requestAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
            //以下を設定することで、写真選択後にiOSデフォルトのトリミングViewが開くようになる
            picker.allowsEditing = true
            if let popover = picker.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = self.view.frame // ポップオーバーの表示元となるエリア
                popover.permittedArrowDirections = UIPopoverArrowDirection.any
            }
            self.present(picker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            if Player.player1 == self.selected{
                self.settingBackground(playerView: &player1view, setImage: pickedImage)
            }
            else{
                self.settingBackground(playerView: &player2view, setImage: pickedImage)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    func settingBackground(playerView : inout UIView, setImage : UIImage)  {
        
        let imageView = UIImageView(image:setImage)
        imageView.alpha = 0.6
        // スクリーンの縦横サイズを取得
        let playerViewWidth:CGFloat = playerView.frame.size.width
        let playerViewHeight:CGFloat = playerView.frame.size.height
        
        // 画像の縦横サイズを取得
        let imgWidth:CGFloat = setImage.size.width
        let imgHeight:CGFloat = setImage.size.height
        
        // 画像サイズをスクリーン幅に合わせる
        let scale:CGFloat = playerViewWidth / imgWidth
        let rect:CGRect =
            CGRect(x:0, y:0, width:imgWidth*scale, height:imgHeight*scale)
        
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
        imageView.center = CGPoint(x:playerViewWidth/2, y:playerViewHeight/2)
        
        // UIImageViewのインスタンスをビューに追加
        imageView.tag = 100
        
        //画像のviewを削除
        if let viewWithTag = playerView.viewWithTag(100){
            viewWithTag.removeFromSuperview()
        }
        
        var b:Bool = true
        for subView in playerView.subviews{
            if b{
                playerView.addSubview(imageView)
                b=false
            }
            playerView.addSubview(subView)
        }
    }
}



class CustomBtn:UIButton{
    
    //CABasicAnimationのtransform.zを使用する
    let rotationAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
    
    
    func spinAnim(_ sender: UIView,_ t:CGFloat)
    {
        rotationAnimation.toValue = CGFloat(Double.pi) * t
        rotationAnimation.duration = 0.4//アニメーションにかかる時間
        rotationAnimation.repeatCount = 1.0//何回繰り返すか(MAXFLOATを修正)
        
        
        //アニメーションさせたいものにaddする
        sender.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func spinStop(_ sender: UIView)
    {
        sender.layer.removeAnimation(forKey:"rotationAnimation")
    }
}
