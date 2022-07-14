//
//  AdvisorTabBarController.swift
//  Imposta
//
//  Created by mac on 28.09.21.
//  Copyright © 2021 Imposta. All rights reserved.
//
import UIKit

class AdvisorTabBarController: UITabBarController {
    
    @IBOutlet weak var tabView: UITabBar!
    
    var customTabBarView = UIView(frame: .zero)
           
       // MARK: View lifecycle
       
       override func viewDidLoad() {
           super.viewDidLoad()
           self.setupTabBarUI()
           self.addCustomTabBarView()
       }
       
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           self.setupCustomTabBarFrame()
       }
       
       // MARK: Private methods
       
       private func setupCustomTabBarFrame() {
           let height = self.view.safeAreaInsets.bottom + 64
           
           var tabFrame = self.tabBar.frame
           tabFrame.size.height = height
           tabFrame.origin.y = self.view.frame.size.height - height
           
           self.tabView.frame = tabFrame
           self.tabView.setNeedsLayout()
           self.tabView.layoutIfNeeded()
           customTabBarView.frame = tabView.frame
       }
       
       private func setupTabBarUI() {
           // Setup your colors and corner radius
           self.tabView.backgroundColor = .white
//           self.tabView.cornerRadius = 25
           self.tabView.layer.cornerRadius = 25
//           self.tabView.roundCorners([.topLeft, .topRight], radius: 25)
           self.tabView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           self.tabView.backgroundColor = .white
           self.tabView.tintColor = .mainColor
           self.tabView.unselectedItemTintColor = .black
           
           // Remove the line
           if #available(iOS 13.0, *) {
               let appearance = self.tabBar.standardAppearance
               appearance.shadowImage = nil
               appearance.shadowColor = nil
               self.tabView.standardAppearance = appearance
           } else {
               self.tabView.shadowImage = UIImage()
               self.tabView.backgroundImage = UIImage()
           }
       }
       
       private func addCustomTabBarView() {
           self.customTabBarView.frame = tabBar.frame
           self.customTabBarView.backgroundColor = .white
           self.customTabBarView.layer.cornerRadius = 25
           self.customTabBarView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

           self.customTabBarView.layer.masksToBounds = false
           self.customTabBarView.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
           self.customTabBarView.layer.shadowOffset = CGSize(width: -4, height: -6)
           self.customTabBarView.layer.shadowOpacity = 0.5
           self.customTabBarView.layer.shadowRadius = 20
           
           self.view.addSubview(customTabBarView)
           self.view.bringSubviewToFront(self.tabView)
       }
}
