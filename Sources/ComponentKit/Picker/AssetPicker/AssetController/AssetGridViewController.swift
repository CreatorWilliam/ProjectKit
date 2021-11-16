//
//  ImagePickerGridViewController.swift
//  ComponentKit
//
//  Created by William Lee on 2018/4/27.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Photos
import UIKit

class AssetGridViewController: UIViewController {
  
  typealias CompleteHandle = AssetPicker.CompleteHandle
  
  private let flowLayout = UICollectionViewFlowLayout()
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
  private let previewView = AssetPickerPreviewView()
  
  // 展示选择数量
  private let bottomView = UIView()
  private let countLabel = UILabel()
  private let completionButton = UIButton(type: .custom)
  
  // 选择的最大数量
  private var maxCount: Int = 1
  // 选择回调
  private var completedHandle: CompleteHandle?
  
  private var album: AlbumItem!
  
  private var selectedAssets: [PHAsset] = []
  
  private let imageManager = PHCachingImageManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // 监测数据源
//    if album == nil {
//
//      let allPhotoOptions = PHFetchOptions()
//      allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//      let allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
//      album = AlbumItem(allPhotos, "全部图片")
//    }
    
    setupUI()
    updateUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 更新
    updateCachedAssets()
  }
  
}

// MARK: - Public
extension AssetGridViewController {
  
  func setup(limited count: Int, album item: AlbumItem, complete handle: CompleteHandle?) {
    
    maxCount = count
    album = item
    title = item.title
    completedHandle = handle
  }
  
}

// MARK: PHAsset Caching
private extension AssetGridViewController {
  
  /// 重置图片缓存
  func resetCachedAssets() {
    
    imageManager.stopCachingImagesForAllAssets()
  }
  
  /// 更新图片缓存设置
  func updateCachedAssets() {
    
    // 视图可访问时才更新
    guard isViewLoaded && view.window != nil else { return }
    
    // 更新图片缓存
    guard let album = album else { return }
    let assets = collectionView.visibleCells.compactMap({ collectionView.indexPath(for: $0) }).map({ album.assets[$0.item] })
    imageManager.startCachingImages(for: assets, targetSize: CGSize(width: 150, height: 150), contentMode: .aspectFill, options: nil)
  }
  
}

// MARK: - UIScrollViewDelegate
extension AssetGridViewController: UIScrollViewDelegate {
  
  //  func scrollViewDidScroll(_ scrollView: UIScrollView) {
  //
  //    self.updateCachedAssets()
  //  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    
    updateCachedAssets()
  }
  
}

// MARK: - UICollectionViewDelegate
extension AssetGridViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    showLargeView(album.assets[indexPath.item])
    collectionView.deselectItem(at: indexPath, animated: true)
  }

}

// MARK: - UICollectionViewDataSource
extension AssetGridViewController: UICollectionViewDataSource {

  func numberOfSections(in collectionView: UICollectionView) -> Int {

    return 1
  }

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

    return album.assets.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageAssetCollectionViewCell", for: indexPath)

    if let cell = cell as? ImageAssetCollectionViewCell {
      
      cell.isShowChoice = (maxCount > 1)
      cell.delegate = self
      cell.imageManager = imageManager
      if let index = selectedAssets.firstIndex(where: { $0.localIdentifier == album.assets[indexPath.item].localIdentifier }) {
        
        cell.update(with: "\(index + 1)")
        
      } else {
        
        cell.update(with: nil)
      }
      cell.update(with: album.assets[indexPath.item])
    }

    return cell
  }

}

// MARK: - ImageAssetCollectionViewCellDelegate
extension AssetGridViewController: ImageAssetCollectionViewCellDelegate {
  
  func select(_ asset: PHAsset) {
    
    // 单选
    if maxCount < 2 {
      
      selectedAssets.append(asset)
      finishSelection()
      return
    }
    
    // 多选
    defer {
      
      collectionView.reloadData()
    }
    
    guard selectedAssets.count < maxCount else {
      
      showAlert()
      return
    }
    
    selectedAssets.append(asset)
    updateCount()
  }
  
  func deselect(_ asset: PHAsset) {
    
    defer {
      
      collectionView.reloadData()
    }
    
    for (index, item) in selectedAssets.enumerated() {
      
      guard item.localIdentifier == asset.localIdentifier else { continue }
      selectedAssets.remove(at: index)
      updateCount()
      return
    }
  }
  
}

// MARK: - Setup
private extension AssetGridViewController {
  
