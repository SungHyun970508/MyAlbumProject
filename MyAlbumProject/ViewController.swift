//
//  ViewController.swift
//  MyAlbumProject
//
//  Created by SSG on 2022/08/01.
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
    let cellIdentifier: String = "firstCollectionCell" //collectionView 프로퍼티
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    var allPhotos: PHFetchResult<PHAsset>? // 모든 사진들을 보여주기 위한 에셋 컬렉션
    var albumList: PHFetchResult<PHAssetCollection>! //PHAssetCollection : 특별한 순간, 사용자정의 앨범, 특별한 순단들 연도와 같은 에셋 컬렉션이 포함된 그룹 나타냄
   
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - PhotoLibrary func
    func requestCollection(){
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)] //최신 날짜순으로 사진들 sort
        
        self.albumList = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular , options: nil)//Photos 앱은 자동으로 스마트 앨범 생성 (앨범은 에셋의 그룹)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let photoAurhorizationState = PHPhotoLibrary.authorizationStatus() // authorizationStatus 는 열거형
        
        switch photoAurhorizationState {
        case .notDetermined:
            print("아직 응답하지 않음")
            PHPhotoLibrary.requestAuthorization({ (status) in
                switch status {
                case .authorized:
                    print("사용자가 허용함")
                    self.requestCollection()
                    OperationQueue.main.addOperation {//이후에 왜 OperationQueue사용하는지 생각해보기. ->비동기 방식으로 한번에 많은 양의 사진들을 불러오는 연산을 수행하기 위해서 main 큐가 아니라 여러 큐를 스레드로 돌리는 방법
                        self.collectionView.reloadData()
                    }
                case .denied:
                    print("사용자가 불허함")
                default: break
                }
            })
        case .restricted:
            print("접근 제한")
        case .denied:
            print("접근 불허")
        case .authorized:
            print("접근 허가")
            //self.requestCollection()
        case .limited:
            print("제한된 접근")
        @unknown default:
            break;
        
        }
    }
}

//MARK: - CollectionViewDataSource : UPdatingCell
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("스마트앨범 count \(albumList.count)")
        return self.albumList.count //섹션에 표시할 아이템의 개수 반환
    }
    //Updating Cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

//        let cell: FirstCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! FirstCollectionViewCell -> 강제로 언래핑 하는 방식이라 아주 좋지않음!!!!
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? FirstCollectionViewCell else {
            fatalError("Unable to dequeue AlbumCollectionViewCell")
        }
        var coverAsset: PHAsset?//앨범 대표 이미지로 나타나질 에셋
        
        let collection = albumList[indexPath.item]
        let fetchAsset = PHAsset.fetchAssets(in: collection, options: nil)//궁금점 : 테이블뷰에서는 indexPath를 row로 접근했었는데 컬렉션뷰에서는 item으로 접근하는지????????
        coverAsset = fetchAsset.firstObject
        
        
        guard let asset = coverAsset else {
            print("coverAsset is nill \(albumList[indexPath.item].localizedTitle)")
            
            cell.mainImageView.isHighlighted = true
            cell.mainNameLabel.text = albumList[indexPath.item].localizedTitle
            cell.numberOfPhoto.text = String(fetchAsset.count)
            return cell
        }
        
        cell.mainImageView.isHighlighted = false
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            cell.mainImageView.image = image
        }
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 160, height: 160), contentMode: .aspectFill, options: nil, resultHandler: resultHandler ) // imageManager : 에셋으로부터 이미지를 불러오고(fetch) 추후에 빠르게 복구하기 위해 결과를 캐싱하는 작업을 함
        
        cell.mainNameLabel.text = albumList[indexPath.item].localizedTitle
        cell.numberOfPhoto.text = String(fetchAsset.count)
        
        return cell
    }
    
//    //화면전환 오류 발생!!
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("화면전환시 데이터 전송")
//        guard let nextViewContoller: PhotoCollecionsViewController = segue.destination as? PhotoCollecionsViewController else {
//            return
//        }
//        //선택된 셀의 indexPath 가져오기
//        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
//            return
//        }
//
//        let item = indexPath.item//아이템 생성
//
//        let assets: PHFetchResult<PHAsset>
//        let title: String
//
//        assets = PHAsset.fetchAssets(in: albumList[item], options: nil)
//        title = albumList[item].localizedTitle ?? ""
//
//        nextViewContoller.asset = assets
//        nextViewContoller.navigationTitle = title
//
//    }
    
}

//MARK:
extension ViewController: UICollectionViewDelegate {

    //셀이 선택되었을 때 뷰 전환 및 데이터 전송 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("화면전환시 데이터 전송")
          performSegue(withIdentifier: "goingToView2", sender: nil)
//        let item = indexPath.item//아이템 생성
//
//        let assets: PHFetchResult<PHAsset>
//        let title: String
//
//        assets = PHAsset.fetchAssets(in: albumList[item], options: nil)
//        title = albumList[item].localizedTitle ?? ""
//
//        nextViewContoller.asset = assets
//        nextViewContoller.navigationTitle = title

    }
    //화면전환 오류 발생!!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("화면전환시 데이터 전송")
        guard let nextViewContoller: PhotoCollecionsViewController = segue.destination as? PhotoCollecionsViewController else {
            return
        }
        //선택된 셀의 indexPath 가져오기
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }
        
        let item = indexPath.item//아이템 생성
        
        let assets: PHFetchResult<PHAsset>
        let title: String
        
        assets = PHAsset.fetchAssets(in: albumList[item], options: nil)
        title = albumList[item].localizedTitle ?? ""
        
        nextViewContoller.asset = assets
        nextViewContoller.navigationTitle = title
        
    }
}
