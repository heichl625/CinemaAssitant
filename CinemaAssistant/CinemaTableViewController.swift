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
import AlamofireImage
import FirebaseDatabase
import CoreData

class Responder: NSObject {
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        UIView.animate(withDuration: 0.3) {
            buttonBar.frame.origin.x = (segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)) * CGFloat(segmentedControl.selectedSegmentIndex)
        }
        
    }
}

let responder = Responder()
let segmentedControl = UISegmentedControl()
let buttonBar = UIView()

class CinemaTableViewController: UITableViewController {
    
    //cinemaImgLink = https://imgur.com/a/5BY8ANj
    
    var cinemas = [Cinema]()
    var ref: DatabaseReference!
    var imageData: Data?
    let imageCache = NSCache<NSString, UIImage>()
    let thumbnailCache = NSCache<NSString, UIImage>()
    
    let fetchRequest: NSFetchRequest<Cinema> = Cinema.fetchRequest()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentControlBar()
        
        ref = Database.database().reference()
        imageCache.countLimit = 23
        thumbnailCache.countLimit = 23
        
        
        
        if UserDefaults.standard.bool(forKey: "cinemaDataLoaded"){
            
            do{
                let cinemas = try PersistenceService.context.fetch(fetchRequest)
                self.cinemas = cinemas
                self.tableView.reloadData()
            }catch{
                print("Failed to fetch request")
            }
        }else{
            getData()
        }
        
//        self.loadSeatToFirebase()
        
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
        return cinemas.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cinemaCell", for: indexPath)
        
        // Configure the cell...
        if let cellCinemaName = cell.viewWithTag(101) as? UILabel {
            
            
            cellCinemaName.text = cinemas[indexPath.row].cinemaName
            
            
        }
        
        if let cellAddress = cell.viewWithTag(102) as? UILabel {
            
            
            cellAddress.text = cinemas[indexPath.row].address
            
            
        }
        
        if let cellImage = cell.viewWithTag(103) as? UIImageView {
            
            //cellImage.image = cinemaImgs[indexPath.row]
            //print("Showing Image: \(realmResults![indexPath.row].cinemaImg)")
            
            //            let cinemaid = cinema[indexPath.row].id
            if let thumbnails = cinemas[indexPath.row].thumbnails{
                cellImage.image = UIImage(data: thumbnails)
            }
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.isSelected = false
    }
    
