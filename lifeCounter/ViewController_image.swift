//
//  ViewController.swift
//  soine
//
//  Created by 倉知諒 on 2022/04/22.
//

import UIKit
import Photos
import CoreData
import Toast_Swift
import GoogleMobileAds

class ViewController_image: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var datas: [Background] = []
//    var sections: [CategoryDataDisplay] = []
//    var selectedData:SoineData?
    
    var appDelegate:AppDelegate!
    var viewContext:NSManagedObjectContext!
    var existNonCategorize = false
    
    weak var delegate: ChildViewControllerDelegate?
    @IBOutlet var bannerView: GADBannerView!
//    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController viewDidLoad")
        // Do any additional setup after loading the view.
        
        //写真アクセス許可
        if #available(iOS 14, *) {
            let accessLebel:PHAccessLevel = .readWrite
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
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let backButton = UIBarButtonItem()
//        backButton.title = "もどる"
        navigationItem.backBarButtonItem = backButton
        
        // In this case, we instantiate the banner with desired ad size.
//        settingAd()
        //ad start
        bannerView.adUnitID = Consts.ADMOB_UNIT_ID_HISTORY
        bannerView.rootViewController = self
        //ad end
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController viewWillAppear")
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        viewContext = appDelegate.persistentContainer.viewContext
        refreshData()
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
    
//    func settingAd() {
//        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
////        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"//test ad
//        bannerView.adUnitID = "ca-app-pub-5418872710464793/4324956840"
//        bannerView.rootViewController = self
//        addBannerViewToView(bannerView)
////        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [Consts.ADMOB_TEST_DEVICE_ID,Consts.ADMOB_TEST_DEVICE_ID_SE2]
//        bannerView.load(GADRequest())
//    }
    func refreshData() {
//        updateIsNonCategorize()
//        appendSections()
        datas = []
//        for _ in 0..<sections.count {
//            datas.append([])
//        }
//        var loopCnt = sections.count
//        if existNonCategorize {
//            loopCnt = loopCnt - 1
//        }
        let request: NSFetchRequest<Background> = Background.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: false)
        let sortDescriptors = [sortDescriptor]
        request.sortDescriptors = sortDescriptors
        do {
            let fetchResults = try viewContext.fetch(request)
            for result: AnyObject in fetchResults {
                let soineData = result as! Background
//                var insert = false
//                for i in 0 ..< loopCnt {
//                    if soineData.categoryData?.categoryId == sections[i].categoryId {
//                        datas[i].append(soineData)
//                        insert = true
//                    }
//                }
//                if !insert {
//                    datas[datas.count - 1].append(soineData)
                datas.append(soineData)
//                }
            }
        } catch let e as NSError{
            print("error !!! : \(e)")
        }
        tableView.reloadData()
//        UIView.transition(with: tableView, duration: 1.0, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
//    func appendSections() {
//        sections = []
//        let request: NSFetchRequest<CategoryData> = CategoryData.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "categoryId", ascending: true)
//        let sortDescriptors = [sortDescriptor]
//        request.sortDescriptors = sortDescriptors
//        do {
//            let fetchResults = try viewContext.fetch(request)
//            for result: AnyObject in fetchResults {
//                let categoryData = result as! CategoryData
//                if categoryData.soineData != nil && categoryData.soineData!.count != 0 {
//                    sections.append(CategoryDataDisplay(_categoryId: categoryData.categoryId, _name: categoryData.name!))
//                }
//            }
//            if existNonCategorize {
//                sections.append(CategoryDataDisplay(_categoryId: nil, _name: "ほか"))
//            }
//        } catch let e as NSError{
//            print("error !!! : \(e)")
//        }
//    }
//    func updateIsNonCategorize() {
//        existNonCategorize = false
//        let request: NSFetchRequest<SoineData> = SoineData.fetchRequest()
//        do{
//            let fetchResults = try viewContext.fetch(request)
//            for result: AnyObject in fetchResults {
//                let soineData = result as! SoineData
//                if soineData.categoryData == nil {
//                    existNonCategorize = true
//                }
//            }
//        } catch let e as NSError{
//            print("error !!! : \(e)")
//        }
//    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toSoine" {
//            let nextVC = segue.destination as! SoineViewController
//            if selectedData != nil {
//                nextVC.targetId = selectedData!.id
//            }
//        }
//        else if segue.identifier == "toSetting" {
//            let nextVC = segue.destination as! SettingsTableViewController
//            if selectedData != nil {
//                nextVC.targetId = selectedData!.id
//            }
//        }
//    }
    @IBAction func touchDown_add(_ sender: Any) {
//        selectedData = nil
//        self.performSegue(withIdentifier: "toSetting", sender: nil)
        //画像を追加するピッカーを起動する
        self.callPhotoLibrary()
    }
