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

class CinemaOnShowMovieTableViewController: UITableViewController {
    
    var MCLcinemaID: String?
    var jsonResult: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let cinemaID = MCLcinemaID{
               
               Alamofire.request("https://www.mclcinema.com/MCLOpenAPI/en-US/NowShowing/app/Cinema/\(cinemaID)").validate().responseJSON { response in
                   
                self.jsonResult = JSON(response.result.value)
                self.tableView.reloadData()
                //print(self.jsonResult![0]["MovieName"])

           }
        }
        
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return jsonResult?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath)
        
        // Configure the cell...
        if let movieTitle = cell.viewWithTag(100) as? UILabel {
            
            print(jsonResult![indexPath.row]["MovieName"].stringValue)
            movieTitle.text = jsonResult![indexPath.row]["MovieName"].stringValue
            
        }
        if let movieThumbnail = cell.viewWithTag(101) as? UIImageView {
            
            Alamofire.request("https://www.mclcinema.com/\(self.jsonResult![indexPath.row]["Poster"].stringValue)").responseData { response in
                
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
                
                destinationVC.cinemaID = self.MCLcinemaID
                destinationVC.movieID = self.jsonResult![tableView.indexPathForSelectedRow!.row]["MovieSetID"].stringValue
                
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
