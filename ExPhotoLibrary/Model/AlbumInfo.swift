//
//  AlbumInfo.swift
//  ExPhotoLibrary
//
//  Created by 김종권 on 2022/07/01.
//

import Photos
import UIKit

struct AlbumInfo: Identifiable {
  let id: String?
  let name: String
  let count: Int
  let album: PHFetchResult<PHAsset>
}
