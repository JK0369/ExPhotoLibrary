//
//  PhotoCell.swift
//  ExPhotoLibrary
//
//  Created by 김종권 on 2022/07/01.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
  static let id = "PhotoCell"
  
  // MARK: UI
  private let imageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFill
    return view
  }()
  
  // MARK: Initializer
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.masksToBounds = true // 주의: 이값을 안주면 이미지가 셀의 다른 영역을 침범하는 영향을 주는것
    self.contentView.addSubview(self.imageView)
    
    NSLayoutConstraint.activate([
      self.imageView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor),
      self.imageView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor),
      self.imageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
      self.imageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
    ])
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    
    self.prepare(image: nil)
  }
  
  func prepare(image: UIImage?) {
    self.imageView.image = image
  }
}
