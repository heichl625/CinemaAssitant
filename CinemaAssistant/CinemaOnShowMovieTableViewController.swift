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

class CinemaOnShowMovieTableViewController: UITableViewController {
    
    var MCLcinemaID: String?
    var UACinemaID: String?
    var cinemaGroup: String?
    var uaOnShowMovieCount: Int = 0
    var uaOnShowMovieName: [String] = []
    var uaOnShowMovieThumbnailURL: [String] = []
    var jsonResult: JSON?
    
    let dispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        switch(cinemaGroup){
        case "MCL":
            if let cinemaID = MCLcinemaID{
                
                Alamofire.request("https://www.mclcinema.com/MCLOpenAPI/en-US/NowShowing/app/Cinema/\(cinemaID)").validate().responseJSON { response in
                    
                    self.jsonResult = JSON(response.result.value)
                    self.tableView.reloadData()
                    //print(self.jsonResult![0]["MovieName"])
                    
                }
                
            }
        case "UA":
            //print(UACinemaID)
            if let cinemaID = UACinemaID{
                
                handleUA(cinemaID: cinemaID)
                //print(uaOnShowMovieName?.count)
            }
        default:
            break
        }
        
        dispatchGroup.notify(queue: .main){
            self.tableView.reloadData()
        }
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch(cinemaGroup){
            
        case "MCL":
            return jsonResult?.count ?? 0
        case "UA":
            //print(uaOnShowMovieName)
            return uaOnShowMovieName.count
        default:
            return 0
            
        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        // Configure the cell...
        if let movieTitle = cell.viewWithTag(100) as? UILabel {
            
            switch (self.cinemaGroup){
            case "MCL":
                print(jsonResult![indexPath.row]["MovieName"].stringValue)
                movieTitle.text = jsonResult![indexPath.row]["MovieName"].stringValue
            case "UA":
                movieTitle.text = uaOnShowMovieName[indexPath.row]
            default:
                break
                
            }
            
        }
        if let movieThumbnail = cell.viewWithTag(101) as? UIImageView {
            
            var url = ""
            switch(self.cinemaGroup){
                
            case "MCL":
                url = "https://www.mclcinema.com/\(self.jsonResult![indexPath.row]["Poster"].stringValue)"
            case "UA":
                url = uaOnShowMovieThumbnailURL[indexPath.row]
            default:
                break
            }
            
            Alamofire.request(url).responseData { response in
                
                if let data = response.result.value{
                    
                    movieThumbnail.image = UIImage(data: data, scale: 1)
                    
                }
                
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
                
                switch(self.cinemaGroup){
                
                case "MCL":
                    destinationVC.cinemaID = self.MCLcinemaID
                    destinationVC.movieID = self.jsonResult![tableView.indexPathForSelectedRow!.row]["MovieSetID"].stringValue
                case "UA":
                    destinationVC.cinemaID = self.UACinemaID
                    destinationVC.movieName = self.uaOnShowMovieName[tableView.indexPathForSelectedRow!.row]
                default:
                    break
                    
                }
                
            }
            
        }
        
    }
    
    func handleUA(cinemaID: String){
        
        dispatchGroup.enter()
        
        print(cinemaID)
        
        let url = URL(string: "https://www.uacinemas.com.hk/eng/cinema/\(cinemaID)")
        
        let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
            
            if error != nil {
                print(error)
            }else{
                
                do {
                    
                    let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    let doc: Document = try SwiftSoup.parse(html! as String)
                    
                    let lists: Elements = try! doc.select("li")
                    
                    for list in lists{
                        //get movie poster
                        if try list.className() == "desktop"{
                            
                            let divs: Elements = try! list.select("div")
                            
                            for div in divs {
                            
                                if try div.className() == "center_img"{
                                    let img: Elements = try! div.select("img")
                                    //print(try img.attr("src"))
                                    self.uaOnShowMovieThumbnailURL.append(try! img.attr("src"))
                                }
                                
                                
                                if try div.className() == "center_info"{
                                    //Get on show movie name
                                    let h3: Elements = try! div.select("h3")
                                    if h3.isEmpty(){
                                        continue
                                    }else{
                                        //print(try h3.text())
                                        self.uaOnShowMovieName.append(try! h3.text())
                                        self.uaOnShowMovieCount+=1
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    
                    print(self.uaOnShowMovieName)
                    self.dispatchGroup.leave()
                    
                    
                    
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
