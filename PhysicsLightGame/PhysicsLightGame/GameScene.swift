//
//  GameScene.swift
//  PhysicsLightGame
//
//  Created by Stephen Gazzard on 2014-08-31.
//  Copyright (c) 2014 Broken Kings. All rights reserved.
//

import SpriteKit
import SceneKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var robot : SKSpriteNode? = nil
    var robotVelocity : CGVector = CGVectorMake(0, 0)
    var startPoint : CGPoint = CGPointZero
    

    var endPoint : SKNode? = nil
    var gameOver : Bool = false

    var levelIndex : NSInteger = 0
    var owningViewController : GameViewController? = nil
    var totalLevelSize : CGSize = CGSizeZero

    var currentTouches : NSMutableSet = NSMutableSet()

    let rootNode : SKNode = SKNode()

    var numLights = 0


    override func didMoveToView(view: SKView) {
        robot = self.scene.childNodeWithName("robot") as SKSpriteNode?
        if let aRobot = robot {
            aRobot.physicsBody.allowsRotation = false
            aRobot.shader = SKShader(fileNamed: "flat.fsh")
            startPoint = aRobot.position

//            let robotSmoke = SKEmitterNode(fileNamed: "robotSmoke")
//            aRobot.addChild(robotSmoke)
        }
        endPoint = self.scene.childNodeWithName("end") as SKNode?
        endPoint?.hidden = true

        if let background = self.scene.childNodeWithName("background") as? SKSpriteNode {
            background.normalTexture = background.texture.textureByGeneratingNormalMap()
        } else {
//            var background3D = SK3DNode(viewportSize: self.size)
//            background3D.scnScene = SCNScene(named: "planet.dae")
//            self.addChild(background3D)
//            background3D.zPosition = -1
        }

        self.addChild(rootNode)
        for var i = self.children.count - 1; i >= 0; i-- {
            let childNode = self.children[i] as SKNode
            if (childNode != rootNode) {
                childNode.removeFromParent()
                rootNode.addChild(childNode)
                if (childNode.physicsBody != nil) {
                    childNode.physicsBody.contactTestBitMask = 1
                }
            }
        }
        totalLevelSize = rootNode.calculateAccumulatedFrame().size

        self.physicsWorld.gravity.dy = -5
        self.physicsWorld.contactDelegate = self


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
            self.owningViewController?.showWinLabel()
            self.scene.physicsWorld.speed = 0

            self.scene.runAction(SKAction.sequence([SKAction.waitForDuration(1), SKAction.runBlock{
                self.owningViewController!.loadLevel( self.levelIndex + 1)
                }]))
        }

        self.moveRobotWithTouches()

        if CGRectGetMaxY(robot!.frame) < 0 {
            robot?.physicsBody.velocity = CGVector(0, 0)
            robot?.position = startPoint
        }
    }

    override func didSimulatePhysics() {
        centerWorldOnRobot()
    }

    func centerWorldOnRobot() -> Void {
        if let aRobot = robot {
            let totalFrame = self.scene.calculateAccumulatedFrame()
            var center = CGPointMake(-CGRectGetMidX(aRobot.frame), -CGRectGetMidY(aRobot.frame))
            center.x += CGRectGetWidth(self.frame) / 2
            center.y += CGRectGetHeight(self.frame) / 2
            center.y = min(center.y, 0)
            self.rootNode.position = center;
        }
    }

    func didBeginContact(contact: SKPhysicsContact!) {
        if (contact.bodyA.node.name == nil || contact.bodyB.node.name == nil) { return }

        if (contact.bodyA.node.name == "light" && contact.bodyB.node == robot) || (contact.bodyB.node.name == "light" && contact.bodyA.node == robot) {
            numLights++
            self.owningViewController?.setLightButtonVisible(numLights > 0)

            if (contact.bodyA.node.name == "light") {
                contact.bodyA.node.removeFromParent()
            } else {
                contact.bodyB.node.removeFromParent()
            }
        }
    }

    func didEndContact(contact: SKPhysicsContact!) {

    }

    func dropLight() -> Void {
        if let aRobot = robot {
            self.numLights--
            self.owningViewController?.setLightButtonVisible(numLights > 0)

            let light = SKLightNode()
            light.falloff = 1.5
            light.categoryBitMask = 1
            light.lightColor = UIColor.orangeColor()
            light.position = CGPointMake(CGRectGetMidX(aRobot.frame), CGRectGetMidY(aRobot.frame))
            self.rootNode.addChild(light)
        }
    }
}
