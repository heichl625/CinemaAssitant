//
//  FavoriteMovieTableViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 16/1/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import RealmSwift
import SwiftyJSON
import BTNavigationDropdownMenu
import AlamofireImage


class ForYouTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var uid: String?
    let imageCache = NSCache<NSString, UIImage>()
    var api_key: String = "c411a985e4c5562757a616894b03eadb"
    
    var moviesID: [String] = []
    var movieTitle: [String] = []
    var realmResults:Results<MovieFeed>?
    var suggestMovie: [String : String] = [:]
    
    var showFavourite = true
    
    
    let dropDownItem = ["最愛電影", "電影建議"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title("最愛電影"), items: dropDownItem)
        
        navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            
            if indexPath == 0 {
                //BTTitle.title("Favourite")
                self!.showFavourite = true
            }else{
                //BTTitle.title("Suggestions")
                self!.showFavourite = false
            }
            
            self!.loadMovie()
            self!.tableView.reloadData()
            
            
            
        }
        
        menuView.cellSeparatorColor = menuView.cellBackgroundColor
        menuView.checkMarkImage = nil
        menuView.cellBackgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
        menuView.cellTextLabelColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        menuView.selectedCellTextLabelColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = UserDefaults.standard.object(forKey: "uid"){
            uid = user as! String
        }else{
            let alertController = UIAlertController(title: "登入", message: "請先登入以使用此功能", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "登入", style: .default, handler: { action in
                self.performSegue(withIdentifier: "showLoginFromFavouriteMovie", sender: self)
            }))
            alertController.addAction(UIAlertAction(title: "取消", style: .default, handler: nil))
            self.present(alertController, animated: true)
        }
        loadMovie()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if let result = realmResults{
        
            if result.count == 0{
                print("First if: \(realmResults?.count)")
                return 1
            }else{
                print("first else: \(realmResults?.count)")
                return result.count
            }
        }else{print("second else: \(realmResults?.count)")
            return 1
        }
        
    }
    
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        getMovieInfo(movieID: moviesID[indexPath.row])
    //    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        // Configure the cell...
        print(realmResults?.count)
        
        if realmResults?.count == 0 || realmResults == nil {
            
            print("no relmresult")
            
            if let cellTitle = cell.viewWithTag(101) as? UILabel{
                
                cellTitle.text = "你尚未加入任何最愛電影"
                
            }
            
            if let cellReleaseDate = cell.viewWithTag(102) as? UILabel{
                
                cellReleaseDate.text = "請於加入後再嘗試"
                
            }
            
            if let cellImage = cell.viewWithTag(103) as? UIImageView{
                
                cellImage.image = nil
                
            }
            
        } else {
            
            
            
            if let cellTitle = cell.viewWithTag(101) as? UILabel{
                
                if let result = realmResults{
                    
                    cellTitle.text = result[indexPath.row].original_title
                    
                }
                
                
            }
            
            if let cellReleaseDate = cell.viewWithTag(102) as? UILabel{
                
                if let result = realmResults{
                    print("RealmResult: \(realmResults)")
                    
                    cellReleaseDate.text = "上映日期： \(result[indexPath.row].release_date!)"
                    
                }
                
            }
            
            
            
            if let cellImage = cell.viewWithTag(103) as? UIImageView {
                
                if let result = realmResults{
                    
                    if self.imageCache.object(forKey: result[indexPath.row].id as NSString? ?? "") == nil{
                        
                        let url = "https://image.tmdb.org/t/p/w500/" + result[indexPath.row].poster_path!
                        
                        AF.request(url).responseImage { response in
                            
                            switch(response.result){
                                
                            case let .success(image):
                                print("write image to cache")
                                self.imageCache.setObject(image, forKey: result[indexPath.row].id as NSString? ?? "")
                                cellImage.image = self.imageCache.object(forKey: result[indexPath.row].id as NSString? ?? "")
                                
                            case let .failure(error):
                                print(error)
                                
                            }
                        }
                    }else{
                        
                        cellImage.image = self.imageCache.object(forKey: result[indexPath.row].id! as NSString)
                    }
                    
                }
            }
            
            
            //                if let image = self.imageCache.image(withIdentifier: result[indexPath.row].id!){
            //
            //                    cellImage.image = image
            //
            //                }
            //            }
            
            //            if let result = realmResults{
            //
            //
            //
            //                            let urlSubString = result[indexPath.row].poster_path
            //
            //
            //                            if let unwrappedSubString = urlSubString {
            //
            //                                DispatchQueue.global(qos: .background).async {
            //                                    AF.request("https://image.tmdb.org/t/p/w500/\(unwrappedSubString)").responseData {
            //                                        response in
            //
            //                                        if let data = response.result.value {
            //
            //                                            DispatchQueue.main.async{
            //
            //                                                cellImage.image = UIImage(data: data, scale:1)
            //
            //                                            }
            //
            //                                        }
            //                                    }
            //                                }
            //
            //
            //                            }
            //            //            }
            //            }
            
            
        }
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showMovieDetailFromFavourite", sender: self)
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    func getSuggestionMovie(){
        
        
        let keys = self.suggestMovie.keys
        
        let realm = try! Realm()
        
        let group = DispatchGroup()
        
        if keys.count > 0{
            
            print("show Suggestion Movie")
            
            try! realm.write {
                
                realm.deleteAll()
                print("All realm deleted")
                
            }
            
            for key in keys {
                
                //print(key)
                
                print(key)
                
                group.enter()
                
                AF.request("https://api.themoviedb.org/3/movie/\(key)?api_key=c411a985e4c5562757a616894b03eadb").responseJSON{ response in
                    
                    var jsonResult: JSON?
                    
                    //print("Alamofire key: \(key)")
                    
                    switch(response.result){
                        
                    case let .success(value):
                        
                        jsonResult = JSON(value)
                        
                        let movie = MovieFeed()
                        
                        movie.id = key
                        movie.original_title = self.suggestMovie[key]
                        movie.overview = jsonResult?["overview"].stringValue
                        movie.release_date = jsonResult?["release_date"].stringValue
                        movie.poster_path = jsonResult?["poster_path"].stringValue
                        
                        
                        
                        try! realm.write{
                            
                            realm.add(movie)
                            
                        }
                        
                        group.leave()
                        
                    case let .failure(error):
                        print(error)
                        
                    }
                    
                    
                }
                
                
                self.realmResults = realm.objects(MovieFeed.self)
                
                
                group.notify(queue: .main){
                    DispatchQueue.main.async {
                        print(self.realmResults?.count)
                        self.tableView.reloadData()
                    }
                }
                
                
            }
        }
        
        
        
    }
    
    func getFavouriteMovieID(){
        
        if let id = uid{
            
            ref.child("users").child(id).child("favMovies").observeSingleEvent(of: .value, with: { snapshot in
                
                let value = snapshot.value as? NSDictionary
                self.moviesID.removeAll()
                
                if value != nil{
                    
                    //print("All MovieID removed")
                    
                    print(value?.allKeys)
                    
                    for key in value!.allKeys{
                        
                        //print(key)
                        self.moviesID.append(key as! String)
                        print("movieID \(key) added")
                        //self.moviesID?.append(key as! Int)
                    }
                    //print("All movieID inserted")
                }
                
                self.getMovieInfo()
                
                
            })
            
            
            
        }
        
    }
    
    func getMovieInfo(){
        let realm = try! Realm()
        
        try! realm.write {
            realm.deleteAll()
            print("All realm deleted")
            
        }
        
        for n in 0..<self.moviesID.count{
            
            print("Loop count: \(n)")
            
            self.ref.child("users").child(uid!).child("favMovies").child(moviesID[n]).observeSingleEvent(of: .value, with: { snapshot in
                
                let value = snapshot.value as? NSDictionary
                let movie = MovieFeed()
                
                movie.id = self.moviesID[n]
                movie.original_title = value?["movieTitle"] as? String
                movie.overview = value?["overview"] as? String
                movie.release_date = value?["releaseDate"] as? String
                movie.poster_path = value?["imgURL"] as? String
                
                try! realm.write{
                    realm.add(movie)
                }
                
                self.realmResults = realm.objects(MovieFeed.self)
                
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
                //self.getSuggestionList()
                
            }){ (error) in
                print(error.localizedDescription)
            }
           
            
        }
         self.tableView.reloadData()
        
        
        
    }
    
    func getSuggestionList(){
        
        var suggestionResult: JSON?
        
        print("count: \(realmResults?.count)")
        
        
        
        
        
        if let result = realmResults{
            
            if result.count > 0{
                
                let group = DispatchGroup()
                //print("inside suggestionList: \(result.count-1)")
                
                for r in result {
                    
                    group.enter()
                    
                    let url = "https://api.themoviedb.org/3/movie/\(r.id!)/recommendations?api_key=\(api_key)&language=zh-HK&page=1"
                    
                    print(url)
                    
                    
                    AF.request(url).responseJSON{ response in
                        
                        //print("inside alamofire")
                        
                        switch(response.result){
                            
                        case let .success(value):
                            suggestionResult = JSON(value)
                            
                            //print(suggestionResult)
                            
                            if suggestionResult!["results"].count > 0{
                                
                                print(suggestionResult!["results"].count)
                                for n in 0..<suggestionResult!["results"].count{
                                    
                                    var writeIn = true
                                    
                                    if self.moviesID.count > 0{
                                        for m in 0..<self.moviesID.count{
                                            if self.moviesID[m] == suggestionResult!["results"][n]["id"].stringValue{
                                                writeIn = false
                                                continue
                                            }
                                        }
                                    }
                                    
                                    if writeIn {
                                        //print("writing movies into suggestion list")
                                        self.suggestMovie[suggestionResult!["results"][n]["id"].stringValue] = suggestionResult!["results"][n]["title"].stringValue
                                        print(self.suggestMovie[suggestionResult!["results"][n]["id"].stringValue])
                                    }
                                    
                                }
                                group.leave()
                            }
                            
                        case let .failure(error):
                            print(error)
                            
                            
                        }
                        
                    }
                    
                    group.notify(queue: .main){
                        print("get suggestion movies")
                        self.getSuggestionMovie()
                    }
                }
                
                
                
            }
        }
        
        //Get suggestion movie info
        //suggestMovie!["results"][n]["poster_path"].stringValue && //suggestionResult!["results"][n]["title"].stringValue
        
    }
    
    func loadMovie(){
        
        if showFavourite{
            getFavouriteMovieID()
        }else{
            
            let group = DispatchGroup()
            getSuggestionList()
            self.tableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMovieDetailFromFavourite" {
            
            if let destinationVC = segue.destination as? MovieDetailViewController{
                
                destinationVC.id = realmResults?[tableView.indexPathForSelectedRow!.row].id ?? ""
                destinationVC.posterPath = realmResults?[tableView.indexPathForSelectedRow!.row].poster_path ?? ""
                destinationVC.movieTitle = realmResults?[tableView.indexPathForSelectedRow!.row].original_title ?? ""
                destinationVC.overviewStr = realmResults?[tableView.indexPathForSelectedRow!.row].overview ?? ""
                destinationVC.releaseDateStr = realmResults?[tableView.indexPathForSelectedRow!.row].release_date ?? ""
                
                
            }
            
        }
        
    }
    
    
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
