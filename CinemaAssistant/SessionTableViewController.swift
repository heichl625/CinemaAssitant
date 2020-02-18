//
//  SessionTableViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 16/2/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import WebKit
import SwiftSoup

class SessionTableViewController: UITableViewController {
    
    var cinemaID: String?
    var movieID: String?
    var movieDetailID: String?
    var movieName: String?
    var cinemaGroup: String?
    var UASessionID: [String] = []
    
    var realmResults:Results<SessionFeed>?
    let realm = try! Realm()
    
    let dispatchGroup = DispatchGroup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        switch(cinemaGroup){
            
        case "MCL":
            Alamofire.request("https://www.mclcinema.com/MCLOpenAPI/en-US/MovieDetails/www/\(movieID!)/Cinema/\(cinemaID!)", method: .get).validate().responseJSON {
                response in
                
                print("Result: \(response.result)") // response serialization result
                
                switch response.result {
                    
                case .success(let value):
                    
                    self.getMovieDetailID(value: value)
                    self.getSessionDetail(movieID: self.movieID!, movieDetailID: self.movieDetailID!, cinemaID: self.cinemaID!)
                    
                case .failure(let error):
                    print(error)
                }
                
            }
            
        case "UA":
            handleUA()
            
            //print(UASessionID)
            
        default:
            break
            
        }
        
        //        dispatchGroup.notify(queue: .main){
        //            self.tableView.reloadData()
        //        }
        
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        //print("number of row: \(Thread.current)")
        return realmResults?.count ?? 0
        
        
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
        
        if let houseName = cell.viewWithTag(100) as? UILabel {
            
            houseName.text = realmResults?[indexPath.row].movieOnShowHouse ?? "Undefined"
            
            
        }
        
        if let onShowTime = cell.viewWithTag(101) as? UILabel {
            
            var dateTime = realmResults?[indexPath.row].movieDate ?? ""
            dateTime += " \(realmResults?[indexPath.row].movieTime ?? "")"
            dateTime += " (\(realmResults?[indexPath.row].movieOnShowDay ?? ""))"
            
            onShowTime.text = dateTime
            
            
        }
        //print("cellforrow: \(Thread.current)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSeatPlanFromSession", sender: self)
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
    
    
    func getMovieDetailID(value: Any){
        
        let jsonResults = JSON(value)
        
        movieDetailID = jsonResults[0]["MovieDetailID"].stringValue
        
        tableView.reloadData()
        
    }
    
