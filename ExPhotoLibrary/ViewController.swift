//
//  ViewController.swift
//  ExPhotoLibrary
//
//  Created by 김종권 on 2022/07/01.
//

import UIKit
import Photos

class ViewController: UIViewController {
  private let albumButton: UIButton = {
    let button = UIButton()
    button.setTitle("album", for: .normal)
    button.setTitleColor(.systemBlue, for: .normal)
    button.setTitleColor(.blue, for: .highlighted)
    button.addTarget(self, action: #selector(requestAlbum), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.addSubview(self.albumButton)
    
    NSLayoutConstraint.activate([
      self.albumButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
      self.albumButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
    ])
  }
  
  @objc private func requestAlbum() {
    self.requestAlbumAuthorization { isAuthorized in
      if isAuthorized {
        PhotoService.shared.getAlbums(mediaType: .image, completion: { [weak self] albums in
          DispatchQueue.main.async {
            let photoViewController = PhotoViewController(albums: albums)
            photoViewController.modalPresentationStyle = .fullScreen
            self?.present(photoViewController, animated: true)
          }
        })
      } else {
        self.showAlertGoToSetting(
          title: "현재 앨범 사용에 대한 접근 권한이 없습니다.",
          message: "설정 > {앱 이름} 탭에서 접근을 활성화 할 수 있습니다."
        )
      }
    }
  }
  
  func requestAlbumAuthorization(completion: @escaping (Bool) -> Void) {
    if #available(iOS 14.0, *) {
      PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
        completion([.authorized, .limited].contains(where: { $0 == status }))
      }
    } else {
      PHPhotoLibrary.requestAuthorization { status in
        completion(status == .authorized)
      }
    }
  }
  
  func showAlertGoToSetting(title: String, message: String) {
    let alertController = UIAlertController(
      title: title,
      message: message,
      preferredStyle: .alert
    )
    let cancelAlert = UIAlertAction(
      title: "취소",
      style: .cancel
    ) { _ in
      alertController.dismiss(animated: true, completion: nil)
    }
    let goToSettingAlert = UIAlertAction(
      title: "설정으로 이동하기",
      style: .default) { _ in
        guard
          let settingURL = URL(string: UIApplication.openSettingsURLString),
          UIApplication.shared.canOpenURL(settingURL)
        else { return }
        UIApplication.shared.open(settingURL, options: [:])
      }
    [cancelAlert, goToSettingAlert]
      .forEach(alertController.addAction(_:))
    DispatchQueue.main.async {
      self.present(alertController, animated: true) // must be used from main thread only
    }
  }
}


