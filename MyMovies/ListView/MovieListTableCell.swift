//
//  MovieListTableCell.swift
//  MyMovies
//
//  Created by Abdul Hoque Nuri on 27/09/19.
//  Copyright © 2019 Abdul Hoque Nuri. All rights reserved.
//

import UIKit
class MovieListTableCell: UITableViewCell {
    
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var popularity: UILabel!
    @IBOutlet weak var voteCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
