//
//  AlbumItem.swift
//  ComponentKit
//
//  Created by William Lee on 2018/5/3.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Photos

struct AlbumItem {
 
  let title: String
  let count: Int
  let assets: [PHAsset]
  let result: PHFetchResult<PHAsset>
  
  init(_ assets: PHFetchResult<PHAsset>, _ title: String?) {
    
    self.result = assets
    var items: [PHAsset] = []
    for index in 0 ..< assets.count {
      
      items.append(assets.object(at: index))
    }
    self.assets = items
    self.title = title ?? ""
    self.count = result.count
  }
  
}
