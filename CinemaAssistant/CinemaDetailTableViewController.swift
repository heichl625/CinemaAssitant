//
//  CinemaDetailTableViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 30/11/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit

class CinemaDetailTableViewController: UITableViewController {

    var cinemaName: String?
    var image: UIImage?
    var address: String?
    var noOfHouse: Int?
    var district: String?
    var tel: String?
    
    var districtCName: String = ""
    
    @IBOutlet weak var cinemaImg: UIImageView!
    @IBOutlet weak var cinemaAddress: UILabel!
    @IBOutlet weak var cinemaNoOfHousees: UILabel!
    @IBOutlet weak var cinemaDistrict: UILabel!
    @IBOutlet weak var cinemaTel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = cinemaName
        cinemaImg.image = image
        cinemaAddress.text = address
        cinemaNoOfHousees.text = "\(noOfHouse!)"
        cinemaTel.text = tel
        
        switch(district){
        case "YTM":
            districtCName = "油尖旺"
            break
        case "KT":
            districtCName = "觀塘"
            break
        case "KLC":
            districtCName = "九龍城"
            break
        case "SSP":
            districtCName = "深水埗"
            break
        case "WTS":
            districtCName = "黃大仙"
            break
        default:
            districtCName = "其他"
            break
        }
        
        cinemaDistrict.text = districtCName
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 6
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 3 {
            makeCall()
        }
        
    }
    
    func makeCall(){
        
        if let phoneURL = URL(string: ("tel://" + tel!)) {
              let alert = UIAlertController(title: ("Call " + tel! + "?"), message: nil, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
                UIApplication.shared.open(phoneURL)
              }))
        
              alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                      
            self.present(alert, animated: true, completion: nil)
          }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showHousesSelection" {
            
            if let destinationVC = segue.destination as? HouseSelectionTableViewController {
                
                destinationVC.houseCount = self.noOfHouse!
                destinationVC.cinemaName = self.cinemaName!
                
            }
            
        }
        
        if segue.identifier == "showMap" {
            
            if let destinationVC = segue.destination as? CinemaMapViewController {
                
                destinationVC.address = self.address!
                destinationVC.cinemaName = self.cinemaName!
                
            }
            
        }
    
    }

    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
//
//        // Configure the cell...
//
//        return cell
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