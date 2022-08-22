//
//  ViewController.swift
//  MyAlbumPJT
//
//  Created by SSG on 2022/08/22.
//

import UIKit
import Photos

/*
 Photos 프레임워크
 - PHAsset: 사진 라이브러리에 있는 이미지, 비디오와 같은 하나의 애셋을 의미
 - PHAssetCollection: PHAsset의 컬렉션
 - PHCachingImageManager: 요청한 크기에 맞게 이미지를 로드하여 캐싱까지 수행
 - PHFetchResult: 앨범 하나
 */

class ViewController: UIViewController {
    
    //MARK: - Properties
    let cellIdentifier: String = "albumCollectionCell"
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    private var albumCollections = PHFetchResult<PHAssetCollection>()// PHFetchReseult => 배열과 비슷

    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestCollection{
            granted in guard granted else { return }
            self.fetchAssets()
            DispatchQueue.main.async {
                print("큐에 스레드 돌아가는중")
                self.collectionView.reloadData()
            }
        }
    }
    
    func requestCollection(completionHandler: @escaping(Bool) -> Void) {
        
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            completionHandler(true)
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in completionHandler(status == .authorized )}
    }
    
    func fetchAssets(){
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] //최신 날짜순으로 사진들 sort
        //smartAlbum 타입이라서 그런지 옵션으로 최신 날짜순의 정렬을 하면 에러 발생함 options를 nil 로 주어야함.
        self.albumCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.albumCollections.count <= 0 {
            print("앨범이 제대로 로드되지 않음")
            return 0
        } else {
            return self.albumCollections.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AlbumCollectionViewCell else {
            fatalError("Unable to dequeue")
        }
        var coverAsset: PHAsset?
        let collection = albumCollections[indexPath.item]
        let fetchedAssets = PHAsset.fetchAssets(in: collection, options: nil)
        coverAsset = fetchedAssets.firstObject
        
        cell.albumName.text = collection.localizedTitle
        cell.photoCount.text = String(fetchedAssets.count)
        cell.albumCoverImage.image = UIImage(named: "emptyPhoto")
       
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            cell.albumCoverImage.image = image
        }
        
        guard let resultAsset = coverAsset else {
            return cell
        }
        imageManager.requestImage(for: resultAsset, targetSize: cell.bounds.size, contentMode: .aspectFill, options: nil, resultHandler: resultHandler)
        
        return cell
    }
    
    
   
}

