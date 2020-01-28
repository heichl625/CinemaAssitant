//
//  HouseSelectionTableViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 30/11/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAnalytics

class HouseSelectionTableViewController: UITableViewController {
    
    var houseCount: Int = 0
    var cinemaID: Int = 0
    var cinemaName: String = ""
    var houseName: [String] = []
    
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()
        
        if cinemaID != 0{
            getHouseName()
        }
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
        return Int(houseCount)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "houseCell", for: indexPath)

        // Configure the cell...
        if houseName.count > 0{
            cell.textLabel?.text = "\(houseName[indexPath.row])"
        }

        return cell
    }
    
    func getHouseName(){
        
        ref.child("cinema").child("\(cinemaID)").child("house").observeSingleEvent(of: .value, with: { snapshot in
            
            let value = snapshot.value as? NSArray
            
            if let unwrappedValue = value{
                
                for n in 1...unwrappedValue.count-1{
                    
                    self.houseName.append(unwrappedValue[n] as! String)
                    
                }
               
            }
            
            self.tableView.reloadData()
            
        }){ (error) in
            print(error.localizedDescription)
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
