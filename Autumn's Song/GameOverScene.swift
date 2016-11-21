//
//  GameOverScene.swift
//  Autumn's Song
//
//  Created by Eder Rengifo on 31/12/14.
//  Copyright (c) 2014 Eder Rengifo. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameOverScene: SKScene {
    
    let won:Bool
    
    let fontColorRed = SKColorWithRGB(217, g: 49, b: 80)
    let fontColorBlack = SKColorWithRGB(69, g: 74, b: 78)
    var fontFamily = "Cochin"
    let background = SKSpriteNode(imageNamed: "bgscene")
    var distance = 0
    var highscore = 0
    let example = SKLabelNode(fontNamed: "Cochin")
    let intentar = SKLabelNode(fontNamed: "Cochin")
    var defaults = UserDefaults()
    let playableRect: CGRect
    let screenSize: CGSize = UIScreen.main.bounds.size
    var maxAspectRatio = CGFloat()
    
    
    init(size: CGSize, won: Bool) {
        self.won = won
        
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
        
        super.init(size: size)
        
        createStaticEngine()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        playBackgroundMusic("ambiance.mp3")
        
        run(SKAction.playSoundFileNamed("gameover.mp3", waitForCompletion: false))
        
        mainBG()
        BirdDead()
        TextDead()
        BackTxt()
        TryAgain()
        Labels()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else {
            return
        }
        let loc = touch.location(in: self)
        
        if let nodePlay = childNode(withName: "tryAgain") {
            if nodePlay.contains(loc) {
                let scene = MenuScene(size: self.size)
                let skView = self.view! as SKView
                scene.scaleMode = .aspectFill
                let reveal = SKTransition.crossFade(withDuration: 0.8)
                skView.presentScene(scene, transition: reveal)
               
            }
        }
        
    }
    
    func mainBG() {
        
        background.setScale(2.0)
        background.position = CGPoint(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        background.zPosition = 0
        addChild(background)
        
    }
    
    func BirdDead() {
        
        let birdDead = SKSpriteNode(imageNamed: "dead")
        birdDead.position = CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.maxY - 250)
        birdDead.zPosition = 20
        birdDead.alpha = 0
        addChild(birdDead)
        
        let up = SKAction.move(to: CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.maxY - (playableRect.maxY / 6.6)), duration: 0.6)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 1.2)
        let group = SKAction.group([up, appear])
        
        birdDead.run(SKAction.sequence([group]))
        
    }
    
    func TextDead() {
        
        let textDead = SKLabelNode()
        textDead.fontName = fontFamily
        textDead.fontColor = fontColorBlack
        textDead.fontSize = 56
        textDead.position = CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.maxY - 250)
        textDead.text = "... the winter finally won. Crow, tired, fell over into the snow."
        textDead.zPosition = 100
        textDead.alpha = 0
        addChild(textDead)
        
        let wait = SKAction.wait(forDuration: 0.4)
        let down = SKAction.move(to: CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.maxY - (playableRect.maxY / 3.4)) , duration: 0.6)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 1.2)
        let group = SKAction.group([down, appear])
        
        textDead.run(SKAction.sequence([wait, group]))
    }
    
    func BackTxt() {
        
        let backTxt = SKSpriteNode(imageNamed: "gameovertxt")
        
        backTxt.position = CGPoint(x:self.frame.size.width * 0.1 - 500, y:self.frame.size.height * 0.5 - 50)
        backTxt.alpha = 0
        addChild(backTxt)
        
        let wait = SKAction.wait(forDuration: 0.1)
        let move = SKAction.move( to: CGPoint(x:self.frame.size.width * 0.5, y:self.frame.size.height * 0.5 - 50), duration: 0.4)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.4)
        let group = SKAction.group([move, appear])
        
        backTxt.run(SKAction.sequence([wait, group]))
    }
    
    func TryAgain() {
        
        let tryAgainButton = SKSpriteNode(imageNamed: "defaultButton")
        tryAgainButton.position = CGPoint(x: self.playableRect.size.width * 0.5, y: playableRect.minY + (playableRect.maxY / 5.5))
        tryAgainButton.zPosition = 100
        tryAgainButton.name = "tryAgain"
        addChild(tryAgainButton)
        
        let tryAgainTxt = SKLabelNode()
        tryAgainTxt.fontName = fontFamily
        tryAgainTxt.fontColor = fontColorBlack
        tryAgainTxt.fontSize = 42
        tryAgainTxt.position = CGPoint(x: 0 ,y: -130)
        tryAgainTxt.text = "TRY AGAIN"
        tryAgainButton.setScale(0)
        tryAgainButton.addChild(tryAgainTxt)
        
        let wait = SKAction.wait(forDuration: 1.2)
        let increase = SKAction.scale(to: 1.1, duration: 0.2)
        let sound = SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false)
        let decrease = SKAction.scale(to: 0.9, duration: 0.3)
        let increase2 = SKAction.scale(to: 1.0, duration: 1.2)
        let groupIncrease = SKAction.group([increase, sound])
        tryAgainButton.run(SKAction.sequence([wait, groupIncrease, decrease, increase2]))
                
    }
    
    func Labels() {
        
        let currentDistance = SKLabelNode()
        currentDistance.fontName = fontFamily
        currentDistance.position = CGPoint(x:self.frame.size.width * 0.5 - 600, y:self.frame.size.height * 0.5 - 120)
        currentDistance.fontColor = fontColorBlack
        currentDistance.text = "\(distance)"
        currentDistance.fontSize = 100
        currentDistance.alpha = 0
        currentDistance.horizontalAlignmentMode = .right
        
        
        let currentDistanceTitle = SKLabelNode()
        currentDistanceTitle.fontName = fontFamily
        currentDistanceTitle.position = CGPoint(x: 0 , y: 100)
        currentDistanceTitle.fontColor = fontColorBlack
        currentDistanceTitle.text = "DISTANCE"
        currentDistanceTitle.horizontalAlignmentMode = .right
        currentDistanceTitle.fontSize = 45
        
        let recordDistanceTitle = SKLabelNode()
        recordDistanceTitle.fontName = fontFamily
        recordDistanceTitle.position = CGPoint(x: 0 , y: 100)
        recordDistanceTitle.fontColor = fontColorRed
        recordDistanceTitle.text = "NEW RECORD!"
        recordDistanceTitle.fontSize = 45
        
        let highDistance = SKLabelNode()
        highDistance.fontName = fontFamily
        highDistance.position = CGPoint(x:self.frame.size.width * 0.5 + 600, y:self.frame.size.height * 0.5 - 120)
        highDistance.fontColor = fontColorRed
        highDistance.text = "\(highscore)"
        highDistance.fontSize = 100
        highDistance.alpha = 0
        highDistance.horizontalAlignmentMode = .left
        
        
        let highDistanceTitle = SKLabelNode()
        highDistanceTitle.fontName = fontFamily
        highDistanceTitle.position = CGPoint(x: 0 , y: 100)
        highDistanceTitle.fontColor = fontColorRed
        highDistanceTitle.text = "HIGH SCORE"
        highDistanceTitle.fontSize = 45
        highDistanceTitle.horizontalAlignmentMode = .left
        
        let wait = SKAction.wait(forDuration: 0.1)
        let moveA = SKAction.move( to: CGPoint(x:self.frame.size.width * 0.5 - 100, y:self.frame.size.height * 0.5 - 120), duration: 0.4)
        let moveB = SKAction.move( to: CGPoint(x:self.frame.size.width * 0.5 + 100, y:self.frame.size.height * 0.5 - 120), duration: 0.4)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.4)
        
        if distance >= highscore {
            currentDistance.addChild(recordDistanceTitle)
            currentDistance.position = CGPoint(x:self.frame.size.width * 0.5 + 600, y:self.frame.size.height * 0.5 - 120)
            currentDistance.horizontalAlignmentMode = .center
            addChild(currentDistance)
            
            let moveRecord = SKAction.move(to: CGPoint(x:self.frame.size.width * 0.5, y:self.frame.size.height * 0.5 - 120), duration: 0.4)
            let group = SKAction.group([moveRecord, appear])
            
            currentDistance.run(SKAction.sequence([wait, group]))
            
        } else {
            
            addChild(currentDistance)
            currentDistance.addChild(currentDistanceTitle)
            Line()
            addChild(highDistance)
            highDistance.addChild(highDistanceTitle)
            
            let groupA = SKAction.group([moveA, appear])
            currentDistance.run(SKAction.sequence([wait, groupA]))
            
            let groupB = SKAction.group([moveB, appear])
            highDistance.run(SKAction.sequence([wait, groupB]))
        }
        
        
    }
    
    
    func Line() {
        
        let line = SKSpriteNode(imageNamed: "gameoverline")
        line.position = CGPoint(x:self.frame.size.width * 0.5, y:self.frame.size.height * 0.5 - 50)
        line.alpha = 0
        addChild(line)
        
        let wait = SKAction.wait(forDuration: 0.6)
        let appear = SKAction.fadeAlpha(to: 1.0, duration: 0.4)
        
        line.run(SKAction.sequence([wait, appear]))
        
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
