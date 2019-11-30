//
//  CinemaTableViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 29/11/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire

class CinemaTableViewController: UITableViewController {
    
    var realmResults:Results<Cinema>?
    var cinemaNames: [String] = []
    var cinemaAddresses: [String] = []
    var cinemaImgs =  [Int:UIImage]()
    var cinemaTels: [String] = []
    var cinemaNoOfHouses: [Int] = []
    var cinemaDistricts: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let config = Realm.Configuration(
        // Get the URL to the bundled file
        fileURL: Bundle.main.url(forResource: "Cinema", withExtension: "realm"),
        // Open the file in read-only mode as application bundles are not writeable
        readOnly: true)
        
        // Open the Realm with the configuration
        let realm = try! Realm(configuration: config)
        
        realmResults = realm.objects(Cinema.self)
        
        print(realmResults![0])
        
        getData()
        
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
        return realmResults?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cinemaCell", for: indexPath)

        // Configure the cell...
        if let cellCinemaName = cell.viewWithTag(101) as? UILabel {
            
            cellCinemaName.text = cinemaNames[indexPath.row]
            
        }
        
        if let cellAddress = cell.viewWithTag(102) as? UILabel {
            
            cellAddress.text = cinemaAddresses[indexPath.row]
            
        }
        
        if let cellImage = cell.viewWithTag(103) as? UIImageView {
            
            cellImage.image = cinemaImgs[indexPath.row]
            
            
        }
        

        return cell
    }

    func getData() {
        
        if let results = realmResults {
            
            for n in 0 ... results.count-1 {
                
                cinemaNames.append(results[n].cinemaName!)
                cinemaAddresses.append(results[n].address!)
                cinemaTels.append(results[n].tel!)
                cinemaDistricts.append(results[n].district!)
                cinemaNoOfHouses.append(results[n].noOfHouses.value!)
                
                let url = results[n].imageURL!
                
                Alamofire.request(url).responseData {
                    
                    response in
                    
                    if let data = response.result.value {
                        
                        self.cinemaImgs[n] = UIImage(data: data, scale: 1)!
                        self.tableView.reloadData()
                        
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCinemaDetail" {
        
            if let destinationVC = segue.destination as? CinemaDetailTableViewController {
            
                let selectedIndex = tableView.indexPathForSelectedRow!
                destinationVC.cinemaName = cinemaNames[selectedIndex.row]
                destinationVC.address = cinemaAddresses[selectedIndex.row]
                destinationVC.district = cinemaDistricts[selectedIndex.row]
                destinationVC.tel = cinemaTels[selectedIndex.row]
                destinationVC.noOfHouse = cinemaNoOfHouses[selectedIndex.row]
                destinationVC.image = cinemaImgs[selectedIndex.row]
            
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
