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


class FavoriteMovieTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var user: User?
    var api_key: String = "c411a985e4c5562757a616894b03eadb"
    
    var moviesID: [String] = []
    var movieTitle: [String] = []
    var realmResults:Results<MovieFeed>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        self.title = "Favourite"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if Auth.auth().currentUser != nil{
            user = Auth.auth().currentUser
        }else{
            let alertController = UIAlertController(title: "Login", message: "Please Login First", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.performSegue(withIdentifier: "showLoginFromFavouriteMovie", sender: self)
            }))
            self.present(alertController, animated: true)
        }
        
        getFavouriteMovieID()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return moviesID.count
    }
    
    //    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        getMovieInfo(movieID: moviesID[indexPath.row])
    //    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favMovieCell", for: indexPath)
        
        // Configure the cell...
        if let cellTitle = cell.viewWithTag(101) as? UILabel{
            
            if let result = realmResults{
                
                cellTitle.text = result[indexPath.row].original_title
                
            }
            
            
        }
        
        if let cellReleaseDate = cell.viewWithTag(102) as? UILabel{
            
            if let result = realmResults{
                
                cellReleaseDate.text = "Release Date： \(result[indexPath.row].release_date!)"
                
            }
            
        }
        
        
        
        if let cellImage = cell.viewWithTag(103) as? UIImageView {
            
            if let result = realmResults{
                
                let urlSubString = result[indexPath.row].poster_path
                
                
                if let unwrappedSubString = urlSubString {
                    
                    Alamofire.request("https://image.tmdb.org/t/p/w500/\(unwrappedSubString)").responseData {
                        response in
                        
                        if let data = response.result.value {
                            cellImage.image = UIImage(data: data, scale:1)
                        }
                    }
                }
            }
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "showMovieDetailFromFavourite", sender: self)
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    func getFavouriteMovieID(){
        
        if user != nil {
            
            ref.child("users").child(user!.uid).child("favMovies").observeSingleEvent(of: .value, with: { snapshot in
                
                let value = snapshot.value as? NSDictionary
                
                if value != nil{
                    
                    //print("All MovieID removed")
                    self.moviesID.removeAll()
                    
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
        
        for n in 0...self.moviesID.count-1{
            
            print("Loop count: \(n)")
            
            self.ref.child("users").child(self.user!.uid).child("favMovies").child(self.moviesID[n]).observeSingleEvent(of: .value, with: { snapshot in
                
                let value = snapshot.value as? NSDictionary
                
                
                
                let movie = MovieFeed()
                
                movie.id = self.moviesID[n]
                movie.original_title = value?["movieTitle"] as? String
                movie.overview = value?["overview"] as? String
                movie.release_date = value?["releaseDate"] as? String
                movie.poster_path = value?["imgURL"] as? String
                
                try! realm.write{
                    realm.add(movie)
                    print("movie \(n) added to the realm")
                    print("realmResult count: \(self.realmResults?.count)")
                    self.tableView.reloadData()
                    
                }
                
                self.realmResults = realm.objects(MovieFeed.self)
                
            }){ (error) in
                print(error.localizedDescription)
            }
            
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showMovieDetailFromFavourite" {
            
            if let destinationVC = segue.destination as? MovieDetailViewController{
                
                destinationVC.id = moviesID[tableView.indexPathForSelectedRow!.row]
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
