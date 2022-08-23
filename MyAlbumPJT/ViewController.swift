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
        
        //flowlayout 적용
        let viewWidth: CGFloat = UIScreen.main.bounds.width / 2 //한 행 당 2개의 셀 배치
        let flowlayout = UICollectionViewFlowLayout()
        flowlayout.sectionInset = UIEdgeInsets(top: 0, left: 20 , bottom: 0, right: 20)
        //flowlayout.minimumLineSpacing = 5
        flowlayout.itemSize = CGSize(width: viewWidth - 40, height: viewWidth + 40)
        collectionView.collectionViewLayout = flowlayout
        
        requestCollection{
            granted in guard granted else { return }
            self.fetchAssets()
//            DispatchQueue.main.async {
//                print("큐에 스레드 돌아가는중")
//                self.collectionView.reloadData()
//            }
            OperationQueue.main.addOperation {
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
        self.albumCollections = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    }
}

//MARK: - collectionView cell 데이터 불러오기
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
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] //최신 날짜순으로 사진들 sort
        let fetchedAssets = PHAsset.fetchAssets(in: collection, options: fetchOptions)
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

//MARK: - ViewController에서 PhotoViewComtroller 화면 전환 및 데이터 전달
extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoViewController") as? PhotoViewController else { return }
        
        guard let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
            return }
        
        let item = selectedIndexPath.item
        print(selectedIndexPath)
        let assets: PHFetchResult<PHAsset>
        let title: String
        
        let album = albumCollections[item]
//        assets = PHAssetCollection.fetchAssetCollections(with: , subtype: .albumRegular, options: nil)
        assets = PHAsset.fetchAssets(in: album, options: nil)
        title = album.localizedTitle ?? ""
        
        photoViewController.photoCollection = assets
        photoViewController.albumTitle = title
        photoViewController.photoCollectionIdx = assets.count
        
        self.navigationController?.pushViewController(photoViewController, animated: true)
        
    }
    
}
