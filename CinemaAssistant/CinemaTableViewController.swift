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
import FirebaseDatabase

class CinemaTableViewController: UITableViewController {
    
    //cinemaImgLink = https://imgur.com/a/5BY8ANj
    
    var realmResults:Results<Cinema>?
    var cinemaImg = [UIImage?](repeating: nil, count: 23)
    
    var ref: DatabaseReference!
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        getData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//    }
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cinemaCell", for: indexPath)
        
        // Configure the cell...
        if let cellCinemaName = cell.viewWithTag(101) as? UILabel {
            
            if realmResults != nil {
                cellCinemaName.text = realmResults![indexPath.row].cinemaName
            }
            
        }
        
        if let cellAddress = cell.viewWithTag(102) as? UILabel {
            
            if realmResults != nil {
                cellAddress.text = realmResults![indexPath.row].address
            }
            
        }
        
        if let cellImage = cell.viewWithTag(103) as? UIImageView {
            
            //cellImage.image = cinemaImgs[indexPath.row]
            //print("Showing Image: \(realmResults![indexPath.row].cinemaImg)")
            if let results = realmResults{
                
                let cinemaid = results[indexPath.row].id
                
                if cinemaImg[cinemaid-1] != nil{
                    
                    cellImage.image = cinemaImg[cinemaid-1]
                    
                }
            }
            
        }
        
        return cell
    }
    
    func getData() {
        
        
        let realm = try! Realm()
        
        
        try! realm.write {
            realm.deleteAll()
        }
        
        for n in 1...23 {
            
            ref.child("cinema").child("\(n)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                //print("reading database")
                
                let value = snapshot.value as? NSDictionary
                
                
                try! realm.write {
                    
                    let cinema = Cinema()
                    
                    cinema.id = n
                    cinema.cinemaName = value?["cinemaName"] as? String ?? ""
                    cinema.address = value?["address"] as? String ?? ""
                    cinema.district = value?["district"] as? String ?? ""
                    
                    
                    if let url = value?["imgURL"] as? String {
                        
                        Alamofire.request(url).responseData { response in
                            
                            if let data = response.result.value{
                                
                                self.cinemaImg[cinema.id-1] = UIImage(data: data, scale: 1)
                                print("Cinema ID \(cinema.id) image loaded")
                                
                            }
                            
                        }
                        
                    }
                    cinema.tel = value?["tel"] as? String ?? ""
                    
                    
                    realm.add(cinema)
                        //print("realm write")
                    
                }
                
                
                if n == 23 {
                    print("Last operation in loop")
                    self.realmResults = realm.objects(Cinema.self)
                    
                }
                
                self.tableView.reloadData()
                
            }){ (error) in
                print(error.localizedDescription)
            }
            
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCinemaDetail" {
            
            if let destinationVC = segue.destination as? CinemaDetailTableViewController {
                
                let selectedIndex = tableView.indexPathForSelectedRow!
                
                if let result = realmResults {
                destinationVC.cinemaName = result[selectedIndex.row].cinemaName
                destinationVC.address = result[selectedIndex.row].address
                destinationVC.district = result[selectedIndex.row].district
                destinationVC.tel = result[selectedIndex.row].tel
                destinationVC.cinemaID = result[selectedIndex.row].id
                destinationVC.image = cinemaImg[result[selectedIndex.row].id-1]
                }
                //destinationVC.image = cinemaImgURL[selectedIndex.row]
                
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
