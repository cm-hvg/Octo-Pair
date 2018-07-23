//
//  GameEngine.swift
//  Octo Pair
//
//  Created by Chuck Ng on 22/07/2018.
//  Copyright © 2018 Chuck Ng. All rights reserved.
//

import UIKit
import Foundation

class Place {
    
    var json: [String: Any]
    var image: UIImage?
    
    init(json: [String: Any]) {
        self.json = json
    }
    
}

extension Place {
    
    static func convert(json: [String: Any]) -> Place {
        return Place(json: json)
    }
    
    static func convert(json: [[String: Any]]) -> [Place] {
        var array = [Place]()
        for item in json {
            array.append(Place.convert(json: item))
        }
        return array
    }
    
}

protocol GameEngineDelegate {
    func didFoundMatchPair()
    func failedToFoundMatchPair()
    func allPairsFound()
}

class GameEngine {
    
    var places: [Place] = []
    var allCards: [Place] = []
    var matchedPlaces: [Place] = []
    
    var delegate: GameEngineDelegate?
    
    init() {
        
    }
    
    func prepareForGame() {
        // Reset
        allCards = []
        // Select 8 random places for 16 Cards
        allCards = pickRandomPlaces(places: places, placeCount: 8)
        // Shuffle?
        allCards = shufflePlaces(cards: allCards)
    }
    
    func pickRandomPlaces(places: [Place], placeCount: Int) -> [Place] {
        
        var cards = [Place]()
        
        // Select 8 random places for 16 Cards
        while cards.count < (placeCount * 2) {
            let index = Int(arc4random_uniform(UInt32(places.count)))
            let card1 = places[index]
            let card2 = Place(json: card1.json)
            cards.append(card1)
            cards.append(card2)
        }
        
        return cards
    }
    
    func shufflePlaces(cards: [Place]) -> [Place] {
        
        // Shuffle?
        var copy = [Place]()
        copy.append(contentsOf: cards)
        
        var shuffled = [Place]()
        
        while copy.count > 0 {
            // Pick random index
            let index = Int(arc4random_uniform(UInt32(copy.count)))
            let card1 = copy[index]
            // Add item
            shuffled.append(card1)
            // Remove from old list
            copy.remove(at: index)
        }
        
        return shuffled
    }
    
    
    func checkSelection(index1: Int, index2: Int) -> Bool {
        guard let placeId1 = allCards[index1].json["place_id"] as? String else { return false }
        guard let placeId2 = allCards[index2].json["place_id"] as? String else { return false }
        
        let matched = placeId1 == placeId2
        
        if matched {
            matchedPair(index1: index1, index2: index2)
            delegate?.didFoundMatchPair()
        } else {
            delegate?.failedToFoundMatchPair()
        }
        
        if matchedPlaces.count == allCards.count {
            delegate?.allPairsFound()
        }
        
        return matched
    }
    
    func isMatched(place1: Place, place2: Place) {
        
    }
    
    func matchedPair(index1: Int, index2: Int) {
        matchedPlaces.append(places[index1])
        matchedPlaces.append(places[index2])
    }
    
    func restart() {
        matchedPlaces.removeAll()
        allCards.removeAll()
    }
    
}
