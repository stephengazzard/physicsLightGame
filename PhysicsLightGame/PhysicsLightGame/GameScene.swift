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
        let firstTouch = touches.anyObject() as UITouch
        let touchPosition = firstTouch.locationInView(firstTouch.view)
        if (touchPosition.x < CGRectGetWidth(firstTouch.view.frame) / 2) {
            robotVelocity.dx = -100;
        } else {
            robotVelocity.dx = 100
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
