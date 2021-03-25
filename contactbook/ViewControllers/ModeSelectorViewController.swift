//
//  ModeSelectorViewController.swift
//  contactbook
//
//  Created by Yastrebov Vsevolod on 25.03.2021.
//

import UIKit

class ModeSelectorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ((sender as? UIButton) != nil) {
            switch (sender as! UIButton).currentTitle {
            case "GCD":
                GlobalDefinitions.parallelismMode = ParallelismMode.gcd
            case "Operation Queue":
                GlobalDefinitions.parallelismMode = ParallelismMode.opqueue
            default:
                fatalError("Illegal state")
            }
        }
    }
    

}
