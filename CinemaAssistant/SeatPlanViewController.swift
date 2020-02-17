//
//  SeatPlanViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 16/2/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import WebKit

class SeatPlanViewController: UIViewController, WKNavigationDelegate {

    var houseName: String?
    var format: String?
    var time: String?
    var adultPrice: Int?
    var childPrice: Int?
    var seniorPrice: Int?
    var studentPrice: Int?
    var movieName: String?
    
    var cinemaID: String?
    var sessionID: String?

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
        let seatPlanURL = URL(string: "https://www.mclcinema.com/SeatPlan.aspx?visLang=2&ci=\(cinemaID!)&si=\(sessionID!)")!
        webView.load(URLRequest(url: seatPlanURL))

    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            
            let css = "body { background-color : #121212; color : white;  width : 100%; height : 100% } table { margin: 0 auto; width: 80%;  height : 100%;  font-size : 25px }"
            
            let js = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            
            webView.evaluateJavaScript(js, completionHandler: nil)
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
