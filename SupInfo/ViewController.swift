//
//  ViewController.swift
//  SupInfo
//
//  Created by Supinfo on 11/12/2017.
//  Copyright © 2017 Supinfo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var txfLogin: UITextField!
    @IBOutlet weak var txfPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submitAction(_ sender: UIButton) {
        let login = txfLogin.text
        let pass = txfPassword.text
        if let user: User = NetworkController.Connection(Login: login!,Password: pass!) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let viewC: AccueilViewController = storyBoard.instantiateViewController(withIdentifier: "Accueil") as! AccueilViewController
            viewC.user = user
            self.present(viewC, animated: true, completion: nil)
        } else{
            self.lblError.text = "Les identifiants sont incorrects vérifiez-les"
            self.lblError.isHidden = false
        }
    }

}

