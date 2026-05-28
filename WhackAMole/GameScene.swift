//
//  GameScene.swift
//  WhackAMole
//
//  Created by Austin Wells on 12/4/25.
//

import SpriteKit
import GameplayKit
import os.log

var hole0: SKSpriteNode?
var hole1: SKSpriteNode?
var hole2: SKSpriteNode?
var hole3: SKSpriteNode?
var mole: SKSpriteNode?

var holeSize = CGSize(width: sizeOfView.width/4, height: sizeOfView.width/4)
var holePositionOffset = holeSize.height / 2.0 + 20.0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var statusLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    var timerLabel: SKLabelNode?
    
    var score = 0
    var isAlive = true
    
    var countDownTimerVar = 0
    var countDownMoleVar = 3
    
    var positionChoices = [CGPoint]()
    var lastMolePosition: Int = -1
    var currentMolePosition = 0
    
    var touchLocation: CGPoint?
    var touchedNode: SKNode?
    
    override func didMove(to view: SKView) {
        self.backgroundColor = notBlackColor
        
        resetGameVariables()
        spawnStatusLabel()
        spawnScoreLabel()
        spawnTimerLabel()
        countDownTimer()
    }
    
    func resetGameVariables() {
        score = 0
        isAlive = true
        
        countDownTimerVar = COUNTDOWN
        lastMolePosition = -1
        
        loadPositionArray()
        spawnHole0()
        spawnHole1()
        spawnHole2()
        spawnHole3()
        spawnMole()
    }
    
    func loadPositionArray() {
        positionChoices = [
            CGPoint(x: self.frame.midX - holePositionOffset, y: self.frame.midY + holePositionOffset),
            CGPoint(x: self.frame.midX + holePositionOffset, y: self.frame.midY + holePositionOffset),
            CGPoint(x: self.frame.midX - holePositionOffset, y: self.frame.midY - holePositionOffset),
            CGPoint(x: self.frame.midX + holePositionOffset, y: self.frame.midY - holePositionOffset)
        ]
    }
    
    func spawnHole0() {
        hole0 = SKSpriteNode(imageNamed: "dirtyHole")
        hole0?.size = holeSize
        hole0?.position = positionChoices[0]
        hole0?.zPosition = 0
        hole0?.name = "hole0"
        self.addChild(hole0!)
    }
    
    func spawnHole1() {
        hole1 = SKSpriteNode(imageNamed: "dirtyHole")
        hole1?.size = holeSize
        hole1?.position = positionChoices[1]
        hole1?.zPosition = 0
        hole1?.name = "hole1"
        self.addChild(hole1!)
    }
    
    func spawnHole2() {
        hole2 = SKSpriteNode(imageNamed: "dirtyHole")
        hole2?.size = holeSize
        hole2?.position = positionChoices[2]
        hole2?.zPosition = 0
        hole2?.name = "hole2"
        self.addChild(hole2!)
    }
    
    func spawnHole3() {
        hole3 = SKSpriteNode(imageNamed: "dirtyHole")
        hole3?.size = holeSize
        hole3?.position = positionChoices[3]
        hole3?.zPosition = 0
        hole3?.name = "hole3"
        self.addChild(hole3!)
    }
    
    func spawnMole() {
        mole = SKSpriteNode(imageNamed: "moleHole")
        mole?.size = holeSize
        mole?.zPosition = 1
        mole?.name = "mole"
        mole?.isHidden = true
        self.addChild(mole!)
        
        randomizeMolePosition()
    }
    
    func spawnStatusLabel() {
        statusLabel = SKLabelNode(fontNamed: "Chalkduster")
        statusLabel?.fontColor = notWhiteColor
        statusLabel?.fontSize = 50
        statusLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.maxY - 300.0)
        
        statusLabel?.text = "Start!"
        self.addChild(statusLabel!)
    }
    
    func spawnScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.fontColor = notWhiteColor
        scoreLabel?.fontSize = 40
        scoreLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 185.0)
        
        scoreLabel?.text = "Score: \(score)"
        self.addChild(scoreLabel!)
    }
    
    func spawnTimerLabel() {
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel?.fontColor = notWhiteColor
        timerLabel?.fontSize = 70
        timerLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.minY + 255.0)
        
        timerLabel?.text = "\(COUNTDOWN)"
        self.addChild(timerLabel!)
    }
    
    func randomizeMolePosition() {
        currentMolePosition = Int(arc4random_uniform(4))
        
        while currentMolePosition == lastMolePosition {
            currentMolePosition = Int(arc4random_uniform(4))
        }
        
        lastMolePosition = currentMolePosition
        mole?.position = positionChoices[currentMolePosition]
        mole?.isHidden = false
        
        countDownMoleTimer()
    }
    
    func countDownMoleTimer() {
        let wait = SKAction.wait(forDuration: 0.23)
        
        let runCountDown = SKAction.run {
            if self.isAlive == true {
                self.statusLabel?.text = "Catch me if you can!"
                self.statusLabel?.fontColor = notWhiteColor
            }
        }
        let sequence = SKAction.sequence([wait, runCountDown])
        let moleTimer = SKAction.repeat(sequence, count: countDownMoleVar)
        
        self.run(moleTimer, completion: {
            if self.isAlive {
                let wait = SKAction.wait(forDuration: 0.15)
                let restartTimer = SKAction.run {
                    self.randomizeMolePosition()
                }
                let catchup = SKAction.sequence([wait, restartTimer])
                self.run(catchup)
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            touchLocation = touch.location(in: self)
            touchedNode = atPoint(touchLocation!)
            
            if touchedNode?.name != "mole" {
                isAlive = false
                gameOverLogic()
            }
            
            if touchedNode?.name == "mole" {
                addToScore()
                mole?.isHidden = true
                randomizeMolePosition()
            }
        }
    }
    
    func addToScore() {
        score = score + 1
        updateScore()
    }
    
    func updateScore() {
        scoreLabel?.text = "Score: \(score)"
    }
    
    func countDownTimer() {
        let wait = SKAction.wait(forDuration: 1.0)
        let runCountDown = SKAction.run {
            if self.isAlive == true {
                self.countDownTimerVar = self.countDownTimerVar - 1
            }
            
            if self.countDownTimerVar <= COUNTDOWN && self.isAlive == true {
                self.timerLabel?.text = "\(self.countDownTimerVar)"
            }
            
            if self.countDownTimerVar <= 0 {
                self.timerLabel?.text = "0"
                self.gameOverLogic()
            }
        }
        
        let sequence = SKAction.sequence([wait, runCountDown])
        self.run(SKAction.repeat(sequence, count: countDownTimerVar))
    }
    
    func gameOverLogic() {
        statusLabel?.fontColor = notWhiteColor
        statusLabel?.text = "Good Score!"
        timerLabel?.text = "Try Again"
        
        if isAlive == false {
            statusLabel?.fontColor = UIColor.yellow
            statusLabel?.text = "Missed - Game Reset!"
            COUNTDOWN = 10
            if score == 0 {
                statusLabel?.fontColor = UIColor.red
                statusLabel?.text = "Skunked!"
                timerLabel?.text = "Game Over!"
                self.waitThenMoveToTitleScreen()
            }
        }
        
        hole0?.removeFromParent()
        hole1?.removeFromParent()
        hole2?.removeFromParent()
        hole3?.removeFromParent()
        mole?.removeFromParent()
        
        if score > highScore {
            highScore = score
            statusLabel?.fontColor = UIColor.yellow
            statusLabel?.text = "High Score! \(highScore)"
            saveScores()
        } else if isAlive == true {
            statusLabel?.text = "Awesome!"
        }
        
        if (isAlive == true && score > COUNTDOWN/2) {
            COUNTDOWN = COUNTDOWN + 5
            timerLabel?.text = "Timer increased!"
            spawnBonusFireworks()
        } else {
            self.resetTheGame()
        }
    }
    
    func spawnBonusFireworks() {
        var explosion: SKEmitterNode?
        
        explosion = SKEmitterNode(fileNamed: "SparkParticle.sks")!
        
        explosion?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        explosion?.zPosition = -1
        explosion?.targetNode = self
        
        self.addChild(explosion!)
        
        let explosionTimerRemove = SKAction.wait(forDuration: 1.0)
        
        let removeExplosion = SKAction.run {
            explosion?.removeFromParent()
            self.resetTheGame()
        }
        
        self.run(SKAction.sequence([explosionTimerRemove, removeExplosion]))
    }
    
    func resetTheGame() {
        let wait = SKAction.wait(forDuration: 2.0)
        let gameScene = GameScene(size: self.size)
        let transitionScene = SKTransition.doorway(withDuration: 0.5)
        
        let changeScene = SKAction.run {
            self.removeAllActions()
            gameScene.scaleMode = SKSceneScaleMode.aspectFill
            self.scene?.view?.presentScene(gameScene, transition: transitionScene)
        }
        
        let sequence = SKAction.sequence([wait, changeScene])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    @objc func waitThenMoveToTitleScreen() {
        let wait = SKAction.wait(forDuration: 1.0)
        let transition = SKAction.run {
            if let scene = TitleScene(fileNamed: "TitleScene") {
                let skView = self.view! as SKView
                scene.scaleMode = .aspectFill
                
                skView.presentScene(scene)
            }
        }
        
        let sequence = SKAction.sequence([wait, transition])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    private func saveScores() {
        scores[0].score = highScore
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: scores, requiringSecureCoding: false)
            try data.write(to: SavedGame.ArchiveURL)
            os_log("High Score successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save high score...", log: OSLog.default, type: .error)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
