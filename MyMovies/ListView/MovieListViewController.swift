//
//  MovieListViewController.swift
//  MyMovies
//
//  Created by Abdul Hoque Nuri on 27/09/19.
//  Copyright © 2019 Abdul Hoque Nuri. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher
class MovieListViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate{
    
    @IBOutlet weak var sortingTable: UITableView!
    let sortTableArray = ["Number of Vote" ,"Popularity", "Top Rating", "Release Date"]
    var movieFetchingURL = ""
    var viewControllerTitle = ""
    var overlayView = CustomProgressView()
    let afManager: SessionManager! = SessionManager.getManager()
    var movieListArray = [JSON]()
    var searchResults = [JSON]()
    let dispatchGroup = DispatchGroup()
    @IBOutlet weak var movieListTable: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.viewControllerTitle
        
        let tapGestureToHideKeyBoard = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        tapGestureToHideKeyBoard.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureToHideKeyBoard)
        
        self.movieListTable.tableFooterView = UIView()
        self.sortingTable.tableFooterView = UIView()
        self.sortingTable.isHidden = true
        self.overlayView = CustomProgressView(frame : CGRect(x: 0, y: 0, width:  self.view.frame.width, height:  self.view.frame.height))
        self.dispatchGroup.enter()
        self.fetchMovieGenreList(urlName: movieFetchingURL)
    }
    //MARK:- Hide Keyboard
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    // MARK: - Table View Delegates/Datasources -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.movieListTable {
            return self.movieListArray.count
        } else {
            return sortTableArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.movieListTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieListTableCell
            cell.selectionStyle = .none
            if searchResults.count > 0  {
                searchActive = false
                var adult = "U/A"
                if self.searchResults[indexPath.row]["adult"].intValue != 0 {
                    adult = "A"
                }
                let relaseYear = self.searchResults[indexPath.row]["release_date"].stringValue.prefix(4)
                if self.searchResults[indexPath.row]["original_language"] == "en" {
                    cell.languageLabel.text = "\(adult) | English | \(relaseYear)"
                } else {
                    cell.languageLabel.text = "\(adult) | \(self.searchResults[indexPath.row]["original_language"].stringValue.capitalized) | \(relaseYear)"
                }
                cell.movieTitle.text = "\(indexPath.row + 1).  \(self.searchResults[indexPath.row]["original_title"].stringValue)"
                cell.rateLabel.text = "\( self.searchResults[indexPath.row]["vote_average"].floatValue.advanced(by: 2))"
                cell.voteCount.text = "\( self.searchResults[indexPath.row]["vote_count"].stringValue)"
                cell.popularity.text = "\( self.searchResults[indexPath.row]["popularity"].floatValue.advanced(by: 2))"
                cell.moviePosterImage.kf.setImage(with: URL(string: "\(imageBaseUrl)\(self.searchResults[indexPath.row]["poster_path"].stringValue)"), placeholder: UIImage(named: "placeholdericon"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
                return cell
            } else {
                var adult = "U/A"
                if self.movieListArray[indexPath.row]["adult"].intValue != 0 {
                    adult = "A"
                }
                let relaseYear = self.movieListArray[indexPath.row]["release_date"].stringValue.prefix(4)
                if self.movieListArray[indexPath.row]["original_language"] == "en" {
                    cell.languageLabel.text = "\(adult) | English | \(relaseYear)"
                } else {
                    cell.languageLabel.text = "\(adult) | \(self.movieListArray[indexPath.row]["original_language"].stringValue.capitalized) | \(relaseYear)"
                }
                
                
                cell.movieTitle.text = "\(indexPath.row + 1).  \(self.movieListArray[indexPath.row]["original_title"].stringValue)"
                cell.rateLabel.text = "\( self.movieListArray[indexPath.row]["vote_average"].floatValue.advanced(by: 2))"
                cell.voteCount.text = "\( self.movieListArray[indexPath.row]["vote_count"].stringValue)"
                cell.popularity.text = "\( self.movieListArray[indexPath.row]["popularity"].floatValue.advanced(by: 2))"
                cell.moviePosterImage.kf.setImage(with: URL(string: "\(imageBaseUrl)\(self.movieListArray[indexPath.row]["poster_path"].stringValue)"), placeholder: UIImage(named: "placeholdericon"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
                }, completionHandler: { image, error, cacheType, imageURL in
                })
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SortingTableCell
            cell.textLabel?.text = self.sortTableArray[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.movieListTable {
            self.view.addSubview(self.overlayView)
            self.overlayView.setUpLoaderText("Please Wait ...")
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
            nextVC.movieDetailsArray.append(self.movieListArray[indexPath.row])
            self.navigationController?.pushViewController(nextVC, animated: true)
            self.overlayView.removeFromSuperview()
        } else {
            var tempSortArray = [JSON]()
            if self.searchResults.count > 0 {
                if indexPath.row == 0 {
                    tempSortArray = searchResults.sorted(by: { $0["vote_count"].intValue < $1["vote_count"].intValue })
                } else if indexPath.row == 1 {
                    tempSortArray = searchResults.sorted(by: { $0["popularity"].floatValue < $1["popularity"].floatValue })
                } else if indexPath.row == 2 {
                    tempSortArray = searchResults.sorted(by: { $0["vote_average"].floatValue < $1["vote_average"].floatValue })
                } else {
                    tempSortArray = searchResults.sorted(by: { $0["release_date"] < $1["release_date"] })
                }
                self.searchResults.removeAll()
                self.searchResults = tempSortArray
                
            } else {
                if indexPath.row == 0 {
                    tempSortArray = movieListArray.sorted(by: { $0["vote_count"].intValue < $1["vote_count"].intValue })
                } else if indexPath.row == 1 {
                    tempSortArray = movieListArray.sorted(by: { $0["popularity"].floatValue < $1["popularity"].floatValue })
                } else if indexPath.row == 2 {
                    tempSortArray = movieListArray.sorted(by: { $0["vote_average"].floatValue < $1["vote_average"].floatValue })
                } else {
                    tempSortArray = movieListArray.sorted(by: { $0["release_date"] < $1["release_date"] })
                }
                self.movieListArray.removeAll()
                self.movieListArray = tempSortArray
            }
            self.sortingTable.isHidden = true
            self.movieListTable.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.movieListTable {
            return 150
        } else {
            return 40
        }
    }
    
    //MARK:- Search controller
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async(execute: {
            searchBar.text = ""
            self.searchResults.removeAll()
            self.movieListTable.isHidden = false
            self.movieListTable.reloadData()
            self.searchActive = false
            searchBar.resignFirstResponder()
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchResults.count)
        self.dispatchGroup.enter()
        self.fetchMovieGenreList(urlName: "\(baseURL)search/movie?api_key=\(api_key)&language=en-US&query=\(searchBar.text!)&page=1&include_adult=false")
        print("searchResults\(searchResults)")
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    { /*
         self.view.addSubview(self.overlayView)
         self.overlayView.setUpLoaderText("Searching")
         if searchBar.text!.isEmpty  {
         searchResults.removeAll()
         searchResults = movieListArray
         movieListTable.isHidden = false
         movieListTable.reloadData()
         }else   {
         
         
         }
         
         print(searchResults)
         if searchResults.count == 0 {
         DispatchQueue.main.async(execute: {
         self.movieListTable.isHidden = true
         })
         }  else {
         self.movieListTable.isHidden = false
         self.movieListTable.reloadData()
         }
         self.overlayView.removeFromSuperview()
         */
    }
    
    
    //MARK:- Fetch All News Details
    func fetchMovieGenreList(urlName : String)  {
        self.view.addSubview(self.overlayView)
        if self.searchActive {
            self.overlayView.setUpLoaderText("Searching")
        } else {
            self.overlayView.setUpLoaderText("Please Wait ...")
        }
        if ((NetworkReachabilityManager()?.isReachable)!) {
            afManager.request(urlName, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil) .responseJSON { response in
                switch response.result {
                case .success(_):
                    print(response)
                    let  json = JSON(response.result.value!)
                    DispatchQueue.main.async {
                        if self.searchActive {
                            self.searchActive = false
                            self.searchBar.text = ""
                            self.searchResults.removeAll()
                            if json["status_code"] == "34" {
                                let alertController = UIAlertController(title: "Search Result", message: "The resource you requested could not be found.", preferredStyle: UIAlertController.Style.alert)
                                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                self.searchResults = json["results"].arrayValue
                                if (self.searchResults.count == 0) {
                                    self.movieListTable.isHidden = true
                                } else {
                                    self.movieListTable.isHidden = false
                                }
                            }
                            self.searchBar.resignFirstResponder()
                        } else {
                            self.movieListArray.removeAll()
                            self.movieListArray = json["results"].arrayValue
                        }
                        self.movieListTable.reloadData()
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
    
    //MARK:- Sorting
    
    @IBAction func onTapSortingBarButton(_ sender: Any) {
        if self.sortingTable.isHidden { self.sortingTable.isHidden = false
        } else {
            self.sortingTable.isHidden = true
        }
    }
}
