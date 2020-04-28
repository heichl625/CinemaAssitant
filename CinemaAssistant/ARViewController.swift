//
//  ARViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 17/1/2020.
//  Copyright © 2020 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import FirebaseDatabase
import Firebase
import AVFoundation
import FirebaseAuth

class ARViewController: UIViewController {
    
    @IBOutlet weak var favBtn: UIBarButtonItem!
    @IBOutlet weak var SeatStr: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    var row: String?
    var seatNum: String?
    var firebaseCinemaID: Int?
    var houseName: String?
    var houseID: String?
    var trailerURL: String?
    var rowArr: [String] = []
    var rowIndex: Int = 0
    var rowIsLoaded: Bool = false
    var isReversed: Bool = false
    
    var xDistance: Double = 0
    var yDistance: Double = 0
    var zDistance: Double = 0
    
    var player: AVPlayer!
    
    var ref: DatabaseReference!
    
    var trailerNode = SCNNode()
    
    
    let updateGroup = DispatchGroup()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        getSeatData()
        
        SeatStr.text = "\(row!)\(seatNum!)"
        print(trailerURL)
        
        //trailerURL = "https://www.mclcinema.com/\(trailerURL!)"
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        if Auth.auth().currentUser != nil{
            checkFav()
        }else{
            favBtn.tintColor = UIColor.white
        }
        
        
        
        self.sceneView.session.run(configuration)
        self.sceneView.scene.background.contents = UIImage(named: "cinema.png")
        // Do any additional setup after loading the view.
        
        
        if let unwrappedURL = trailerURL{
            let url = URL(string: unwrappedURL )
            player = AVPlayer(url: url!)
        }
        
        let trailerGeo = SCNPlane(width: 7, height: 4.5)
        trailerGeo.firstMaterial?.diffuse.contents = player
        trailerGeo.firstMaterial?.isDoubleSided = true
        
