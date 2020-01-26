//
//  ViewController.swift
//  SSLPinning
//
//  Created by Anuj Rai on 25/01/20.
//  Copyright © 2020 Anuj Rai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: "https://www.google.co.uk") else { return }
        ServiceManager().callAPI(withURL: url)
    }


}

