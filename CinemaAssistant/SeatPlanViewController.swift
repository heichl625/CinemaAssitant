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
import SwiftyJSON
import Alamofire
import FirebaseDatabase
import FirebaseAuth
import Firebase
import SwiftSoup
import YoutubeDirectLinkExtractor

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
    var chosenRow: String?
    var chosenSeat: String?
    var firebaseCinemaID: Int?
    var trailerURL: String?
    var date: String?
    var price: String?
    var youtubeURL: String?
    
    
    var cinemaID: String?
    var sessionID: String?
    
    var seatPlanURL: URL?
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var houseText: UILabel!
    @IBOutlet weak var timeText: UILabel!
    @IBOutlet weak var adultPriceText: UILabel!
    @IBOutlet weak var studentPriceText: UILabel!
    @IBOutlet weak var childPriceText: UILabel!
    @IBOutlet weak var seniorPriceText: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var favSeatStr: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.title = movieName!
        getPrice()
        getTrailerURL()
        ref = Database.database().reference()
        
        
        switch(cinemaGroup){
            
            //        case "UA":
            //
            //            houseText.text = "\(houseName!) (\(format!))"
            //
            //            timeText.text = "Time: \(time!)"
            //
            //            if adultPrice != 0 {
            //                adultPriceText.text = "Adult: $\(adultPrice!)"
            //            }else {
            //                adultPriceText.text = "Adult: N/A)"
            //            }
            //            if studentPrice != 0{
            //                studentPriceText.text = "Student: $\(studentPrice!)"
            //            }else{
            //                studentPriceText.text = "Student: N/A"
            //            }
            //            if childPrice != 0{
            //                childPriceText.text = "Child: $\(childPrice!)"
            //            }else{
            //                childPriceText.text = "Child: N/A"
            //            }
            //            if seniorPrice != 0 {
            //                seniorPriceText.text = "Senior: $\(seniorPrice!)"
            //            }else{
            //                seniorPriceText.text = "Senior: N/A"
            //            }
            
            
        default:
            houseText.text = "\(houseName!)"
            timeText.text = "時間: \(time!)"
            
        }
        
        webView.navigationDelegate = self
        
        switch(cinemaGroup){
            
            //        case "MCL":
            //            let contentController = WKUserContentController()
            //            //width: 350px; max-height : 100%
            //            //width: 350px; height: 100%
            //            let css = "html, body { background : #121212; color: white } table { margin: 0 auto; background-color: #121212; max-width: 1125px; max-height: 1800px } table tr { max-height: 100%; max-width: 100% } table tr td { max-height: 100%; max-width: 100% } table  tr  td  img { max-width: 6px; max-height: 6px} table  tr  td  p { font-size: 7px } .Seating-RowLabel{ font-size: 7px}"
            //
            //            let scriptSource = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            //
            //            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            //            contentController.addUserScript(script)
            //            webView.configuration.userContentController.addUserScript(script)
            //            webView.frame = self.view.bounds
            //
            //            self.seatPlanURL = URL(string: "https://www.mclcinema.com/SeatPlan.aspx?visLang=2&ci=\(cinemaID!)&si=\(sessionID!)")
            //        case "UA":
            //            getUASeatPlan()
            //
            //            let contentController = WKUserContentController()
            //            let css = "html, body { background : #121212; width: 100%; height : 100% } table { background-color: #121212; width : 100%; height: 20vh; font-size : 25px;}"
            //            let scriptSource = "document.getElementsByClassName(\"page_title\")[0].style.display = 'none'; document.getElementsByClassName(\"tableBG\")[0].style.display = 'none'; document.getElementsByClassName(\"tableBG\")[1].style.display = 'none'; document.getElementsByClassName(\"termsBG\")[1].style.display = 'none'; document.getElementsByClassName(\"termsBG\")[2].style.display = 'none'; document.getElementsByClassName(\"footer\")[0].style.display = 'none'; document.getElementsByClassName(\"pageBG\")[0].style.background = '#121212'; document.getElementById(\"seatPlanRemarkRow\").style.background = '#121212'; document.getElementsByClassName(\"seatRemarkDesc\")[0].style.background = '#121212'; document.getElementById(\"seatPlanContainer\").style.background = '#121212'; document.getElementById(\"seatPlanRemarkAndZoomRow\").style.background = '#121212'; document.getElementsByClassName(\"ua_copyright\")[1].style.display = 'none'; var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            //            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            //            contentController.addUserScript(script)
            //            webView.configuration.userContentController.addUserScript(script)
            //
        //            self.seatPlanURL = URL(string: "https://www.uacinemas.com.hk/eng/ticketing/overview?cid=\(cinemaID!)&sid=\(sessionID!)")
        case "GoldenHarvest":
            
            let contentController = WKUserContentController()
            let css = "html {background: #121212}, header {height: 0px} body { background : #121212 } .layui-layer-shade {display: none} .layui-layer.layui-layer-dialog.layer-anim { display: none } .Seating_plan_preview .seat-choose {background: #121212} .ticket-class { display: none } .sort.content { display: none }"
            let scriptSource = "document.getElementsByClassName('content login-bar mobile-hide')[0].style.display = \"none\"; document.getElementsByClassName('mobile-bar desktop-hide')[0].style.display = \"none\"; document.getElementsByClassName('logo-menu content logo-menu-hide')[0].style.display = \"none\"; document.getElementsByClassName('seacher-bar seacher-bar-hide desktop-hide content')[0].style.display = \"none\"; document.getElementsByClassName('popup-common hide')[0].style.display = \"none\"; document.getElementsByClassName('grade-title content mobile-hide')[0].style.display = \"none\"; document.getElementsByClassName('Seating_plan_preview_head content')[0].style.display = \"none\"; document.getElementsByClassName('Seating_plan_preview-btn content')[0].style.display = \"none\"; document.getElementsByClassName('footer-menu content mobile-hide')[0].style.display = \"none\"; document.getElementsByClassName('footer-copyright')[0].style.display = \"none\"; var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style)"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
        case "Broadway":
            let contentController = WKUserContentController()
            let css = "#header { display: none } body { background: #121212 } .mainmenu-row { display: none } .helpStep { display: none } .showInfo, .fnbDesc { display: none } .seatPlanArea { background-color: #121212 } .seatPlanArea.container { padding-left: 0px; padding-right: 0px } .mobile.legend.row { border-bottom-color: #121212; background: #121212; margin-bottom: 0px; margin-left: 0px; margin-right: 0px; margin-top: 0px } .mobile.legend .item {display: none }  #seatPlanTable { background-color: #121212 } .beforeShowNotice{ display: none } .template-login-container { display: none } .gift-card-main-container .gift-card-set-password-row-container, .template-login-wrapper .gift-card-set-password-row-contain { display: none } #footer { display: none } .mobile-footer { display: none } .mobile-header-bar { display: none } .mobile-header { display: none } .gift-card-main-container .gift-card-set-password-row-container, .template-login-wrapper .gift-card-set-password-row-container {display: none} .seatPlanArea { background: #121212 } span.movieScreen { color: white }"
            let scriptSource = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style)"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            
        case "Metroplex":
            let contentController = WKUserContentController()
            let css = "#header {display:none} body{ background:#121212} #movieDesc { display: none } #page {padding-bottom:0px} #cinemaLegend {display:none} .purple_btn {display:none} #ticketingNotice {display:none} #footer-container {display: none} #footer{display:none} "
            let scriptSource = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style)"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            webView.isUserInteractionEnabled = false
            
        case "Newport":
            let contentController = WKUserContentController()
            let css = "#mobileInnerHeader{display:none} #mobileHeader.navbar-header{display:none} .topGreenLine{display:none} #movieInfoSec{display:none} #cinemaLegend {display: none} #seatPlan_submit_btn {display:none} #ticketingNotice {display:none} #mobileFooter.mobile{display:none} #stage {background:#121212; margin: 0px} table#seatPlanTable {background:#121212; border:0} tr#legendRow {height:0px} html,body {background: #121212 !important} body {background:#121212} #seatPlanRow{background:#121212}"
            let scriptSource = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style)"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            webView.isUserInteractionEnabled = false
            
        case "CinemaCity":
            let contentController = WKUserContentController()
            let css = ".siteOverlay {display:none} div.header {display:none} .mobile_view {display:none} .show_remarks {display:none} body{background:#121212} .seatplan_viewport {background: #121212} .nav_bar{ display:none} .seatplan_popup, .cc_popup {display:none !important} .dbox_popup{display:none !important} td {font-size: 0} .movieScreen_TC { top: 560px }"
            let scriptSource = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style)"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            webView.isUserInteractionEnabled = false
            
        case "CGV":
            let contentController = WKUserContentController()
            let css = ".selected-movie{display:none !important} div.legend{display:none} .reminder{display:none !important} footer{display:none} body{background:#121212} .centerContent{background:#121212} .seat-wrap.fitted{background:#121212} body#seat{padding-top:10px}"
            let scriptSource = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style)"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            webView.isUserInteractionEnabled = false
            
        case "MCL":
            let contentController = WKUserContentController()
            let css = ".image-lightbox {display:none} #dvMobileMsg{display:none !important} head {display: none} header{display: none; min-width: 80vw; width: 80vw} nav{display:none} header+nav {width:80vw !important}.notice-info{display:none} .buttons.container{display:none} .session-selection{display:none} .breadcrumb{display:none} .ticket-progress.container {display:none} .col-xs-12.text-center {display:none} .inner-container{display:none} footer {min-width:80vw} body{background:#121212; width: 100%; height: auto; margin: 0} td{color:white !important} main{padding-top:0px; min-width: 100%; min-height:auto} .text-center{display:none} .Seating-Area{width:100%; height: auto} table{width:100%; height: auto;} html{min-width: 100%; min-height:auto} .message{margin:0} .top-visual.swiper.swiper-container-horizontal{display:none} img {width: 100%; height: auto}"
            let scriptSource = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style); var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            //webView.frame = self.view.bounds
            //webView.scale = self.view.frame.width
            // webView.isUserInteractionEnabled = false
            
        case "UA":
            let contentController = WKUserContentController()
            let css = ".modal-dialog {display:none} .modal.bootstrap-dialog.type-default.fade.size-normal.in {display:none} .modal-backdrop.fade.in {display:none} .page_title{display:none} .tableBG{display:none} #seatPlanRemarkAndZoomRow.row{display:none} .terms_title{display:none} .terms_content{display:none} .termsBG{background:#121212} .ua_copyright{display:none} .pageBG{background:#121212} svg{background-color:#121212 !important} #seatPlanContainer{background:#121212}"
            let scriptSource = "var style = document.createElement('style'); style.innerHTML = '\(css)'; document.head.appendChild(style);"
            
            let script = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            contentController.addUserScript(script)
            webView.configuration.userContentController.addUserScript(script)
            
            
        default:
            break
            
        }
        //webView.frame.size = webView.scrollView.contentSize
        webView.load(URLRequest(url: self.seatPlanURL!))
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getSeatPref()
    }
    
    //    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    //        webView.frame.size.width = 1
    //        webView.scrollView.contentSize =  webView.frame.size
    //    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAR" {
            
            if let destionationVC = segue.destination as? ARViewController {
                
                destionationVC.row = self.chosenRow
                destionationVC.seatNum = self.chosenSeat
                destionationVC.firebaseCinemaID = self.firebaseCinemaID
                destionationVC.houseName = self.houseName
                destionationVC.trailerURL = self.trailerURL
                
            }
            
        }
    }
    
    @IBAction func ARBtnPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Choose Your Seat", message: "", preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Row"})
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.placeholder = "Seat Number"})
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            self.chosenRow = alertController.textFields![0].text
            self.chosenSeat = alertController.textFields![1].text
            self.performSegue(withIdentifier: "showAR", sender: self)
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(alertController, animated: true)
        
    }
    
    func getPrice(){
        
        print("Getting price")
        
        switch(cinemaGroup){
            
        case "GoldenHarvest":
            let url = "\(seatPlanURL!)"
            
            print("url: \(url)")
            
            var showID = url.suffix(6)
            
            print("showID: \(showID)")
            
            var ghURL = URL(string: "https://www.goldenharvest.com/seatPlan/index?type=read&film_show_id=\(showID)&from_type=web")
            
            if cinemaID == "53"{
                showID = url.suffix(5)
                ghURL = URL(string: "https://www.theskycinema.com/seatPlan/index?type=read&film_show_id=\(showID)&from_type=web")
            }
            
            
            
            DispatchQueue.global(qos: .background).async {
                
                let task = URLSession.shared.dataTask(with: ghURL!){ (data, response, error) in
                    
                    if error != nil {
                        print(error)
                    }else{
                        
                        do{
                            
                            let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            let doc: Document = try SwiftSoup.parse(html! as String)
                            
                            let us: Elements = try! doc.select("u")
                            
                            var prices: [String] = []
                            
                            for u in us{
                                
                                let word = try! u.text()
                                
                                if let index = word.range(of: "$")?.lowerBound{
                                    
                                    let subString = word.suffix(from: index)
                                    
                                    let dollor = String(subString)
                                    
                                    prices.append(dollor)
                                    
                                    //print(dollor)
                                    
                                }
                            }
                            
                            DispatchQueue.main.async {
                                self.adultPriceText.text = "成人: \(prices[0])"
                                if prices.count < 2{
                                    self.childPriceText.text = "小童： N/A"
                                    self.studentPriceText.text = "學生： N/A"
                                }else{
                                    self.childPriceText.text = "小童: \(prices[1])"
                                    self.studentPriceText.text = "學生： \(prices[1])"
                                }
                                if prices.count < 3{
                                    self.seniorPriceText.text = "長者： N/A"
                                }else{
                                    self.seniorPriceText.text = "長者: \(prices[2])"
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
                
                task.resume()
                
            }
        case "Broadway":
            
            print("Broadway")
            
            let id = "\(seatPlanURL!)".replacingOccurrences(of: "https://www.cinema.com.hk/tc/ticketing/seatplan/", with: "")
            
            let bwURL = URL(string: "https://www.cinema.com.hk/tc/site/setNonMember?redirectUrl=https%3A%2F%2Fwww.cinema.com.hk%2Ftc%2Fticketing%2Fseatselection%2F\(id)")
            
            print(bwURL)
            
            DispatchQueue.global(qos: .background).async {
                
                let task = URLSession.shared.dataTask(with: bwURL!) { (data, response, error) in
                    
                    if error != nil{
                        //print(error)
                    }else{
                        
                        do{
                            
                            let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                            let doc: Document = try SwiftSoup.parse(html! as String)
                            
                            //print(doc)
                            
                            let divs: Elements = try! doc.select("div")
                            
                            for div in divs{
                                
                                if try! div.className() == "ticketType" {
                                    
                                    let text = try! div.text()
                                    
                                    var start = text.index(text.startIndex, offsetBy: 7)
                                    let end = text.index(text.endIndex, offsetBy: -3)
                                    var range = start..<end
                                    
                                    var price = text[range]
                                    
                                    if text.contains("成人"){
                                        DispatchQueue.main.async{
                                            self.adultPriceText.text = "成人： \(String(price))"
                                        }
                                    }
                                    if text.contains("學生"){
                                        DispatchQueue.main.async{
                                            self.studentPriceText.text = "學生： \(String(price))"
                                        }
                                    }
                                    if text.contains("長者"){
                                        DispatchQueue.main.async{
                                            self.seniorPriceText.text = "長者： \(String(price))"
                                        }
                                    }
                                    if text.contains("小童"){
                                        DispatchQueue.main.async{
                                            self.childPriceText.text = "小童： \(String(price))"
                                        }
                                    }
                                    if text.contains("早場"){
                                        
                                        DispatchQueue.main.async{
                                            
                                            self.adultPriceText.text = "成人： \(String(price))"
                                            self.studentPriceText.text = "學生： N/A"
                                            self.childPriceText.text = "小童： N/A"
                                            
                                        }
                                    }
                                    if text.contains("首場長者優惠"){
                                        
                                        start = text.index(text.startIndex, offsetBy: 11)
                                        range = start..<end
                                        price = text[range]
                                        
                                        DispatchQueue.main.async{
                                            self.seniorPriceText.text = "長者： \(String(price))"
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                            
                        }catch Exception.Error(type: let type, Message: let message){
                            
                            //print(type)
                            //print(message)
                            
                        }catch{
                            print("")
                        }
                        
                    }
                    
                }
                
                task.resume()
                
            }
        case "Metroplex":
            
            
            if time!.contains("AM"){
                
                childPriceText.text = "小童: N/A"
                seniorPriceText.text = "長者: N/A"
                studentPriceText.text = "學生: N/A"
                
                if houseName!.contains("貴賓院"){
                    adultPriceText.text = "成人: $120"
                }else{
                    adultPriceText.text = "成人: $45"
                }
                
            }else{
                
                childPriceText.text = "小童: $50"
                seniorPriceText.text = "長者: $50"
                studentPriceText.text = "學生: $50"
                
                if getDayOfWeek(date!) == 3 && !houseName!.contains("貴賓院"){
                    adultPriceText.text = "成人: $60"
                }else if houseName!.contains("貴賓院"){
                    adultPriceText.text = "成人: $220"
                    childPriceText.text = "小童: N/A"
                    seniorPriceText.text = "長者: N/A"
                    studentPriceText.text = "學生: N/A"
                }else{
                    adultPriceText.text = "成人: $85"
                }
                
            }
        case "Newport":
            
            let alertController = UIAlertController(title: "注意", message: "優惠票價未能於網上提供, 詳情請到影院查詢", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            present(alertController, animated: true)
            
            if time!.contains("12:") || time!.contains("11:") {
                
                adultPriceText.text = "成人: $60"
                
            }else{
                
                adultPriceText.text = "成人: $90"
                
            }
            
            childPriceText.text = "小童: N/A"
            seniorPriceText.text = "長者: N/A"
            studentPriceText.text = "學生: N/A"
            
        case "CinemaCity", "CGV":
            let alertController = UIAlertController(title: "注意", message: "優惠票價未能於預覽時提供, 詳情請到影院網站查閱", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
            present(alertController, animated: true)
            
            adultPriceText.text = "成人: \(self.price!)"
            childPriceText.text = "小童: N/A"
            seniorPriceText.text = "長者: N/A"
            studentPriceText.text = "學生: N/A"
            
        case "MCL":
            //"https://www.mclcinema.com/MCLOpenAPI/en-US/MovieDetail/www/Movie/\(movieID)/Version/\(movieDetailID)/Cinema/\(cinemaID)"
            
            var movieID: String?
            var movieDetailID: String?
            
            let group0 = DispatchGroup()
            
            group0.enter()
            
            let sessionString = "\(seatPlanURL!)".replacingOccurrences(of: "https://www.mclcinema.com/MCLSelectSeat.aspx?si=", with: "")
            let sID = String(sessionString.prefix(5))
            print(sID)
            
            group0.leave()
            group0.notify(queue: .main){
                let cinemaString = "\(self.seatPlanURL!)".replacingOccurrences(of: "https://www.mclcinema.com/MCLSelectSeat.aspx?si=\(sID)&ci=", with: "")
                print(cinemaString)
                let cinemaID = String(cinemaString.prefix(3))
                print(cinemaID)
            }
            
            
            let group = DispatchGroup()
            
            group.enter()
            print("Entered")
            
            let task = URLSession.shared.dataTask(with: self.seatPlanURL!){ (data, response, error) in
                
                if error != nil{
                    print(error!)
                }else{
                    
                    do{
                        
                        let html = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        let doc: Document = try SwiftSoup.parse(html! as String)
                        
                        let As: Elements = try! doc.select("a")
                        
                        for a in As{
                            if try! a.className() == "news-button custom-btn style-1 alt" {
                                movieID = try! a.attr("data-value")
                                print(movieID)
                                break
                            }
                        }
                        
                        let option: Element = try! doc.select("option").last()!
                        
                        movieDetailID = try! option.attr("value")
                        
                        print(movieDetailID)
                        
                        group.leave()
                        print("left")
                        
                        group.notify(queue: .main){
                            AF.request("https://www.mclcinema.com/MCLOpenAPI/en-US/MovieDetail/www/Movie/\(movieID ?? "")/Version/\(movieDetailID ?? "")/Cinema/\(self.cinemaID)").responseJSON{ response in
                                
                                switch (response.result){
                                
                                case let .success(value):
                                    
                                    let jsonResult = JSON(value)
                                    
                                    
                                    for n in 0..<jsonResult["MovieSessions"].count{
                                    
                                        print(jsonResult["MovieSessions"][n]["SessionID"].stringValue)
                                    
                                        if jsonResult["MovieSessions"][n]["SessionID"].stringValue == sID{
                                    
                                                print("inside if")
                                    
                                                DispatchQueue.main.async{
                                                    self.adultPriceText.text = "成人: $\(jsonResult["MovieSessions"][n]["AdultPrice"].stringValue)"
                                                    self.childPriceText.text = "小童： $\(jsonResult["MovieSessions"][n]["ChildPrice"].stringValue)"
                                                    self.studentPriceText.text = "學生： $\(jsonResult["MovieSessions"][n]["StudentPrice"].stringValue)"
                                                    self.seniorPriceText.text = "長者： $\(jsonResult["MovieSessions"][n]["SeniorPrice"].stringValue)"
                                                }
                                    
                                                break
                                        }
                                    
                                    }
                                    
                                case let .failure(error):
                                    print(error)
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
            task.resume()
            
        case "UA":
            DispatchQueue.global(qos: .background).async {
                let task = URLSession.shared.dataTask(with: self.seatPlanURL!){ (data, response, error) in
                    
                    print("inside ua case")
                    
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
                                            print(trArr[0])
                                            
                                            switch (trArr[0]){
                                                
                                            case "成人":
                                                self.adultPrice = Int(trArr[2])
                                                
                                                DispatchQueue.main.async {
                                                    self.adultPriceText.text = "成人: $\(self.adultPrice!)"
                                                }
                                                
                                            case "長者":
                                                self.seniorPrice = Int(trArr[2])
                                                
                                                DispatchQueue.main.async {
                                                    self.seniorPriceText.text = "長者: $\(self.seniorPrice!)"
                                                }
                                                
                                            case "小童":
                                                self.childPrice = Int(trArr[2])
                                                
                                                DispatchQueue.main.async {
                                                    self.childPriceText.text = "小童: $\(self.childPrice!)"
                                                }
                                                
                                            case "學生":
                                                self.studentPrice = Int(trArr[2])
                                                
                                                DispatchQueue.main.async {
                                                    self.studentPriceText.text = "學生: $\(self.studentPrice!)"
                                                }
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
            
            
        default:
            break
            
        }
        
    }
    
    func getSeatPref(){
        
        if let id = UserDefaults.standard.object(forKey: "uid"){
            
            ref.child("users").child(id as! String).child("favSeat").child("\(firebaseCinemaID!)").child(houseName!).observeSingleEvent(of: .value, with: { snapshot in
                
                let value = snapshot.value as? String
                
                if value != nil{
                    
                    self.favSeatStr.text = value
                    
                }else{
                    
                    self.favSeatStr.text = "No Preference"
                    
                }
                
            })
            
        }else{
            
            self.favSeatStr.text = "Login First"
            
        }
        
    }
    
    func getDayOfWeek(_ day:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let dayDate = formatter.date(from: day) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: dayDate)
        return weekDay
    }
    
    
    func getTrailerURL(){
        let y = YoutubeDirectLinkExtractor()
        
        if let url = youtubeURL{
            y.extractInfo(for: .urlString(url), success: { info in
                self.trailerURL = info.highestQualityPlayableLink
                print(self.trailerURL)
            }) { error in
                print(error)
            }
        }
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