//    @IBAction func toushDown_edit(_ sender: Any) {
//        tableView.setEditing(!tableView.isEditing, animated: true)
//    }
//    func addBannerViewToView(_ bannerView: GADBannerView) {
//        bannerView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(bannerView)
//        view.addConstraints(
//            [NSLayoutConstraint(item: bannerView,
//                                attribute: .bottom,
//                                relatedBy: .equal,
//                                toItem: bottomLayoutGuide,
//                                attribute: .top,
//                                multiplier: 1,
//                                constant: 0),
//             NSLayoutConstraint(item: bannerView,
//                                attribute: .centerX,
//                                relatedBy: .equal,
//                                toItem: view,
//                                attribute: .centerX,
//                                multiplier: 1,
//                                constant: 0)
//            ])
//    }
}
///////////////////////////
///extentions
/////////////////////////
extension ViewController_image:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return datas[section].count
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let soineData: SoineData = datas[indexPath.section][indexPath.row]
        let soineData: Background = datas[indexPath.row]
//        if soineData.adFlg {
//            let cell: TableViewCell_list_ad = tableView.dequeueReusableCell(withIdentifier: "TableViewCell_list_ad") as! TableViewCell_list_ad
//            cell.setCell(unitId: "ca-app-pub-5418872710464793/1165352137", rootViewController: self, _id: soineData.id)
//            return cell
//        }
        let cell: TableViewCell_list = tableView.dequeueReusableCell(withIdentifier: "TableViewCell_list") as! TableViewCell_list
        let image:UIImage = soineData.picture == nil ? UIImage() : UIImage(data: soineData.picture!)!
//        let voiceName: String = soineData.voiceName == nil ? "" : soineData.voiceName!
        cell.setCell(data: Data_list(category: image, scale: CGFloat(soineData.scale)))//\(String(soineData.id)):
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
//        cell.btn.isHidden = false
//        if soineData.voiceName == nil {
//            cell.btn.isHidden = true
//        }
//        else{
//            cell.btn.tag = (indexPath.section * 1000) + indexPath.row
//            cell.btn.addTarget(self, action: #selector(self.pushButton(_:)), for: .touchUpInside)
//        }
        return cell
    }
