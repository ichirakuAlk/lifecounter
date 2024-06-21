//
//  SettingsTableViewController.swift
//  SettingsInAppExample
//
//  Created by Sakura on 2018/03/07.
//  Copyright © 2018年 Sakura. All rights reserved.
//

import UIKit
import Photos
import MediaPlayer
import CoreData
import UniformTypeIdentifiers
import AVFoundation
import Toast_Swift
import GoogleMobileAds

class SettingsTableViewController: UITableViewController{
    
    @IBOutlet weak var interval: UISlider!
    @IBOutlet weak var intervalLabel: UILabel!
    @IBOutlet weak var interval2: UISlider!
    @IBOutlet weak var intervalLabel2: UILabel!
    @IBOutlet var interval3: UISlider!
    @IBOutlet var opacityLabel: UILabel!
    
    @IBOutlet var bannerView: GADBannerView!
    weak var delegate: ChildViewControllerDelegate?
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    
//    var bannerView: GADBannerView!
    var upperLifeP1:Int = 20
    var upperLifeP2:Int = 20
    var bgopacity:Float = 0.8
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        
        // In this case, we instantiate the banner with desired ad size.
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
//        bannerView = GADBannerView()
        bannerView.adUnitID = Consts.ADMOB_UNIT_ID_HISTORY2
//        bannerView.adUnitID = "ca-app-pub-5418872710464793/9454905695"
        bannerView.rootViewController = self
//        addBannerViewToView(bannerView)
//        bannerView.load(GADRequest())
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
////        interval.isEnabled = false
////        intervalLabel.isEnabled = false
////        intervalTitleLabel.isEnabled = false
//    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let request: NSFetchRequest<Setting> = Setting.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(request)
            if let setting = fetchResults.first {
//                screenRotate = Rotate(rawValue: setting.rotateDirection) ?? .normal
                upperLifeP1 = Int(setting.defaultLifeP1)
                intervalLabel.text = "\(upperLifeP1)"
                interval.setValue(Float(upperLifeP1), animated: false)
                
                upperLifeP2 = Int(setting.defaultLifep2)
                intervalLabel2.text = "\(upperLifeP2)"
                interval2.setValue(Float(upperLifeP2), animated: false)
                
                if setting.bgopacity != 0 {
                    bgopacity=setting.bgopacity
                    opacityLabel.text = "\(bgopacity)"
                    interval3.setValue(bgopacity, animated: false)
                }
            } else {
//                screenRotate = .normal
                print("設定なし”")
            }
        } catch {
            print("Error fetching data: \(error)")
        }
        //ad
        loadBannerAd()
    }
    
    override func viewWillTransition(to size: CGSize,
                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to:size, with:coordinator)
        //ad start
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
        //ad end
    }
    //ad
    func loadBannerAd() {
        let frame = { () -> CGRect in
        if #available(iOS 11.0, *) {
            return view.frame.inset(by: view.safeAreaInsets)
        } else {
            return view.frame
        }
        }()
        let viewWidth = frame.size.width
        let viewHeight = frame.size.height
        let aspect = viewHeight/viewWidth
        print("aspect:\(aspect)")
        bannerView.adSize = GADInlineAdaptiveBannerAdSizeWithWidthAndMaxHeight(viewWidth,50*aspect)
        let request: GADRequest = GADRequest()
        bannerView.load(request)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // セクションの数を返します
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // それぞれのセクション毎に何行のセルがあるかを返します
        switch section {
        case 0: // 「設定」のセクション
            return 7
        case 1: // 「その他」のセクション
            return 0//要らないから表示しない
        default: // ここが実行されることはないはず
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            if indexPath.row == 0 {
//                //画像
//                callPhotoLibrary()
//            }
//            else if indexPath.row == 2 {
//                let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.wav,UTType.mp3])
//                documentPicker.delegate = self
//                self.present(documentPicker, animated: true, completion: nil)
//                // クルクルスタート
//                ActivityIndicator.startAnimating()
//            }
//        }
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    @IBAction func touchDown_save(_ sender: Any) {
//        var adCount = 0
//        var dataCount = 0
//        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//        let request_ad: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//        do {
//            request.predicate = NSPredicate(format: "adFlg = true")
//            request_ad.predicate = NSPredicate(format: "adFlg = false")
//            var fetchResults = try viewContext.fetch(request)
//            adCount = fetchResults.count
//            fetchResults = try viewContext.fetch(request_ad)
//            dataCount = fetchResults.count
//        }
//        catch  let e as NSError{
//            print("error !!! : \(e)")
//        }
//        
//        if (addAd(dataCount: dataCount, adCount: adCount))
//        {
//            save(adFlag: true)//add ad
//        }
        save(adFlag: false)
        
        let screenSizeWidth = UIScreen.main.bounds.width
        let screenSizeHeight = UIScreen.main.bounds.height
        let offsetY = self.tableView.contentOffset.y
        var hosei = offsetY
        if hosei < 0 {
            hosei = 0
        }
        print("tableview offset y : \(offsetY)")
        self.view.makeToast("Saved!", point: CGPoint(x: screenSizeWidth/2, y: screenSizeHeight/2+hosei), title: nil, image: nil, completion: nil)
        delegate?.didPerformAction(from: self)
    }
//    func addAd(dataCount:Int,adCount:Int) -> Bool {
//        let interval = 5
//        let tekiseisu = Int(dataCount/interval)
//        print("adCount : \(adCount),tekiseisu : \(tekiseisu)")
//        return adCount < tekiseisu
//    }
    func save(adFlag:Bool){
//        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        let viewContext = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Setting> = Setting.fetchRequest()
        do {
            let fetchResults = try viewContext.fetch(request)
            if let text = intervalLabel.text,
               let integerValue = Int(text),
               let int16Value = Int16(exactly: integerValue) ,
               let text2 = intervalLabel2.text,
               let integerValue2 = Int(text2),
               let int16Value2 = Int16(exactly: integerValue2) {
                if fetchResults.isEmpty {
                    //insert
                    let entity = NSEntityDescription.entity(forEntityName: "Setting", in: viewContext)
                    if let entity = entity {
                        let record = Setting(entity: entity, insertInto: viewContext)
                        record.defaultLifeP1=int16Value
                        record.defaultLifep2=int16Value2
                        record.bgopacity=bgopacity
                    }
                }
                else{
                    //edit
                    for record in fetchResults {
                        record.defaultLifeP1=int16Value
                        record.defaultLifep2=int16Value2
                        record.bgopacity=bgopacity
                    }
                }
            } else {
                // 変換に失敗した場合の処理
                print("Int16への変換に失敗しました")
            }
            try viewContext.save()
            //            appDelegate.saveContext()
        } catch {
        }
//        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//        let request_cat: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
//        if targetId != nil {
////                request.predicate = NSPredicate(format: "id = \(targetId)")
//            request.predicate = NSPredicate(format: "id = %d", targetId!)
//        }
//        
//        var change = false
//        //create voice data
//        let entity_voice = NSEntityDescription.entity(forEntityName: "VoiceData", in: viewContext)
//        let record_voice = NSManagedObject(entity: entity_voice!, insertInto: viewContext) as! VoiceData
////                record_voice.id = targetId!
//        record_voice.fileData = fileData
//        
//        if selectedRow != 0 {
//            request_cat.predicate = NSPredicate(format: "categoryId = %d", categories[selectedRow - 1].categoryId)
//        }
//        if adFlag && categories.count != 0 {
//            //広告を入れるカテゴリをランダムに決定する
//            var rand = 0
//            
//            do {
//                //フェールセーフ
//                var limit = 30//ランダム値取得制限（データが存在しない）
//                var limit_notExistAd = 10//ランダム値取得制限（広告が存在する）
//                while limit > 0 && limit_notExistAd > 0{
//                    rand = Int.random(in: 0...(categories.count - 1))
//                    let request = SoineData.fetchRequest()
//                    request.predicate = NSPredicate(format: "categoryData.categoryId = %d", categories[rand].categoryId)
//                    let fetchResults = try viewContext.fetch(request)
//                    //データが存在するカテゴリを対象にする
//                    if fetchResults.count != 0 {
//                        let request2: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//                        request2.predicate = NSPredicate(format: "categoryData.categoryId = %d and adFlg = true", categories[rand].categoryId)
//                        let fetchResults2 = try viewContext.fetch(request2)
//                        //広告が存在しないカテゴリを対象にする
//                        if fetchResults2.count == 0 {
//                            break
//                        }
//                        //なければupperを減らして最終的なランダム値が採用される（広告が存在する）
//                        else{
//                            print("loop not exist ad - rand : \(rand)")
//                            limit_notExistAd = limit_notExistAd - 1
//                        }
//                    }
//                    else{
//                        print("loop - rand : \(rand)")
//                        limit = limit - 1
//                    }
//                }
//                if limit <= 0 {
//                    print("ループ上限")
//                }
//                if limit_notExistAd <= 0 {
//                    print("ループ上限　adなし")
//                }
//            } catch  let e as NSError{
//                print("error !!! : \(e)")
//            }
////            rand = Int.random(in: 0...(categories.count - 1))
//            print("rand : \(rand)")
//            request_cat.predicate = NSPredicate(format: "categoryId = %d", categories[rand].categoryId)
//        }
//        do {
//            let fetchResults = try viewContext.fetch(request)
//            let fetchResults_cat = try viewContext.fetch(request_cat)
//            //change
//            if(fetchResults.count != 0 && targetId != nil && !adFlag){
//                change=true
//                for result: AnyObject in fetchResults {
//                    let record = result as! SoineData
//                    record.id = targetId!
//                    
//                    //image
//                    record.picture = imageData
//                    if scale != nil {
//                        record.scale = Float(scale!)
//                    }
//                    
//                    //voice
//                    record.voiceName = fileName
//                    record.voiceFileExtention = fileExtention
//                    record_voice.id = targetId!
//                    record.voiceData = record_voice
//                    record.voiceLoopFlg = loopFlag.isOn
//                    record.voiceLoopCount = Int16(voiceLoopCount)
//                    
//                    //category
//                    if selectedRow == 0 {
//                        record.categoryData = nil
//                    }
//                    else{
//                        record.categoryData = fetchResults_cat[0]
//                    }
//                    
//                }
//                try viewContext.save()
//            }
//            
//            //add
//            //ad - add
//            //ad - change
//            if !change || adFlag {
//                let next_id = Utilities.getNextId(viewContext: viewContext)
//                let soineData = NSEntityDescription.entity(forEntityName: "SoineData", in: viewContext)
//                let record = NSManagedObject(entity: soineData!, insertInto: viewContext) as! SoineData
//                record.id = next_id
//                
//                //image
//                record.picture = imageData
//                if scale != nil {
//                    record.scale = Float(scale!)
//                }
//                
//                //voice
//                record.voiceName = fileName
//                record.voiceFileExtention = fileExtention
//                record_voice.id = next_id
//                record.voiceData = record_voice
//                record.voiceLoopFlg = loopFlag.isOn
//                record.voiceLoopCount = Int16(voiceLoopCount)
//                
//                //category
//                //新規かつ広告でない
//                if selectedRow == 0 && !adFlag {
//                    record.categoryData = nil
//                }
//                else if categories.count != 0 {
//                    record.categoryData = fetchResults_cat[0]
//                }
//                else{
//                    record.categoryData = nil
//                }
//                
//                //ad
//                record.adFlg = adFlag
//                
//                appDelegate.saveContext()
//                
//                if !adFlag {
//                    targetId = next_id
//                }
//            }
//        } catch let e as NSError{
//            print("error !!! : \(e)")
//        }
    }
//    @IBAction func editingChanged_interval(_ sender: Any) {
//    }
//    @IBAction func valueChanged_loopFlg(_ sender: Any) {
//        interval.setNeedsLayout()
//        interval.isEnabled = !loopFlag.isOn
//        intervalLabel.isEnabled = !loopFlag.isOn
//        intervalTitleLabel.isEnabled = !loopFlag.isOn
//        
////        let indexPath = IndexPath(row: 5, section: 0)
////        tableView.reloadRows(at: [indexPath], with: .none)
//    }
    @IBAction func valueChanged_interval(_ sender: Any) {
        print("interval value : \(interval.value)")
        upperLifeP1 = Int(round(interval.value))
        intervalLabel.text = "\(upperLifeP1)"
//        interval.setValue(v, animated: false)
    }
    @IBAction func valueChanged_interval2(_ sender: Any) {
        print("interval2 value : \(interval2.value)")
        upperLifeP2 = Int(round(interval2.value))
        intervalLabel2.text = "\(upperLifeP2)"
//        interval.setValue(v, animated: false)
    }
    @IBAction func valueChanged_opacity(_ sender: Any) {
        print("interval2 value : \(interval3.value)")
        bgopacity = Float(round(interval3.value * 10) / 10)
        opacityLabel.text="\(bgopacity)"
    }
    //    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        print("touchesEnded")
//    }
    
//    deinit {
//    // UserDefaultsの変更の監視を解除する
//        NotificationCenter.default.removeObserver(self, name: UserDefaults.didChangeNotification, object: nil)
//    }
}
