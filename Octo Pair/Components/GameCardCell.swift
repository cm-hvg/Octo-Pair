//
//  GameCardCellCollectionViewCell.swift
//  Octo Pair
//
//  Created by Chuck Ng on 22/07/2018.
//  Copyright © 2018 Chuck Ng. All rights reserved.
//

import UIKit

class GameCardCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var place: Place? {
        didSet {
            guard let _ = place else { return }
            guard let id = place!.json["place_id"] as? String else { return }
            PlaceService.shared.loadFirstPhoto(placeID: id) { (image) in
                // Hide and set image
                self.imageView.alpha = 0
                self.imageView.image = image
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
    }
}
