//
//  MovieDetailViewController.swift
//  CinemaAssistant
//
//  Created by Cheuk Hei Lo on 30/12/2019.
//  Copyright © 2019 Cheuk Hei Lo. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics

class MovieDetailViewController: UIViewController {

    var movieTitle: String?
    var id: String?
    
    var imageURLStr: String?
    var overviewStr: String?
    var releaseDateStr: String?
    var posterPath: String?
    var castArr:[String] = []
    var castStr: String = ""
    var crewStr: String = ""
    var crewArr:[String] = []
    
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var overview: UITextView!
    @IBOutlet weak var director: UILabel!
    @IBOutlet weak var actor: UILabel!
    @IBOutlet weak var fav: UIBarButtonItem!
    
    var ref: DatabaseReference!
    
    var key: String = "c411a985e4c5562757a616894b03eadb"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        self.navigationItem.title = movieTitle
        ref = Database.database().reference()
        
       isFavourite()
        
        getMovieImageURL()
        getMovieCastAndCrew()
        releaseDate.text = "Release Date： \(releaseDateStr!)"
        overview.text = "Overview: \n\(overviewStr!)"
        
    }
    
    override func viewDidLayoutSubviews() {
        overview.sizeToFit()
        director.sizeToFit()
        actor.sizeToFit()
        releaseDate.sizeToFit()
    }
    
    func getMovieImageURL() {
        
        let url = "https://api.themoviedb.org/3/movie/\(id!)/images?api_key=\(key)"
        
        Alamofire.request(url, method: .get).validate().responseJSON {
            response in
            
            switch response.result {
                
            case .success(let value):
                //print("JSON GET MOVIE IMAGEURL SUCCESS")
                let jsonResults = JSON(value)
                self.imageURLStr = "https://image.tmdb.org/t/p/w500\(jsonResults["backdrops"][0]["file_path"])"
               
            case .failure(let error):
                print(error)
            }
            self.getMovieImage()
        }
    }
    
    func getMovieImage(){
        if let unwrappedURL = imageURLStr{
            Alamofire.request(unwrappedURL).responseData {
                response in
                //print("JSON GET MOVIE IMAGE SUCCESS")
                if let data = response.result.value {
                    self.movieImage.image = UIImage(data: data, scale:1)
                }
                
            }
        }
    }
    
    func getMovieCastAndCrew(){
        
        let url = "https://api.themoviedb.org/3/movie/\(id!)/credits?api_key=\(key)"
        
        Alamofire.request(url, method: .get) .validate().responseJSON {
            response in
            
            switch response.result {
                
            case .success(let value):
                
                //print("JSON GET MOVIE CAST AND CREW SUCCESS")
                let jsonResults = JSON(value)
                
                for n in 0...jsonResults["cast"].count-1{
                    self.castArr.append(jsonResults["cast"][n]["name"].stringValue)
                }
                //print("cast: \(self.castArr)")
                
                for n in 0...jsonResults["crew"].count-1{
                    if jsonResults["crew"][n]["job"].stringValue == "Director" {
                        self.crewArr.append(jsonResults["crew"][n]["name"].stringValue)
                    }
                }
                //print("crew: \(self.crewArr)")
            
            case .failure(let error):
                print(error)
                
            }
            
            if self.castArr.count != 0{
                
                if self.castArr.count <= 5{
                    for n in 0...self.castArr.count-1{
                        
                        if n != self.castArr.count-1 {
                            self.castStr += "\(self.castArr[n]), "
                        }else{
                            self.castStr += self.castArr[n]
                        }
                        
                    }
                }else{
                
                    for n in 0...5{
                        
                        if n != 5 {
                            self.castStr += "\(self.castArr[n]), "
                        }else{
                            self.castStr += self.castArr[n]
                        }
                    }
                }
                    //print("cast: \(self.castStr)")
                self.actor.text = "Actor: \(self.castStr)"
                print("Actor: \(self.castStr)")
                
            }
            
            if self.crewArr.count != 0{
                for n in 0...self.crewArr.count-1{
                    
                    if n != self.crewArr.count-1 {
                        self.crewStr += "\(self.crewArr[n]), "
                    }else{
                        self.crewStr += self.crewArr[n]
                    }
                }
                //print("crew: \(self.crewStr)")
                self.director.text = "Director: \(self.crewStr)"
                print("Director: \(self.crewStr)")
            }
            
        }
        
        
        
        
    }
    @IBAction func favouriteBtnPressed(_ sender: UIBarButtonItem) {
        
        if Auth.auth().currentUser == nil {
            
            let alertController = UIAlertController(title: "Login", message: "Please Login First.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                
                self.performSegue(withIdentifier: "showLoginFromMovieDetail", sender: self)
                
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alertController, animated: true)
            
        }else{
            
            let userid = Auth.auth().currentUser?.uid
            
            if fav.tintColor == UIColor(red:0.92, green:0.30, blue:0.29, alpha:1.0){
                
                ref.child("users").child("\(userid!)").child("favMovies").child(id!).removeValue()
                fav.tintColor = UIColor.white
                
            }else{
                ref.child("users").child("\(userid!)").child("favMovies").child(id!).child("movieTitle").setValue(movieTitle)
                ref.child("users").child("\(userid!)").child("favMovies").child(id!).child("releaseDate").setValue(releaseDateStr)
                ref.child("users").child("\(userid!)").child("favMovies").child(id!).child("imgURL").setValue(posterPath)
                ref.child("users").child("\(userid!)").child("favMovies").child(id!).child("overview").setValue(overviewStr)
                
                fav.tintColor = UIColor(red:0.92, green:0.30, blue:0.29, alpha:1.0)
            }
        }
        
    }
    
    func isFavourite(){
        
        if Auth.auth().currentUser != nil {
            let userid = Auth.auth().currentUser?.uid
            
            ref.child("users").child(userid!).child("favMovies").observeSingleEvent(of: .value, with: { snapshot in
                
                let value = snapshot.value as? NSDictionary
                
                //print(value)
                
                if value?[self.id!] != nil {
                    //print("is Favourite")
                    self.fav.tintColor = UIColor(red:0.92, green:0.30, blue:0.29, alpha:1.0)
                }else{
                    //print("Not favorite")
                    self.fav.tintColor = UIColor.white
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

}
