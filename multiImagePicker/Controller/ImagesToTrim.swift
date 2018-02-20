//
//  ImagesToTrim.swift
//  CampAppPreview
//
//  Created by c.uraga on 2017/09/08.
//  Copyright © 2017年 c.uraga. All rights reserved.
//

import UIKit

protocol FixHorizontalScrollView: class{
    var getCurrentPage: (()->CGFloat)! { get set }
}
extension FixHorizontalScrollView {
    func fixScrollView(_ size : CGSize,_  scrollView: UIScrollView){
        
        let pageWidth = size.width
        let currentPage:CGFloat = getCurrentPage()
        let point = CGPoint(x: currentPage * pageWidth, y: scrollView.contentOffset.y)
        scrollView.setContentOffset(point, animated: false)
    }
}

extension UICollectionView {
    var name: String {
        return "collectionView"
    }
}
extension ImagesToTrim: UICollectionViewDelegateFlowLayout {
    //TODO: Check iOS 11 devices
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == previewImages {
            let height = min(collectionView.bounds.height, collectionView.bounds.width)
            if collectionView.numberOfItems(inSection: 0) == 1 {
                return CGSize.init(width: view.frame.width, height: height)
            }
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            let divider =  1
            let totalSpace = layout.sectionInset.left  + layout.sectionInset.right + (layout.minimumInteritemSpacing * CGFloat(divider - 1))
            
            let width =  (self.view.frame.width * 0.90 - totalSpace) / CGFloat(divider)
            return CGSize(width: width , height: height  )
        }
        else {
            let viewWidth: CGFloat = collectionView.bounds.width
            let desiredItemWidth:CGFloat = 25
            let columns: CGFloat = max( min(floor(viewWidth / desiredItemWidth), 5), 4)
            let padding: CGFloat = 1
            let itemWidth = min(floor((viewWidth - (columns - 1) * padding) / columns), view.bounds.height * 0.15)
            let itemSize = CGSize(width: itemWidth, height: itemWidth)
            return itemSize
        }
        
    }
    
    
    
}

class ImagesToTrim: UIViewController, FixHorizontalScrollView, UIGestureRecognizerDelegate, UICollectionViewDataSource,  UICollectionViewDelegate, PassImageBack, UIScrollViewDelegate {
    var images = [UIImage]()
    var hori: HorizontalScrollView!
    var getCurrentPage: (()-> (CGFloat))!
    var timer: Timer!
    var previousLocation: CGPoint = CGPoint.zero
    var previewImages: UICollectionView!
    private var collectionViewCarousel: UICollectionView!
    
    private var selectedIndex: IndexPath = IndexPath.init(row: 0, section: 0)
    private var selectedIndexPath: IndexPath?
    private var selectedIndexForCarousel: IndexPath!
    private var allowFreeMovement:Bool = false
    private var garbageView: UIImageView!
    private var selectedCell: ImagesCollectionViewCell?
    private var wasSmallDueToDeletion: Bool = false
    private var intersectedWithGarbage: Bool = false
    private var minusMe: CGFloat = 0
    
