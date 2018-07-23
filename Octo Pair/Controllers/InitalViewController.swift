//
//  ViewController.swift
//  Octo Pair
//
//  Created by Chuck Ng on 20/07/2018.
//  Copyright © 2018 Chuck Ng. All rights reserved.
//

import UIKit
import ChameleonFramework

class InitalViewController: UIViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        view.backgroundColor = UIColor.mainGradient(view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startButton.roundColor(pct: 0.5)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func startButtonOnTap(_ sender: Any) {
    }
    
}
