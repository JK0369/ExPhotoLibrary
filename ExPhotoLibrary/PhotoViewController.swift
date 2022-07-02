//
//  PhotoViewController.swift
//  ExPhotoLibrary
//
//  Created by 김종권 on 2022/07/01.
//

import UIKit
import Photos

final class PhotoViewController: UIViewController {
  private enum Const {
    static let numberOfColumns = 3.0
    static let cellSpace = 1.0
    static let length = (UIScreen.main.bounds.size.width - cellSpace * (numberOfColumns - 1)) / numberOfColumns
    static let cellSize = CGSize(width: length, height: length)
    static let scale = UIScreen.main.scale
  }
  private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = Const.cellSpace
    layout.minimumInteritemSpacing = Const.cellSpace
    layout.itemSize = Const.cellSize
    return layout
  }()
  private lazy var collectionView: UICollectionView = {
    let view = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewFlowLayout)
    view.isScrollEnabled = true
    view.showsHorizontalScrollIndicator = false
    view.showsVerticalScrollIndicator = true
    view.contentInset = .zero
    view.backgroundColor = .clear
    view.clipsToBounds = true
    view.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.id)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  private let pickerView: UIPickerView = {
    let view = UIPickerView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private var albums: [AlbumInfo]
  private var currentAlbumIndex = 0 {
    didSet {
      PhotoService.shared.getPHAssets(album: self.albums[self.currentAlbumIndex].album) { [weak self] phAssets in
        self?.phAssets = phAssets
      }
    }
  }
  private var currentAlbum: PHFetchResult<PHAsset>? {
    guard self.currentAlbumIndex <= self.albums.count - 1 else { return nil }
    return self.albums[self.currentAlbumIndex].album
  }
  private var phAssets = [PHAsset]() {
    didSet {
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
    }
  }
  
  init(albums: [AlbumInfo]) {
    self.albums = albums
    
    super.init(nibName: nil, bundle: nil)
    
    self.view.backgroundColor = .white
    
    DispatchQueue.main.async {
      self.pickerView.reloadAllComponents() // must be used from main thread only
    }
    
    PhotoService.shared.delegate = self
    
    self.pickerView.dataSource = self
    self.pickerView.delegate = self
    
    self.collectionView.dataSource = self
    
    self.view.addSubview(self.collectionView)
    self.view.addSubview(self.pickerView)
    NSLayoutConstraint.activate([
      self.pickerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.pickerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.pickerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
      self.pickerView.heightAnchor.constraint(equalToConstant: 160)
    ])
    
    NSLayoutConstraint.activate([
      self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
      self.collectionView.bottomAnchor.constraint(equalTo: self.pickerView.topAnchor),
      self.collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
    ])
    
    PhotoService.shared.getPHAssets(album: self.albums[self.currentAlbumIndex].album) { [weak self] phAssets in
      self?.phAssets = phAssets
    }
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
}

extension PhotoViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    print("change!")
  }
}

extension PhotoViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  // dataSource
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    1
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    self.albums.count
  }
  
  // delegate
  func pickerView(
    _ pickerView: UIPickerView,
    viewForRow row: Int,
    forComponent component: Int,
    reusing view: UIView?
  ) -> UIView {
    let pickerLabel = UILabel()
    pickerLabel.font = .systemFont(ofSize: 24)
    let album = self.albums[row]
    pickerLabel.text = "\(album.name) (\(album.count))"
    pickerLabel.textAlignment = .center
    return pickerLabel
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    self.currentAlbumIndex = row
  }
}

extension PhotoViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    self.phAssets.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath) as? PhotoCell
    else { fatalError() }
    
    PhotoService.shared.fetchImage(
      asset: self.phAssets[indexPath.item],
      size: .init(width: Const.length * Const.scale, height: Const.length * Const.scale),
      contentMode: .aspectFit
    ) { [weak cell] image in
      DispatchQueue.main.async {
        cell?.prepare(image: image)
      }
    }
    
    return cell
  }
}
