//
//  MultipleImagePicker.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit
import Photos
private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
protocol MultiPhotoDelegate: class {
    func multiImagePickerController(image: [UIImage])
}
class MultipleImagePicker: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private let BORDER_COLOR = #colorLiteral(red: 0.8588235294, green: 0.8588235294, blue: 0.8745098039, alpha: 1)
    
    var fetchPhotoResult: PHFetchResult<PHAsset>!
    //the number of allowed selection to upload
    var maxNumberOfSelection: Int = 4
    //apple supplied cache manager
    fileprivate let imageManager = PHCachingImageManager()
    //size of the thumnail size. Defaults to 100 by 100
    fileprivate var thumbnailSize: CGSize!
    fileprivate var previousPreheatRect = CGRect.zero
    //A queue that is ordered via FIFO. HOWEVER, it allows to deletion from any index! This is not a 100% correct queue(on purpose, of course). Actually, you could have just used a regular array...
    fileprivate var queue: [HoldIndexPathAndImage] =  [HoldIndexPathAndImage] ()
    
    /// saves the collectionView content insets
    fileprivate var previousContentInset: UIEdgeInsets = UIEdgeInsets.zero
    
    /// number of items in queue. If it's set, we update the label with the number of items selected.
    /// We also adjust the collectionView's insets
    fileprivate var numberOfItemsInQueue: Int = 0 {
        didSet {
            numberOfPhotosUpload.numberOfMessage = "\(numberOfItemsInQueue)"
            if numberOfItemsInQueue > 0 {
                if self.navBarHeight.constant == getNavbarHeight() {
                    return
                }
                
                //adjust the content insets
                numberOfPhotosUpload.isHidden = false
                self.navBarHeight.constant = getNavbarHeight()
                photosCollectionView.contentInset  = UIEdgeInsets.init(top: previousContentInset.top, left: 0, bottom: getNavbarHeight(), right: 0)
                photosCollectionView.setContentOffset(CGPoint.init(x: photosCollectionView.contentOffset.x, y: photosCollectionView.contentOffset.y + 50 ), animated: true)
                // add a nice little spring animation
                let springRotation = CASpringAnimation(keyPath: "position.y")
                springRotation.fromValue = view.frame.height
                springRotation.toValue = view.frame.height - getNavbarHeight() / 2
                springRotation.duration = springRotation.settlingDuration
                springRotation.damping = 8
                UIView.animate(withDuration: 0.4, animations: {
                    self.bottomNav.layer.add(springRotation, forKey: "rotationAnimation")
                    self.photosCollectionView.layoutIfNeeded()
                    self.bottomNav.layoutIfNeeded()
                })
            }
            else {
                photosCollectionView.contentInset  = previousContentInset
                numberOfPhotosUpload.isHidden = true
                self.bottomNav.layer.removeAllAnimations()
                self.navBarHeight.constant = 0
                UIView.animate(withDuration: 0.3, animations: {
                    self.photosCollectionView.layoutIfNeeded()
                    self.bottomNav.layoutIfNeeded()
                })
            }
        }
    }
    //collectionView that will hold all the user's images
    fileprivate var photosCollectionView: UICollectionView!
    //just shows the images the user already selected
    fileprivate var previewImages: UICollectionView!
    //the layoutconstraint that adjusts the nav bar height
    fileprivate var navBarHeight: NSLayoutConstraint!
    //the bottom navigation bar
    fileprivate var bottomNav: UIToolbar!
    //a button that will tell the delegate that we have images
    var numberOfPhotosUpload: SendButtonWithNumberOfImages!
    
    fileprivate var previewImage: UIImageView!
    //delegate that passes all the images that was selected
    weak var delegate: MultiPhotoDelegate!
    private var firstCall: Bool = true
    //remove the observer of the photolibrary
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    convenience init(delegate: MultiPhotoDelegate, maxPhotos: Int = 4) {
        self.init()
        self.delegate = delegate
        self.maxNumberOfSelection = maxPhotos
    }
    
    
    override func loadView() {
        super.loadView()
        //creation  of UICollectionView
        createCollectionView()
        //creation of the bottom toolbar
        createBottomToolbar()
        
        createPreviewImageInToolbar()
        //set constraints
        setupConstraints()
        self.navigationItem.title = "カメラロール"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "キャンセル", style: .done, target: self, action: #selector(dismissController))
        self.navigationItem.rightBarButtonItem?.tintColor = GetColorForCampOrIishii.mainColor
        //register the observer in case the user adds/delete images
        PHPhotoLibrary.shared().register(self)
        if fetchPhotoResult == nil {
            let allPhotosOptions = PHFetchOptions()
            //sort by creation date
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            //fetch by the descriptior above
            fetchPhotoResult = PHAsset.fetchAssets(with: allPhotosOptions)
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    //======== creation of views========
    func createCollectionView(){
        previewImage = UIImageView()
        //        previewImage.
        previewImage.contentMode = .scaleAspectFill
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize.zero
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0
        photosCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        photosCollectionView.backgroundColor = UIColor.white
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        view.addSubview(previewImage)
        view.addSubview(photosCollectionView)
        
        photosCollectionView?.allowsMultipleSelection = true
        photosCollectionView?.register(UserPhotoCell.self, forCellWithReuseIdentifier: "UserPhotoCell")
    }
    /// Creates a tool bar and adds it to the collectionview
    func createBottomToolbar(){
        bottomNav = UIToolbar()
        bottomNav.barStyle = .default
        bottomNav.layer.borderColor = BORDER_COLOR.cgColor
        bottomNav.layer.borderWidth = 0.5
        bottomNav.tintColor = GetColorForCampOrIishii.mainColor
        //create a button to upload to the user
        numberOfPhotosUpload = SendButtonWithNumberOfImages(hasNewMessage: false)
        numberOfPhotosUpload.isUserInteractionEnabled = true
        numberOfPhotosUpload.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        numberOfPhotosUpload.isHidden = true
        numberOfPhotosUpload.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnImagesBackToCaller)))
        let uploadPhotos = UIBarButtonItem.init(customView: numberOfPhotosUpload)
        //we need a flex space to move the upload button to the right
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bottomNav.setItems([flexSpace, uploadPhotos], animated: false)
        view.addSubview(bottomNav)
    }
    func createPreviewImageInToolbar(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 25, height: 25)
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        previewImages = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        previewImages.backgroundColor = UIColor.clear
        previewImages.delegate = self
        previewImages.dataSource = self
        bottomNav.addSubview(previewImages)
        previewImages.activateConstraintAutomatically(bottomNav, attribute: .left, multiplier: 1.0, constant: 0, toParent: true)
        previewImages.activateConstraintAutomatically(bottomNav, attribute: .bottom, multiplier: 1.0, constant: 0, toParent: true)
        previewImages.activateConstraintAutomatically(bottomNav, attribute: .top, multiplier: 1.0, constant: 0, toParent: true)
        previewImages.activateConstraintAutomatically(bottomNav, attribute: .right, multiplier: 1.0, constant: 125, toParent: true)
        previewImages.register(UserPhotoCell.self, forCellWithReuseIdentifier: "UserPhotoCell")
    }
    
    /// Setup constraints for the viewss
    func setupConstraints(){
        previewImage.activateConstraintAutomatically(view, attribute: .height, multiplier: 0.40, constant: 0, toParent: true)
        previewImage.activateConstraintLeftAndRightOfParent(view, constant: 0)
        previewImage.activateConstraintAutomatically(topLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0, toParent: false)
        photosCollectionView.activateConstraintAutomatically(previewImage, attribute: .top, multiplier: 1.0, constant: 0, toParent: false)
        photosCollectionView.activateConstraintLeftAndRightOfParent(view, constant: 0)
        photosCollectionView.activateConstraintAutomatically(view, attribute: .bottom, multiplier: 1.0, constant: 0, toParent: true)
        
        bottomNav.activateConstraintAutomatically(view, attribute: .bottom, multiplier: 1.0, constant: 0, toParent: true)
        bottomNav.activateConstraintLeftAndRightOfParent(view, constant: 0)
        navBarHeight = bottomNav.setHeight(to: 0)
    }
    //========end of creation of views========
    
    /// Checks if we have access to the photo album. If we don't we should dismiss this controller
    ///
    /// - Returns: Bool, String, Status. Bool is to indicate if we're good to go.
    ///  String for error
    ///  The status of the photo album access
    func checkPhotoAutorizationStatus()-> (Bool, String, PHAuthorizationStatus){
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            return (true, "", .authorized)
        case .notDetermined:
            return (false, "", .notDetermined)
        default:
            return (false, "We can't access your photos and will not proceeed further", .denied)
        }
    }
    /// Checks if we have access to the user's photo libray. Crashes the app if we don't
    func checkStatus(){
        let (status, errorMsg, enumStatus) = checkPhotoAutorizationStatus()
        if !status {
            if enumStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized {
                        return
                    }
                    else {
                        self.showAlert("error", errorMsg, completion: { (_) in
                            self.dismissController()
                        })
                    }
                })
            }
            else {
                showAlert("error", errorMsg, completion: { (_) in
                    self.dismissController()
                })
            }
        }
    }
    
    /// calls the the delegate of the images passed
    @objc func returnImagesBackToCaller(){
        let imagesToTrim = ImagesToTrim.init(delegate: delegate)
        imagesToTrim.images = queue.map{
            holder in
            return holder.image!
        }
        navigationController?.pushViewController(imagesToTrim, animated: true)
    }
    @objc func dismissController(){
        dismiss(animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkStatus()
        let _ = view
        updateItemSize()
        updatItemSizeForPreview()
        //TODO: This might not look nice
        
        //        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
        //            if self.fetchPhotoResult.count != 0  {
        //                let indexPathToGoTo: IndexPath = IndexPath.init(row: self.fetchPhotoResult.count - 1, section: 0)
        //                self.photosCollectionView?.scrollToItem(at: indexPathToGoTo, at: .bottom, animated: false)
        //            }
        //        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
        checkStatus()
        previousContentInset = photosCollectionView.contentInset
    }
    private func getNavbarHeight()-> CGFloat{
        return view.frame.height * 0.10
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    private func updateItemSize(){
        let viewWidth: CGFloat = view.bounds.size.width
        let desiredItemWidth:CGFloat = 100
        let columns: CGFloat = max( min(floor(viewWidth / desiredItemWidth), 6), 4)
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumLineSpacing = padding
            layout.minimumInteritemSpacing = padding
        }
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    private func updatItemSizeForPreview(){
        let viewWidth: CGFloat = view.bounds.size.width
        let desiredItemWidth:CGFloat = getNavbarHeight()
        let columns: CGFloat = max( min(floor(viewWidth / desiredItemWidth), 5), 4)
        let padding: CGFloat = 1
        let itemWidth = min(floor((viewWidth - (columns - 1) * padding) / columns), getNavbarHeight())
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = previewImages.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumLineSpacing = padding
            layout.minimumInteritemSpacing = padding
        }
    }
    
    
    
    /// Refer to apple's code to further understand this
    private func updateCachedAssets(){
        guard isViewLoaded && view.window != nil else { return }
        
        let visibleRect = CGRect(origin: photosCollectionView!.contentOffset, size: photosCollectionView!.bounds.size)
        //preheat will have double the size of the visible rect
        let preheat = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        //calculate the change of the distance between the previous heat
        let delta = abs(preheat.midY - previousPreheatRect.midY)
        //if the difference is big enough, then we should update the assets
        guard delta > view.bounds.height / 3 else { return }
        //retreive the images we need to start catching and the rects we don't need to catch no
        let (addedRects, removedRects) = differencesBetweenRects(old: previousPreheatRect, new: preheat)
        
        let addedAssets = addedRects.flatMap { rect in photosCollectionView!.indexPathsForElements(in: rect)}.map { (indexPath)  in
            fetchPhotoResult.object(at: indexPath.item)
        }
        let removedAssets = removedRects.flatMap { rect in photosCollectionView!.indexPathsForElements(in: rect)}.map { (indexPath)  in
            fetchPhotoResult.object(at: indexPath.item)
        }
        imageManager.startCachingImages(for: addedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        previousPreheatRect = preheat
    }
    
    private func differencesBetweenRects(old: CGRect, new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            var removed = [CGRect]()
            //Did the new rect move more downwards?
            if new.maxY > old.maxY {
                //now we're gotta cover from the old's y to the new rect's y.
                added += [CGRect.init(x: new.origin.x, y: old.maxY, width: new.width, height: new.maxY - old.maxY)]
            }
            //if we're moving upwards?
            if old.minY > new.minY {
                //the new y until the oldy's y origin
                added += [CGRect.init(x: new.origin.x, y: new.minY, width: new.width, height: old.minY - new.minY)]
            }
            if new.maxY < old.maxY {
                removed += [CGRect.init(x: new.origin.x, y: new.maxY, width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect.init(x: new.origin.x, y: old.minY, width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        }
        else {
            return ([new], [old])
        }
    }
    
    
}
extension MultipleImagePicker: PHPhotoLibraryChangeObserver {
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    /// very simple to understand. get all photos that were changed(inserted, moved, added, etc)
    ///
    /// - Parameter changeInstance:
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchPhotoResult) else {
            return
        }
        DispatchQueue.main.async {
            self.fetchPhotoResult = changes.fetchResultAfterChanges
            if changes.hasIncrementalChanges {
                guard let collectionView = self.photosCollectionView else { fatalError("something bad happened")}
                collectionView.performBatchUpdates({
                    if let removed = changes.removedIndexes, !removed.isEmpty {
                        collectionView.deleteItems(at: removed.map { return IndexPath.init(row: $0, section: 0)})
                    }
                    if let inserted = changes.insertedIndexes, !inserted.isEmpty {
                        collectionView.insertItems(at: inserted.map { return IndexPath.init(row: $0, section: 0)})
                    }
                    if let changed = changes.changedIndexes, !changed.isEmpty {
                        collectionView.reloadItems(at: changed.map{ return IndexPath.init(row: $0, section: 0)})
                    }
                    changes.enumerateMoves({ (from, to) in
                        collectionView.moveItem(at: IndexPath.init(row: from, section: 0), to: IndexPath.init(row: to, section: 0))
                    })
                })
            }
            else {
                self.photosCollectionView?.reloadData()
            }
            self.resetCachedAssets()
        }
    }
}

extension MultipleImagePicker {
    //following is the collectinView Handles
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.photosCollectionView {
            return fetchPhotoResult.count
        }
        return queue.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.photosCollectionView {
            let asset = fetchPhotoResult.object(at: indexPath.row)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UserPhotoCell.self), for: indexPath) as? UserPhotoCell else {
                fatalError()
            }
            cell.representedIdent = asset.localIdentifier
            let holdImage = HoldIndexPathAndImage.init(indexPath: indexPath)
            if let indexOf = queue.index(where: { (holder) -> Bool in
                return holder == holdImage
            }){
                cell.number = "\(indexOf  + 1 )"
                
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init(rawValue: 0))
                cell.isSelected = true
            }
            
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
                if cell.representedIdent == asset.localIdentifier && image != nil {
                    cell.thumbnailImage = image!
                    
                }
            }
            if self.firstCall && indexPath.row == 0 {
                imageManager.requestImage(for: asset, targetSize: CGSize.init(width: view.frame.width, height: view.frame.height * 0.4), contentMode: .aspectFill, options: nil) { (image, _) in
                    if let img = image {self.previewImage.image = img}
                }
                self.firstCall = false
                
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: UserPhotoCell.self), for: indexPath) as? UserPhotoCell else {
                fatalError()
            }
            cell.isPreviewImages = true
            cell.showNumberLabel()
            let holdImage = queue[indexPath.item]
            if let indexOf = queue.index(of: holdImage) {
                cell.number = "\(indexOf  + 1 )"
                //                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init(rawValue: 0))
                cell.thumbnailImage = holdImage.image!
            }
            return cell
        }
    }
    
    func getImageFor(row: Int){
        let asset = fetchPhotoResult.object(at: row)
        imageManager.requestImage(for: asset, targetSize: CGSize.init(width: view.frame.width, height: view.frame.height * 0.4), contentMode: .aspectFill, options: nil) { (image, _) in
            if let img = image {self.previewImage.image = img}
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.photosCollectionView == collectionView {
            if !checkIfExceedsLimitation() {
                let cell = collectionView.cellForItem(at: indexPath) as! UserPhotoCell
                let holdImage = HoldIndexPathAndImage.init(indexPath: indexPath, cell.imageView.image)
                getImageFor(row: indexPath.row)
                queue.append(holdImage)
                cell.number =  "\(queue.count)"
                numberOfItemsInQueue += 1
                collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                let indexPathAdded = IndexPath.init(row: queue.count - 1, section: 0)
                previewImages.insertItems(at: [indexPathAdded])
                previewImages.scrollToItem(at: indexPathAdded, at: .centeredHorizontally, animated: true)
            }
            else {
                collectionView.deselectItem(at: indexPath, animated: false)
                showAlert("Exceed limitation", "You are allowed to only pick \(maxNumberOfSelection) photos", completion: nil)
            }
        }
        else {
            let holder = queue[indexPath.item]
            
            photosCollectionView.deselectItem(at: holder.indexPath, animated: false)
            self.collectionView(photosCollectionView, didDeselectItemAt: holder.indexPath)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if self.photosCollectionView == collectionView {
            
            if let cell = collectionView.cellForItem(at: indexPath) as? UserPhotoCell {
                cell.reset()
            }
            //not visible
            let holdImage = HoldIndexPathAndImage.init(indexPath: indexPath)
            let index = queue.index(of: holdImage)!
            var reloadItems = [IndexPath]()
            var reloadPreview = [IndexPath]()
            var start = true
            for (i , item) in (index..<queue.count).enumerated() {
                if start {
                    start = false
                    continue
                }
                reloadItems.append(queue[item].indexPath)
                reloadPreview.append(IndexPath.init(row: i, section: 0))
            }
            queue.remove(at: index)
            let removeIndexAt = IndexPath(row: index, section: 0)
            previewImages.deleteItems(at: [removeIndexAt])
            updateCellsForPreview(reloadItems : reloadPreview )
            updateCellsFor(index: reloadItems)
            numberOfItemsInQueue -= 1
        }
        
    }
    private func testingPurpose()-> [IndexPath]{
        return queue.map{ return $0.indexPath}
    }
    private func updateCellsFor(index: [IndexPath]){
        photosCollectionView?.reloadItems(at: index)
    }
    private func updateCellsForPreview(reloadItems : [IndexPath]){
        let count = Int(queue.count)
        let reloadItems = (0..<count).map {
            return IndexPath.init(row: $0, section: 0)
        }
        previewImages?.reloadItems(at: reloadItems)
    }
    
    private func checkIfExceedsLimitation()-> Bool{
        if maxNumberOfSelection != -1 {
            if queue.count >= maxNumberOfSelection {
                return true
            }
        }
        return false
    }
}

extension MultipleImagePicker: ShowGenericAlert {
}
