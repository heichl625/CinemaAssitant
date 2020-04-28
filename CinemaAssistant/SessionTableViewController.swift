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
import BTNavigationDropdownMenu


class MovieSession{
    
    var houseName: String?
    var onShowDate: String?
    var onShowTime: String?
    var purchaseURL: String?
    var price: String?
    
}

class SessionTableViewController: UITableViewController {
    
    var cinemaID: String?
    var movieID: String?
    var movieDetailID: String?
    var movieName: String?
    var cinemaGroup: String?
    var UASessionID: [String] = []
    var sessions: [MovieSession] = []
    var firebaseCinemaID: Int?
    var dataFetchingDate: String?
    var pendingDate: [String] = []
    var dropDownItem: [String] = []
    var youtubeURL: String?
    
    var realmResults:Results<SessionFeed>?
    let realm = try! Realm()
    
    let dispatchGroup = DispatchGroup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataFetchingDate)
        
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        //
        
        var dateComponent = DateComponents()
        
        dateComponent.day = 1
        
        var dateToProcess = currentDate
        
        //dropDownItem
        
        for n in 0..<3 {
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateStr = dateFormatter.string(from: dateToProcess)
            
            pendingDate.append(dateStr)
            
            if n == 0{
                dropDownItem.append("今天")
            }else if n == 1{
                dropDownItem.append("明天")
            }else{
                if cinemaGroup != "Newport"{
                    dropDownItem.append(dateStr)
                }
            }
            
            dateToProcess = Calendar.current.date(byAdding: dateComponent, to: dateToProcess)!
            
            
            
        }
        
        
        let menuView = BTNavigationDropdownMenu(navigationController: self.navigationController, containerView: self.navigationController!.view, title: BTTitle.title("今天"), items: dropDownItem)
        
        navigationItem.titleView = menuView
        
        menuView.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            
            self!.dataFetchingDate = self!.pendingDate[indexPath]
            self!.handleWebData()
            self!.tableView.reloadData()
            //self!.loadMovie()
            
            
        }
        
        menuView.cellSeparatorColor = menuView.cellBackgroundColor
        menuView.checkMarkImage = nil
        menuView.cellBackgroundColor = UIColor(red:0.06, green:0.06, blue:0.06, alpha:1.00)
        menuView.cellTextLabelColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        menuView.selectedCellTextLabelColor = UIColor(red:1.00, green:0.20, blue:0.20, alpha:1.00)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        handleWebData()
        
        
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

            if sessions.count > 0{
                return sessions.count
            }else{
                return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell", for: indexPath)
            
            if let houseName = cell.viewWithTag(100) as? UILabel {
                
                if sessions.count > 0{
                    
                    if cinemaGroup == "Lux"{
                        houseName.text = "Lux"
                    }else{
                        houseName.text = sessions[indexPath.row].houseName
                    }
                }
                
            }
            
            if let onShowTime = cell.viewWithTag(101) as? UILabel{
                
                if sessions.count > 0{
                    onShowTime.text = "\(sessions[indexPath.row].onShowDate!) \(sessions[indexPath.row].onShowTime!)"
                }
                
            }
            
            
        //print("cellforrow: \(Thread.current)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if cinemaGroup != "Lux"{
            performSegue(withIdentifier: "showSeatPlanFromSession", sender: self)
        }else{
            let alertController = UIAlertController(title: "抱歉", message: "影院並沒有提供座位資訊", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true)
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        if segue.identifier == "showSeatPlanFromSession" {
            
            if let destinationVC  = segue.destination as? SeatPlanViewController {
                
                destinationVC.firebaseCinemaID = self.firebaseCinemaID
                destinationVC.cinemaID = self.cinemaID
                destinationVC.cinemaGroup = self.cinemaGroup
                destinationVC.movieName = self.movieName
                destinationVC.houseName = self.sessions[indexPath!.row].houseName
                destinationVC.time = self.sessions[indexPath!.row].onShowTime
                destinationVC.seatPlanURL = URL(string: self.sessions[indexPath!.row].purchaseURL!)
                destinationVC.date = self.dataFetchingDate
                destinationVC.price = self.sessions[indexPath!.row].price
                destinationVC.youtubeURL = self.youtubeURL
                
                
                
            }
            
        }
        
    }
    
    func getTrailerURL(){
        
        let url = URL(string: "https://wmoov.com/movie/trailers/\(self.movieID!)")
        
        DispatchQueue.global(qos: .background).async{
            
            let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
            
                if error != nil{
                    print(error)
                }else{
                    
                    do{
                        
                        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        let doc: Document = try SwiftSoup.parse(html! as String)
                        
                        let iframe: Element = try! doc.select("iframe").first()!
                        
                        self.youtubeURL = try! iframe.attr("src")
                        
                        print(self.youtubeURL)
                        

                        
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
        
    }
    
    func handleWebData(){
        
        sessions.removeAll()
        
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        cell?.isUserInteractionEnabled = true
        
        
        let url = URL(string: "https://wmoov.com/cinema/movies/\(self.cinemaID!)?date=\(self.dataFetchingDate!)&movie=\(self.movieID!)")
        
        DispatchQueue.global(qos: .background).async {
            
            let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
                
                if error != nil {
                    print(error)
                }else{
                    
                    do{
                        
                        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        let doc: Document = try SwiftSoup.parse(html! as String)
                        
                        let trs: Elements = try! doc.select("tr")
                        
                        for tr in trs {
                            
                            if try! tr.className() == "even"{
                                
                                let session = MovieSession()
                                
                                let tds: Elements = try! tr.select("td")
                                session.houseName = try! tds.first()!.text()
                                for td in tds {
                                    if try! td.className() == "price"{
                                        session.price = try! td.text()
                                    }
                                }
                                
                                let acronym: Element = try! tr.select("acronym").first()!
                                session.onShowDate = try! acronym.attr("title")
                                session.onShowTime = try! acronym.text()
                                
                                let a: Element = try! tr.select("a").last()!
                                session.purchaseURL = try! a.attr("href")
                                
                                self.sessions.append(session)
                                print(self.sessions[self.sessions.count-1].houseName)
                                
                            }
                            
                            
                        }
                        
                        DispatchQueue.main.async {
                            
                            if self.sessions.count == 0{
                                let title = self.tableView.viewWithTag(100) as? UILabel
                                title!.text = "今天已經上映完畢"
                                
                                let subtitle = self.tableView.viewWithTag(101) as? UILabel
                                subtitle!.text = "請查看明天或打後的時間"
                                
                                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))
                                cell?.isUserInteractionEnabled = false
                            }
                            
                            self.tableView.reloadData()
                            
                            
                            
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
        
        getTrailerURL()
        
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
