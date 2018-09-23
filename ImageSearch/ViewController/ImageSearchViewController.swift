//
//  ImageSearchViewController.swift
//  ImageSearch
//
//  Created by Rohit Jain on 22/09/18.
//  Copyright © 2018 Rohit Jain. All rights reserved.
//

import UIKit
import SDWebImage

class ImageSearchViewController: UIViewController {

    var imageSearchController :UISearchController!
    var cellWidth: CGFloat!
    var currentMenuItem: CGFloat = 2
    var imageListModel:[ImageListDataModel] = []
    var currentSearchText: String?
    
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var menuButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        currentMenuItem = 2
        menuButton.setImage(UIImage(named: "three_column_icon"), for: .normal)
        getCellWidth(columnCount: currentMenuItem)
        self.navigationController?.delegate = self
        noResultView.isHidden = false
        imagesCollectionView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureSearchController()
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        self.title = "Image Search"
        self.navigationController?.navigationBar.barTintColor = UIColor(string: "#f5f5f5")
    }
    
    func configureSearchController() {
        if imageSearchController != nil
        {
            return
        }
        
        
        // Initialize and perform a minimum configuration to the search controller.
        imageSearchController = UISearchController(searchResultsController: nil)
        imageSearchController.searchResultsUpdater = self
        imageSearchController.dimsBackgroundDuringPresentation = false
        imageSearchController.searchBar.placeholder = "Search"
        imageSearchController.searchBar.delegate = self
        imageSearchController.searchBar.sizeToFit()
        imageSearchController.searchBar.searchBarStyle = .minimal
        imageSearchController.searchBar.backgroundColor = UIColor(string: "#f5f5f5")
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = imageSearchController
        } 
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        switch currentMenuItem {
        case 2:
            currentMenuItem = 3
            menuButton.setImage(UIImage(named: "four_column_icon"), for: .normal)
        case 3:
            currentMenuItem = 4
            menuButton.setImage(UIImage(named: "two_column_icon"), for: .normal)
        case 4:
            currentMenuItem = 2
            menuButton.setImage(UIImage(named: "three_column_icon"), for: .normal)
        default:
            currentMenuItem = 2
            menuButton.setImage(UIImage(named: "three_column_icon"), for: .normal)
        }
        getCellWidth(columnCount: currentMenuItem)
    }
    
    func getCellWidth(columnCount: CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let spacing: CGFloat = CGFloat(5 * (columnCount - 1))
        self.cellWidth = ((screenWidth - spacing - 10) / columnCount)
        self.imagesCollectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ImageSearchViewController : UINavigationControllerDelegate,UISearchResultsUpdating, UISearchBarDelegate{
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        noResultView.isHidden = true
        imagesCollectionView.isHidden = false
        if let searchText = searchBar.text{
            self.currentSearchText = searchText
            self.imageListModel = []
            let imageList = DatabaseManager.sharedInstance.getDataFromRealm(searchItem: searchText)
            if (Reachability.isConnectedToNetwork() && imageList.count <= 0){
                self.searchImageWithLoader(text: searchText, index: 1)
            }else{
                self.imageListModel.append(contentsOf: imageList)
                self.imagesCollectionView.reloadData()
            }
        }
    }
    
    func searchImageWithLoader(text: String, index: Int)  {
        let sv = UIViewController.displaySpinner(onView: self.view)
        ImageNetworkWrapper.sharedInstance.getImageList(text: text, startIndex: index, success: { (imageList) in
            UIViewController.removeSpinner(spinner: sv)
            self.imageListModel.append(contentsOf: imageList)
            self.imagesCollectionView.reloadData()
        }, failure: { (errorData) in
            UIViewController.removeSpinner(spinner: sv)
        })
    }
    
    func searchImageWithOutLoader(text: String, index: Int)  {
        ImageNetworkWrapper.sharedInstance.getImageList(text: text, startIndex: index, success: { (imageList) in
            self.imageListModel.append(contentsOf: imageList)
            self.imagesCollectionView.reloadData()
        }, failure: { (errorData) in
            
        })
    }
}

extension ImageSearchViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageListModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if #available(iOS 11.0, *)
        {
            return CGSize(width: screenWidth, height: 0)
        }
        else
        {
            return CGSize(width: screenWidth, height: 44)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "groupSessionCollectionHeader", for: indexPath)
            return headerView
            
        default:
            fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageReuseCell", for: indexPath) as! ImageCollectionViewCell
        let item = imageListModel[indexPath.row]
        cell.imageViewItem.sd_setImage(with: URL(string: item.thumbnailLink!), completed: nil)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row + 1 == (imageListModel.count - 3)) {
            if Reachability.isConnectedToNetwork(){
                self.searchImageWithOutLoader(text: currentSearchText!, index: (imageListModel.count + 1))
            }
        }
    }
}


class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageViewItem: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViewItem.image = nil
    }
}