    private var previousIndex: IndexPath!
    private var moved: Bool = false
    private var heightForGarbageView: NSLayoutConstraint!
    weak var delegate: MultiPhotoDelegate!
    convenience init(delegate: MultiPhotoDelegate) {
        self.init()
        self.delegate = delegate
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        moved = false
    }
    override func loadView() {
        super.loadView()
        //setup garbage view
        garbageView = UIImageView.init(image: UIImage.init(named: "transcan"))
        garbageView.contentMode = .scaleAspectFit
        
        
        //creation of the carousel that will place in the bottom
        let carouselLayout = UICollectionViewFlowLayout()
        carouselLayout.itemSize = CGSize(width: 25, height: 25)
        carouselLayout.minimumLineSpacing = 0.0
        carouselLayout.minimumInteritemSpacing = 0
        carouselLayout.scrollDirection = .horizontal
        collectionViewCarousel = UICollectionView(frame: CGRect.zero, collectionViewLayout: carouselLayout)
        view.addSubview(collectionViewCarousel)
        collectionViewCarousel.backgroundColor = UIColor.clear
        collectionViewCarousel.activateConstraintLeftAndRightOfParent(view, constant: 12)
        collectionViewCarousel.setHeightPorpotionTo(view: view, 0, multiplier: 0.15)
        collectionViewCarousel.bottomToParent(given: view, multiplier: 1.0, constant: 8)
        collectionViewCarousel.showsHorizontalScrollIndicator = false
        collectionViewCarousel.delegate = self
        collectionViewCarousel.dataSource = self
        collectionViewCarousel.register(UserPhotoCell.self, forCellWithReuseIdentifier: "carouselCell")
        
        
        //instagram like layout
        let layout: UICollectionViewFlowLayout = ShowCellsAfterBefore()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.scrollDirection = .horizontal
        previewImages = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        previewImages.register(ImagesCollectionViewCell.self, forCellWithReuseIdentifier: previewImages.name)
        previewImages.addSubview(garbageView)
        view.addSubview(previewImages)
        
        garbageView.activateConstraintLeftAndRightOfParent(view, constant: 0)
        garbageView.activateConstraintAutomatically(topLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0, toParent: false)
        heightForGarbageView = garbageView.setHeight(to: 50)
        garbageViewShow(false)
        previewImages.backgroundColor = UIColor.black.withAlphaComponent(0.76)
        previewImages.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
        previewImages.dataSource = self
        previewImages.isPagingEnabled = false
        previewImages.delegate = self
        previewImages.layer.borderColor = UIColor.gray.cgColor
        previewImages.layer.borderWidth = 0
        previewImages.activateConstraintLeftAndRightOfParent(view, constant: 0)
        previewImages.activateConstraintAutomatically(view, attribute: .top, multiplier: 1.0, constant: 0, toParent: true)
        previewImages.activateConstraintAutomatically(collectionViewCarousel, attribute: .bottom, multiplier: 1.0, constant: 0, toParent: false)
        previewImages.activateConstraintAutomatically(nil, attribute: .height, multiplier: 1.0, constant:100, toParent: true)
        let longPressure   = UILongPressGestureRecognizer(target: self, action: #selector(handlePressedGesture(_:)))
        longPressure.minimumPressDuration = 0.0
        longPressure.delegate = self
        previewImages.addGestureRecognizer(longPressure)
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "決定", style: .done, target: self, action: #selector(sendImagesToDelegate))
        
    }
    @objc private func sendImagesToDelegate(){
        delegate.multiImagePickerController(image: images)
        dismiss(animated: true, completion: nil)
    }
    private func garbageViewShow(_ bool: Bool) {
        garbageView.isHidden = !bool
        garbageView.alpha = bool ? 1.0 : 0.0
        heightForGarbageView.constant = bool ? 50 : 0
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateItemSize()
        updateItemSizeForCaro()
        collectionViewCarousel.selectItem(at: IndexPath.init(row: 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        collectionView(collectionViewCarousel, didSelectItemAt: IndexPath.init(row: 0, section: 0))
    }
    func updateItemSize(){
        let viewWidth: CGFloat = view.bounds.size.width
        let columns: CGFloat = 1
        let padding: CGFloat = 1
        let itemWidth = floor((viewWidth - (columns - 1) * padding) / columns) * 0.75
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = previewImages.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumLineSpacing = padding
            layout.minimumInteritemSpacing = padding
        }
    }
    private func updateItemSizeForCaro(){
        collectionViewCarousel.layoutIfNeeded()
        print(collectionViewCarousel.frame)
        let viewWidth: CGFloat = collectionViewCarousel.bounds.width
        let desiredItemWidth:CGFloat = 25
        let columns: CGFloat = max( min(floor(viewWidth / desiredItemWidth), 5), 4)
        let padding: CGFloat = 1
        let itemWidth = min(floor((viewWidth - (columns - 1) * padding) / columns), view.bounds.height * 0.15)
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        if let layout = collectionViewCarousel.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumLineSpacing = padding
            layout.minimumInteritemSpacing = padding
        }
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let removedImage = images.remove(at: sourceIndexPath.item)
        images.insert(removedImage, at: destinationIndexPath.item)
        previewImages.scrollToItem(at: destinationIndexPath, at: .centeredHorizontally, animated: true)
        collectionViewCarousel.moveItem(at: sourceIndexPath, to: destinationIndexPath)
        UIView.animate(withDuration: 0.4, animations: {
            self.collectionViewCarousel.selectItem(at: destinationIndexPath, animated: false, scrollPosition: .init(rawValue: 0))
        }, completion: { (_) in
            self.collectionView(self.collectionViewCarousel, didSelectItemAt: destinationIndexPath)
        })
    }
    @objc func handlePressedGesture(_ sender : UILongPressGestureRecognizer){
        switch sender.state {
        case .began:
            moved = false
            guard let selectedIndex = previewImages.indexPathForItem(at: sender.location(in: previewImages)) else {
                return
            }
            let cell = previewImages.cellForItem(at: selectedIndex) as! ImagesCollectionViewCell
            selectedCell = cell
            minusMe = (cell.frame.height * 0.30)
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                cell.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            }, completion: nil)
            if #available(iOS 10.0, *) {
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: {
                    _ in
                    self.allowFreeMoveOfImage(nil)
                })
            } else {
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(allowFreeMoveOfImage(_:)), userInfo: nil, repeats: false)
            }
            self.selectedIndex = selectedIndex
        case .changed:
            if allowFreeMovement {
                if timer != nil {
                    timer.invalidate()
                    timer = nil
                }
                if doesIntersect(){
                    if !wasSmallDueToDeletion {
                        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                            self.selectedCell?.imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            self.minusMe = (self.selectedCell?.imageView.frame.height ?? 2) * 3/4
                        }, completion: nil)
                    }
                    wasSmallDueToDeletion = true
                }
                else {
                    let selectedCellFrame = selectedCell?.frame ?? CGRect.zero
                    let cellFrame = previewImages.convert(selectedCellFrame, to: view)
                    minusMe = cellFrame.height * 0.30
                    if wasSmallDueToDeletion && cellFrame.origin.y > 50.cgFloat {
                        if wasSmallDueToDeletion {
                            scaleBackToNormal()
                        }
                        wasSmallDueToDeletion = false
                    }
                }
            }
            previewImages.updateInteractiveMovementTargetPosition(sender.location(in: previewImages))
        case .ended:
            if timer != nil {
                timer.invalidate()
                timer  = nil
                if allowFreeMovement {
                    print("GoToCropController")
                }
            }
            let shouldWeCallCropper = !allowFreeMovement
            wasSmallDueToDeletion = false
            allowFreeMovement = false
            scaleBackToNormal()
            
            if doesIntersect(){
                previewImages.endInteractiveMovement()
                images.remove(at: self.selectedIndex.item)
                previewImages.deleteItems(at: [self.selectedIndex])
                collectionViewCarousel.deleteItems(at: [self.selectedIndex])
                let numberOfItems = previewImages.numberOfItems(inSection: 0)
                var scrollTo = self.selectedIndex.item
                
                if numberOfItems == 0 {
                    self.navigationController?.popViewController(animated: true)
                    return
                }
                else if numberOfItems == 1 {
                    UIView.animate(withDuration: 0.1, animations: { [weak self] in
                        self?.previewImages.collectionViewLayout.invalidateLayout()
                    })
                }
                if scrollTo >= numberOfItems {
                    scrollTo -= 1
                }
                garbageViewShow(false)
                let indexPath = IndexPath.init(row: scrollTo,  section: 0)
                previewImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                selectedIndexForCarousel = indexPath
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionViewCarousel.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                }, completion: { (_) in
                    self.collectionView(self.collectionViewCarousel, didSelectItemAt: indexPath)
                })
            }
            else {
                previewImages.endInteractiveMovement()
                garbageViewShow(false)
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                    
                    //            self.selectedCell?.imageView.transform = CGAffineTransform.identity
                    self.selectedCell?.transform = CGAffineTransform.identity
                }, completion: {
                    (_) -> Void in
                    if !self.moved && shouldWeCallCropper  {
                        self.sendImageToCropper()
                    }
                })
                
            }
            
        default:
            if timer != nil {
                timer.invalidate()
                timer  = nil
            }
            allowFreeMovement = false
            scaleBackToNormal()
            previewImages.cancelInteractiveMovement()
        }
        
    }
    private func sendImageToCropper(){
        guard let cell = selectedCell else {
            return
        }
        guard let image = cell.imageView.image else {
            return
        }
        selectedIndexPath = previewImages.indexPath(for: cell)
        let cropper = FreeHandCropper()
        cropper.image = image
        cropper.delegate = self
        present(cropper, animated: true, completion: nil)
    }
    private func doesIntersect()->Bool {
        let selectedCellFrame = selectedCell?.frame ?? CGRect.zero
        let cellFrame = previewImages.convert(selectedCellFrame, to: view)
        let gbFrame = previewImages.convert(garbageView.frame, to: view)
        let halfOfGarbage = CGRect(x: gbFrame.origin.x, y: gbFrame.origin.y - minusMe, width: gbFrame.width * 3, height: gbFrame.height )
        intersectedWithGarbage = cellFrame.intersects(halfOfGarbage)
        return cellFrame.intersects(halfOfGarbage)
    }
    private func scaleBackToNormal(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            //            self.selectedCell?.imageView.transform = CGAffineTransform.identity
            self.selectedCell?.imageView.transform = CGAffineTransform.identity
        }, completion: nil)
    }
    
    func returnImageToNormal(_ gesture: UILongPressGestureRecognizer){
        guard let imageView = gesture.view else { return}
        UIView.animate(withDuration: 0.3, animations: {
            imageView.transform = CGAffineTransform.identity
        })
        
    }
    @objc func allowFreeMoveOfImage(_ timer: Any?){
        previewImages.beginInteractiveMovementForItem(at: selectedIndex)
        allowFreeMovement = true
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            let cell = self.previewImages.cellForItem(at: self.selectedIndex) as! ImagesCollectionViewCell
            cell.transform = CGAffineTransform.identity
            //            self.garbageView.layoutIfNeeded()
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                self.garbageViewShow(true)
                self.garbageView.layoutIfNeeded()
            })
        })
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] (_)-> Void in
            guard let gearPreview = self?.hori else {
                return
            }
            self?.fixScrollView(size, gearPreview)
            }, completion: nil)
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !allowFreeMovement
    }
    
    func useImageCropped(image: UIImage) {
        guard let selected = selectedIndexPath else {
            return
        }
        guard let cell = previewImages.cellForItem(at: selected) as? ImagesCollectionViewCell else {
            return
        }
        images[selected.item] = image
        cell.imageView.image = image
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == previewImages {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView.name, for: indexPath) as! ImagesCollectionViewCell
            cell.setupViews(image: images[indexPath.row])
            if collectionView == collectionViewCarousel {
                
                cell.imageView.alpha = 1.5
            }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath) as! UserPhotoCell
            cell.addCoverLayerIfNotCreated()
            cell.isPreviewImages = true
            cell.imageView.image = images[indexPath.row]
            cell.coverLayer?.opacity = 0.7
            if selectedIndexForCarousel != nil && selectedIndexForCarousel == indexPath {
                UIView.animate(withDuration: 0.4, animations: {
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .init(rawValue: 0))
                }, completion: { (_) in
                    self.collectionView(self.collectionViewCarousel, didSelectItemAt: indexPath)
                })
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == collectionViewCarousel {
            selectedIndexForCarousel = indexPath
            for indexPathTemp in collectionView.indexPathsForVisibleItems {
                collectionView.deselectItem(at: indexPathTemp, animated: false)
                self.collectionView(collectionView, didDeselectItemAt: indexPathTemp)
            }
            if collectionView.indexPathsForVisibleItems.contains(indexPath) {
                //TODO:Check if we should
                let cell = collectionView.cellForItem(at: indexPath) as! UserPhotoCell
                cell.isPreviewImages = true
                cell.coverLayer?.opacity = 0.0
                previewImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == collectionViewCarousel {
            if collectionView.indexPathsForVisibleItems.contains(indexPath) {
                let cell = collectionView.cellForItem(at: indexPath) as! UserPhotoCell
                cell.coverLayer?.opacity = 0.7
            }
        }
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let visiblePoint = getVisibleIndexPath()
        if let visibleIndexPath: IndexPath = previewImages.indexPathForItem(at: visiblePoint){
            previousIndex = visibleIndexPath
        }
        moved = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == previewImages {
            
            let visiblePoint = getVisibleIndexPath()
            
            if let visibleIndexPath: IndexPath = previewImages.indexPathForItem(at: visiblePoint){
                selectedIndexForCarousel = visibleIndexPath
                collectionViewCarousel.deselectItem(at: previousIndex, animated: false)
                collectionView(collectionViewCarousel, didDeselectItemAt: previousIndex)
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.collectionViewCarousel.selectItem(at: visibleIndexPath, animated: false, scrollPosition: .centeredHorizontally)
                }, completion: { (_) in
                    self.collectionView(self.collectionViewCarousel, didSelectItemAt: visibleIndexPath)
                })
            }
        }
    }
    
    private func getVisibleIndexPath() -> CGPoint{
        let visibleRect =
            CGRect(
                origin: previewImages.contentOffset,
                size: previewImages.bounds.size
        )
        return CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    }
    
}