    func getData() {
        
        let group = DispatchGroup()
        
        
        for n in 1...23 {
            
            group.enter()
            
            let alertController = UIAlertController(title: nil, message: "Downloading Cinema Data...", preferredStyle: .alert)
            present(alertController, animated: true, completion: nil)
            
            self.ref.child("cinema").child("\(n)").observeSingleEvent(of: .value, with: { (snapshot) in
                
                print("Getting cinema results")
                
                let value = snapshot.value as? NSDictionary
                
                let cinema = Cinema(context: PersistenceService.context)
                
                cinema.cinemaID = Int16(n)
                cinema.cinemaName = value?["cinemaName"] as? String ?? ""
                cinema.address = value?["address"] as? String ?? ""
                cinema.district = value?["district"] as? String ?? ""
                cinema.cinemaGroup = value?["cinemaGroup"] as? String ?? ""
                cinema.tel = value?["tel"] as? String ?? ""
                cinema.lat = value?["lat"] as? Double ?? 0.0
                cinema.lon = value?["lon"] as? Double ?? 0.0
                
                let thumbnailsURL = value?["thumbnailsURL"] as? String
                
                AF.request(thumbnailsURL!).responseData { response in
                    
                    switch(response.result){
                        
                    case let .success(thumbnailsData):
                        print("Getting thumbnails")
                        cinema.thumbnails = thumbnailsData
                        group.leave()
                    case let .failure(error):
                        print(error)
                        
                    }
                    
                    
                    //self.thumbnailCache.setObject(image, forKey: "\(cinema.id)" as NSString)
                }
                
                DispatchQueue.global(qos: .background).async{
                    
                    let imgURL = value?["imgURL"] as? String
                    
                    AF.request(imgURL!).responseData { response in
                        
                        
                        switch(response.result){
                            
                        case let .success(data):
                            print("Getting image")
                            
                            cinema.fullImage = data
                            PersistenceService.saveContext()
                        case let .failure(error):
                            print(error)
                            
                            
                        }
                        
                    }
                    
                }
                
                group.notify(queue: .main){
                    self.cinemas.append(cinema)
                    alertController.dismiss(animated: true, completion: nil)
                    self.tableView.reloadData()
                }
                
            }){ (error) in
                print(error.localizedDescription)
            }
        }
        
        UserDefaults.standard.set(true, forKey: "cinemaDataLoaded")
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showCinemaDetail" {
            
            if let destinationVC = segue.destination as? CinemaDetailTableViewController {
                
                let selectedIndex = tableView.indexPathForSelectedRow!
                
                destinationVC.cinemaName = cinemas[selectedIndex.row].cinemaName
                destinationVC.address = cinemas[selectedIndex.row].address
                destinationVC.district = cinemas[selectedIndex.row].district
                destinationVC.tel = cinemas[selectedIndex.row].tel
                destinationVC.cinemaID = Int(cinemas[selectedIndex.row].cinemaID)
                destinationVC.image = UIImage(data: cinemas[selectedIndex.row].fullImage!)
                destinationVC.cinemaGroup   = cinemas[selectedIndex.row].cinemaGroup
                destinationVC.lat = cinemas[selectedIndex.row].lat
                destinationVC.lon = cinemas[selectedIndex.row].lon
                //destinationVC.image = cinemaImgURL[selectedIndex.row]
                
            }
        }
    }
    
    
    
    @objc func segmentSelected(sender: UISegmentedControl){
        
        var cinemaBrand: String = ""
        cinemaBrand = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        
        switch(sender.selectedSegmentIndex){
            
        case 1, 2:
            fetchRequest.predicate = NSPredicate(format: "cinemaGroup == %@", cinemaBrand)
        case 3:
            fetchRequest.predicate = NSPredicate(format: "cinemaGroup == %@", "Broadway")
        case 4:
            fetchRequest.predicate = NSPredicate(format: "cinemaGroup == %@", "GoldenHarvest")
        case 5:
            fetchRequest.predicate = NSPredicate(format: "cinemaGroup != %@ && cinemaGroup != %@ && cinemaGroup != %@ && cinemaGroup != %@", "GoldenHarvest", "Broadway", "UA", "MCL")
        default:
            fetchRequest.predicate = nil
            
        }
        
        do{
            let cinemas = try PersistenceService.context.fetch(fetchRequest)
            self.cinemas = cinemas
            self.tableView.reloadData()
        }catch{
            print("Failed to fetch request")
        }
    }
    
    func setupSegmentControlBar(){
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 40))
        view.backgroundColor = .black
        
        
        // Add segments
        segmentedControl.insertSegment(withTitle: "全部", at: 0, animated: true)
        segmentedControl.insertSegment(withTitle: "MCL", at: 1, animated: true)
        segmentedControl.insertSegment(withTitle: "UA", at: 2, animated: true)
        segmentedControl.insertSegment(withTitle: "百老匯", at: 3, animated: true)
        segmentedControl.insertSegment(withTitle: "嘉禾", at: 4, animated: true)
        segmentedControl.insertSegment(withTitle: "其他", at: 5, animated: true)
        // First segment is selected by default
        segmentedControl.selectedSegmentIndex = 0
        
        // Add lines below selectedSegmentIndex
        segmentedControl.tintColor = .clear
        segmentedControl.backgroundColor = .clear
        segmentedControl.selectedSegmentTintColor = .clear
        
        // Add lines below the segmented control's tintColor
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.white
        ], for: .normal)
        
        segmentedControl.setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        ], for: .selected)
        
        // This needs to be false since we are using auto layout constraints
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the segmented control to the container view
        view.addSubview(segmentedControl)
        
        // Constrain the segmented control to the top of the container view
        segmentedControl.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        // Constrain the segmented control width to be equal to the container view width
        segmentedControl.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        // Constraining the height of the segmented control to an arbitrarily chosen value
        segmentedControl.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        // This needs to be false since we are using auto layout constraints
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.backgroundColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        
        view.addSubview(buttonBar)
        
        buttonBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor).isActive = true
        buttonBar.heightAnchor.constraint(equalToConstant: 5).isActive = true
        // Constrain the button bar to the left side of the segmented control
        buttonBar.leftAnchor.constraint(equalTo: segmentedControl.leftAnchor).isActive = true
        // Constrain the button bar to the width of the segmented control divided by the number of segments
        buttonBar.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)).isActive = true
        
        
        
        segmentedControl.addTarget(responder, action: #selector(responder.segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)
        segmentedControl.addTarget(self, action: #selector(CinemaTableViewController.segmentSelected), for:.valueChanged)
        
        tableView.tableHeaderView = view
        
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
