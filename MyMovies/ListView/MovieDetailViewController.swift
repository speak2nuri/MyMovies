//
//  MovieDetailViewController.swift
//  MyMovies
//
//  Created by Abdul Hoque Nuri on 27/09/19.
//  Copyright © 2019 Abdul Hoque Nuri. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import Kingfisher
class MovieDetailViewController: UIViewController{
    var movieDetailsArray = [JSON]()
    @IBOutlet weak var movieageView: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var subDetails: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var movieRating: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    @IBOutlet weak var moviePopularity: UILabel!
    @IBOutlet weak var movieDetails: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.movieageView.kf.setImage(with: URL(string: "\(imageBaseUrl)\(self.movieDetailsArray[0]["poster_path"].stringValue)"), placeholder: UIImage(named: "placeholdericon"), options: [.transition(ImageTransition.fade(1))], progressBlock: { receivedSize, totalSize in
        }, completionHandler: { image, error, cacheType, imageURL in
        })
        
        var adult = "U/A"
        if self.movieDetailsArray[0]["adult"].intValue != 0 {
            adult = "A"
        }
        if self.movieDetailsArray[0]["original_language"].stringValue.localizedLowercase == "en" {
            self.subDetails.text = "Language : English (\(adult))"
        } else {
            self.subDetails.text = "Language : \(self.movieDetailsArray[0]["original_language"].stringValue.capitalized) (\(adult))"
        }
        
        self.releaseDate.text = "Release : \(self.movieDetailsArray[0]["release_date"].stringValue)"
        self.movieTitle.text = self.movieDetailsArray[0]["original_title"].stringValue
        self.movieRating.text = "\(self.movieDetailsArray[0]["vote_average"].floatValue.advanced(by: 2))"
        self.voteCount.text = self.movieDetailsArray[0]["vote_count"].stringValue
        self.moviePopularity.text = "\(self.movieDetailsArray[0]["popularity"].floatValue.advanced(by: 2))"
        self.movieDetails.text = self.movieDetailsArray[0]["overview"].stringValue
    }
}