//    @objc private func pushButton(_ sender:UIButton)
//    {
//        let row = sender.tag % 1000
//        let section = sender.tag / 1000
//        selectedData = datas[section][row]
//        self.performSegue(withIdentifier: "toSoine", sender: nil)
//    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return sections.count
//    }
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        var rtn :[String] = []
//        for sec in sections {
////            rtn.append(String(sec.name?.prefix(3)))
//            rtn.append(String(sec.name!.prefix(3)))
//        }
//        return rtn
//    }
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let swipeCell = UITableViewRowAction(style: .default, title: NSLocalizedString("deleteBtn_title", comment: "")) { (action: UITableViewRowAction, index: IndexPath) in

            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            let viewContext = appDelegate.persistentContainer.viewContext
//            let request: NSFetchRequest<Account> = Account.fetchRequest()
//            let account: Account = self.accounts![indexPath.section][indexPath.row]

            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("confirm_title", comment: ""),
                message: String(format: NSLocalizedString("confirm_sentence_delete", comment: "")),
                preferredStyle: UIAlertController.Style.alert)
            let cancelAction: UIAlertAction = UIAlertAction(
                title: "No",
                style: UIAlertAction.Style.cancel,
                handler: {
                    (action: UIAlertAction!) -> Void in
                }
            )
            let defaultAction: UIAlertAction = UIAlertAction(
                title: "Yes",
                style: UIAlertAction.Style.default,
                handler: {
                    (action: UIAlertAction!) -> Void in
//                    let predicate = NSPredicate(format: "name = %@", account.name!)
//
//                    request.predicate = predicate
//                    do {
//                        let fetchResults = try viewContext.fetch(request)
//                        for result: AnyObject in fetchResults {
//                            let record = result as! NSManagedObject
//                            viewContext.delete(record)
//                        }
//                        try viewContext.save()
//                    } catch {
//                    }
//                    self.search(searchText: ViewController_list.searchText, category: ViewController_list.selectedCategory)
                    let request: NSFetchRequest<Background> = Background.fetchRequest()
                    request.predicate = NSPredicate(format: "id = %d", self.datas[indexPath.row].id)
                    do{
                        let fetchResults = try viewContext.fetch(request)
                        viewContext.delete(fetchResults[0])
                        try viewContext.save()
                    } catch let e as NSError{
                        print("error !!! : \(e)")
                    }
                    
                    let screenSizeWidth = UIScreen.main.bounds.width
                    let screenSizeHeight = UIScreen.main.bounds.height
                    self.view.makeToast("削除しました", point: CGPoint(x: screenSizeWidth/2, y: screenSizeHeight/2), title: nil, image: nil, completion: nil)
                    
                    self.refreshData()
                }
            )
            alert.addAction(cancelAction)
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        swipeCell.backgroundColor = .red
        return [swipeCell]
    }
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if Consts.DEBUG_FLG {
//            let id = sections[section].categoryId ?? 999
//            let name = sections[section].name ?? ""
//            
//            return "\(id):\(name)"
//        }
//        else{
//            return sections[section].name
//        }
//    }
}
extension ViewController_image:UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
//        selectedData = datas[indexPath.section][indexPath.row]
//        self.performSegue(withIdentifier: "toSetting", sender: nil)
        let request: NSFetchRequest<Background> = Background.fetchRequest()
//        var predicate:NSPredicate
        let p1selected = (Player.player1 == ViewController.selected)
        
