//
//  ViewController.swift
//  lifeCounter
//
//  Created by 倉知諒 on 2019/06/04.
//  Copyright © 2019 kurachi. All rights reserved.
//

import UIKit
import Photos
import CoreData
import GoogleMobileAds

class ViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate, UITableViewDataSource,GADInterstitialDelegate{
    

    @IBOutlet weak var player1view: UIView!
    @IBOutlet weak var player2view: UIView!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var clearBtn: CustomBtn!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var life1: UILabel!
    @IBOutlet weak var life2: UILabel!
    @IBOutlet weak var time1: UILabel!
    @IBOutlet weak var time2: UILabel!
    @IBOutlet weak var time_master: UILabel!
    @IBOutlet weak var timerSw: UISwitch!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lifeflow_width: NSLayoutConstraint!
    @IBOutlet weak var constraint_sw_right: NSLayoutConstraint!
    @IBOutlet weak var constraint_history_right: NSLayoutConstraint!
    @IBOutlet weak var constraint_dice_right: NSLayoutConstraint!
    @IBOutlet weak var constraint_image_right: NSLayoutConstraint!
    @IBOutlet weak var constraint_clear_right: NSLayoutConstraint!
    @IBOutlet weak var dice: UIButton!
    @IBOutlet weak var p1bg: UIView!
    @IBOutlet weak var p2bg: UIView!
    var lifeflow_lifes = [[Int]]()
    
    var _life1 :Int=20
    var _life2 : Int=20
    
    var timer_master:Timer?
    
    var passMin_master:Int = 0
    let formatter = DateComponentsFormatter()
    var gameStatus:GameStatus = GameStatus.ready
    var currentPlayer : Player!
    var selected : Player!
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    var countDownCnt:Countdown = Countdown.three
    
