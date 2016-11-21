//
//  MenuScene.swift
//  Autumn's Song
//
//  Created by Eder Rengifo on 23/01/15.
//  Copyright (c) 2015 Eder Rengifo. All rights reserved.
//

import SpriteKit
import UIKit

class MenuScene: SKScene {
    
    
    let fontColorRed = SKColorWithRGB(217, g: 49, b: 80)
    let fontColorBlack = SKColorWithRGB(69, g:74, b:78)
    var fontFamily = "Cochin"
    let background = SKSpriteNode(imageNamed: "bgscene")
    let mainTitle = SKSpriteNode(imageNamed: "maintitle")
    let playButton = SKSpriteNode(imageNamed: "defaultButton")
    let playableRect: CGRect
    let screenSize: CGSize = UIScreen.main.bounds.size
    var maxAspectRatio = CGFloat()
    
    override init(size: CGSize) {
        
        // Definition of playeable area according Devices
        
        if screenSize.height == 768 { // Retina iPad - Air
            maxAspectRatio = 4.0/3.0
        }
        
        if screenSize.height == 384 { // No-Retina iPad - Mini
            maxAspectRatio = 4.0/3.0
        }
        
        if screenSize.width == 480 { // iPhone 4 - 4s
            maxAspectRatio = 3.0/2.0
        }
        
        if screenSize.width == 568 { // iPhone 5 - 5s
            maxAspectRatio = 16.0/9.0
        }
        
        if screenSize.height == 375 { // iPhone 6
            maxAspectRatio = 16.0/9.0
        }
        
        if screenSize.height == 414 { // iPhone 6 Plus
            maxAspectRatio = 16.0/9.0
        }
        
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height-playableHeight)/2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size:size)
        
        createStaticEngine()
        
    }

    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        playBackgroundMusic("ambiance.mp3")
        
        run(SKAction.playSoundFileNamed("start.mp3", waitForCompletion: true))
        
        mainBG()
        MainTitle()
        PlayButton()
        Description()
        Credit()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let loc = touch.location(in: self)
        
        if let nodePlay = childNode(withName: "playButton") {
            if nodePlay.contains(loc) {
                let scene = GameScene(size: self.size)
                let skView = self.view! as SKView
                scene.scaleMode = .aspectFill
                skView.presentScene(scene)
                
                backgroundMusicPlayer.stop()
            }
        }
        
    }
    
    
    func mainBG() {
        
        background.setScale(2.0)
        background.position = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        background.zPosition = 0
        addChild(background)
        
    }
    
    func MainTitle() {
        
        mainTitle.position = CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.maxY + 20)
        mainTitle.alpha = 0
        addChild(mainTitle)
        
        let down = SKAction.move(to: CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.maxY - (playableRect.maxY / 4.5)), duration: 0.8)
        let waitAppear = SKAction.wait(forDuration: 0.4)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let appearSequence = SKAction.sequence([waitAppear, appear])
        let group = SKAction.group([down, appearSequence])

        mainTitle.run(SKAction.sequence([group]))
        
    }
    
    func PlayButton() {
        
        playButton.position = CGPoint(x: self.frame.size.width * 0.5, y: (self.frame.size.height * 0.5) - 50)
        playButton.zPosition = 100
        playButton.setScale(0)
        playButton.name = "playButton"
        addChild(playButton)
        
        let playLabel = SKLabelNode()
        playLabel.fontName = fontFamily
        playLabel.fontColor = fontColorBlack
        playLabel.fontSize = 42
        playLabel.text = "PLAY"
        playLabel.position = CGPoint(x: 0, y: -130)
        playLabel.zPosition = 100
        playButton.addChild(playLabel)
        
        let wait = SKAction.wait(forDuration: 1.2)
        let increase = SKAction.scale(to: 1.1, duration: 0.2)
        let sound = SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)
        let decrease = SKAction.scale(to: 0.9, duration: 0.3)
        let increase2 = SKAction.scale(to: 1.0, duration: 1.2)
        let groupIncrease = SKAction.group([increase, sound])
        
        playButton.run(SKAction.sequence([wait, groupIncrease, decrease, increase2]))
        
    
    }
    
    func Description() {
        
        let txtBg = SKSpriteNode(imageNamed: "maintxt")
        txtBg.position = CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.minY - 20)
        txtBg.alpha = 0
        addChild(txtBg)
        
        let txtLabel = SKLabelNode()
        txtLabel.fontName = fontFamily
        txtLabel.fontColor = fontColorBlack
        txtLabel.fontSize = 46
        txtLabel.text = "At the end of autumn, a brave bird tries to save the colors..."
        txtLabel.position = CGPoint(x: 0, y: -10)
        txtBg.addChild(txtLabel)
        
        let wait = SKAction.wait(forDuration: 0.2)
        let up = SKAction.move(to: CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.minY + (playableRect.maxY / 6)), duration: 0.8)
        let waitAppear = SKAction.wait(forDuration: 0.4)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        let appearSequence = SKAction.sequence([waitAppear, appear])
        let group = SKAction.group([up, appearSequence])
        
        txtBg.run(SKAction.sequence([wait, group]))
        
    }
    
    func Credit() {
        
        let creditTxt = SKLabelNode()
        creditTxt.fontName = fontFamily
        creditTxt.fontColor = fontColorBlack
        creditTxt.fontSize = 26
        creditTxt.text = "® DESIGN, CODE & MUSIC BY EDER RENGIFO"
        creditTxt.position = CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.minY + 40)
        creditTxt.alpha = 0
        addChild(creditTxt)
        
        let wait = SKAction.wait(forDuration: 0.6)
        let appear = SKAction.fadeAlpha(to: 0.75, duration: 0.8)
        
        creditTxt.run(SKAction.sequence([wait, appear]))
        
    }
    
    func createStaticEngine() {
        
        let staticEngineEmitter = SKEmitterNode(fileNamed: "staticEngine.sks")
        staticEngineEmitter!.setScale(1.6)
        staticEngineEmitter!.position = CGPoint(x:self.frame.size.width * 0.5, y:self.frame.size.height)
        staticEngineEmitter!.name = "staticEngineEmitter"
        staticEngineEmitter!.zPosition = 50
        addChild(staticEngineEmitter!)
        
    }
    
    
    
}
