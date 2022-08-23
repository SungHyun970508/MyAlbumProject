//
//  PhotoViewController.swift
//  MyAlbumPJT
//
//  Created by SSG on 2022/08/23.
//

import UIKit
import Photos

class PhotoViewController: UIViewController {
    
    var albumTitle: String?
    var photoCollection: PHFetchResult<PHAsset>?
    var photoCollectionIdx: Int?
    let cellIdentifier: String = "photoCollectionCell"
    let imageManager: PHCachingImageManager = PHCachingImageManager()
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = albumTitle
        
        // Do any additional setup after loading the view.
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

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoCollectionIdx ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("Unable to dequeue")
        }
        
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            cell.photoImageView.image = image
        }
        
        var photoAsset: PHAsset?
        
        photoAsset = photoCollection?.object(at: indexPath.item)
        
        guard let resultAsset = photoAsset else {
            print("제대로 안넘어옴")
            return cell
        }
        
        imageManager.requestImage(for: resultAsset, targetSize: cell.bounds.size, contentMode: .aspectFill, options: nil, resultHandler: resultHandler)
        
        return cell
    }
    
    
    
}
