//
//  TitleScene.swift
//  WhackAMole
//
//  Created by Austin Wells on 12/4/25.
//

import Foundation
import SpriteKit
import os.log

// Global COUNTDOWN, highScore, and scores array
var highScore: Int = 0
var scores = [SavedGame]()
var COUNTDOWN = 10

class TitleScene: SKScene {
    var btnPlay: UIButton!
    var btnReset: UIButton!
    var achievementTitle: UILabel!
    var centerImage: SKSpriteNode!
    
    var gameTitle = SKLabelNode()
    var gameFAQs = SKLabelNode()
    
    override func didMove(to view: SKView) {
        self.backgroundColor = notBlackColor
        
        setUpText()
    }
    
    @objc func playTheGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.fade(withDuration: 1.0))
        
        btnPlay.removeFromSuperview()
        btnReset.removeFromSuperview()
        achievementTitle.removeFromSuperview()
        
        gameTitle.removeFromParent()
        gameFAQs.removeFromParent()
        centerImage.removeFromParent()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
    }
    
    @objc func resetTheGame() {
        achievementTitle.text = " "
        scores[0].score = 0
        highScore = 0
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: scores, requiringSecureCoding: false)
            try data.write(to: SavedGame.ArchiveURL)
            os_log("High Score successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save high score...", log: OSLog.default, type: .error)
        }
    }
    
    func setUpText() {
        // Be sure to scale the fonts and label positions to fit the device view
        sizeOfView = view!.frame.size
        let scaleYPosition = sizeOfView.height
        let btnSize: CGFloat = view!.frame.size.width/3.8
        
        gameTitle = SKLabelNode(fontNamed: "Chalkduster")
        gameTitle.fontColor = notWhiteColor
        gameTitle.fontSize = scaleYPosition/17
        gameTitle.position = CGPoint(x: self.frame.midX, y: self.frame.midY + scaleYPosition/3.5)
        gameTitle.text = "WHACK A MOLE!"
        
        self.addChild(gameTitle)
        
        gameFAQs = SKLabelNode(fontNamed: "Chalkduster")
        gameFAQs.fontColor = notWhiteColor
        gameFAQs.fontSize = scaleYPosition/50
        gameFAQs.position = CGPoint(x: self.frame.midX, y: self.frame.midY + scaleYPosition/4.2)
        gameFAQs.text = "--Tap the mole, not the empty hole--"
        
        self.addChild(gameFAQs)
        
        let imageWidth = sizeOfView.width * 0.45
        centerImage = SKSpriteNode(imageNamed: "moleHole")
        centerImage.size = CGSize(width: imageWidth, height: imageWidth)
        centerImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 65)
        self.addChild(centerImage)
        
        // PLAY BUTTON with image
        btnPlay = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize, height: btnSize/2))
        btnPlay.center = CGPoint(x: sizeOfView.width/2, y: sizeOfView.height/1.35)
        btnPlay.setImage(UIImage(named: "playWhackAMole"), for: .normal)
        btnPlay.addTarget(self, action: (#selector(TitleScene.playTheGame)), for: .touchUpInside)
        self.view?.addSubview(btnPlay)
        
        let margin: CGFloat = 20
        
        // HIGH SCORE
        achievementTitle = UILabel(frame: CGRect(x: margin, y: (scaleYPosition - 100), width: 500, height: 75))
        achievementTitle.textColor = notWhiteColor
        achievementTitle.font = UIFont(name: "Chalkduster", size: scaleYPosition/20)
        achievementTitle.textAlignment = NSTextAlignment.left
        
        if highScore != 0 {
            achievementTitle.text = "High Score: \(highScore)"
        }
        
        self.view?.addSubview(achievementTitle)
        
        // RESET HIGH SCORE
        btnReset = UIButton(frame: CGRect(x: 0, y: 0, width: btnSize/2.5, height: btnSize/2.5))
        btnReset.backgroundColor = notBlackColor
        // Bottom right corner
        btnReset.center = CGPoint(x: sizeOfView.width - (btnSize/5) - margin, y: sizeOfView.height - (btnSize/5) - margin)
        btnReset.setImage(UIImage(named: "resetWhackAMoleButton"), for: .normal)
        btnReset.addTarget(self, action: (#selector(TitleScene.resetTheGame)), for: .touchUpInside)
        self.view?.addSubview(btnReset)
    }
}
