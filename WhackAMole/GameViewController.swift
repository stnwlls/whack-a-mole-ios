//
//  GameViewController.swift
//  WhackAMole
//
//  Created by Austin Wells on 12/4/25.
//

import UIKit
import SpriteKit
import GameplayKit
import os.log

var sizeOfView: CGSize!
var notWhiteColor = UIColor(red: 248/255, green: 236/255, blue: 217/255, alpha: 1.0)
var notBlackColor = UIColor(red: 68/255, green: 37/255, blue: 0/255, alpha: 1.0)

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content including entities and graphs.
        
        sizeOfView = view!.frame.size
        gameAchievements()
        
        // Load 'TitleScene'
        if let view = self.view as! SKView? {
            if let scene = TitleScene(fileNamed: "TitleScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // For now there should only be one score saved, but it could be modified for multiple players
                highScore = scores[0].score
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Private Functions
    private func gameAchievements() {
        // Load any saved score, otherwise load sample score
        if let savedScores = loadScores() {
            scores += savedScores
        } else {
            // Load the sample data
            loadSampleScores()
        }
    }
    
    private func loadSampleScores() {
        guard let saved1 = SavedGame(name: "Whack A Mole", score: 0) else {
            fatalError("Unable to instantiate saved1")
        }
        scores += [saved1]
    }

    private func loadScores() -> [SavedGame]? {
        do {
            let data = try Data(contentsOf: SavedGame.ArchiveURL)
            let scores = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, SavedGame.self], from: data) as? [SavedGame]
            return scores
        } catch {
            return nil
        }
    }
}
