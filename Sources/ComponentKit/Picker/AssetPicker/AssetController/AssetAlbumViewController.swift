  //
  //  AssetAlbumViewController.swift
  //  Base
  //
  //  Created by William Lee on 2018/4/27.
  //  Copyright © 2018 William Lee. All rights reserved.
  //

import UIKit
import Photos
import ApplicationKit

class AssetAlbumViewController: UIViewController {
  
  typealias CompleteHandle = AssetPicker.CompleteHandle
  
    /// 所有资源
  private var allAssetsAlbum: AlbumItem?
    /// 智能相册
  private var smartAlbums: [AlbumItem] = []
    /// 用户自定义相册
  private var userAlbums: [AlbumItem] = []
    /// 最大选择数
  private var maxCount: Int = 0
  
    /// n内容
  private var content: Content = .image
  
  private var completedHandle: CompleteHandle?
  
  private let server = TableServer()
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    loadData()
    setupUI()
    updateUI()
    showDetail(with: allAssetsAlbum, animated: false)
    
      // 监测系统相册增加，即使用期间是否拍照
    PHPhotoLibrary.shared().register(self)
  }
  
  deinit {
    
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
}

  // MARK: - Public
extension AssetAlbumViewController {
  
  enum Content {
    case video
    case image
  }
  
  class func select(limit count: Int,
                    content: Content,
                    completion handle: @escaping CompleteHandle) {
    
    authorize() {
      
      let viewController = AssetAlbumViewController()
      
      viewController.title = "相册"
      viewController.maxCount = max(1, count)
      viewController.content = content
      viewController.completedHandle = handle
      
      let navigationController = UINavigationController(rootViewController: viewController)
      navigationController.modalPresentationStyle = .fullScreen
      Presenter.present(navigationController)
    }
    
  }
  
}

  // MARK: - Setup
private extension AssetAlbumViewController {
  
    /// 获取所有系统相册概览信息
  func loadData() {
    
    var phAssetMediaType: PHAssetMediaType
    var phAssetCollectionSubtype: PHAssetCollectionSubtype
    switch content {
    case .video:
      
      phAssetMediaType = .video
      phAssetCollectionSubtype = .smartAlbumVideos
      
    case .image:
      
      phAssetMediaType = .image
      phAssetCollectionSubtype = .smartAlbumGeneric
    }
    
      // 时间降序
    let options = PHFetchOptions()
    //options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    
    let allAssetsResult = PHAsset.fetchAssets(with: phAssetMediaType, options: options)
    allAssetsAlbum = AlbumItem(allAssetsResult, "全部")
    
      // 智能相册
    let smartAlbumResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: phAssetCollectionSubtype, options: options)
    
    for index in 0 ..< smartAlbumResult.count {
      
      let collection = smartAlbumResult.object(at: index)
      let assets = PHAsset.fetchAssets(in: collection, options: options)
      let item = AlbumItem(assets, collection.localizedTitle)
      guard item.count > 0 else { continue }
      smartAlbums.append(item)
    }
    