    func getSessionDetail(movieID: String, movieDetailID: String, cinemaID: String){
        
        
        Alamofire.request("https://www.mclcinema.com/MCLOpenAPI/en-US/MovieDetail/www/Movie/\(movieID)/Version/\(movieDetailID)/Cinema/\(cinemaID)").validate().responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                
                let jsonResults = JSON(value)
                
                try! self.realm.write {
                    self.realm.deleteAll()
                }
                
                for index in 0..<jsonResults["MovieSessions"].count {
                    
                    let sessionFeed = SessionFeed()
                    sessionFeed.movieID = movieID
                    sessionFeed.sessionID = jsonResults["MovieSessions"][index]["SessionID"].stringValue
                    sessionFeed.movieDate = jsonResults["MovieSessions"][index]["Day"].stringValue
                    sessionFeed.movieLang = jsonResults["Language"].stringValue
                    sessionFeed.movieAdultPrice = jsonResults["MovieSessions"][index]["AdultPrice"].intValue
                    sessionFeed.movieName = jsonResults["VersionName"].stringValue
                    sessionFeed.movieTime = jsonResults["MovieSessions"][index]["Time"].stringValue
                    sessionFeed.movieFormat = jsonResults["Format"].stringValue
                    sessionFeed.movieOnShowDay = jsonResults["MovieSessions"][index]["DayOfWeek"].stringValue
                    sessionFeed.movieChildPrice = jsonResults["MovieSessions"][index]["ChildPrice"].intValue
                    sessionFeed.movieOnShowHouse = jsonResults["MovieSessions"][index]["ScreenName"].stringValue
                    sessionFeed.movieSeniorPrice = jsonResults["MovieSessions"][index]["SeniorPrice"].intValue
                    sessionFeed.movieStudentPrice = jsonResults["MovieSessions"][index]["StudentPrice"].intValue
                    
                    
                    try! self.realm.write {
                        self.realm.add(sessionFeed)
                    }
                }
                
                
                print("getSessionDetail: \(Thread.current)")
                self.realmResults = self.realm.objects(SessionFeed.self)
                self.tableView.reloadData()
                
                
                
            case .failure(let error):
                print(error)
            }
            
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        if segue.identifier == "showSeatPlanFromSession" {
            
            if let destinationVC  = segue.destination as? SeatPlanViewController {
                
                destinationVC.adultPrice = realmResults![indexPath!.row].movieAdultPrice
                destinationVC.childPrice = realmResults![indexPath!.row].movieChildPrice
                destinationVC.format = realmResults![indexPath!.row].movieFormat
                destinationVC.houseName = realmResults![indexPath!.row].movieOnShowHouse
                destinationVC.seniorPrice = realmResults![indexPath!.row].movieSeniorPrice
                destinationVC.studentPrice = realmResults![indexPath!.row].movieStudentPrice
                destinationVC.time = realmResults![indexPath!.row].movieTime
                destinationVC.movieName = realmResults![indexPath!.row].movieName
                destinationVC.cinemaID = self.cinemaID
                destinationVC.sessionID = realmResults![indexPath!.row].sessionID
                destinationVC.cinemaGroup = self.cinemaGroup
                
            }
            
        }
        
    }
    
    func handleUA(){
        
        //dispatchGroup.enter()
        let url = URL(string: "https://www.uacinemas.com.hk/eng/cinema/\(cinemaID!)")
        
       
           
        
        let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
            
            if error != nil {
                print(error)
            }else{
                
                 DispatchQueue.main.async {
                
                do {
                    
                    let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    
                    
                    let doc: Document = try SwiftSoup.parse(html! as String)
                    
                    let lists: Elements = try! doc.select("li")
                    
                    //get cinemaLinkID
                    let inputs: Elements = try! lists.select("input")
                    
                    for input in inputs {
                        if try input.className() == "sub buyTicketBtn"{
                            self.cinemaID = try! input.attr("cinema-id")
                            print(self.cinemaID)
                            break
                        }
                    }
                    
                    for list in lists{
                        
                        
                        //get movie poster
                        if try list.className() == "desktop"{
                            
                            let divs: Elements = try! list.select("div")
                            
                            for div in divs {
                                
                                
                                if try div.className() == "center_info"{
                                    //Get on show movie name
                                    let h3: Elements = try! div.select("h3")
                                    if try h3.text() == self.movieName{
                                        //print("h3 == moviename")
                                        let options: Elements = try! div.select("option")
                                        
                                        //print("handleUA: \(Thread.current)")
                                        try! self.realm.write {
                                            self.realm.deleteAll()
                                        }
                                        
                                        
                                        for option in options {
                                            //print(try option.val())
                                            
                                            let sessionFeed = SessionFeed()
                                            
                                            let sessionStr: String = try option.text()
                                            if sessionStr != "---------------------------------------------------------"{
                                                
                                                let sessionStrArr1 = sessionStr.components(separatedBy: ", ")
                                                
                                                sessionFeed.sessionID = try option.val()
                                                sessionFeed.movieName = self.movieName
                                                
                                                //get dayofWeek
                                                sessionFeed.movieOnShowDay = sessionStrArr1[0]
                                                print(sessionStrArr1[0])
                                                //get date
                                                sessionFeed.movieDate = sessionStrArr1[1]
                                                print(sessionStrArr1[1])
                                                //get second long string
                                                
                                                var sessionStrArr2 = sessionStrArr1[2].components(separatedBy: " ")
                                                //get time
                                                sessionFeed.movieTime = "\(sessionStrArr2[0]) \(sessionStrArr2[1])"
                                                print("\(sessionStrArr2[0]) \(sessionStrArr2[1])")
                                                //get House name
                                                if sessionStrArr2[3] != "HKD"{
                                                    sessionFeed.movieOnShowHouse = "\(sessionStrArr2[2]) \(sessionStrArr2[3])"
                                                }else{
                                                    sessionFeed.movieOnShowHouse = "\(sessionStrArr2[2])"
                                                }
                                                print("\(sessionStrArr2[2]) \(sessionStrArr2[3])")
                                                //get adult price
                                                sessionFeed.movieAdultPrice = Int(sessionStrArr2[5]) ?? 0
                                                print(sessionStrArr2[5])
                                                //get format
                                                sessionStrArr2[6] = sessionStrArr2[6].replacingOccurrences(of: "(", with: "")
                                                sessionStrArr2[6] = sessionStrArr2[6].replacingOccurrences(of: ")", with: "")
                                                sessionFeed.movieFormat = sessionStrArr2[6]
                                                print(sessionStrArr2[6])
                                                
                                            }else{
                                                continue
                                            }
                                            
                                            try! self.realm.write {
                                                self.realm.add(sessionFeed)
                                            }
                                            
                                        }
                                        
                                        self.realmResults = self.realm.objects(SessionFeed.self)
                                        self.tableView.reloadData()
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    //self.dispatchGroup.leave()
                    
                }catch Exception.Error(type: let type, Message: let message){
                    print(type)
                    print(message)
                }catch{
                    print("")
                    
                    }}
                
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
