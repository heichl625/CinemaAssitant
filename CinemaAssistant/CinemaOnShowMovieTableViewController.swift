//
//  CinemaOnShowMovieTableViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 15/2/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit
import SwiftSoup

class onShowMovie {
    
    var movieName: String?
    var movieImgURL: String?
    var id: String?
    
}

class CinemaOnShowMovieTableViewController: UITableViewController {
    
    var MCLcinemaID: String?
    var UACinemaID: String?
    var wmoovID: String?
    var cinemaGroup: String?
    var firebaseCinemaID: Int?
    
    var dataFetchingDate: String?
    
    var uaOnShowMovieName: [String] = []
    
    var movies: [onShowMovie] = []
    
    var uaOnShowMovieThumbnailURL: [String] = []
    var jsonResult: JSON?
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let cinemaID = wmoovID{
            handleCinema(cinemaID: cinemaID)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        if movies.count == 0{
            return 1
        }else{
            return movies.count
        }
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        if movies.count != 0{
            
            // Configure the cell...
            if let movieTitle = cell.viewWithTag(100) as? UILabel {
                
                
                movieTitle.text = movies[indexPath.row].movieName
                
                
            }
            if let movieThumbnail = cell.viewWithTag(101) as? UIImageView {
                
                var url = ""
                
                
                if movies.count > 0 && movies[indexPath.row].movieImgURL != nil{
                    
                    url = movies[indexPath.row].movieImgURL!
                    print("row: \(indexPath.row)")
                }
                
                DispatchQueue.global(qos: .background).async {
                    AF.request(url).responseData { response in
                        
                        switch(response.result){
                            
                        case let .success(value):
                            
                            DispatchQueue.main.async {
                                movieThumbnail.image = UIImage(data: value, scale: 1)
                            }
                            
                        case let .failure(error):
                            print("error")
                        }
                    }
                }
            }
        }else{
            
            if let movieTitle = cell.viewWithTag(100) as? UILabel{
                
                movieTitle.text = "此戲院現時未有任何電影正在上映"
                
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSessionFromOnShowing", sender: self)
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showSessionFromOnShowing" {
            
            if let destinationVC = segue.destination as? SessionTableViewController {
                
                destinationVC.cinemaGroup = self.cinemaGroup
                destinationVC.firebaseCinemaID = self.firebaseCinemaID
                
                
                destinationVC.cinemaID = self.wmoovID
                destinationVC.dataFetchingDate = self.dataFetchingDate
                destinationVC.movieID = self.movies[tableView.indexPathForSelectedRow!.row].id
                destinationVC.movieName = self.movies[tableView.indexPathForSelectedRow!.row].movieName
                
            }
            
        }
        
    }
    
    //    func handleUA(cinemaID: String){
    //
    //        dispatchGroup.enter()
    //
    //        print(cinemaID)
    //
    //        let url = URL(string: "https://www.uacinemas.com.hk/eng/cinema/\(cinemaID)")
    //
    //        DispatchQueue.global(qos: .background).async{
    //
    //            let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
    //
    //                if error != nil {
    //                    print(error)
    //                }else{
    //
    //                    do {
    //
    //                        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    //
    //                        let doc: Document = try SwiftSoup.parse(html! as String)
    //
    //                        let lists: Elements = try! doc.select("li")
    //
    //                        for list in lists{
    //                            //get movie poster
    //                            if try list.className() == "desktop"{
    //
    //                                let divs: Elements = try! list.select("div")
    //
    //                                for div in divs {
    //
    //                                    if try div.className() == "center_img"{
    //                                        let img: Elements = try! div.select("img")
    //                                        //print(try img.attr("src"))
    //                                        self.uaOnShowMovieThumbnailURL.append(try! img.attr("src"))
    //                                    }
    //
    //
    //                                    if try div.className() == "center_info"{
    //                                        //Get on show movie name
    //                                        let h3: Elements = try! div.select("h3")
    //                                        if h3.isEmpty(){
    //                                            continue
    //                                        }else{
    //                                            //print(try h3.text())
    //                                            self.uaOnShowMovieName.append(try! h3.text())
    //
    //                                        }
    //
    //                                    }
    //                                }
    //                            }
    //                        }
    //
    //
    //                        print(self.uaOnShowMovieName)
    //                        self.dispatchGroup.leave()
    //
    //
    //
    //                    }catch Exception.Error(type: let type, Message: let message){
    //                        print(type)
    //                        print(message)
    //                    }catch{
    //                        print("")
    //
    //                    }
    //
    //                }
    //
    //            }
    //            task.resume()
    //        }
    //
    //    }
    //
    func handleCinema(cinemaID: String){
        
        movies.removeAll()
        
        print(cinemaID)
        
        let group = DispatchGroup()
        
        let url = URL(string: "https://wmoov.com/cinema/movies/\(cinemaID)")
        
        
        
        let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
            
            if error != nil {
                print(error)
            }else{
                
                do {
                    
                    let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    let doc: Document = try SwiftSoup.parse(html! as String)
                    
                    let options: Elements = try! doc.select("option")
                    
                    for option in options {
                        
                        if try! option.attr("selected") == "selected"{
                            
                            self.dataFetchingDate = try! option.attr("value")
                            break
                            
                        }
                    }
                    let selects: Elements = try! doc.select("select")
                    
                    for select in selects{
                        
                        if select.id() == "movies_option"{
                            
                            let movieNames: Elements = try select.select("option")
                            
                            group.enter()
                            print("entered")
                            
                            for movieName in movieNames{
                                if try! movieName.attr("value") != "" {
                                    
                                    let newMovie = onShowMovie()
                                    
                                    newMovie.movieName = try! movieName.text()
                                    
                                    newMovie.id = try! movieName.attr("value")
                                    
                                    let movieURL = URL(string: "https://wmoov.com/movie/details/\(newMovie.id!)")
                                    let imgTask = URLSession.shared.dataTask(with: movieURL!){ (data, response, error) in
                                        if error != nil {
                                            print(error)
                                        }else{
                                            do {
                                                let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                                                
                                                let doc: Document = try SwiftSoup.parse(html! as String)
                                                
                                                let img: Element = try! doc.select("img").first()!
                                                
                                                newMovie.movieImgURL = "https:\(try! img.attr("src"))"
                                                
                                                self.movies.append(newMovie)
                                                
                                                print("\(newMovie.id) add!")
                                                
                                                if movieName == movieNames.last(){
                                                    group.leave()
                                                    print("left")
                                                }
                                                group.notify(queue: .main){
                                                    print("All movie added to class")
                                                    DispatchQueue.main.async{
                                                        self.tableView.reloadData()
                                                    }
                                                }
                                                
                                            }catch Exception.Error(type: let type, Message: let message){
                                                print(type)
                                                print(message)
                                            }catch{
                                                print("")
                                            }
                                            
                                        }
                                    }
                                    imgTask.resume()
                                }
                                //group.leave()
                            }
                            
                        }
                        
                    }
                }catch Exception.Error(type: let type, Message: let message){
                    print(type)
                    print(message)
                }catch{
                    print("")
                }
            }
        }
        task.resume()
    }
    
    
    //        group.notify(queue: .main){
    //
    //            print("Finished loading names")
    //
    //            let dg = DispatchGroup()
    //
    //                for n in 0..<self.movies.count{
    //
    //                    dg.enter()
    
    //                    let movieURL = URL(string: "https://wmoov.com/movie/details/\(self.movies[n].id!)")
    //                    let imgTask = URLSession.shared.dataTask(with: movieURL!){ (data, response, error) in
    //                        if error != nil {
    //                            print(error)
    //                        }else{
    //                            do {
    //                                let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
    //
    //                                let doc: Document = try SwiftSoup.parse(html! as String)
    //
    //                                let img: Element = try! doc.select("img").first()!
    //
    //                                self.movies[n].movieImgURL = "https:\(try! img.attr("src"))"
    //
    //                                dg.leave()
    //
    //                            }catch Exception.Error(type: let type, Message: let message){
    //                                print(type)
    //                                print(message)
    //                            }catch{
    //                                print("")
    //                            }
    //                        }
    //                    }
    //                    imgTask.resume()
    
    //            }
    
    //            dg.notify(queue: .main){
    //                DispatchQueue.main.async {
    //                    self.tableView.reloadData()
    //                }
    //            }
    //
    //        }
    //    }
    
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
