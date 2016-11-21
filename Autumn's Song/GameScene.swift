//
//  GameScene.swift
//  Autumn's Song
//
//  Created by Eder Rengifo on 31/12/14.
//  Copyright (c) 2014 Eder Rengifo. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene {
    
    // Configurations
    
    let fontColorRed = SKColorWithRGB(217, g: 49, b: 80)
    let fontColorBlack = SKColorWithRGB(69, g: 74, b: 78)
    var fontFamily = "Cochin"
    let bird = SKSpriteNode(imageNamed: "bird1")
    let bgText = SKSpriteNode(imageNamed: "bgtext")
    let petalSpawnRange = 3.2
    let snowSpawnRange = 3.2
    let snowRecurrentSpawnRange = 8.5
    var disConv = 12
    var winPetalsScore = 1
    var losePetalsScore = 1
    var hitGroundScore = 3
    var hitSnowScore = 5
    
    // Sounds
    
    var soundBird = SKAction.playSoundFileNamed("bird.mp3", waitForCompletion: false)
    var soundLosePetal = SKAction.playSoundFileNamed("losepetal.mp3", waitForCompletion: false)
    var soundWinPetal = SKAction.playSoundFileNamed("winpetal.mp3", waitForCompletion: false)
    var soundIce = SKAction.playSoundFileNamed("ice.mp3", waitForCompletion: false)
    var soundGround = SKAction.playSoundFileNamed("ground.mp3", waitForCompletion: false)
    
    
    // Another variables and constants
    
    var currentSentence:Int = 0
    let bottomEdge = SKSpriteNode(imageNamed: "guideline")
    let leftEdge = SKSpriteNode(imageNamed: "guideline2")
    let birdAnimation: SKAction
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let birdMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPoint.zero
    var lastTouchLocation: CGPoint?
    let backgroundBMovePointsPerSec: CGFloat = 50.0
    let backgroundCMovePointsPerSec: CGFloat = 100.0
    let groundMovePointsPerSec: CGFloat = 250.0
    let treeMovePointsPerSec: CGFloat = 1100.0
    var gameOver = false
    var invincible = false
    var score = 0
    var distance = 0
    var timer = Timer()
    var velocitySnow : TimeInterval = 0.0
    var velocityPetals : TimeInterval = 0.0
    var velocitySnowRecurrent: TimeInterval = 0.0
    let scoreLabel = SKLabelNode()
    let scoreTitle = SKLabelNode()
    let distanceLabel = SKLabelNode()
    let distanceTitle = SKLabelNode()
    let losePetalsSnow = SKLabelNode()
    let losePetalsGround = SKLabelNode()
    let losePetalsLeft = SKLabelNode()
    let storyText = SKLabelNode()
    let particleLayerNode = SKNode()
    let pauseButton = SKSpriteNode(imageNamed: "pauseButton")
    var pauseText = SKLabelNode()
    let showBg2 = SKNode()
    let resume = SKNode()
    
    let playableRect: CGRect
    let screenSize: CGSize = UIScreen.main.bounds.size
    var maxAspectRatio = CGFloat()

    var gameState = GameState.starting
    
    
    override func didEvaluateActions() {
        
        checkCollisions()
        
    }
    
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
        
        // Bird Animation
        
        var textures:[SKTexture] = []
        for i in 1...8 {
            textures.append(SKTexture(imageNamed: "bird\(i)"))
        }
        birdAnimation = SKAction.repeat(SKAction.animate(with: textures, timePerFrame: 0.05), count: 3)
        
        super.init(size:size)
        
        // Layers and particles
        
        particleLayerNode.zPosition = 10
        addChild(particleLayerNode)
        setupSceneLayers()
        createMagic()
        petalsLayersNode()
        storyLayers()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implement")
        
    }
    
    
    override func didMove(to view: SKView) {
        
        
        playBackgroundMusic("main.mp3")
        
        if gameState == .starting {
            isPaused = true
            backgroundMusicPlayer.stop()
            pauseButton.setScale(0)
        }
        
        // Timer definition
        
        timer = Timer.scheduledTimer(timeInterval: 1, target:self,selector:#selector(GameScene.updateTimer), userInfo:nil, repeats: true)
        
        // Physics Gravity
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        
        // Adding Elements
        
        backgroundNodeAll()
        createEngine()
        spawnBird()
        blurTree()
        groundEdges()
        createUserInterface()
        pauseButtonNode()

        
        // Spawn Petals
        
            run(SKAction.sequence([SKAction.wait(forDuration: 0.0),SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnPetal),SKAction.wait(forDuration: petalSpawnRange)]))]))
        
        // Spawn Snow
        
        run(SKAction.sequence([SKAction.wait(forDuration: 10.6),SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnSnow),SKAction.wait(forDuration: snowSpawnRange)]))]))
        
            run(SKAction.sequence([SKAction.wait(forDuration: 80),SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnSnow2),SKAction.wait(forDuration: snowRecurrentSpawnRange)]))]))
        
            run(SKAction.sequence([SKAction.wait(forDuration: 169.25),SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnSnow2),SKAction.wait(forDuration: snowRecurrentSpawnRange)]))]))
        
            run(SKAction.sequence([SKAction.wait(forDuration: 949.875),SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnSnow2),SKAction.wait(forDuration: snowRecurrentSpawnRange)]))]))
        
            run(SKAction.sequence([SKAction.wait(forDuration: 954.125),SKAction.repeatForever(SKAction.sequence([SKAction.run(spawnSnow2),SKAction.wait(forDuration: snowRecurrentSpawnRange)]))]))
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
            } else {
                dt = 0
        }
        
        if isPaused {
            lastUpdateTime = currentTime
            timer.invalidate()
            return
        } else {
            updateTimer()
        }
        
        lastUpdateTime = currentTime
        print("\(dt*1000) milliseconds since last update!")
        
        checkCollisions()
        
        // Logic and actions for lose game
        
        if score < 0 && !gameOver {
            
            gameOver = true
            isPaused = true
            print("You lose!")
            backgroundMusicPlayer.stop()
            
            scoreLabel.removeFromParent()
            scoreTitle.removeFromParent()
            distanceLabel.removeFromParent()
            distanceTitle.removeFromParent()
            
            let distanceConv = (distance / disConv) - 1
            
            let defaults = UserDefaults()
            let highscore = defaults.integer(forKey: "highscore")
            
            if (distanceConv > highscore) {
                defaults.set(distanceConv, forKey: "highscore")
                
            }
            
            let highScoreShow = defaults.integer(forKey: "highscore")
            
            let gameOverScene = GameOverScene(size: size, won: true)
            gameOverScene.scaleMode = scaleMode
            gameOverScene.distance = distanceConv
            gameOverScene.highscore = highScoreShow
            let reveal = SKTransition.crossFade(withDuration: 1.2)
            view?.presentScene(gameOverScene, transition: reveal)
            self.scene?.removeFromParent()
            
        }
        
        
        
        // Custom game difficulty and another conditionals
        
        difficultyConditionals()
        storyTextConditionals()
        
        
        // Moving Elements

        moveSprite(bird, velocity: CGPoint(x:0, y:birdMovePointsPerSec))
        moveBackgroundB()
        moveBackgroundC()
        moveGround()
        moveTree()

    }
    
    // Touches methods
    
    func moveBirdToward(_ location: CGPoint) {
        
        startBirdAnimacion()
        
    }
    
    func SceneTouched(_ touchLocation:CGPoint) {
        
        moveBirdToward(touchLocation)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        switch gameState {
            
        case .starting:
            
            let nodeBg = childNode(withName: "showbg")! as SKNode
            nodeBg.run(SKAction.sequence([(SKAction.fadeAlpha(to: 0, duration: 0.7)), (SKAction.run() { nodeBg.isHidden = true })]))
            let nodeTouch = childNode(withName: "touchimage")! as SKNode
            nodeTouch.run(SKAction.sequence([(SKAction.fadeAlpha(to: 0, duration: 0.7)), (SKAction.run() { nodeTouch.isHidden = true })]))
            backgroundMusicPlayer.play()
            gameState = .playing
            
            isPaused = false
            
            fallthrough
            
        case .playing:
        
            guard let touch = touches.first else {
                return
            }
            let loc = touch.location(in: self)
            SceneTouched(loc)
            bird.physicsBody?.velocity = CGVector(dx: 0,dy: 0)
            bird.physicsBody?.applyImpulse(CGVector(dx: 0,dy: 50))
            playSound(soundBird)
            startBirdAnimacion()
            pauseButton.setScale(1.0)
           
            if let nodePause = childNode(withName: "pauseButton") {
                if nodePause.contains(loc) {
                    isPaused = true
                    pauseGame()
                    backgroundMusicPlayer.pause()
                }
            }
            
            var node: SKNode? = atPoint(loc)
            
            if node!.name != nil && node!.name == "restart" {
                
                let scene = MenuScene(size: self.size)
                let skView = self.view! as SKView
                scene.scaleMode = .aspectFill
                skView.presentScene(scene)
                
            } else if node!.name != nil && node!.name == "resume" {
                node!.removeFromParent()
                let nodeBg2 = childNode(withName: "pausebg")
                nodeBg2?.removeFromParent()
                node = childNode(withName: "restart")
                node?.removeFromParent()
                gameState = .playing
                backgroundMusicPlayer.play()
                pauseButton.setScale(1.0)
                
                isPaused = false
                
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard touches.first != nil else {
            return
        }
        
    }
    
    func moveSprite(_ sprite: SKSpriteNode, velocity: CGPoint) {
        
        let amountToMove = velocity * CGFloat(dt)
        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
        
    }
    
    // Method for ground and edges
    
    func groundEdges() {
        
        for i in 0...1 {
            
            let groundFloor = groundNode()
            groundFloor.anchorPoint = CGPoint.zero
            groundFloor.zPosition = 5
            groundFloor.position = CGPoint(x: CGFloat(i)*groundFloor.size.width, y:0)
            groundFloor.name = "Bgd"
            addChild(groundFloor)
            
        }
        
        bottomEdge.position = CGPoint(x: 0, y: self.frame.height*0.01)
        bottomEdge.name = "bottomEdge"
        
        addChild(bottomEdge)
        
        leftEdge.position = CGPoint(x: self.frame.width*0.001, y: self.frame.height*0.5)
        addChild(leftEdge)
        
        let ground = SKSpriteNode()
        ground.position = CGPoint(x: 0, y: self.frame.height*0.01)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: self.frame.height*0.01))
        ground.physicsBody?.isDynamic = false
        ground.name = "ground"
        addChild(ground)
        
        let sky = SKNode()
        sky.position = CGPoint(x: 0, y: self.frame.height*1.88)
        sky.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.size.width, height: self.frame.height*1.88))
        sky.physicsBody?.isDynamic = false
        addChild(sky)
    }
    
    
    // Methods for Bird
    
    func startBirdAnimacion() {
        
        if bird.action(forKey: "animation") == nil {
            bird.run(SKAction.repeat(birdAnimation, count: 1), withKey: "animation")
            
            }
        
    }
    
    func spawnBird() {
        
        bird.setScale(0.70)
        bird.zPosition = 10
        bird.position = CGPoint(x: self.frame.size.width * 0.30, y: playableRect.maxY - (playableRect.maxY / 2))
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/5.5)
        bird.physicsBody?.isDynamic = true
        bird.physicsBody?.allowsRotation = false
        addChild(bird)
        
    }
    
    // Method to Spawn Petals
    
    func spawnPetal() {
        
        let petal = SKSpriteNode(imageNamed: "petal")
        petal.name = "petal"
        petal.position = CGPoint(x: size.width + petal.size.width/2, y: CGFloat.random(playableRect.minY, max: playableRect.maxY))
        petal.setScale(0)
        addChild(petal)
        
        petal.zRotation = 16
        let appear = SKAction.scale(to: 1.0, duration: 0.5)
        let leftWiggle = SKAction.rotate(byAngle: 2, duration: 2)
        let rightWiggle = leftWiggle.reversed()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let groupWait = SKAction.repeat(fullWiggle, count: 2)
        let disappear = SKAction.scale(to: 0, duration: 0.5)
        let actions = SKAction.sequence([appear, groupWait, disappear])
        petal.run(actions)
        
        let actionMove = SKAction.move(to: CGPoint(x: -petal.size.width/2 - 400, y: petal.position.y), duration:velocityPetals)
        let actionRemove = SKAction.removeFromParent()
        
        petal.run(SKAction.sequence([actionMove, actionRemove]))
        
    }
    
    // Method to Spawn Snow
    
    func spawnSnow() {
        
        let snow = SKSpriteNode(imageNamed: "snow")
        snow.name = "snow"
        let snowScenePos = CGPoint(x: size.width + snow.size.width/2, y: CGFloat.random( playableRect.minY + snow.size.height/2, max: playableRect.maxY - snow.size.height/2))
        snow.position = convert(snowScenePos, from: self)
        addChild(snow)
        
        let snowRotation = SKAction.rotate(byAngle: 5, duration: 7)
        let actionRemove = SKAction.removeFromParent()
        let decrease = SKAction.scale(to: 0.85, duration: 0.6)
        let increase = SKAction.scale(to: 1, duration: 0.7)
        let popsnow = SKAction.sequence([decrease,increase])
        let popsnowForever = SKAction.repeatForever(popsnow)
        let group = SKAction.group([snowRotation, popsnowForever])
        snow.run(group)
        
        let actionMove = SKAction.move(to: CGPoint(x: -snow.size.width/2, y: snow.position.y), duration: velocitySnow)
        snow.run(SKAction.sequence([actionMove, actionRemove]))
        
    }
    
    // Method to Spawn recurrent Snow
    
    func spawnSnow2() {
    
        let snow = SKSpriteNode(imageNamed: "snow")
        snow.name = "snow"
        let snowScenePos = CGPoint(x: size.width + snow.size.width/2, y: CGFloat.random(playableRect.minY + snow.size.height/2,max: playableRect.maxY - snow.size.height/2))
        snow.position = convert(snowScenePos, from: self)
        addChild(snow)
        
        let snowRotation = SKAction.rotate(byAngle: 5, duration: 7)
        let actionRemove = SKAction.removeFromParent()
        let decrease = SKAction.scale(to: 0.85, duration: 0.6)
        let increase = SKAction.scale(to: 1, duration: 0.7)
        let popsnow = SKAction.sequence([decrease,increase])
        let popsnowForever = SKAction.repeatForever(popsnow)
        let group = SKAction.group([snowRotation, popsnowForever])
        snow.run(group)
        
        let actionMove = SKAction.move(to: CGPoint(x: -snow.size.width/2, y: snow.position.y), duration: velocitySnowRecurrent)
        snow.run(SKAction.sequence([actionMove, actionRemove]))
        
    }
    
    // Methods to collide elements
    
    func birdHitPetal(_ petal: SKSpriteNode) {
        
        getPetals()
        
        // If birHitPetal win +1 score
        
        self.score = score + winPetalsScore
        self.increaseScoreBy(score)
        
        playSound(soundWinPetal)
        
        petal.removeFromParent()
        
    }
    
    func birdHitSnow(_ snow: SKSpriteNode) {
        
        losePointsSnow()
        losePetals()
        
        // If birdHitSnow lose -5 score
        
        self.score = score - hitSnowScore
        self.increaseScoreBy(score)
        
        invincible = true
        
        let decreaseOpacity = SKAction.fadeAlpha(to: 0.5, duration: 0.4)
        let increaseOpacity = SKAction.fadeAlpha(to: 1, duration: 0.3)
        _ = SKAction.run() {
            self.bird.isHidden = false
            self.invincible = false
        }
        
        bird.run(SKAction.sequence([decreaseOpacity, increaseOpacity]))
        
        playSound(soundIce)
        
        snow.removeFromParent()
        
        if score < 0 {
            scoreLabel.removeFromParent()
        }
        
    }
    
    func birdHitGround(_ bottomEdge: SKSpriteNode) {
        
        losePointsGround()
        losePetals()
        
        // If birdHitGround lose -3 score
        
        self.score = score - hitGroundScore
        self.increaseScoreBy(score)
    
        invincible = true
        
        let decreaseOpacity = SKAction.fadeAlpha(to: 0.5, duration: 0.4)
        let increaseOpacity = SKAction.fadeAlpha(to: 1, duration: 0.3)
        _ = SKAction.run() {
            self.bird.isHidden = false
            self.invincible = false
        }
        bird.run(SKAction.sequence([decreaseOpacity, increaseOpacity]))
        playSound(soundGround)
        
        let actionMove = SKAction.moveTo(y: bottomEdge.frame.height*0.01 - 200 , duration: 0)
        let actionReturn = SKAction.moveTo(y: bottomEdge.frame.height*0.01, duration: 2.0)
        bottomEdge.run(SKAction.sequence([actionMove,actionReturn]))
        
        if score < 0 {
            scoreLabel.removeFromParent()
        }
        
    }
    
    func petalHitEdge(_ petal: SKSpriteNode) {
        
        losePointsLeft()
        losePetals()
        
        // If petalHitEdge lose -1 score
        
        self.score = score - losePetalsScore
        self.increaseScoreBy(score)
        
        playSound(soundLosePetal)
        
        petal.removeFromParent()
        
        if score < 0 {
            scoreLabel.removeFromParent()
        }
        
    }
    
    func checkCollisions() {
        
        // For bird hit Petals
        
        var hitPetals: [SKSpriteNode] = []
        enumerateChildNodes(withName: "petal") { node, _ in
            let petal = node as! SKSpriteNode
            if petal.frame.intersects(self.bird.frame) {
                hitPetals.append(petal)
                }
            }
        
        for petal in hitPetals {
            birdHitPetal(petal)
            }
        
        // For bird hit Snow
        
        var hitSnow: [SKSpriteNode] = []
        enumerateChildNodes(withName: "snow") { node, _ in
            let snow = node as! SKSpriteNode
            if node.frame.insetBy(dx: 20, dy: 20).intersects(self.bird.frame) {
                hitSnow.append(snow)
            }
        }
        
        for snow in hitSnow {
            birdHitSnow(snow)
        }
        
        // For bird hit Ground
        
        var hitGround: [SKSpriteNode] = []
        enumerateChildNodes(withName: "bottomEdge") { node, _ in
            let bottomEdge = node as! SKSpriteNode
            if bottomEdge.frame.intersects(self.bird.frame) {
                hitGround.append(bottomEdge)
            }
        }
        
        for bottomEdge in hitGround {
            birdHitGround(bottomEdge)
        }
        
        // For petal hit Edge
        
        var hitEdge: [SKSpriteNode] = []
        enumerateChildNodes(withName: "petal") { node, _ in
            _ = node as! SKSpriteNode
            let petal = node as! SKSpriteNode
            if petal.frame.intersects(self.leftEdge.frame) {
                hitEdge.append(petal)
            }
        }
        
        for petal in hitEdge {
            petalHitEdge(petal)
        }
        
    }
    
    // Methods for elements actions
    
    func getPetals() {
        
        let increase = SKAction.scale(to: 1.2, duration: 0.3)
        let decrease = SKAction.scale(to: 1.0, duration: 0.3)
        scoreLabel.run(SKAction.sequence([increase,decrease]))

    }
    
    func losePetals() {
        
        let increase = SKAction.scale(to: 1.2, duration: 0.1)
        let decrease = SKAction.scale(to: 1.0, duration: 0.3)
        let shakeLeft = SKAction.rotate(toAngle: 0.4, duration: 0.1)
        let shakeRight = SKAction.rotate(toAngle: -0.4, duration: 0.1)
        let shakeCenter = SKAction.rotate(toAngle: 0, duration: 0.1)
        scoreLabel.run(SKAction.sequence([increase, shakeLeft, shakeRight, shakeLeft, shakeRight, shakeCenter, decrease]))
    
    }
    
    func losePointsSnow() {
        
        let increase = SKAction.scale(to: 2.0, duration: 0.2)
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let groupA = SKAction.group([appear,increase])
        let decrease = SKAction.scale(to: 0, duration: 0.7)
        let desappear = SKAction.fadeAlpha(to: 0, duration: 0.7)
        let groupB = SKAction.group([decrease,desappear])
        losePetalsSnow.run(SKAction.sequence([groupA,groupB]))
        
    }
    
    func losePointsGround() {
        
        let increase = SKAction.scale(to: 2.0, duration: 0.2)
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let groupA = SKAction.group([appear,increase])
        let decrease = SKAction.scale(to: 0, duration: 0.7)
        let desappear = SKAction.fadeAlpha(to: 0, duration: 0.7)
        let groupB = SKAction.group([decrease,desappear])
        
        losePetalsGround.run(SKAction.sequence([groupA,groupB]))
        
    }
    
    func losePointsLeft() {
        
        let increase = SKAction.scale(to: 2.0, duration: 0.2)
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.2)
        let groupA = SKAction.group([appear,increase])
        let decrease = SKAction.scale(to: 0, duration: 0.7)
        let desappear = SKAction.fadeAlpha(to: 0, duration: 0.7)
        let groupB = SKAction.group([decrease,desappear])
        losePetalsLeft.run(SKAction.sequence([groupA,groupB]))
        
    }
    
    // Background moves
    
    func backgroundNodeAll() {
        
        // Background level 0 - Static Background - 1 slide
        
        let level0 = SKSpriteNode(imageNamed: "bga1")
        level0.setScale(2.0)
        level0.anchorPoint = CGPoint.zero
        level0.position = CGPoint.zero
        level0.zPosition = -4
        level0.name = "bg"
        addChild(level0)
        
        // Background level 1 - Back mountains - 2 slides
        
        for i in 0...1 {
            let level1 = backgroundNodeB()
            level1.anchorPoint = CGPoint.zero
            level1.zPosition = -3
            level1.position = CGPoint(x: CGFloat(i)*level1.size.width, y: 550)
            level1.name = "backgroundB"
            addChild(level1)
        }
        
        // Background level 2 - Mountains and landscapes - 4 slides
        
        for i in 0...3 {
            let level2 = backgroundNodeC()
            level2.anchorPoint = CGPoint.zero
            level2.zPosition = -2
            level2.position = CGPoint(x: CGFloat(i)*level2.size.width, y: 0)
            level2.name = "backgroundC"
            addChild(level2)
        }
        
    }
    
    func bgTextActions() {
        
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.3)
        let disappear = SKAction.fadeAlpha(to: 0, duration: 3)
        bgText.run(SKAction.sequence([appear, SKAction.wait(forDuration: 4), disappear]))
    
    }
    
    // Method for Background level 1
    
    func backgroundNodeB() -> SKSpriteNode {
        
        let backgroundNodeB = SKSpriteNode()
        backgroundNodeB.anchorPoint = CGPoint.zero
        backgroundNodeB.name = "backgroundB"
        
        let backgroundB1 = SKSpriteNode(imageNamed: "bgb1")
        backgroundB1.anchorPoint = CGPoint.zero
        backgroundB1.position = CGPoint(x: 0, y: 0)
        backgroundNodeB.addChild(backgroundB1)
        
        let backgroundB2 = SKSpriteNode(imageNamed: "bgb1")
        backgroundB2.anchorPoint = CGPoint.zero
        backgroundB2.position = CGPoint(x: backgroundB1.size.width, y: 0)
        backgroundNodeB.addChild(backgroundB2)
    
        backgroundNodeB.size = CGSize(
            width: backgroundB1.size.width + backgroundB2.size.width,
            height: backgroundB1.size.height)
        
        return backgroundNodeB
        
    }
    
    // Method for Background level 2
    
    func backgroundNodeC() -> SKSpriteNode {
        
        let backgroundNodeC = SKSpriteNode()
        backgroundNodeC.anchorPoint = CGPoint.zero
        backgroundNodeC.name = "backgroundC"
        
        let backgroundC1 = SKSpriteNode(imageNamed: "bgc1")
        backgroundC1.anchorPoint = CGPoint.zero
        backgroundC1.position = CGPoint(x: 0, y: 0)
        backgroundNodeC.addChild(backgroundC1)
        
        let backgroundC2 = SKSpriteNode(imageNamed: "bgc2")
        backgroundC2.anchorPoint = CGPoint.zero
        backgroundC2.position = CGPoint(x: backgroundC1.size.width, y: 0)
        backgroundNodeC.addChild(backgroundC2)
        
        let backgroundC3 = SKSpriteNode(imageNamed: "bgc3")
        backgroundC3.anchorPoint = CGPoint.zero
        backgroundC3.position = CGPoint(x: backgroundC1.size.width + backgroundC2.size.width, y: 0)
        backgroundNodeC.addChild(backgroundC3)
        
        let backgroundC4 = SKSpriteNode(imageNamed: "bgc4")
        backgroundC4.anchorPoint = CGPoint.zero
        backgroundC4.position = CGPoint(x: backgroundC1.size.width + backgroundC2.size.width + backgroundC3.size.width, y: 0)
        backgroundNodeC.addChild(backgroundC4)
        
        backgroundNodeC.size = CGSize(
            width: backgroundC1.size.width + backgroundC2.size.width + backgroundC3.size.width + backgroundC4.size.width,
            height: backgroundC1.size.height)
        
        return backgroundNodeC
        
    }
    
    // Method to moves backgrounds as parallax effect
    
    func moveBackgroundB() {
        
        enumerateChildNodes(withName: "backgroundB") { node, _ in
            let backgroundB = node as! SKSpriteNode
            let backgroundBVelocity = CGPoint(x: -self.backgroundBMovePointsPerSec, y: 0)
            let amountBToMove = backgroundBVelocity * CGFloat(self.dt)
            backgroundB.position += amountBToMove
            
            if backgroundB.position.x <= -backgroundB.size.width {
                backgroundB.position = CGPoint(x: backgroundB.position.x + backgroundB.size.width*2, y: backgroundB.position.y)
            }
        }
    }

    func moveBackgroundC() {
        
        enumerateChildNodes(withName: "backgroundC") { node, _ in
            let backgroundC = node as! SKSpriteNode
            let backgroundCVelocity = CGPoint(x: -self.backgroundCMovePointsPerSec, y: 0)
            let amountCToMove = backgroundCVelocity * CGFloat(self.dt)
            backgroundC.position += amountCToMove
            
            if backgroundC.position.x <= -backgroundC.size.width {
                backgroundC.position = CGPoint(x: backgroundC.position.x + backgroundC.size.width*2, y: backgroundC.position.y)
                
            }
        }
    }
    
    // Method for ground visual elements
    
    func groundNode() -> SKSpriteNode {
        
        let groundNode = SKSpriteNode()
        groundNode.anchorPoint = CGPoint.zero
        groundNode.name = "Bgd"
        
        let Bgd1 = SKSpriteNode (imageNamed: "bgd1")
        Bgd1.anchorPoint = CGPoint.zero
        Bgd1.position = CGPoint (x: 0, y: 0)
        Bgd1.setScale(2.0)
        groundNode.addChild(Bgd1)
        
        let Bgd2 = SKSpriteNode (imageNamed: "bgd2")
        Bgd2.anchorPoint = CGPoint.zero
        Bgd2.position = CGPoint (x: Bgd1.size.width, y: 0)
        Bgd1.setScale(2.0)
        groundNode.addChild(Bgd2)
        
        groundNode.size = CGSize(
            width: Bgd1.size.width + Bgd2.size.width,
            height: Bgd1.size.height
        )
        
        return groundNode
    }
    
    func moveGround() {
        
        enumerateChildNodes(withName: "Bgd") { node, _ in
            let Bgd = node as! SKSpriteNode
            let groundVelocity = CGPoint(x: -self.groundMovePointsPerSec, y: 0)
            let amountGroundToMove = groundVelocity * CGFloat(self.dt)
            Bgd.position += amountGroundToMove
            
            if Bgd.position.x <= -Bgd.size.width {
                Bgd.position = CGPoint(x: Bgd.position.x + Bgd.size.width*2, y: Bgd.position.y)
            
            }
        }
    }
    
    // Method for recurrent Blur Tree
    
    func treeNode() -> SKSpriteNode {
        
        let treeNode = SKSpriteNode()
        treeNode.anchorPoint = CGPoint.zero
        treeNode.name = "tree"
        
        let tree1 = SKSpriteNode (imageNamed: "blurtree1")
        tree1.anchorPoint = CGPoint.zero
        tree1.position = CGPoint (x: 0, y: 0)
        treeNode.addChild(tree1)
        
        treeNode.size = CGSize(
            width: tree1.size.width * 5,
            height: tree1.size.height
        )
        
        return treeNode
        
    }
    
    func blurTree() {
        
        for i in 0...1 {
            let blurTree = treeNode()
            blurTree.anchorPoint = CGPoint.zero
            blurTree.zPosition = 10
            blurTree.position = CGPoint(x: CGFloat(i)*blurTree.size.width, y:0)
            blurTree.name = "tree"
            addChild(blurTree)
        }
    }
    
    func moveTree() {
        
        enumerateChildNodes(withName: "tree") { node, _ in
            let tree = node as! SKSpriteNode
            let treeVelocity = CGPoint(x: -self.treeMovePointsPerSec, y: 0)
            let amountTreeToMove = treeVelocity * CGFloat(self.dt)
            tree.position += amountTreeToMove
        
            if tree.position.x <= -tree.size.width {
                tree.position = CGPoint(x: tree.position.x + tree.size.width*2, y: tree.position.y)
            }
            
        }
    }
    
    // Methods for Setup Layers
    
    func setupSceneLayers() {
        
        // For score labels
        
        scoreLabel.fontName = fontFamily
        scoreLabel.fontSize = 110
        scoreLabel.text = "0"
        scoreLabel.name = "scoreLabel"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.fontColor = fontColorRed
        scoreLabel.position = CGPoint(x: self.playableRect.size.width * 0.95, y: playableRect.maxY - 210)
        addChild(scoreLabel)
        
        scoreTitle.fontName = fontFamily
        scoreTitle.fontSize = 45
        scoreTitle.text = "PETALS"
        scoreTitle.horizontalAlignmentMode = .right
        scoreTitle.fontColor = fontColorRed
        scoreTitle.position = CGPoint(x: 0, y: 100)
        scoreLabel.addChild(scoreTitle)
        
        // For distance labels
        
        distanceLabel.fontName = fontFamily
        distanceLabel.fontSize = 110
        distanceLabel.text = String(distance)
        distanceLabel.name = "distanceLabel"
        distanceLabel.horizontalAlignmentMode = .left
        distanceLabel.fontColor = fontColorBlack
        distanceLabel.position = CGPoint(x: self.playableRect.size.width * 0.05, y: playableRect.maxY - 210)
        addChild(distanceLabel)
        
        distanceTitle.fontName = fontFamily
        distanceTitle.fontSize = 45
        distanceTitle.text = "DISTANCE"
        distanceTitle.horizontalAlignmentMode = .left
        distanceTitle.fontColor = fontColorBlack
        distanceTitle.position = CGPoint(x: 0, y: 100)
        distanceLabel.addChild(distanceTitle)
        
    }
    
    func distanceLabelAction() {
        
        let increase = SKAction.scale(to: 1.2, duration: 0.3)
        let decrease = SKAction.scale(to: 1, duration: 0.7)
        distanceLabel.run(SKAction.sequence([increase, decrease, SKAction.wait(forDuration: 7)]))
        
    }
    
    func increaseScoreBy(_ increment: Int) {
        
        scoreLabel.text = "\(score)"
        
    }
    
    
    // Method for label that appear near to bird when hit elements
    
    func petalsLayersNode() {
        
        
        losePetalsSnow.fontName = fontFamily
        losePetalsSnow.setScale(0.0)
        losePetalsSnow.position = CGPoint(x: 180, y: 50)
        losePetalsSnow.text = "-5"
        losePetalsSnow.name = "losePetalsSnow"
        losePetalsSnow.fontColor = fontColorRed
        losePetalsSnow.fontSize = 130
        bird.addChild(losePetalsSnow)
        
        losePetalsGround.fontName = fontFamily
        losePetalsGround.setScale(0.0)
        losePetalsGround.position = CGPoint(x: 180, y: 50)
        losePetalsGround.text = "-3"
        losePetalsGround.name = "losePetalGround"
        losePetalsGround.fontColor = fontColorRed
        losePetalsGround.fontSize = 130
        bird.addChild(losePetalsGround)
        
        losePetalsLeft.fontName = fontFamily
        losePetalsLeft.setScale(0.0)
        losePetalsLeft.position = CGPoint(x: 180, y: 50)
        losePetalsLeft.text = "-1"
        losePetalsLeft.name = "losePetalLeft"
        losePetalsLeft.fontColor = fontColorRed
        losePetalsLeft.fontSize = 130
        bird.addChild(losePetalsLeft)

    }
    
    // Story Layers
    
    func storyLayers() {
        
        bgText.position = CGPoint(x: self.playableRect.size.width / 2, y: playableRect.minY + 120)
        bgText.zPosition = 90
        addChild(bgText)
        
        storyText.fontName = fontFamily
        storyText.fontSize = 55
        storyText.name = "distanceLabel"
        storyText.horizontalAlignmentMode = .center
        storyText.fontColor = fontColorBlack
        storyText.position = CGPoint(x: 0, y: -20)
        storyText.zPosition = 100
        storyText.alpha = 0.7
        bgText.addChild(storyText)
        
    }
    
    func StoryLayersAction() {
        let appear = SKAction.fadeAlpha(to: 1, duration: 0.3)
        let increase = SKAction.scale(to: 1.15, duration: 0.3)
        let decrease = SKAction.scale(to: 1, duration: 0.7)
        let group = SKAction.group([appear,increase])
        let disappear = SKAction.fadeAlpha(to: 0, duration: 3)
        storyText.run(SKAction.sequence([group, decrease, SKAction.wait(forDuration: 4), disappear]))
    }
    
    // Story Text Conditionals & effects
    
    
    func storyTextConditionals() {
        
        let storyAction = SKAction.run(StoryLayersAction)
        let distanceAction = SKAction.run(distanceLabelAction)
        let bgTextAction = SKAction.run(bgTextActions)
        let textActions = SKAction.group([storyAction, distanceAction, bgTextAction])
        
        let currentSentenceName = dictionary[currentSentence]
        let distanceConv = distance / disConv
        
        for (indicator, range) in conditionalsDictionary {
            
            if distanceConv == range {
            
                    currentSentence = indicator
                    run(textActions)
            }
        }
        
        storyText.text = "\(currentSentenceName)"
    }
    
    // Methods to difficulty logic
    
    
    func difficultyConditionals() {
    
        if distance <= 400 * disConv {
            velocitySnow = 6.6
            velocityPetals = 6.6
            velocitySnowRecurrent = 0
        } else {
            if distance <= 1540 * disConv {
                velocitySnow = 6.6
                velocityPetals = 6.6
                velocitySnowRecurrent = 3.5
            } else {
                if distance <= 2680 * disConv {
                    velocitySnow = 7.625
                    velocityPetals = 7.2
                    velocitySnowRecurrent = 3
                } else {
                     if distance <= 3820 * disConv {
                        velocitySnow = 8.75
                        velocityPetals = 4.35
                        velocitySnowRecurrent = 2.5
                    } else {
                        if distance <= 4960 * disConv {
                            velocitySnow = 9.875
                            velocityPetals = 5.15
                            velocitySnowRecurrent = 2
                        } else {
                            velocitySnow = 11.0
                            velocityPetals = 6.0
                            velocitySnowRecurrent = 1.7
                        }
                    }
                }
            }
        }
        
    }
    
    // Timer method
    
    func updateTimer() {
        
        distance += 1
        distanceLabel.text = "\(Int(distance) / disConv)"

    }
    
    // Snow Particles generator 
    
    
    func createEngine() {
        
        let engineEmitter = SKEmitterNode(fileNamed: "engine.sks")
        engineEmitter!.setScale(1.6)
        engineEmitter!.position = CGPoint(x:self.frame.size.width, y:self.frame.size.height - 500)
        engineEmitter!.name = "engineEmitter"
        addChild(engineEmitter!)
        
        if score < 0 {
            engineEmitter!.removeFromParent()
        }
        
    }
    
    // Petals Particles generator
    
    func createMagic() {
        
        let magicEmitter = SKEmitterNode(fileNamed: "magic.sks")
        magicEmitter!.position = CGPoint(x:1, y: -10)
        magicEmitter!.targetNode = particleLayerNode
        magicEmitter!.name = "magicEmitter"
        magicEmitter!.zPosition = 9
        bird.addChild(magicEmitter!)
        
        if score < 0 {
            magicEmitter!.removeFromParent()
        }
        
    }
    
    func createUserInterface() {
        
        let showBg = SKSpriteNode(imageNamed: "lightboxbg")
        showBg.position = CGPoint(x:self.frame.size.width * 0.5, y:self.frame.size.height * 0.5)
        showBg.setScale(2.0)
        showBg.zPosition = 200
        showBg.name = "showbg"
        showBg.alpha = 0.93
        addChild(showBg)
        
        
        let ready = SKSpriteNode(imageNamed: "touchready")
        ready.position = CGPoint(x:self.frame.size.width * 0.5, y:self.frame.size.height * 0.5)
        ready.zPosition = 210
        ready.setScale(0.94)
        ready.name = "touchimage"
        addChild(ready)
        
    
    }
    
    func pauseButtonNode() {
        
        pauseButton.position = CGPoint(x:self.frame.size.width * 0.94, y: playableRect.minY + 120)
        pauseButton.zPosition = 190
        pauseButton.name = "pauseButton"
        addChild(pauseButton)
        
    }
    
    func pauseGame() {
        
        let showBg2 = SKSpriteNode(imageNamed: "bgscene")
        showBg2.position = CGPoint(x:self.frame.size.width * 0.5, y:self.frame.size.height * 0.5)
        showBg2.setScale(2.0)
        showBg2.zPosition = 200
        showBg2.alpha = 0.85
        showBg2.name = "pausebg"
        addChild(showBg2)
        
        let resume = SKSpriteNode(imageNamed: "defaultButton")
        resume.position = CGPoint(x:self.frame.size.width * 0.5 - 300, y:self.frame.size.height * 0.5)
        resume.zPosition = 230
        resume.name = "resume"
        addChild(resume)
        
        let resumeTxt = SKLabelNode()
        resumeTxt.fontName = fontFamily
        resumeTxt.fontColor = fontColorBlack
        resumeTxt.name = "resume"
        resumeTxt.text = "RESUME"
        resumeTxt.fontSize = 45
        resumeTxt.position = CGPoint(x: 0,y: -150)
        resume.addChild(resumeTxt)
        
        let restart = SKSpriteNode(imageNamed: "defaultButton")
        restart.position = CGPoint(x:self.frame.size.width * 0.5 + 300, y:self.frame.size.height * 0.5)
        restart.zPosition = 230
        restart.name = "restart"
        addChild(restart)
        
        let restartTxt = SKLabelNode()
        restartTxt.fontName = fontFamily
        restartTxt.fontColor = fontColorBlack
        restartTxt.name = "restart"
        restartTxt.text = "RESTART"
        restartTxt.fontSize = 45
        restartTxt.position = CGPoint(x: 0,y: -150)
        restart.addChild(restartTxt)
        
        pauseButton.setScale(0)
        
    }
    
    func playSound(_ soundVariable: SKAction) {
        run(soundVariable)
    }

}


