//
//  PhotoCollecionsViewController.swift
//  MyAlbumProject
//
//  Created by SSG on 2022/08/03.
//

import UIKit
import Photos

class PhotoCollecionsViewController: UIViewController {

    var asset: PHFetchResult<PHAsset>!// 첫번째 화면에서 받아올 에셋 프로퍼티
    var navigationTitle: String!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var photoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.title = navigationTitle
        var photoasset: PHAsset
        
        let imageManager = PHCachingImageManager()
        
        //photoasset = PHAsset.fetchAssets(in: asset, options: nil)
        //imageManager.requestImage(for: photoasset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil, resultHandler: { image, _ in self.photoView.image = image })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
