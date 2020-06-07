//
//  GameScene.swift
//  testGame
//
//  Created by Caleb on 4/18/20.
//  Copyright © 2020 Caleb. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
        
    var gameScore = 0
    let timerLabel = SKLabelNode(fontNamed: "8bit16")
    var timer = 0
    
    
    @objc func incrementTimer() {
        
        timer += 1
        timerLabel.text = String(timer)
        
    }
        
    struct PhysicsCategories {
        
        static let None : UInt32 = 0 //0
        static let Player : UInt32 = 0b1 //1
        static let Car : UInt32 = 0b10 //2
        
    }
    
    let player = SKSpriteNode(imageNamed: "player")
    let gameArea: CGRect
    let playerArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat =  24.5/9.0
        let playableWidth = size.height/maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        playerArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height * 0.25)
        
        super.init(size: size)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
        

        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.setScale(1)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(1.4)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Car
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        self.addChild(player)
        
        timerLabel.text = "\(timer)"
        timerLabel.fontSize = 70
        timerLabel.fontColor = SKColor.white
        timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        timerLabel.position = CGPoint(x: self.size.width*0.2, y: self.size.height*0.9)
        timerLabel.zPosition = 100
        self.addChild(timerLabel)
        
        spawnCarsForever()
        spawnEnvironment()
        
        
    }

    func didBegin(_ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            
            body1 = contact.bodyA
            body2 = contact.bodyB
            
        } else {
            
            body1 = contact.bodyB
            body2 = contact.bodyA
            
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Car {
            //If the player hits the NPC car
            
            if body1.node != nil {
            spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body1.node != nil {
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
        }
        
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 2, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
        
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
        moveEnvironment()

    }
    
    func spawnCarsForever() {
    
        let spawnLeft = SKAction.run(spawnLeftCar)
        let spawnMiddle = SKAction.run(spawnMiddleCar)
        let spawnRight = SKAction.run(spawnRightCar)
        let waitToSpawnLeft = SKAction.wait(forDuration: 0.8, withRange: 4)
        let waitToSpawnMiddle = SKAction.wait(forDuration: 0.8, withRange: 4)
        let waitToSpawnRight = SKAction.wait(forDuration: 0.8, withRange: 4)
        let leftSpawnSequence = SKAction.sequence([spawnLeft, waitToSpawnLeft])
        let middleSpawnSequence = SKAction.sequence([spawnMiddle, waitToSpawnMiddle])
        let rightspawnSequence = SKAction.sequence([spawnRight, waitToSpawnRight])
        let spawnSequence = SKAction.sequence([leftSpawnSequence, middleSpawnSequence, rightspawnSequence])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
        
    }
    
    func spawnLeftCar() {
        
        let carLeft = SKSpriteNode(imageNamed: "car1")
        
        let xStart1 = CGPoint(x: gameArea.size.width * 0.65, y: gameArea.maxY)
        let xEnd1 = CGPoint(x: gameArea.size.width * 0.65, y: gameArea.minY - self.size.height)
        
        carLeft.position = xStart1
        carLeft.zPosition = 3
        carLeft.physicsBody = SKPhysicsBody(rectangleOf: carLeft.size)
        carLeft.physicsBody!.affectedByGravity = false
        carLeft.physicsBody!.categoryBitMask = PhysicsCategories.Car
        carLeft.physicsBody!.collisionBitMask = PhysicsCategories.None
        carLeft.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Car
        carLeft.setScale(1.2)

        addChild(carLeft)
        
        let randomSpeed = Float.random(in:1.3...3)
        let moveLeftCar = SKAction.move(to: xEnd1, duration: TimeInterval(randomSpeed))
        let deleteCar = SKAction.removeFromParent()
        let leftCarSequence = SKAction.sequence([moveLeftCar, deleteCar])
        
        carLeft.run(leftCarSequence)
        
    }
    
    func spawnRightCar() {
        
        let carRight = SKSpriteNode(imageNamed: "car1")
        
        let xStart3 = CGPoint(x: gameArea.size.width * 1.35, y: gameArea.maxY)
        let xEnd3 = CGPoint(x: gameArea.size.width * 1.35, y: gameArea.minY - self.size.height)
        
        carRight.position = xStart3
        carRight.zPosition = 3
        carRight.physicsBody = SKPhysicsBody(rectangleOf: carRight.size)
        carRight.physicsBody!.affectedByGravity = false
        carRight.physicsBody!.categoryBitMask = PhysicsCategories.Car
        carRight.physicsBody!.collisionBitMask = PhysicsCategories.None
        carRight.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Car
        carRight.setScale(1.2)
        addChild(carRight)
    
        
        let randomSpeed = Float.random(in:1.3...3)
        let moveRightCar = SKAction.move(to: xEnd3, duration: TimeInterval(randomSpeed))
        let deleteCar = SKAction.removeFromParent()
        let rightCarSequence = SKAction.sequence([moveRightCar, deleteCar])
        
        carRight.run(rightCarSequence)
        
    }
    
    func spawnMiddleCar() {
        
            let carMiddle = SKSpriteNode(imageNamed: "car1")
            
            let xStart2 = CGPoint(x: gameArea.size.width, y: gameArea.maxY)
            let xEnd2 = CGPoint(x: gameArea.size.width, y: gameArea.minY - self.size.height)
            
            carMiddle.position = xStart2
            carMiddle.zPosition = 3
            carMiddle.physicsBody = SKPhysicsBody(rectangleOf: carMiddle.size)
            carMiddle.physicsBody!.affectedByGravity = false
            carMiddle.physicsBody!.categoryBitMask = PhysicsCategories.Car
            carMiddle.physicsBody!.collisionBitMask = PhysicsCategories.None
            carMiddle.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Car
            carMiddle.setScale(1.2)
            addChild(carMiddle)
        
            
        let randomSpeed = Float.random(in:1.3...3)
            let moveMiddleCar = SKAction.move(to: xEnd2, duration: TimeInterval(randomSpeed))
            let deleteCar = SKAction.removeFromParent()
            let middleCarSequence = SKAction.sequence([moveMiddleCar, deleteCar])
            
            carMiddle.run(middleCarSequence)
        
    }
    
    func spawnEnvironment() {
        
        //Spawn road lines
        for i in 0...3 {
            
            let roadLinesLeft = SKSpriteNode(imageNamed: "roadLinesLeft")
            roadLinesLeft.name = "roadLinesLeft"
            roadLinesLeft.position = CGPoint(x: gameArea.size.width + 135, y: CGFloat(i) * self.size.height)
            roadLinesLeft.setScale(1)
            roadLinesLeft.zPosition = 1
            self.addChild(roadLinesLeft)
            
            let roadLinesRight = SKSpriteNode(imageNamed: "roadLinesRight")
            roadLinesRight.name = "roadLinesLeft"
            roadLinesRight.position = CGPoint(x: gameArea.size.width - 135, y: CGFloat(i) * self.size.height)
            roadLinesRight.setScale(1)
            roadLinesRight.zPosition = 1
            self.addChild(roadLinesRight)
        }
        
    }
    
    func moveEnvironment() {
        
        self.enumerateChildNodes(withName: "roadLinesLeft", using: ({
            (node, error) in
            
            node.position.y -= 20
            
            if node.position.y < -(self.scene?.size.height)! {
                
                node.position.y += (self.scene?.size.height)! * 3
                
            }
        }))
        
        self.enumerateChildNodes(withName: "roadLinesRight", using: ({
            (node, error) in
                
            node.position.y -= 20
                
            if node.position.y < -(self.scene?.size.height)! {
                    
                node.position.y += (self.scene?.size.height)! * 3
                    
                }
            }))
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            //Code to let the player move around.
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDraggedX = pointOfTouch.x - previousPointOfTouch.x
            let amountDraggedY = pointOfTouch.y - previousPointOfTouch.y
            
            player.position.x += amountDraggedX
            player.position.y += amountDraggedY
            
            //Keeping the players car within the game boundaries
            if player.position.x < playerArea.minX + player.size.width/2 {
                player.position.x = playerArea.minX + player.size.width/2
                
            }
            
            if player.position.x > playerArea.maxX - player.size.width/2 {
                player.position.x = playerArea.maxX - player.size.width/2
                
            }
            if player.position.y > playerArea.maxY - player.size.height/2 {
                player.position.y = playerArea.maxY - player.size.height/2
                
            }
            if player.position.y < playerArea.minY + player.size.height/2 {
                player.position.y = playerArea.minY + player.size.height/2
                
            }
            
        }
        
        
    }
    
}