//        predicate = NSPredicate(format: "id = " + (p1selected ? "1" : "2"))
//        predicate = NSPredicate(format: "id = %d", datas[indexPath.row].id)
//        predicate = NSPredicate(format: "player = " + (p1selected ? "1" : "2"))
//        request.predicate = predicate
        //change
        do {
            let fetchResults = try viewContext.fetch(request)
            if(fetchResults.count != 0){
//                let target:Background = fetchResults.first!
//                let pNum:Int32 = (p1selected ? 1 : 2)
//                let pNumReverse:Int32 = (p1selected ? 2 : 1)
//                if target.player == 0{//nil
//                    target.setValue(pNum, forKey: "player")
//                }
//                else if target.player == pNum{//me
//                }
//                else if target.player == pNumReverse{//you
//                    target.setValue(3, forKey: "player")
//                }
//                else if target.player == 3{//both
//                }
//                change=true
                for result: AnyObject in fetchResults {
                    let record = result as! Background
                    var newPlayer = record.player
                    let pNum:Int16 = (p1selected ? 1 : 2)
                    let pNumReverse:Int32 = (p1selected ? 2 : 1)
                    
                    if record.id == datas[indexPath.row].id {
                        if record.player == 0{//nil
                            newPlayer += pNum
                        }
                        else if record.player == pNum{//me
                        }
                        else if record.player == pNumReverse{//you
                            newPlayer = 3
                        }
                        else if record.player == 3{//both
                        }
                    }
                    else{
                        if record.player == 0{//nil
                        }
                        else if record.player == pNum{//me
                            newPlayer -= pNum
                        }
                        else if record.player == pNumReverse{//you
//                            newPlayer = 3
                        }
                        else if record.player == 3{//both
                            newPlayer -= pNum
                        }
                    }
                    print("id:\(record.id) newPlayer:\(newPlayer)")
                    record.setValue(newPlayer, forKey: "player")
                    //                    record.setValue(pickedImage.pngData(), forKey: "picture")
                    //                    record.setValue(scale, forKey: "scale")
                    
                    try viewContext.save()
                }
            }
        } catch {
        }
        delegate?.didPerformAction(from: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if tableView.isEditing {
            return .delete
        }
        return .none
    }
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let request: NSFetchRequest<Background> = Background.fetchRequest()
            request.predicate = NSPredicate(format: "id = %d", datas[indexPath.row].id)
            do{
                let fetchResults = try viewContext.fetch(request)
                viewContext.delete(fetchResults[0])
                try viewContext.save()
            } catch let e as NSError{
                print("error !!! : \(e)")
            }
            
            let screenSizeWidth = UIScreen.main.bounds.width
            let screenSizeHeight = UIScreen.main.bounds.height
            self.view.makeToast("削除しました", point: CGPoint(x: screenSizeWidth/2, y: screenSizeHeight/2), title: nil, image: nil, completion: nil)
            
            refreshData()
        }
    }
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        print("(\(sourceIndexPath.section),\(sourceIndexPath.row))->(\(destinationIndexPath.section),\(destinationIndexPath.row))")
//        //セクション間移動
//        if sourceIndexPath.section != destinationIndexPath.section {
//            refreshData()
//            return
//        }
//        let category = datas[sourceIndexPath.section][sourceIndexPath.row]
//        datas[sourceIndexPath.section].remove(at: sourceIndexPath.row)
//        datas[sourceIndexPath.section].insert(category, at: destinationIndexPath.row)
//        var data_tmp: [SoineData] = []
//        let next_id = Utilities.getNextId(viewContext: viewContext)
//        for (i,data) in datas[sourceIndexPath.section].enumerated() {
////            data.id = Int16(i) + next_id
//            data.id = Int32(datas[sourceIndexPath.section].count - 1 - i) + next_id
//            data_tmp.append(data)
//        }
//        datas[sourceIndexPath.section] = data_tmp
//        do{
//            try viewContext.save()
//        } catch let e as NSError{
//            print("error !!! : \(e)")
//        }
//        refreshData()
//    }

}
extension ViewController_image:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
//        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        let viewContext = appDelegate.persistentContainer.viewContext
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            let request: NSFetchRequest<Background> = Background.fetchRequest()
            var predicate:NSPredicate
//            // スクリーンの縦横サイズを取得
//            let playerViewWidth:CGFloat = playerView.frame.size.width
//            let playerViewHeight:CGFloat = playerView.frame.size.height
//
//            // 画像の縦横サイズを取得
//            let imgWidth:CGFloat = setImage.size.width
//            let imgHeight:CGFloat = setImage.size.height
            // スクリーンの縦横サイズを取得
            let scale:CGFloat
            if let someVC = AppManager.shared.viewController {
//                let playerViewWidth:CGFloat = p1bg.frame.size.width
                let playerViewWidth:CGFloat = someVC.p1bg.frame.width
                //            let playerViewHeight:CGFloat = player1view.frame.size.height
                
                // 画像の縦横サイズを取得
                let imgWidth:CGFloat = pickedImage.size.width
                //            let imgHeight:CGFloat = pickedImage.size.height
                
                scale = playerViewWidth / imgWidth
            } else {
                scale = 1.0
            }
//            var change = false
            
            //            //add
            //            if !change {
            let background = NSEntityDescription.entity(forEntityName: "Background", in: viewContext)
            let newRecord = NSManagedObject(entity: background!, insertInto: viewContext)
            //                newRecord.setValue((p1selected ? 1 : 2), forKey: "player")
            let next_id = Utilities.getNextId(viewContext: viewContext)
            print("nextId:\(next_id)")
            newRecord.setValue(next_id, forKey: "id")
            newRecord.setValue(pickedImage.pngData(), forKey: "picture")
            newRecord.setValue(scale, forKey: "scale")
            appDelegate.saveContext()
            //            }
            
            //背景設定
//            if Player.player1 == self.selected{
//                self.settingBackground(playerView: &p1bg, setImage: pickedImage,scale: scale)
//            }
//            else{
//                self.settingBackground(playerView: &p2bg, setImage: pickedImage,scale: scale)
//            }
            self.dismiss(animated: true, completion: nil)
            refreshData()
        }
    }
}
