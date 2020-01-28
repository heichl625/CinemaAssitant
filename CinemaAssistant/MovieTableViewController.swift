//
//  MovieTableViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 30/11/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift

class MovieTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)
    var realmResults:Results<MovieFeed>?
    
    let realm = try! Realm()
    var searchShown: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //loadSearchBar()
        tableView.keyboardDismissMode = .onDrag
        tableView.sizeToFit()
        
        
        let url = "https://api.themoviedb.org/3/movie/now_playing?api_key=c411a985e4c5562757a616894b03eadb"
        
        
        Alamofire.request(url, method: .get).validate().responseJSON {
            response in
            
            print("Result: \(response.result)") // response serialization result
            
            switch response.result {
                
            case .success(let value):
                
                self.loadJSON(value: value)
                
            case .failure(let error):
                print(error)
            }
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadSearchBar()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return realmResults?.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        // Configure the cell...
        
        if let cellTitle = cell.viewWithTag(101) as? UILabel{
            cellTitle.text = self.realmResults![indexPath.row].title
            
            
        }
        
        if let cellReleaseDate = cell.viewWithTag(102) as? UILabel{
            cellReleaseDate.text = "Release Date： \(self.realmResults![indexPath.row].release_date!)"
        }
        
        
        
        if let cellImage = cell.viewWithTag(103) as? UIImageView {
            
            let urlSubString = self.realmResults![indexPath.row].poster_path
            
            if let unwrappedSubString = urlSubString {
                
                Alamofire.request("https://image.tmdb.org/t/p/w500/\(unwrappedSubString)").responseData {
                    response in
                    
                    if let data = response.result.value {
                        cellImage.image = UIImage(data: data, scale:1)
                    }
                }
            }
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)!.isSelected {
            tableView.cellForRow(at: indexPath)?.isSelected = false
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMovieDetail"{
            if let destinationVC = segue.destination as? MovieDetailViewController{
                
                let selectedIndex = tableView.indexPathForSelectedRow!
                destinationVC.id = self.realmResults![selectedIndex.row].id
                destinationVC.movieTitle = self.realmResults![selectedIndex.row].title
                destinationVC.releaseDateStr = self.realmResults![selectedIndex.row].release_date
                destinationVC.overviewStr = self.realmResults![selectedIndex.row].overview
                destinationVC.posterPath = self.realmResults![selectedIndex.row].poster_path
                tableView.endEditing(true)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print(searchController.searchBar.text)
        
        let inputedMovieName = searchController.searchBar.text ?? ""
        let nameWithoutSpace = inputedMovieName.replacingOccurrences(of: " ", with: "%20")
        
        var url = "https://api.themoviedb.org/3/movie/now_playing?api_key=c411a985e4c5562757a616894b03eadb"
        
        if nameWithoutSpace != "" {
            url = "https://api.themoviedb.org/3/search/movie?api_key=c411a985e4c5562757a616894b03eadb&query=\(nameWithoutSpace)&language=us_en&page=1&region=hk"
        }
        
        
        Alamofire.request(url, method: .get).validate().responseJSON{ response in
            
            switch response.result{
                
            case .success(let value):
                //print(response.result.value)
                self.loadJSON(value: value)
                
            case .failure(let e):
                print(e.localizedDescription)
                
            }
            
        }
        
    }
    
    func loadSearchBar(){
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0)
        searchController.searchBar.tintColor = UIColor.white
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.automaticallyShowsCancelButton = false
        searchController.searchBar.searchTextField.textColor = UIColor.white
        searchController.searchBar.searchTextField.placeholder = "Search by Movie Name"
        searchController.searchBar.backgroundColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0)
        definesPresentationContext = true
        
        
        
    }
    
    func loadJSON(value: Any){
        
        let jsonResults = JSON(value)
        
        
        try! realm.write {
            realm.deleteAll()
        }
        
        for index in 0..<jsonResults["results"].count {
            
            let movieFeed = MovieFeed()
            movieFeed.id = jsonResults["results"][index]["id"].stringValue
            movieFeed.title = jsonResults["results"][index]["title"].stringValue
            movieFeed.overview = jsonResults["results"][index]["overview"].stringValue
            movieFeed.original_title = jsonResults["results"][index]["original_title"].stringValue
            movieFeed.release_date = jsonResults["results"][index]["release_date"].stringValue
            movieFeed.poster_path = jsonResults["results"][index]["poster_path"].stringValue
            
            try! realm.write {
                realm.add(movieFeed)
            }
        }
        
        self.realmResults = realm.objects(MovieFeed.self)
        self.tableView.reloadData()
        
    }
    
    @IBAction func searchButtonPressed(_ sender: UIBarButtonItem) {
        
        if searchShown{
            tableView.tableHeaderView = nil
            searchShown = false
        }else{
            tableView.tableHeaderView = searchController.searchBar
            searchShown = true
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
