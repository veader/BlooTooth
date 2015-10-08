//
//  IntroViewController.swift
//  BlooTooth
//
//  Created by Shawn Veader on 9/22/15.
//  Copyright © 2015 V8 Logic. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    @IBOutlet weak var scanButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let ident = segue.identifier {
            switch ident {
                case "btServerSegue":
                    print("Server")
                    let destinationNav = segue.destinationViewController as! UINavigationController
                    let finalDestination = destinationNav.topViewController as! ChatTableViewController
                    finalDestination.actAsPeripheral()
                default:
                    print("Other")
            }
        }
    }
}
