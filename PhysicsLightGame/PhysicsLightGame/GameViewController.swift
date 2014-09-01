//
//  GameViewController.swift
//  PhysicsLightGame
//
//  Created by Stephen Gazzard on 2014-08-31.
//  Copyright (c) 2014 Broken Kings. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData.dataWithContentsOfFile(path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    var currentScene : GameScene? = nil

    @IBOutlet var winLabel : UILabel? = nil
    @IBOutlet var lightButton : UIButton? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        loadLevel(0)
    }

    func loadLevel(index : NSInteger) -> Void {
        if let scene = GameScene.unarchiveFromFile("Level\(index)") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            scene.owningViewController = self
            scene.levelIndex = index

            skView.presentScene(scene)

            self.winLabel?.hidden = true
            self.currentScene = scene
        } else {
            loadLevel(0)
        }
    }

    func showWinLabel() -> Void {
        self.winLabel?.hidden = false
    }

    func setLightButtonVisible(visible : Bool) {
        self.lightButton?.hidden = !visible
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.All.toRaw())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    @IBAction func dropLight() -> Void {
        self.currentScene?.dropLight()
    }
}
