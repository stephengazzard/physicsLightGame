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

    override func didMoveToView(view: SKView) {
        robot = self.scene.childNodeWithName("robot") as SKSpriteNode?
    }

    func moveRobotWithTouches(touches : NSSet, withEvent event:UIEvent) -> Void {
        switch touches.count {
        case 1:
            let firstTouch = touches.anyObject() as UITouch
            let touchPosition = firstTouch.locationInView(firstTouch.view)
            if (touchPosition.x < CGRectGetWidth(firstTouch.view.frame) / 2) {
                robotVelocity.dx = -400;
            } else {
                robotVelocity.dx = 400
            }
        case 2:
            if (robot?.physicsBody.velocity.dy <= 0) {
                robot?.physicsBody.applyImpulse(CGVectorMake(0, 200))
            } else {
                robot?.physicsBody.applyImpulse(CGVectorMake(0, 50))
            }
        default:
            break;
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        moveRobotWithTouches(touches, withEvent: event)
    }

    override func touchesMoved(touches: NSSet!, withEvent event: UIEvent!) {
        moveRobotWithTouches(touches, withEvent: event)
    }

    override func touchesEnded(touches: NSSet!, withEvent event: UIEvent!) {
        robotVelocity.dx = 0
    }
   
    override func update(currentTime: CFTimeInterval) {
        robot?.physicsBody.velocity.dx = robotVelocity.dx
    }
}
