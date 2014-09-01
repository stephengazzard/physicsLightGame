//
//  GameScene.swift
//  PhysicsLightGame
//
//  Created by Stephen Gazzard on 2014-08-31.
//  Copyright (c) 2014 Broken Kings. All rights reserved.
//

import SpriteKit



class GameScene: SKScene {

    var robot : SKSpriteNode? = nil
    var robotVelocity : CGVector = CGVectorMake(0, 0)
    var startPoint : CGPoint = CGPointZero

    var endPoint : SKNode? = nil
    var gameOver : Bool = false
    var gameOverLabel : SKLabelNode? = nil

    var levelIndex : NSInteger = 0
    var owningViewController : GameViewController? = nil

    var currentTouches : NSMutableSet = NSMutableSet()

    override func didMoveToView(view: SKView) {
        robot = self.scene.childNodeWithName("robot") as SKSpriteNode?
        robot?.physicsBody.allowsRotation = false
        if let aRobot = robot {
            startPoint = aRobot.position
        }
        endPoint = self.scene.childNodeWithName("end") as SKNode?
        endPoint?.hidden = true
        gameOverLabel = self.scene.childNodeWithName("gameOverLabel") as SKLabelNode?
        gameOverLabel?.hidden = true
    }

    func moveRobotWithTouches() -> Void {
        switch self.currentTouches.count {
        case 1:
            let firstTouch = self.currentTouches.anyObject() as UITouch
            let touchPosition = firstTouch.locationInView(firstTouch.view)
            if (touchPosition.x < CGRectGetWidth(firstTouch.view.frame) / 2) {
                robotVelocity.dx = -400;
            } else {
                robotVelocity.dx = 400
            }
        case 2:
            if (robot?.physicsBody.velocity.dy <= 0) {
                robot?.physicsBody.applyImpulse(CGVectorMake(0, 100))
            } else {
                robot?.physicsBody.applyImpulse(CGVectorMake(0, 10))
            }
        default:
            break;
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.currentTouches.addObjectsFromArray(touches.allObjects)
    }

    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        for touch in touches {
            self.currentTouches.removeObject(touch)
        }
        robotVelocity.dx = 0
    }
   
    override func update(currentTime: CFTimeInterval) {
        if (gameOver) {
            robot?.physicsBody.velocity = CGVectorMake(0, 0)
            return
        }

        if (robot == nil || endPoint == nil) { return }

        robot!.physicsBody.velocity.dx = robotVelocity.dx
        if (CGRectIntersectsRect(robot!.frame, endPoint!.frame)) {
            gameOver = true
            gameOverLabel?.hidden = false
            self.scene.physicsWorld.speed = 0

            self.scene.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock{
                self.owningViewController!.loadLevel( self.levelIndex + 1)
                }]))
        }

        self.moveRobotWithTouches()

        if CGRectGetMaxX(robot!.frame) < 0 || CGRectGetMaxY(robot!.frame) < 0 || CGRectGetMinX(robot!.frame) > self.frame.size.width || CGRectGetMinY(robot!.frame) > self.frame.size.height + CGRectGetHeight(robot!.frame) {
            robot?.physicsBody.velocity = CGVector(0, 0)
            robot?.position = startPoint
        }
    }
}
