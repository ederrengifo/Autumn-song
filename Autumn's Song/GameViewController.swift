//
//  GameViewController.swift
//  Autumn's Song
//
//  Created by Eder Rengifo on 31/12/14.
//  Copyright (c) 2014 Eder Rengifo. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let sizeRect = UIScreen.main.applicationFrame
        _ = sizeRect.size.width * 2048  //
        _ = sizeRect.size.height * 1536
        
        let scene = MenuScene(size: CGSize(width: 2048, height: 1536))
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
     
        
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
}