      // 用户自定义相册
    let userCollections = PHCollectionList.fetchTopLevelUserCollections(with: options)
    for index in 0 ..< userCollections.count {
      
      guard let collection = userCollections.object(at: index) as? PHAssetCollection else { continue }
      let assets = PHAsset.fetchAssets(in: collection, options: options)
      let item = AlbumItem(assets, collection.localizedTitle)
      guard item.count > 0 else { continue }
      userAlbums.append(item)
    }
  }
  
  func setupUI() {
    
    navigationView.setup(title: title)
    navigationView.addRight(title: "取消", target: self, action: #selector(clickCancel))
    
    server.tableView.rowHeight = 80
    view.addSubview(server.tableView)
    server.tableView.layout.add { (make) in
      make.top().equal(navigationView).bottom()
      make.leading().trailing().bottom().equal(view)
    }
  }
  
  func updateUI() {
    
    let reuseCell = ReuseItem(Cell.self)
    var groups: [TableSectionGroup] = []
    
    var allGroup = TableSectionGroup()
    allGroup.header.height = 5
    allGroup.footer.height = 5
    allGroup.items.append(TableCellItem(reuseCell, data: allAssetsAlbum, accessoryType: .disclosureIndicator, selected: { [weak self] in
      
      self?.showDetail(with: self?.allAssetsAlbum, animated: true)
    }))
    groups.append(allGroup)
    
    var smartGroup = TableSectionGroup(header: TableSectionItem(height: 5), footer: TableSectionItem(height: 5))
    smartAlbums.forEach({ [weak self] (album) in
      
      smartGroup.items.append(TableCellItem(reuseCell, data: album, accessoryType: .disclosureIndicator, selected: {
        
        self?.showDetail(with: album, animated: true)
      }))
    })
    groups.append(smartGroup)
    
    var userGroup = TableSectionGroup(header: TableSectionItem(height: 5), footer: TableSectionItem(height: 5))
    userAlbums.forEach({ [weak self] (album) in
      
      userGroup.items.append(TableCellItem(reuseCell, data: album, accessoryType: .disclosureIndicator, selected: {
        
        self?.showDetail(with: album, animated: true)
      }))
    })
    groups.append(userGroup)
    
    server.update(groups)
  }
  
}

  // MARK: - PHPhotoLibraryChangeObserver
extension AssetAlbumViewController: PHPhotoLibraryChangeObserver {
  
    /// 系统相册改变
  public func photoLibraryDidChange(_ changeInstance: PHChange) {
    
  }
  
}

  // MARK: - Action
private extension AssetAlbumViewController {
  
  @objc func clickCancel(_ sender: Any) {
    
    dismiss(animated: true) {
      self.completedHandle?([], [])
    }
  }
  
}

  // MARK: - Utility
private extension AssetAlbumViewController {
  
  func showDetail(with album: AlbumItem?, animated: Bool) {
    
    guard let album = album else { return }
    
    let assetViewController = AssetGridViewController()
    assetViewController.setup(limited: maxCount, album: album, complete: completedHandle)
    navigationController?.pushViewController(assetViewController, animated: animated)
  }
  
  class func authorize(completion handler: @escaping () -> Void) {
    
    let status = PHPhotoLibrary.authorizationStatus()
    if status == .authorized {
      
      DispatchQueue.main.async {
        
        handler()
      }
      return
    }
    
    PHPhotoLibrary.requestAuthorization({ (status) in
      
      if #available(iOS 14, *) {
        
        if status == .limited {
          
        }
      }
      
      if status == .denied {
        
        return
      }
      
      if status == .restricted {
        
        return
      }
      
      if status == .authorized {
        
        DispatchQueue.main.async {
          
          handler()
        }
        return
      }
      
    })
  }
  
}

  // MARK: - Cell
private extension AssetAlbumViewController {
  
  class Cell: UITableViewCell, TableCellItemUpdatable {
    
    private let thumbView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
      super.init(style: style, reuseIdentifier: reuseIdentifier)
      
      setupUI()
    }
    
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      
      updateUI()
    }
    
    private func setupUI() {
      
      accessoryType = .disclosureIndicator
      selectionStyle = .none
      
      contentView.addSubview(thumbView)
      thumbView.clipsToBounds = true
      thumbView.contentMode = .scaleAspectFill
      
      titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
      contentView.addSubview(titleLabel)
    }
    
    private func updateUI() {
      
      let width = bounds.height - 16
      thumbView.frame = CGRect(x: 8, y: 8, width: width, height: width)
      titleLabel.frame = CGRect(x: thumbView.frame.maxX + 5, y: 4, width: 200, height: width)
    }
    
    func update(with item: TableCellItem) {
      
      guard let item = item.data as? AlbumItem else { return }
      
      titleLabel.text = "\(item.title)（\(item.count)）"
      
      let defaultSize = UIScreen.main.bounds.size
      guard let thumbAsset = item.assets.first else { return }
      
      PHCachingImageManager.default()
        .requestImage(for: thumbAsset,
                         targetSize: defaultSize,
                         contentMode: .aspectFill,
                         options: nil,
                         resultHandler: { (image, _) in
          
          self.thumbView.image = image
        })
    }
    
  }
  
}
