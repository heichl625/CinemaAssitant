//
//  SeatPlanViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 16/2/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

class SeatPlanViewController: UIViewController, WKNavigationDelegate {
    
    var houseName: String?
    var format: String?
    var time: String?
    var adultPrice: Int?
    var childPrice: Int?
    var seniorPrice: Int?
    var studentPrice: Int?
    var movieName: String?
    var cinemaGroup: String?
    
    var cinemaID: String?
    var sessionID: String?
    
    var seatPlanURL: URL?
    
    @IBOutlet weak var houseText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var adultPriceText: UILabel!
    @IBOutlet weak var studentPriceText: UILabel!
    @IBOutlet weak var childPriceText: UILabel!
    @IBOutlet weak var seniorPriceText: UILabel!
    @IBOutlet weak var webView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = movieName!
        
        houseText.text = "\(houseName!) (\(format!))"
        
        timeText.text = "Time: \(time!)"
        
        if adultPrice != 0 {
            adultPriceText.text = "Adult: $\(adultPrice!)"
        }else {
            adultPriceText.text = "Adult: N/A)"
        }
        if studentPrice != 0{
            studentPriceText.text = "Student: $\(studentPrice!)"
        }else{
            studentPriceText.text = "Student: N/A"
        }
        if childPrice != 0{
            childPriceText.text = "Child: $\(childPrice!)"
        }else{
            childPriceText.text = "Child: N/A"
        }
        if seniorPrice != 0 {
            seniorPriceText.text = "Senior: $\(seniorPrice!)"
        }else{
            seniorPriceText.text = "Senior: N/A"
        }
        
        webView.navigationDelegate = self
        
        switch(cinemaGroup){
            
        case "MCL":
            let contentController = WKUserContentController()
            //width: 350px; max-height : 100%
            //width: 350px; height: 100%
            let css = "html, body { background : #121212; color: white } table { margin: 0 auto; background-color: #121212; max-width: 1125px; max-height: 1800px } table tr { max-height: 100%; max-width: 100% } table tr td { max-height: 100%; max-width: 100% } table  tr  td  img { max-width: 6px; max-height: 6px} table  tr  td  p { font-size: 7px } .Seating-RowLabel{ font-size: 7px}"

            let scriptSource = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            webView.frame = self.view.bounds
            
            self.seatPlanURL = URL(string: "https://www.mclcinema.com/SeatPlan.aspx?visLang=2&ci=\(cinemaID!)&si=\(sessionID!)")
        case "UA":
            getUASeatPlan()
            
            let contentController = WKUserContentController()
            let css = "html, body { background : #121212; width: 100%; height : 100% } table { background-color: #121212; width : 100%; height: 20vh; font-size : 25px;}"
            let scriptSource = "document.getElementsByClassName(\"page_title\")[0].style.display = 'none'; document.getElementsByClassName(\"tableBG\")[0].style.display = 'none'; document.getElementsByClassName(\"tableBG\")[1].style.display = 'none'; document.getElementsByClassName(\"termsBG\")[1].style.display = 'none'; document.getElementsByClassName(\"termsBG\")[2].style.display = 'none'; document.getElementsByClassName(\"footer\")[0].style.display = 'none'; document.getElementsByClassName(\"pageBG\")[0].style.background = '#121212'; document.getElementById(\"seatPlanRemarkRow\").style.background = '#121212'; document.getElementsByClassName(\"seatRemarkDesc\")[0].style.background = '#121212'; document.getElementById(\"seatPlanContainer\").style.background = '#121212'; document.getElementById(\"seatPlanRemarkAndZoomRow\").style.background = '#121212'; document.getElementsByClassName(\"ua_copyright\")[1].style.display = 'none'; var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            
            self.seatPlanURL = URL(string: "https://www.uacinemas.com.hk/eng/ticketing/overview?cid=\(cinemaID!)&sid=\(sessionID!)")
        default:
            break
            
        }
        webView.load(URLRequest(url: self.seatPlanURL!))
        
        
        
    }
    
    func getUASeatPlan(){
        
        let url = URL(string: "https://www.uacinemas.com.hk/eng/ticketing/overview?cid=\(cinemaID!)&sid=\(sessionID!)")
        
        let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
            
            if error != nil {
                print(error)
            }else{
                
                DispatchQueue.main.async{
                    do {
                        
                        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        
                        
                        let doc: Document = try SwiftSoup.parse(html! as String)
                        
                        //Get UA ticket price
                        let tables: Elements = try! doc.select("table")
                        
                        for table in tables {
                            if try table.className() == "table_price"{
                                
                                let trs: Elements = try! table.select("tr")
                                
                                for tr in trs {
                                    
                                    let trStr = try tr.text()
                                    let trArr = trStr.components(separatedBy: " ")
                                    
                                    switch (trArr[0]){
                                        
                                    case "Regular":
                                        self.adultPrice = Int(trArr[2])
                                        self.adultPriceText.text = "Adult: $\(self.adultPrice!)"
                                    case "Senior":
                                        self.seniorPrice = Int(trArr[2])
                                        self.seniorPriceText.text = "Senior: $\(self.seniorPrice!)"
                                    case "Kid":
                                        self.childPrice = Int(trArr[2])
                                        self.childPriceText.text = "Child: $\(self.childPrice!)"
                                    case "Student":
                                        self.studentPrice = Int(trArr[2])
                                        self.studentPriceText.text = "Student: $\(self.studentPrice!)"
                                    default:
                                        break
                                        
                                    }
                                    
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
        }
        task.resume()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