  /// 展示
  func setupUI() {
    
    navigationView.setup(title: album?.title)
    navigationView.addRight(title: "取消", target: self, action: #selector(clickCancel))
    navigationView.showBack()
    view.backgroundColor = .white
    
    let spaceing: CGFloat = 3
    let count: CGFloat = 3
    let width = (UIScreen.main.bounds.width - (count + 1) * spaceing) / count
    
    flowLayout.itemSize = CGSize(width: width, height: width)
    flowLayout.minimumLineSpacing = spaceing
    flowLayout.minimumInteritemSpacing = spaceing
    
    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.contentInset = UIEdgeInsets(top: spaceing, left: spaceing, bottom: spaceing, right: spaceing)
    collectionView.allowsMultipleSelection = (maxCount > 1)
    collectionView.backgroundColor = .white
    collectionView.register(ImageAssetCollectionViewCell.self, forCellWithReuseIdentifier: "ImageAssetCollectionViewCell")
    view.addSubview(collectionView)
    collectionView.layout.add { (make) in
      
      make.top().equal(navigationView).bottom()
      make.leading().trailing().equal(view)
    }
    
    view.addSubview(bottomView)
    bottomView.layout.add { (make) in
      
      if maxCount < 2 {
        
        make.leading().trailing().equal(view)
        make.bottom(50).equal(view).safeBottom()
        
      } else {
        
        make.leading().trailing().equal(view)
        make.bottom().equal(view).safeBottom()
      }
      make.top().equal(collectionView).bottom()
      make.height(50)
    }
    
    countLabel.font = UIFont.systemFont(ofSize: 14)
    bottomView.addSubview(countLabel)
    countLabel.layout.add { (make) in
      
      make.leading(15).centerY().equal(bottomView)
    }
    
    completionButton.setTitle("完成", for: .normal)
    completionButton.setTitleColor(UIColor.black, for: .normal)
    completionButton.layer.borderColor = UIColor.black.cgColor
    completionButton.layer.borderWidth = 0.5
    completionButton.layer.cornerRadius = 5
    completionButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    completionButton.addTarget(self, action: #selector(clickCompletion), for: .touchUpInside)
    bottomView.addSubview(completionButton)
    completionButton.layout.add { (make) in
      
      make.centerY().trailing(-15).height(-20).equal(bottomView)
      make.width(60)
    }
    
    previewView.alpha = 0
    view.addSubview(previewView)
    previewView.layout.add { (make) in
      
      make.top().equal(navigationView).bottom()
      make.leading().trailing().bottom().equal(view)
    }
  }
  
  func updateUI() {
    
    collectionView.reloadData()
  }
  
}

// MARK: - Action
private extension AssetGridViewController {
  
  /// 照片选择结束
  @objc func clickCompletion(_ sender: Any) {
    
    finishSelection()
  }
  
  /// 取消照片选择
  @objc func clickCancel(_ sender: Any) {
    
    dismiss(animated: true) {
      self.completedHandle?([], [])
    }
  }
  
}

// MARK: - Utility
private extension AssetGridViewController {
  
  func showAlert() {
    
    let alertViewController = UIAlertController(title: "提示", message: "最多只能选择 \(maxCount) 张图片", preferredStyle: .alert)
    alertViewController.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
    
    DispatchQueue.main.async {
      
      self.present(alertViewController, animated: true)
    }
  }
  
  func showLargeView(_ item: PHAsset) {
    
    imageManager.requestImage(for: item,
                                 targetSize: PHImageManagerMaximumSize,
                                 contentMode: .aspectFill,
                                 options: nil,
                                 resultHandler: { [weak self] (image, _) in
      
      self?.previewView.update(with: image)
      
      UIView.animate(withDuration: 0.5, animations: {
        
        self?.previewView.alpha = 1.0
        
      }, completion: { (_) in
        
      })
    })
    
  }
  
  private func updateCount() {
    
    let count = selectedAssets.count
    countLabel.text = "已选择：\(count) 张"
  }
  
  func finishSelection() {
    
    var images: [UIImage] = []
    var assets: [PHAsset] = []
    selectedAssets.forEach({ (item) in
      
      assets.append(item)
      imageManager.requestImage(for: item,
                                   targetSize: PHImageManagerMaximumSize,
                                   contentMode: .aspectFill,
                                   options: nil,
                                   resultHandler: { (image, _) in
        
        guard let image = image else { return }
        images.append(image)
      })
    })
    
    dismiss(animated: true, completion: {
      
      self.completedHandle?(assets, images)
    })
  }
  
}

// MARK: - ImageAssetCollectionViewCellDelegate
private protocol ImageAssetCollectionViewCellDelegate: AnyObject {
  
  func select(_ asset: PHAsset)
  
  func deselect(_ asset: PHAsset)
}

private class ImageAssetCollectionViewCell: UICollectionViewCell {
  
  weak var delegate: ImageAssetCollectionViewCellDelegate?
  var isShowChoice: Bool = true
  var imageManager: PHCachingImageManager?
  var image: UIImage? {
    set { imageView.image = newValue }
    get { return imageView.image }
  }
  
  private let imageView = UIImageView()
  private let choiceButton = UIButton(type: .custom)
  
  private var asset: PHAsset?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - Public
extension ImageAssetCollectionViewCell {
  
  func update(with item: PHAsset) {
    
    asset = item
    imageManager?.requestImage(for: item,
                                       targetSize: imageView.bounds.size,
                                       contentMode: .aspectFill,
                                       options: nil,
                                       resultHandler: { [weak self] (image, _) in
      
      guard self?.asset?.localIdentifier == item.localIdentifier else { return }
      self?.image = image
    })
  }
  
  func update(with title: String?) {
    
    choiceButton.setTitle(title, for: .normal)
  }
  
}

// MARK: - Setup
private extension ImageAssetCollectionViewCell {
  
  func setupUI() {
    
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    imageView.backgroundColor = UIColor(0xeeeeee)
    contentView.addSubview(imageView)
    imageView.layout.add { (make) in
      make.top().bottom().leading().trailing().equal(contentView)
    }
    
    choiceButton.setTitleColor(UIColor.black, for: .normal)
    choiceButton.layer.borderColor = UIColor.gray.cgColor
    choiceButton.layer.borderWidth = 1
    choiceButton.layer.cornerRadius = 15
    choiceButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0.7).cgColor
    choiceButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
    choiceButton.addTarget(self, action: #selector(clickChoice(_:)), for: .touchUpInside)
    contentView.addSubview(choiceButton)
    choiceButton.layout.add { (make) in
      make.top(5).trailing(-5).equal(contentView)
      make.width(30).height(30)
    }
  }
  
}

// MARK: - Action
private extension ImageAssetCollectionViewCell {
  
  @objc func clickChoice(_ sender: UIButton) {
    
    guard let item = asset else { return }
    if choiceButton.title(for: .normal)?.count ?? 0 > 0 {
      
      delegate?.deselect(item)
      
    } else {
      
      delegate?.select(item)
    }
    
  }
  
}