        trailerNode = SCNNode(geometry: trailerGeo)
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
    }
    
    func getSeatData(){
        //print("CinemaID: \(firebaseCinemaID)")
        
        var houseCount: Int?
        
        
        let group = DispatchGroup()
        
        //rowArr.removeAll()
        
        ref.child("cinema").child("\(firebaseCinemaID!)").child("house").observeSingleEvent(of: .value, with: { snapshot in
            
            group.enter()
            print("entered")
            
            let value = snapshot.value as? NSArray
            
            houseCount = value!.count-1
            print("houseCount: \(houseCount)")
            
            group.leave()
            print("leave")
            
            group.notify(queue: .main){
                
                for n in 1...houseCount!{
                    
                    self.ref.child("cinema").child("\(self.firebaseCinemaID!)").child("house").child("\(n)").observeSingleEvent(of: .value, with: { snapshot in
                        
                        let value = snapshot.value as? NSDictionary
                        
                        //print(value)
                        
                        if value?.value(forKey: "houseName") as? String == self.houseName{
                            
                            self.houseID = "\(n)"
                            self.checkReverseOrder()
                            
                            
                            if self.rowIsLoaded == false {
                                
                                
                                self.ref.child("cinema").child("\(self.firebaseCinemaID!)").child("house").child("\(n)").child("seat").observeSingleEvent(of: .value, with: { snapshot in
                                    
                                    
                                    let value = snapshot.value as? NSDictionary
                                    
                                    let keys = value?.allKeys as! [String]
                                    
                                    self.rowArr = keys.sorted(by: <)
                                    
//                                    for k in sortedKeys {
//                                        self.rowArr.append(k)
//                                    }
                                    
                                    print(self.rowArr)
                                    self.rowIsLoaded = true
                                    
                                    self.getRowNum()
                                    
                                })
                            }
                            self.ref.child("cinema").child("\(self.firebaseCinemaID!)").child("house").child("\(n)").child("seat").child(self.row!).child(self.seatNum!).observeSingleEvent(of: .value, with: { snapshot in
                                
                                let value = snapshot.value as? NSDictionary
                                
                                if value == nil{
                                    
                                    let alertController = UIAlertController(title: "Seat not found", message: "There is no such seat", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    
                                }else{
                                    
                                    self.xDistance = value?.value(forKey: "x") as! Double
                                    self.yDistance = value?.value(forKey: "y") as! Double
                                    self.zDistance = value?.value(forKey: "z") as! Double
                                    
                                    print("x: \(self.xDistance)")
                                    print("z: \(self.zDistance)")
                                    self.trailerNode.position = SCNVector3(self.xDistance, self.yDistance, self.zDistance)
                                    self.sceneView.scene.rootNode.addChildNode(self.trailerNode)
                                    self.player.play()
                                }
                                
                            })
                            
                        }
                    })
                }
            }
            
        })
        
        
        
        
        
    }
    
    //    func addTrailer(){
    //
    //
    //
    //
    //    }
    
    
    @IBAction func upBtnPressed(_ sender: UIButton) {
        
        print("btnPressed: \(rowArr)")
        print("btnPressed: \(row)")
        print("btnPressed: \(rowIndex)")
        
        if self.rowIndex > 0{
            self.row = self.rowArr[self.rowIndex-1]
            rowIndex -= 1
        }
        
        self.getSeatData()
        self.updateSeatLabel()
        
        
        //        switch row {
        //        case "AA":
        //            row = "AA"
        //        case "A":
        //            row = "AA"
        //        case "B":
        //            row = "A"
        //        case "C":
        //            row = "B"
        //        case "D":
        //            row = "C"
        //        case "E":
        //            row = "D"
        //        case "F":
        //            row = "E"
        //        case "G":
        //            row = "F"
        //        default:
        //            break
        //
        //        }
        
        
        
    }
    @IBAction func rightBtnPressed(_ sender: UIButton) {
        
        if !isReversed{
            seatNum = String(Int(seatNum!)! + 1)
        }else{
            seatNum = String(Int(seatNum!)! - 1)
        }
        
        print("isReversed: \(checkReverseOrder())")
        getSeatData()
        updateSeatLabel()
        
    }
    @IBAction func downBtnPressed(_ sender: UIButton) {
        
        //getRowNum()
        
        
        if rowIndex < rowArr.count-1{
            row = rowArr[rowIndex+1]
            rowIndex += 1
        }
        
        //        switch row {
        //        case "AA":
        //            row = "A"
        //        case "A":
        //            row = "B"
        //        case "B":
        //            row = "C"
        //        case "C":
        //            row = "D"
        //        case "D":
        //            row = "E"
        //        case "E":
        //            row = "F"
        //        case "F":
        //            row = "G"
        //        default:
        //            break
        //
        //        }
        getSeatData()
        updateSeatLabel()
        
    }
    @IBAction func leftBtnPressed(_ sender: UIButton) {
        
        if !isReversed{
            seatNum = String(Int(seatNum!)! - 1)
        }else{
            seatNum = String(Int(seatNum!)! + 1)
        }
        
        print("isReversed: \(checkReverseOrder())")
        getSeatData()
        updateSeatLabel()
        
    }
    
    
    func checkReverseOrder() {
        
        print("houseID: \(houseID)")

        ref.child("cinema").child("\(firebaseCinemaID!)").child("house").child(houseID!).child("isReversed").observeSingleEvent(of: .value, with: { snapshot in
            
            let value = snapshot.value as! Bool
            
            print(value)
            
            self.isReversed = value
            
        })

        

    }
    
    func getRowNum(){
        
        
        
        for n in 0..<rowArr.count{
            
            if row == rowArr[n]{
                
                rowIndex = n
                
            }
            
        }
        
        
    }
    
    //ref.child("cinema").child("4").child("house").child("1").child("seat").child(row).child("\(n)").child("x").setValue(xDistance)
    
    func updateSeatLabel(){
        
        SeatStr.text = "\(row!)\(seatNum!)"
        checkFav()
        
    }
    
    @IBAction func favBtnPressed(_ sender: UIBarButtonItem) {
        
        //firebaseCinemaID, houseName
        //row + seatNum
        
        if let id = UserDefaults.standard.object(forKey: "uid"){
            
            let seat = "\(row!)\(seatNum!)"
            
            if favBtn.tintColor == UIColor.white{
                
                ref.child("users").child(id as! String).child("favSeat").child("\(firebaseCinemaID!)").child(houseName!).setValue(seat)
                
                favBtn.tintColor = UIColor(red:0.92, green:0.30, blue:0.29, alpha:1.0)
                
            }else{
                
                ref.child("users").child(id as! String).child("favSeat").child("\(firebaseCinemaID!)").child(houseName!).removeValue()
                favBtn.tintColor = UIColor.white
                
            }
            
            
            
        }else{
            
            let alertController = UIAlertController(title: "Login First", message: "Please login first to save your seat preference", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Login", style: .default, handler: { action in
                
                self.performSegue(withIdentifier: "showLoginFromAR", sender: self)
                
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(alertController, animated: true)
            
        }
        
        
    }
    
    func checkFav(){
        
        ref.child("users").child(UserDefaults.standard.object(forKey: "uid") as! String).child("favSeat").child("\(firebaseCinemaID!)").child(houseName!).observeSingleEvent(of: .value, with: { snapshot in
            
            let value = snapshot.value as? String
            
            if value != "\(self.row!)\(self.seatNum!)" || value == nil{
                
                self.favBtn.tintColor = UIColor.white
                
            }else{
                
                self.favBtn.tintColor = UIColor(red:0.92, green:0.30, blue:0.29, alpha:1.0)
                
            }
        })
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