    var interstitial: GADInterstitial!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //受信設定
        NotificationCenter.default.addObserver(self, selector: #selector(notificationFunc_pushhome(notification:)), name: .notificationName, object: nil)
        
        interstitial = createAndLoadInterstitial()
//        interstitial = GADInterstitial(adUnitID: Consts.ADMOB_UNIT_ID_INTERSTITIAL_CLEAR)
//        let request = GADRequest()
//        interstitial.load(request)
        
        // Do any additional setup after loading the view.
        player2view.transform=CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        p2bg.transform=CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        startBtn.imageView?.contentMode = .scaleAspectFit
        startBtn.contentHorizontalAlignment = .fill
        startBtn.contentVerticalAlignment = .fill
        clearBtn.imageView?.contentMode = .scaleAspectFit
        clearBtn.contentHorizontalAlignment = .fill
        clearBtn.contentVerticalAlignment = .fill
        settingBtn.imageView?.contentMode = .scaleAspectFit
        settingBtn.contentHorizontalAlignment = .fill
        settingBtn.contentVerticalAlignment = .fill
        
        formatter.unitsStyle = .brief
        formatter.allowedUnits = [.minute, .second]
        
        setBackground_init()
        setMasterSetting_init()
        self.setNeedsStatusBarAppearanceUpdate()
        
        tableView.rowHeight = 30
        tableView?.dataSource = self
        tableView?.delegate = self
        timeHiddenRefresh()
        
        //写真アクセス許可
        if #available(iOS 14, *) {
            let accessLebel:PHAccessLevel = .addOnly
            PHPhotoLibrary.requestAuthorization(for: accessLebel){status in
                DispatchQueue.main.async() {
                }
            }
//            PHPhotoLibrary.authorizationStatus(for: accessLebel)
        }
        else {
            // Fallback on earlier versions
            PHPhotoLibrary.requestAuthorization(){status in
                DispatchQueue.main.async() {
                }
            }
//            PHPhotoLibrary.authorizationStatus()
            dice.setTitle("D6", for: .normal)
        }
        
    }
    @objc func notificationFunc_pushhome(notification: NSNotification?) {
        print("called! notificationFunc_pushhome")
        //画面初期化
        screenInitialize([])
    }
    //背景設定初期メソッド（DBから読み込む）
    func setBackground_init()  {
        var player1Img:UIImage? = nil
        var player2Img:UIImage? = nil
        var scale1:CGFloat = CGFloat(1)
        var scale2:CGFloat = CGFloat(1)
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        
        let query: NSFetchRequest<Background> = Background.fetchRequest()
        
        do {
            let fetchResults = try viewContext.fetch(query)
            if fetchResults.count != 0 {
                for result: AnyObject in fetchResults {
                    let player: Int16 = result.value(forKey: "player") as! Int16
                    
                    if player==1 {
                        player1Img=UIImage(data: result.value(forKey: "picture") as! Data)
                        scale1 = result.value(forKey: "scale") as! CGFloat
                    }
                    else if player==2 {
                        player2Img=UIImage(data: result.value(forKey: "picture") as! Data)
                        scale2 = result.value(forKey: "scale") as! CGFloat
                    }
                }
            }
            self.settingBackground(playerView: &p1bg, setImage: player1Img ?? UIImage(),scale: scale1,initial: true)
            self.settingBackground(playerView: &p2bg, setImage: player2Img ?? UIImage(),scale: scale2,initial: true)
        } catch {
        }
    }
    func setMasterSetting_init()  {
        let query: NSFetchRequest<Setting> = Setting.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(query)
            if fetchResults.count != 1 {
                setRecodeSw(isOn: false)
            }
            else{
                setRecodeSw(isOn: (fetchResults[0] as Setting).recode)
            }
        } catch {
        }
    }
    func setRecodeSw(isOn:Bool)  {
        timerSw.isOn=isOn
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
    @IBAction func timerSwValueChanged(_ sender: Any) {
        timeHiddenRefresh()
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let viewContext = appDelegate.persistentContainer.viewContext
        
        //delete
        let request: NSFetchRequest<Setting> = Setting.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let record = result as! NSManagedObject
                viewContext.delete(record)
            }
            try viewContext.save()
        } catch {
        }
        
        //insert
        let entity = NSEntityDescription.entity(forEntityName: "Setting", in: viewContext)
        let recode = NSManagedObject(entity: entity!, insertInto: viewContext) as! Setting
        recode.recode=timerSw.isOn
        appDelegate.saveContext()
        
        //select
        let query: NSFetchRequest<Setting> = Setting.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(query)
            let setting = fetchResults[0] as Setting
            setRecodeSw(isOn: setting.recode)
        } catch {
        }
        
    }
    func timeHiddenRefresh()  {
        time1.isHidden = true
        time2.isHidden = true
        startBtn.isHidden = !timerSw.isOn
        settingBtn.isHidden = timerSw.isOn
        lifeflow_width.constant = timerSw.isOn ? 80 : 0
        if Utilities.isSmall() {
            constraint_sw_right.constant=timerSw.isOn ? 15 : 25
            constraint_history_right.constant=timerSw.isOn ? 15 : 25
            constraint_clear_right.constant=timerSw.isOn ? 10 : 16
        }
//        constraint_history_right.constant=timerSw.isOn ? 10 : 30
        constraint_dice_right.constant=timerSw.isOn ? (Utilities.isSmall() ? -20 : -10) : 25
        constraint_image_right.constant=timerSw.isOn ? 0 : 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lifeflow_lifes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lifes:[Int] = lifeflow_lifes[indexPath.row]
        let cell: TableViewCell_lifeflow = tableView.dequeueReusableCell(withIdentifier: "TableViewCell_lifeflow") as! TableViewCell_lifeflow
        cell.setCell(data: Data_lifeflow(p1life: lifes[0], p2life: lifes[1]))
        return cell
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let swipeCell = UITableViewRowAction(style: .default, title: NSLocalizedString("deleteBtn_title", comment: "")) { action, index in
            self.lifeflow_lifes.remove(at: indexPath.row)
            tableView.reloadData()
        }
        swipeCell.backgroundColor = .red
        return [swipeCell]
    }
    @IBAction func touchDown_startBtn(_ sender: Any) {
        switch gameStatus {
        case .ready:
            
            //ちょいバック回転(回転と言うよりはそれになるといった感じ。pi / 2   は画像の初期位置を0としてそれから45°き回転させた位置)
            let random = Int.random(in: 1 ... 10)
            startBtn.setImage(UIImage(named:"pause"), for: .normal)
            if random % 2 == 0 {
                currentPlayer = .player2
            }
            else{
                currentPlayer = .player1
            }
            timer_master = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:  #selector(self.timerFunc_master),userInfo: nil, repeats: true)
            gameStatus = .playing
            
        case .playing:
            startBtn.setImage(UIImage(named:"start"), for: .normal)
            if timer_master != nil{
                timer_master!.invalidate()
            }
            gameStatus = .stop
        case .stop:
            startBtn.setImage(UIImage(named:"pause"), for: .normal)
            timer_master = Timer.scheduledTimer(timeInterval: 1.0,target: self, selector:  #selector(self.timerFunc_master),userInfo: nil, repeats: true)
            gameStatus = .playing
        }
    }
    @IBAction func touchDown_clearBtn(_ sender: Any) {
        let t:CGFloat = -1.0
        self.clearBtn.spinAnim(self.clearBtn,t)
        
        //広告表示(勝ってたら広告を表示)
        if interstitial.isReady && Int(life1.text!)! > Int(life2.text!)! {
            interstitial.present(fromRootViewController: self)
        }
        else {
            print("Ad wasn't ready")
        }
        
        lifeReset()
        if timerSw.isOn {
            saveGame()
        }
        
        //画面初期化
        screenInitialize(sender)
        timerSwValueChanged(sender)
    }
    
    //広告作成
    func createAndLoadInterstitial() -> GADInterstitial {
        var interstitial = GADInterstitial(adUnitID: Consts.ADMOB_UNIT_ID_INTERSTITIAL_CLEAR)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }

    //広告非表示
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen!!")
        interstitial = createAndLoadInterstitial()
    }
    
    func screenInitialize(_ sender: Any)  {
        passMin_master = 0//経過時間
        updateDisp(passMin: &passMin_master ,time:time_master)
        if timer_master != nil{
            timer_master!.invalidate()
        }
        lifeflow_lifes.removeAll()
        tableView.reloadData()
        startBtn.setImage(UIImage(named:"start"), for: .normal)
        gameStatus = .ready
    }
    
    func saveGame()  {
        let gameEntity = NSEntityDescription.entity(forEntityName: "Game", in: viewContext)
        let gameRecode = NSManagedObject(entity: gameEntity!, insertInto: viewContext) as! Game
        gameRecode.gameDate=Date()
        gameRecode.time=time_master.text

        for (index,lifes) in lifeflow_lifes.enumerated() {
            for (index_life,life) in lifes.enumerated() {
                let lifeEntity = NSEntityDescription.entity(forEntityName: "Life", in: viewContext)
                let lifeRecode = NSManagedObject(entity: lifeEntity!, insertInto: viewContext) as! Life
                lifeRecode.player=Int16(index_life)
                lifeRecode.stage=Int16(index)
                lifeRecode.life=Int16(life)
                lifeRecode.game = gameRecode
            }
        }
        appDelegate.saveContext()
    }
    @IBAction func touchDown_settingBtn(_ sender: Any) {
        let actionSheet: UIAlertController = UIAlertController(
            title: NSLocalizedString("bgAlert_title", comment: ""),
            message: NSLocalizedString("bgAlert_messsage", comment: ""),
            preferredStyle: UIAlertController.Style.actionSheet)
        actionSheet.addAction(
            UIAlertAction(title: NSLocalizedString("bgAlert_button_set_1", comment: ""),style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                    self.selected = .player1
                    self.callPhotoLibrary()
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: NSLocalizedString("bgAlert_button_set_2", comment: ""), style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.selected = .player2
                self.callPhotoLibrary()
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: NSLocalizedString("bgAlert_button_del_1", comment: ""), style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.deleteImg(player: Player.player1)
                self.setBackground_init()
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: NSLocalizedString("bgAlert_button_del_2", comment: ""), style: .default, handler: {
                (action: UIAlertAction!) -> Void in
                self.deleteImg(player: Player.player2)
                self.setBackground_init()
            })
        )
        actionSheet.addAction(
            UIAlertAction(title: NSLocalizedString("bgAlert_button_cancel", comment: ""), style: .cancel, handler: nil)
        )
        actionSheet.popoverPresentationController?.sourceView = view
        actionSheet.popoverPresentationController?.sourceRect = (sender as AnyObject).frame
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func touchDown_dice6(_ sender: Any) {
        let diceNum_p1 = getDiceNum(type: DiceType.six)
        var diceNum_p2 = getDiceNum(type: DiceType.six)
        while diceNum_p1 == diceNum_p2 {
            print("一致したので振り直し p1:\(diceNum_p1),p2\(diceNum_p2)")
            diceNum_p2 = getDiceNum(type: DiceType.six)
        }
        ViewController_popup.dispDiceImage = getDiceImage(type: .six, num: diceNum_p1)
        ViewController_popup.dispDiceImage2 = getDiceImage(type: .six, num: diceNum_p2)
        performSegue(withIdentifier: "toPopUp", sender: nil)
    }
    func deleteImg(player:Player)  {
        let request: NSFetchRequest<Background> = Background.fetchRequest()
        let predicate = NSPredicate(format: "player = \(Player.player1==player ? "1" : "2")")

        request.predicate = predicate
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let record = result as! NSManagedObject
                viewContext.delete(record)
            }
            try viewContext.save()
        } catch {
        }
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
    @objc func timerFunc_master()  {
        updateDisp(passMin: &passMin_master ,time:time_master)
        countDown()
        if countDownCnt == .zero {
            recodeLife()
        }
    }
    
    func updateDisp(passMin:inout Int,time : UILabel)  {
        time.text = formatter.string(from: TimeInterval(Double(passMin)))!
        passMin = passMin + 1
    }
    func recodeLife()  {
        //前のライフと同じ場合記録しない
        if lifeflow_lifes.count != 0
            && lifeflow_lifes[lifeflow_lifes.count-1][0] == _life1
            && lifeflow_lifes[lifeflow_lifes.count-1][1] == _life2
        {
            print("life recode return")
            return
        }
        
        lifeflow_lifes.append([_life1,_life2])
        for lifes in lifeflow_lifes {
            print("add! p1 : \(lifes[0]) , p2 : \(lifes[1])")
        }
        tableView.reloadData()
    }
    @IBAction func touchDown_plusBtn1(_ sender: Any) {
        lifeIncrement(.player1)
    }
    @IBAction func touchDown_centerPlusBtn1(_ sender: Any) {
//        if GameStatus.ready == gameStatus ||
//            GameStatus.stop == gameStatus ||
//            !timerSw.isOn{
            lifeIncrement(.player1)
//        }
//        else{
//            end(sender)
//        }
    }
    @IBAction func touchDown_plusBtn2(_ sender: Any) {
        lifeIncrement(.player2)
    }
    @IBAction func touchDown_centerPlusBtn2(_ sender: Any) {
//        if GameStatus.ready == gameStatus ||
//            GameStatus.stop == gameStatus ||
//            !timerSw.isOn {
            lifeIncrement(.player2)
//        }
//        else{
//            end(sender)
//        }
    }
    @IBAction func touchDown_minusBtn1(_ sender: Any) {
        lifeDecrement(.player1)
    }
    @IBAction func touchDown_centerMinusBtn1(_ sender: Any) {
//        if GameStatus.ready == gameStatus ||
//            GameStatus.stop == gameStatus ||
//            !timerSw.isOn {
            lifeDecrement(.player1)
//        }
//        else{
//            end(sender)
//        }
    }
    @IBAction func touchDown_minusBtn2(_ sender: Any) {
        lifeDecrement(.player2)
    }
    @IBAction func touchDown_centerMinusBtn2(_ sender: Any) {
//        if GameStatus.ready == gameStatus ||
//            GameStatus.stop == gameStatus ||
//            !timerSw.isOn {
            lifeDecrement(.player2)
//        }
//        else{
//            end(sender)
//        }
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
    enum DiceType {
        case six
        case twenty
    }
    enum Countdown {
        case three
        case two
        case one
        case zero
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
        var status:PHAuthorizationStatus
        if #available(iOS 14, *) {
            let accessLebel:PHAccessLevel = .addOnly
            status = PHPhotoLibrary.authorizationStatus(for: accessLebel)
        } else {
            // Fallback on earlier versions
            status = PHPhotoLibrary.authorizationStatus()
        }
        // authorization
        if (status != .authorized) {
//            if (status == PHAuthorizationStatus.denied) {
            //アクセス不能の場合。アクセス許可をしてもらう。snowなどはこれを利用して、写真へのアクセスを禁止している場合は先に進めないようにしている。
            //アラートビューで設定変更するかしないかを聞く
            let alert = UIAlertController(title: NSLocalizedString("PhotoAuthAlert_title", comment: ""),
                                          message: NSLocalizedString("PhotoAuthAlert_messsage", comment: ""),
                                          preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: NSLocalizedString("PhotoAuthAlert_button_1", comment: ""), style: .default) { (_) -> Void in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                    return
                }
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
            alert.addAction(settingsAction)
            alert.addAction(UIAlertAction(title: NSLocalizedString("PhotoAuthAlert_button_cancel", comment: ""), style: .cancel) { _ in
                // ダイアログがキャンセルされた。つまりアクセス許可は得られない。
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    //フォトライブラリを呼び出すメソッド
    func callPhotoLibrary(){
        //権限の確認
        self.requestAuthorizationOn()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.modalPresentationStyle = UIModalPresentationStyle.popover
            picker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
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
    func countDown() {
        switch countDownCnt {
        case .three:
            countDownCnt = .two
        case .two:
            countDownCnt = .one
        case .one:
            countDownCnt = .zero
        case .zero:
            countDownCnt = .three
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
//        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        let viewContext = appDelegate.persistentContainer.viewContext
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let request: NSFetchRequest<Background> = Background.fetchRequest()
            var predicate:NSPredicate
            let p1selected = (Player.player1 == self.selected)
//            // スクリーンの縦横サイズを取得
//            let playerViewWidth:CGFloat = playerView.frame.size.width
//            let playerViewHeight:CGFloat = playerView.frame.size.height
//
//            // 画像の縦横サイズを取得
//            let imgWidth:CGFloat = setImage.size.width
//            let imgHeight:CGFloat = setImage.size.height
            // スクリーンの縦横サイズを取得
            let playerViewWidth:CGFloat = p1bg.frame.size.width
//            let playerViewHeight:CGFloat = player1view.frame.size.height
            
            // 画像の縦横サイズを取得
            let imgWidth:CGFloat = pickedImage.size.width
//            let imgHeight:CGFloat = pickedImage.size.height
            
            let scale:CGFloat = playerViewWidth / imgWidth
            
            predicate = NSPredicate(format: "player = " + (p1selected ? "1" : "2"))
            request.predicate = predicate
            
            var change = false
            
            //change
            do {
                let fetchResults = try viewContext.fetch(request)
                if(fetchResults.count != 0){
                    change=true
                    for result: AnyObject in fetchResults {
                        let record = result as! NSManagedObject
                        record.setValue((p1selected ? 1 : 2), forKey: "player")
                        record.setValue(pickedImage.pngData(), forKey: "picture")
                        record.setValue(scale, forKey: "scale")
                    }
                    try viewContext.save()
                }
            } catch {
            }
            //add
            if !change {
                let background = NSEntityDescription.entity(forEntityName: "Background", in: viewContext)
                let newRecord = NSManagedObject(entity: background!, insertInto: viewContext)
                newRecord.setValue((p1selected ? 1 : 2), forKey: "player")
                newRecord.setValue(pickedImage.pngData(), forKey: "picture")
                newRecord.setValue(scale, forKey: "scale")
                appDelegate.saveContext()
            }
            
            //背景設定
            if Player.player1 == self.selected{
                self.settingBackground(playerView: &p1bg, setImage: pickedImage,scale: scale)
            }
            else{
                self.settingBackground(playerView: &p2bg, setImage: pickedImage,scale: scale)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //背景画像を設定
    //  playerView:プレイヤービュー
    //  setImage:背景画像
    func settingBackground(playerView : inout UIView, setImage : UIImage,scale:CGFloat,initial:Bool = false)  {
        
        let imageView = UIImageView(image:setImage)
        imageView.alpha = 0.6
        // スクリーンの縦横サイズを取得
//        let playerViewWidth:CGFloat = playerView.frame.size.width
//        let playerViewHeight:CGFloat = playerView.frame.size.height
        
        // 画像の縦横サイズを取得
        let imgWidth:CGFloat = setImage.size.width
        let imgHeight:CGFloat = setImage.size.height
        
//        print("imgWidth:\(imgWidth)")
//        print("imgHeight:\(imgHeight)")
        
        // 画像サイズをスクリーン幅に合わせる
//        let scale:CGFloat = playerViewWidth / imgWidth
//        let scale:CGFloat = 0.4
        print("scale:\(scale)")
        let rect:CGRect =
            CGRect(x:0, y:0, width:imgWidth*scale, height:imgHeight*scale)
//        let scale_w:CGFloat = playerViewWidth / imgWidth
//        let scale_h:CGFloat = playerViewWidth / imgHeight
//        let rect:CGRect =
//            CGRect(x:0, y:0, width:imgWidth*scale_w, height:imgHeight*scale_h)
        
        // ImageView frame をCGRectで作った矩形に合わせる
        imageView.frame = rect;
        
        // 画像の中心を画面の中心に設定
//        imageView.center = CGPoint(x:playerViewWidth/2, y:playerViewHeight/2)
        
        // UIImageViewのインスタンスをビューに追加
        imageView.tag = 100
        
        //画像のviewを削除
        if let viewWithTag = playerView.viewWithTag(100){
            viewWithTag.removeFromSuperview()
        }
        
        if playerView.subviews.count == 0 {
            playerView.addSubview(imageView)
        }
        else{
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
    
    func getDiceNum(type:DiceType) -> Int16 {
        var num:Int
        switch type {
        case .six:
            num = Int.random(in: 1 ... 6)
        case .twenty:
            num = Int.random(in: 1 ... 20)
        }
        return Int16(num)
    }
    func getDiceImage(type:DiceType,num:Int16) -> UIImage {
        var image = UIImage()
        switch type {
        case .six:
            image = UIImage(named: UITraitCollection.isDarkMode ? "dice\(num)n" : "dice\(num)d")!
        case .twenty:
            image = UIImage()
        }
        return image
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
