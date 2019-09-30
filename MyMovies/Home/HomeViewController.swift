//
//  ViewController.swift
//  MyMovies
//
//  Created by Abdul Hoque Nuri on 27/09/19.
//  Copyright © 2019 Abdul Hoque Nuri. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher

var api_key = "a5ae83891eb2ec3c23227a9cf54943a9"
var baseURL = "https://api.themoviedb.org/3/"
let imageBaseUrl = "https://image.tmdb.org/t/p/w500/"

class HomeViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var overlayView = CustomProgressView()
    let afManager: SessionManager! = SessionManager.getManager()
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false
    var movieGenreArray = [JSON]()
    @IBOutlet weak var homeTableView: UITableView!
    let dispatchGroup = DispatchGroup()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.homeTableView.tableFooterView = UIView()
        self.overlayView = CustomProgressView(frame : CGRect(x: 0, y: 0, width:  self.view.frame.width, height:  self.view.frame.height))
        
        if ((NetworkReachabilityManager()?.isReachable)!) {
            self.dispatchGroup.enter()
            self.fetchMovieGenreList(urlName: "\(baseURL)genre/movie/list?api_key=\(api_key)&language=en-US")
        }else{
            let alertController = UIAlertController(title: "No Internet connection", message: "Please connect to Internet", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK: - Table View Delegates/Datasources -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movieGenreArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * 0.25
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        cell.selectionStyle = .none
        cell.movieGenreTitle.text = self.movieGenreArray[indexPath.row]["name"].stringValue.uppercased()
        cell.genreImage.image = UIImage(named: self.movieGenreArray[indexPath.row]["name"].stringValue)
        cell.movieGenreTitle.layer.cornerRadius = 5.0
        cell.movieGenreTitle.layer.borderWidth = 1.0
        cell.movieGenreTitle.layer.borderColor = UIColor.lightGray.cgColor
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.addSubview(self.overlayView)
        self.overlayView.setUpLoaderText("Please Wait ...")
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieListViewController") as! MovieListViewController
        nextVC.movieFetchingURL = "\(baseURL)genre/\(self.movieGenreArray[indexPath.row]["id"].stringValue)/movies?api_key=\(api_key)"
        nextVC.viewControllerTitle = self.movieGenreArray[indexPath.row]["name"].stringValue
        self.navigationController?.pushViewController(nextVC, animated: true)
        self.overlayView.removeFromSuperview()
    }
    
    //MARK:- Fetch All News Details
    func fetchMovieGenreList(urlName : String)  {
        self.view.addSubview(self.overlayView)
        self.overlayView.setUpLoaderText("Please Wait ...")
        if ((NetworkReachabilityManager()?.isReachable)!) {
            afManager.request(urlName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response)
                    let  json = JSON(response.result.value!)
                    DispatchQueue.main.async {
                        self.movieGenreArray.removeAll()
                        self.movieGenreArray = json["genres"].arrayValue
                        self.homeTableView.reloadData()
                        self.dispatchGroup.leave()
                        self.overlayView.removeFromSuperview()
                    }
                case .failure(_):
                    print("Request failed with error: \(response.result.error ?? "" as! Error)")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.dispatchGroup.leave()
                self.overlayView.removeFromSuperview()
            }
            
            let alertController = UIAlertController(title: "No Internet connection", message: "Please connect to Internet", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

