//
//  GameViewController.swift
//  Octo Pair
//
//  Created by Chuck Ng on 21/07/2018.
//  Copyright © 2018 Chuck Ng. All rights reserved.
//

import UIKit
import GooglePlacePicker
import Alamofire

class GameViewController: UIViewController {

    typealias Json = [String: Any]
    
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var gridView: UICollectionView!
    
    let manager = CLLocationManager()
    let engine = GameEngine()
    var selectedIndexPaths: [IndexPath] = []
    var matchedIndexPaths: [IndexPath] = []
    
    var placesJson: [Json]? {
        didSet {
            startGame()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Styling
        view.backgroundColor = UIColor.mainGradient(view)
        restartButton.alpha = 0
        
        engine.delegate = self
        
        // Location Pop up
        pickLocation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restartButton.roundColor(pct: 0.5)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonOnTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func restartOnTap(_ sender: Any) {
        startGame()
    }
    
    // MARK: - Game
    
    func startGame() {
        
        guard let json = placesJson else {
            return
        }
        
        selectedIndexPaths.removeAll()
        matchedIndexPaths.removeAll()
        
        // Clear Data
        engine.restart()
        // Convert Json to places
        engine.places = Place.convert(json: json)
        // Getting Ready
        engine.prepareForGame()
        
        if (restartButton.alpha > 0) {
            showRestartButton(visbility: false)
        }
        
        // Popular grid view 
        gridView.reloadData()
    }
    
    func showRestartButton(visbility: Bool) {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                        self.restartButton.alpha = visbility ? 1 : 0
        }, completion: { (finished) in
        })
    }
    
    // MARK: - Location
    
    func pickLocation() {
        
        guard let location = PlaceService.shared.location else {
            PlaceService.shared.manager.delegate = self
            PlaceService.shared.manager.requestWhenInUseAuthorization()
            return
        }
        
        searchPlaces()
    }
    
    func searchPlaces() {
        guard let location = PlaceService.shared.location else {
            return
        }
        
        PlaceService.shared.searchRestaurants(at: "\(location.coordinate.latitude),\(location.coordinate.longitude)") { (json) in
            guard let places = json["results"] as? [Json] else { return }
            self.placesJson = places
        }
    }
    
    // MARK: - Cell State
    
    func flipCell(indexPath: IndexPath, selected: Bool, completed: ((Bool) -> Void)?) {
        
        guard let cell = gridView.cellForItem(at: indexPath) as? GameCardCell else { return }
        
        UIView.transition(with: cell, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            cell.imageView.alpha = selected ? 1 : 0
        }, completion: completed)
    }
    
    func resetCells() {
        self.flipCell(indexPath: self.selectedIndexPaths.first!, selected: false, completed: nil)
        self.flipCell(indexPath: self.selectedIndexPaths.last!, selected: false, completed: nil)
        self.selectedIndexPaths.removeAll()
    }
}

extension GameViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            return
        }
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            return
        }
        
        manager.stopUpdatingLocation()
        
        PlaceService.shared.location = location
        searchPlaces()
    }
}

// MARK: Collection View Data Source

extension GameViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return engine.allCards.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath)
        
        if let gameCard = cell as? GameCardCell {
            gameCard.place = engine.allCards[indexPath.row]
        }
        
        return cell
    }
}

// MARK: Collection View Delegate

extension GameViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Already matched.
        guard !matchedIndexPaths.contains(indexPath) else {
            return
        }
        
        // Maxiumn 2 cards can be flipped at a time
        guard selectedIndexPaths.count <= 1 else {
            return
        }
        
        guard !selectedIndexPaths.contains(indexPath) else {
            return
        }
        
        selectedIndexPaths.append(indexPath)
        flipCell(indexPath: indexPath, selected: true, completed: { (finished) in
            
            guard self.selectedIndexPaths.count == 2 else {
                return
            }
            
            let _ = self.engine.checkSelection(index1: self.selectedIndexPaths.first!.row, index2: self.selectedIndexPaths.last!.row)
        })
    }
}

// MARK: Game Engine Delegate

extension GameViewController: GameEngineDelegate {
    
    func allPairsFound() {
        
        self.showAlert(title: "Congratulations!", message: "All matches have been found!", completeion: { })
        
        showRestartButton(visbility: true)
    }
    
    
    func didFoundMatchPair() {
        self.dismissCards()
        self.selectedIndexPaths.removeAll()
    }
    
    func failedToFoundMatchPair() {
        self.resetCells()
//        self.showAlert(title: "Message", message: "Not a match") { }
    }
    
    func showAlert(title: String, message: String, completeion: @escaping () -> Void) {
        
        let controller = UIAlertController.init(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completeion()
            controller.dismiss(animated: true, completion: nil)
        }))
        
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func dismissCards() {
        
        for indexPath in selectedIndexPaths {
            
            matchedIndexPaths.append(indexPath)
            
            let cell = gridView.cellForItem(at: indexPath) as! GameCardCell
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 1,
                           options: .curveEaseInOut,
                           animations: {
                            //
                            cell.alpha = 0
                            cell.imageView.alpha = 0
                            //
            }, completion: { (finished) in
            })
        }
    }
}
