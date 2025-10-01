//
//  DeeplinkingexampleSecondVC.swift
//  NetomiSampleApp
//
//  Created by Netomi  on 13/02/25.
//


import UIKit

class DeeplinkingexampleSecondVC: UIViewController {
    
    @IBOutlet weak var localImage: UIImageView!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var imageLink: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        localImage.isHidden = true
        descLbl.isHidden = true
        imageLink.isHidden = false
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        imageLink.loadImage(from: "https://demo.netomi.com/images/deeplink2.png", placeholder: AppImages.messageIcon)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
