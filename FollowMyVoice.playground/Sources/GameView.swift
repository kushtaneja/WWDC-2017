//
//  GameView.swift
//
//  Created by Kush Taneja
//  Copyright © 2017 Kush Taneja. All rights reserved.
//
import UIKit
import SpriteKit
import AudioToolbox
import AVFoundation

/// Variable game status for the game.
enum GameStatus {
    case ready
    case interupted
    case play
    case pause
    case end
}

/// GameView game status for the game.
public class GameView: UIViewController{
    
    // MARK: Private Properties
    
    private var status: GameStatus = .ready
    
    private let speech = Speech()
    
    private var contentLayoutGuide = UILayoutGuide()
    
    private var spokenDirection = String()
    
    private var gameTimer: Timer?
    
    public var showIntroduction: Bool = true
    private var speakWithSwipe: Bool = true

    private var gamePauseButton = UIButton(frame: CGRect.zero)
    
    private var gameSKView = SKView()
    private var gameScene: scene?
    
    private var scoreCount: Int = 0
    private var seconds: Int = 0
    private var numberOfStrokes: Int = 0
    private var scoreRecord:Int = 0
    
    private var ringDurationTimeInterval: TimeInterval = 3.0
    
    private var wrongAnswerView = UIImageView()
    private var correctAnswerView = UIImageView()
    
    private var scoreLabel = UILabel()
    private var scoreNameLabel = UILabel()
    private var timerLabel = UILabel()
    private var actionLabel = UILabel()
    private var smilingLabel = UILabel()
    public var speechLabel = UILabel()
    
    private var ringView = ProgressRingView()
    private var visualEffectView = UIVisualEffectView()
    
    private var swipeUp = UISwipeGestureRecognizer()
    private var swipeDown = UISwipeGestureRecognizer()
    private var swipeRight = UISwipeGestureRecognizer()
    private var swipeLeft = UISwipeGestureRecognizer()
    private var panRecognizer = UIPanGestureRecognizer()
    
    private enum Defaults {
        static let volume = Twist.twist(normalizedValue: CGFloat(Speech().defaultVolume), forType: .volume)
        static let rate = Twist.twist(normalizedValue: Speech().normalizedSpeed, forType: .speed)
        static let pitch = Twist.twist(normalizedValue: Speech().normalizedPitch, forType: .pitch)
        
        static let pauseImage = UIImage(named:"pause")
        static let playImage = UIImage(named: "play")
        static let restartImage = UIImage(named: "restart")
        static let correctImage = UIImage(named: "correct")
        static let wrongImage = UIImage(named: "cross")
        static let standardLabelFont = UIFont.systemFont(ofSize: CGFloat(40.0), weight:10)
        
        static let actionLabelText = "DON'T FOLLLOW ME"
        static let timerText = "00:00"
        static let scoreText = "SCORE"
        static let smileText = "😄"
        
        static let gestures = ["up","left","down","tap","right"]
        
        static let winningEmojis: [String] = ["😑","😒","🤔","😏","😕","☹️","😣","😖","😫","😦","😓","😶"]
        static let loosingEmojis: [String] = ["😀","😃","😂","🤣","😋","😎","🤓","🙌","😅","😙","😇","😂"]
        
        static let WWDCColorCode = ["background":#colorLiteral(red: 0.9725490196, green: 0.9725490196, blue: 0.9725490196, alpha: 1),"reddish":#colorLiteral(red: 0.9019607843, green: 0.3058823529, blue: 0.2705882353, alpha: 1),"greenish":#colorLiteral(red: 0.1215686275, green: 0.662745098, blue: 0.5843137255, alpha: 1),"golden":#colorLiteral(red: 0.8823529412, green: 0.662745098, blue: 0.1921568627, alpha: 1),"darkBlue":#colorLiteral(red: 0.2274509804, green: 0.3647058824, blue: 0.4352941176, alpha: 1)]
    }
    
    override
    public func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Defaults.WWDCColorCode["background"]
        self.speech.speechSynthesizer.delegate = self
        if (status == .end){
            visualEffectView.removeFromSuperview()
            smilingLabel.removeFromSuperview()
            scoreLabel.transform = .identity
            scoreLabel.removeFromSuperview()
        }else{
            view.addLayoutGuide(contentLayoutGuide)
            contentLayoutGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            contentLayoutGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            contentLayoutGuide.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            contentLayoutGuide.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            contentLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            contentLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            contentLayoutGuide.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
        
        view.insertSubview(gameSKView, at: 0)
        gameSKView.allowsTransparency = true
        gameSKView.backgroundColor = UIColor.clear
        gameSKView.frame = UIScreen.main.bounds
        
        gameScene = scene(size: gameSKView.frame.size)
        gameScene?.scaleMode = .resizeFill
        gameScene?.backgroundColor = Defaults.WWDCColorCode["background"]!
        gameSKView.presentScene(gameScene)
        
        view.addSubview(ringView)
        ringView.translatesAutoresizingMaskIntoConstraints = false
        ringView.alpha = 1.0
        ringView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        ringView.topAnchor.constraint(equalTo: view.topAnchor, constant: 22.0).isActive = true
        ringView.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        ringView.widthAnchor.constraint(equalTo: ringView.heightAnchor).isActive = true
        self.ringView.viewStyle = 4
        self.ringView.outerRingWidth = 8.0
        self.ringView.innerRingWidth = 8.0
        self.ringView.shouldShowValueText = false
        self.ringView.innerRingColor = Defaults.WWDCColorCode["reddish"]!
        self.ringView.outerRingColor = Defaults.WWDCColorCode["golden"]!
        self.ringView.maxValue = 100
        self.ringView.delegate = self
        
        view.addSubview(timerLabel)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.alpha = 1.0
        timerLabel.textAlignment = .center
        timerLabel.centerXAnchor.constraint(equalTo: self.ringView.centerXAnchor).isActive = true
        timerLabel.topAnchor.constraint(equalTo: self.ringView.bottomAnchor).isActive = true
        timerLabel.font = UIFont.systemFont(ofSize: CGFloat(14), weight:5)
        timerLabel.textColor = Defaults.WWDCColorCode["darkBlue"]
        timerLabel.text = Defaults.timerText
        
        view.addSubview(actionLabel)
        actionLabel.isHidden = false
        actionLabel.translatesAutoresizingMaskIntoConstraints = false
        actionLabel.alpha = 1.0
        actionLabel.textAlignment = .center
        actionLabel.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        actionLabel.centerYAnchor.constraint(equalTo: contentLayoutGuide.centerYAnchor).isActive = true
        actionLabel.font =  UIFont.systemFont(ofSize: CGFloat(20), weight:30)
        actionLabel.textColor = Defaults.WWDCColorCode["background"]
        actionLabel.backgroundColor = Defaults.WWDCColorCode["reddish"]
        actionLabel.text = Defaults.actionLabelText
        
        view.addSubview(gamePauseButton)
        gamePauseButton.addTarget(self, action: #selector(gameStatusChanged), for: .touchUpInside)
        gamePauseButton.translatesAutoresizingMaskIntoConstraints = false
        gamePauseButton.setBackgroundImage(Defaults.pauseImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        gamePauseButton.tintColor = Defaults.WWDCColorCode["reddish"]
        gamePauseButton.alpha = 1.0
        gamePauseButton.isUserInteractionEnabled = true
        gamePauseButton.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        gamePauseButton.widthAnchor.constraint(equalTo: gamePauseButton.heightAnchor).isActive = true
        gamePauseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        gamePauseButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0).isActive = true
        
        view.addSubview(scoreLabel)
        scoreLabel.isHidden = false
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.alpha = 1.0
        scoreLabel.textAlignment = .center
        scoreLabel.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16.0).isActive = true
        scoreLabel.font = Defaults.standardLabelFont
        scoreLabel.textColor = Defaults.WWDCColorCode["greenish"]
        scoreLabel.text = "\(scoreCount)"
        
        view.addSubview(scoreNameLabel)
        scoreNameLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreNameLabel.isHidden = true
        scoreNameLabel.alpha = 1.0
        scoreNameLabel.textAlignment = .center
        scoreNameLabel.centerXAnchor.constraint(equalTo: self.scoreLabel.centerXAnchor).isActive = true
        scoreNameLabel.topAnchor.constraint(equalTo: self.scoreLabel.bottomAnchor).isActive = true
        scoreNameLabel.font = UIFont.systemFont(ofSize: CGFloat(14), weight:5)
        scoreNameLabel.textColor = Defaults.WWDCColorCode["greenish"]
        scoreNameLabel.text = Defaults.scoreText
        

        view.addSubview(smilingLabel)
        smilingLabel.isHidden = false
        smilingLabel.translatesAutoresizingMaskIntoConstraints = false
        smilingLabel.alpha = 1.0
        smilingLabel.textAlignment = .center
        smilingLabel.centerXAnchor.constraint(equalTo: contentLayoutGuide.centerXAnchor).isActive = true
        smilingLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        smilingLabel.font =  UIFont.systemFont(ofSize: CGFloat(60), weight:20)
        smilingLabel.text = Defaults.smileText
        
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = self.view.bounds
        // Gesture Properties
        
        swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        swipeUp.delegate = self
        swipeUp.delaysTouchesBegan = true
        self.view.addGestureRecognizer(swipeUp)
        
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft.delegate = self
        swipeLeft.delaysTouchesBegan = true
        self.view.addGestureRecognizer(swipeLeft)
        
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        swipeRight.delegate = self
        swipeRight.delaysTouchesBegan = true
        self.view.addGestureRecognizer(swipeRight)
        
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        swipeDown.delegate = self
        swipeDown.delaysTouchesBegan = true
        self.view.addGestureRecognizer(swipeDown)
        
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))
        panRecognizer.delegate = self
        view.addGestureRecognizer(panRecognizer)
    }
    
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.visualEffectView.frame.size = size
    }
    
    //MARK: Tap/Swipe Guesture Methods
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else{ return }
        if speech.isSpeaking(){speech.stopSpeaking()}
        if showIntroduction{
            UIView.animate(withDuration: 0.5, animations: {
                self.speechLabel.removeFromSuperview()
                self.visualEffectView.removeFromSuperview()
            })
            self.showIntroduction = false
            self.beginCountDown()
        }else if status == .pause{
            resumeGame()
        }else if (status != .pause && status != .end){
            let initialCount = scoreCount
            if spokenDirection.contains("tap") { scoreCount += 2
                addCorrectIconToView()
            }else{ scoreCount -= 1
                addWrongIconToView()
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))}
            self.numberOfStrokes += 1
            gameScene?.updateEmitters(at: touch.location(in: self.view))
            updateScoreLabel(with: initialCount)
        }
    }
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if speech.isSpeaking(){speech.stopSpeaking()}
        if event?.type == UIEventType.touches && status != .pause && status != .end{
            if speech.isSpeaking(){speech.stopSpeaking()}
            self.ringView.stop()
        }
    }
    
    @objc private func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            if speech.isSpeaking(){speech.stopSpeaking()}
            
            gameScene?.updateEmitters(fromRecognizer: swipeGesture)
            
            let initalCount = scoreCount
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                if spokenDirection.contains("right") { scoreCount += 2
                    addCorrectIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["greenish"] }else{ scoreCount -= 1
                    addWrongIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["reddish"]
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))}
            case UISwipeGestureRecognizerDirection.down:
                if spokenDirection.contains("down"){ scoreCount += 2
                    addCorrectIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["greenish"] }else{ scoreCount -= 1
                    addWrongIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["reddish"]
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) }
            case UISwipeGestureRecognizerDirection.left:
                if spokenDirection.contains("left"){ scoreCount += 2
                    addCorrectIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["greenish"] }else{ scoreCount -= 1
                    addWrongIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["reddish"]
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))}
            case UISwipeGestureRecognizerDirection.up:
                if spokenDirection.contains("up") { scoreCount += 2
                    addCorrectIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["greenish"] }else{ scoreCount -= 1
                    addWrongIconToView()
                    scoreLabel.textColor = Defaults.WWDCColorCode["reddish"]
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))}
            default:
                break
            }
            
            updateScoreLabel(with: initalCount)
            numberOfStrokes += 1
        }
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        gameScene?.updateEmitters(fromRecognizer: recognizer)
        
        if recognizer.state == UIGestureRecognizerState.ended {
            if speech.isSpeaking(){speech.stopSpeaking()}
            self.ringView.stop()
        }
    }
    func addGestures(){
        self.view.addGestureRecognizer(swipeUp)
        self.view.addGestureRecognizer(swipeLeft)
        self.view.addGestureRecognizer(swipeDown)
        self.view.addGestureRecognizer(swipeRight)
        self.view.addGestureRecognizer(panRecognizer)
    }
    func removeGestures(){
        self.view.removeGestureRecognizer(swipeUp)
        self.view.removeGestureRecognizer(swipeLeft)
        self.view.removeGestureRecognizer(swipeDown)
        self.view.removeGestureRecognizer(swipeRight)
        self.view.removeGestureRecognizer(panRecognizer)
    }
    
    //MARK: Speech Methods
    
    private func speakRandomDirection(){
        let gestures = Defaults.gestures
        let initalSpokenDirection = spokenDirection
        var randomNumber = Int(arc4random_uniform(UInt32(gestures.count)))
        spokenDirection = self.speakWithSwipe && !gestures[randomNumber].contains("tap") ? "Swipe " + gestures[randomNumber] : gestures[randomNumber]
        if spokenDirection == initalSpokenDirection && seconds < 10 {
            randomNumber = randomNumber != 0 ? randomNumber - 1 : 1
            spokenDirection = self.speakWithSwipe && !gestures[randomNumber].contains("tap") ? "Swipe " + gestures[randomNumber] : gestures[randomNumber]
        }
        actionLabel.font =  UIFont.systemFont(ofSize: CGFloat(50), weight:30)
        let colors = [#colorLiteral(red: 0.9019607843, green: 0.3058823529, blue: 0.2705882353, alpha: 1),#colorLiteral(red: 0.1215686275, green: 0.662745098, blue: 0.5843137255, alpha: 1),#colorLiteral(red: 0.8823529412, green: 0.662745098, blue: 0.1921568627, alpha: 1),#colorLiteral(red: 0.2274509804, green: 0.3647058824, blue: 0.4352941176, alpha: 1)]
        let totalColors = colors.count
        let randomColor = colors[Int(arc4random_uniform(UInt32(totalColors)))]
        actionLabel.backgroundColor = randomColor
        UIView.animate(withDuration: 0.01, delay: 0.0, options: .transitionCrossDissolve, animations: {
            self.actionLabel.text = randomNumber <= gestures.count &&  randomNumber > 0 ? gestures[randomNumber - 1].uppercased() : gestures[randomNumber + 1].uppercased()
            self.ringView.outerRingColor = randomColor == #colorLiteral(red: 0.9019607843, green: 0.3058823529, blue: 0.2705882353, alpha: 1) ? #colorLiteral(red: 0.8823529412, green: 0.662745098, blue: 0.1921568627, alpha: 1) : randomColor
        }) { (true) in
            self.speech.speak(self.spokenDirection,rate: Defaults.rate, pitchMultiplier: Defaults.pitch, volume: Defaults.volume)
        }
        
    }
    
    //MARK: Timer Methods
    
    private func runTimer(){
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc private func updateTimer(){
        if (status != .pause && seconds != 60){
            seconds += 1
            timerLabel.text = seconds < 10 ? "00:0\(seconds)" : "00:\(seconds)"
            self.speakWithSwipe = seconds < 10 ? true : false
        if seconds%10 == 0  && seconds != 60{
                ringDurationTimeInterval -= 0.2
            }
        }else if seconds == 60{
            gameTimer?.invalidate()
            self.gameEnded()
        }else{
            gameTimer?.invalidate()
        }
    }
    
    func beginCountDown(){
        var i = 4
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (t) in
            self.scoreLabel.text = "\(i-1)"
            self.speech.speak("\(i-1)")
            i -= 1
            if i == 1{
                t.invalidate()
                self.addGestures()
                self.scoreLabel.text = "0"
                self.scoreNameLabel.isHidden = false
                if self.status != .end{
                    self.startRing()
                    self.runTimer()
                }else{
                    self.ringView.stop()
                    self.runTimer()
                }
            }
        })
    }
    
    func startRing(){
        let initalCount = scoreCount
        if self.status != .pause && self.status != .end{
            if self.speech.isSpeaking(){ self.speech.stopSpeaking() }
            self.speakRandomDirection()
        }
        self.ringView.setProgress(value: 0.0, animationDuration: 0.1){
            self.ringView.setProgress(value: 100, animationDuration: self.ringDurationTimeInterval) {
                if self.status != .pause && self.status != .end{
                    if self.scoreCount - initalCount == 0{
                        self.scoreCount -= 1
                        self.updateScoreLabel()
                        self.addWrongIconToView()
                    }
                    if self.status == .end {
                        if self.speech.isSpeaking(){ self.speech.stopSpeaking() }
                        self.speakRandomDirection()
                        self.status = .play
                    }
                }
                self.startRing()
            }
        }
    }
    //MARK: SpriteKit Methods
    
    private class scene: SKScene {
        var emitters: [SKEmitterNode] = []
        
        override init(size: CGSize){
            super.init(size: size)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        override func didMove(to view: SKView) {
            emitters = (1...10).map { idx in
                let emitter = SKEmitterNode(fileNamed: "SparkParticleEmitter")!
                emitter.position = CGPoint(x: frame.midX, y: frame.midY)
                emitter.particleBirthRate = 0.0
                emitter.targetNode = self
                self.addChild(emitter)
                return emitter
            }
            
        }
        func updateEmitters(fromRecognizer recognizer: UIGestureRecognizer) {
            for i in 0 ..< recognizer.numberOfTouches {
                let touchPoint = convertPoint(fromView: recognizer.location(ofTouch: i, in: view))
                if i < emitters.count {
                    let emitter = emitters[i]
                    emitter.position = touchPoint
                    emitter.particleBirthRate = 300.0
                    
                    let wait = SKAction.wait(forDuration: 0.1)
                    let stopParticleBirth = SKAction.run({
                        emitter.particleBirthRate = 0.0
                    })
                    
                    let sequence = SKAction.sequence([wait, stopParticleBirth])
                    emitter.run(sequence, withKey: "fadeParticles")
                }
            }
        }
        func updateEmitters(at touch: CGPoint) {
            let touchPoint = convertPoint(fromView: touch)
            let emitter = emitters[1]
            emitter.position = touchPoint
            emitter.particleBirthRate = 300.0
            let wait = SKAction.wait(forDuration: 0.1)
            let stopParticleBirth = SKAction.run({
                emitter.particleBirthRate = 0.0
            })
            let sequence = SKAction.sequence([wait, stopParticleBirth])
            emitter.run(sequence, withKey: "fadeParticles")
        }
    }
    
    // MARK: Updating Outlet Methods
    
    func addCorrectIconToView(){
        UIView.animate(withDuration: 1.0, animations: {
            self.view.addSubview(self.correctAnswerView)
            self.correctAnswerView.image = Defaults.correctImage?.withRenderingMode(.alwaysTemplate)
            self.correctAnswerView.tintColor = Defaults.WWDCColorCode["greenish"]
            self.correctAnswerView.isHidden = false
            self.correctAnswerView.translatesAutoresizingMaskIntoConstraints = false
            self.correctAnswerView.backgroundColor = UIColor.clear
            self.correctAnswerView.alpha = 1.0
            self.correctAnswerView.centerXAnchor.constraint(equalTo: self.contentLayoutGuide.centerXAnchor).isActive = true
            self.correctAnswerView.topAnchor.constraint(equalTo: self.scoreNameLabel.bottomAnchor).isActive = true
            
            self.correctAnswerView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            self.correctAnswerView.widthAnchor.constraint(equalTo: self.correctAnswerView.heightAnchor).isActive = true
        })
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
            self.correctAnswerView.removeFromSuperview()
        })
        
    }
    func addWrongIconToView(){
        UIView.animate(withDuration: 1.0, animations: {
            self.view.addSubview(self.wrongAnswerView)
            self.wrongAnswerView.image = Defaults.wrongImage?.withRenderingMode(.alwaysTemplate)
            self.wrongAnswerView.tintColor = Defaults.WWDCColorCode["reddish"]
            self.wrongAnswerView.isHidden = false
            self.wrongAnswerView.translatesAutoresizingMaskIntoConstraints = false
            self.wrongAnswerView.backgroundColor = UIColor.clear
            self.wrongAnswerView.alpha = 1.0
            self.wrongAnswerView.centerXAnchor.constraint(equalTo: self.contentLayoutGuide.centerXAnchor).isActive = true
            self.wrongAnswerView.topAnchor.constraint(equalTo: self.scoreNameLabel.bottomAnchor).isActive = true
            self.wrongAnswerView.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
            self.wrongAnswerView.widthAnchor.constraint(equalTo: self.wrongAnswerView.heightAnchor).isActive = true
        })
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
            self.wrongAnswerView.removeFromSuperview()
        })
    }
    
    func removeChildren(){
        self.scoreCount = 0
        self.seconds = 0
        self.numberOfStrokes = 0
        self.scoreRecord = 0
        self.ringDurationTimeInterval = 3.0
        self.gameTimer?.invalidate()
        self.removeGestures()
    }
    
    func updateScoreLabel(with inital:Int? = 0){
        if scoreLabel.transform != .identity {
            scoreLabel.transform = .identity
        }
        switch scoreCount - inital! {
        case -2:
            scoreLabel.textColor = Defaults.WWDCColorCode["reddish"]
            smilingLabel.text = Defaults.loosingEmojis[Int(arc4random_uniform(UInt32(Defaults.loosingEmojis.count)))]
        default:
            scoreLabel.textColor = Defaults.WWDCColorCode["greenish"]
            smilingLabel.text = Defaults.winningEmojis[Int(arc4random_uniform(UInt32(Defaults.winningEmojis.count)))]
            
        }
        if seconds > 5 && scoreCount <= 0{
            scoreLabel.text = "0"
            self.gameEnded()
        }else{
            scoreCount = scoreCount <= 0 ? 0 : scoreCount
            scoreLabel.text = "\(scoreCount)"
        }
        
    }
    
    //MARK: Game Lifecycle Methods
    
    public func play(){
        self.removeGestures()
        if showIntroduction && status != .end{
            self.showIntroductionView()
        }else{
            beginCountDown()
        }
    }
    
    func showIntroductionView(){
        UIView.animate(withDuration: 1.0) {
            self.view.insertSubview(self.visualEffectView, belowSubview: self.smilingLabel)
            self.view.addSubview(self.speechLabel)
            self.speechLabel.isHidden = false
            self.speechLabel.translatesAutoresizingMaskIntoConstraints = false
            self.speechLabel.alpha = 1.0
            self.speechLabel.textAlignment = .center
            self.speechLabel.centerXAnchor.constraint(equalTo: self.contentLayoutGuide.centerXAnchor).isActive = true
            self.speechLabel.centerYAnchor.constraint(equalTo: self.contentLayoutGuide.centerYAnchor).isActive = true
            self.speechLabel.font =  UIFont.systemFont(ofSize: CGFloat(17), weight:2)
            self.speechLabel.textColor = UIColor.white
            self.speechLabel.numberOfLines = 0
            self.speech.speak("Hello, I will direct you to victory.", rate: Defaults.rate, pitchMultiplier: Defaults.pitch, volume: Defaults.volume)
            self.speech.speak("And I will distract you away from it.", rate: 0.9*(Defaults.rate), pitchMultiplier: 2.5*Defaults.pitch, volume: Defaults.volume)
            self.speech.speak("Follow my voice", rate: Defaults.rate, pitchMultiplier: Defaults.pitch, volume: Defaults.volume)
            self.speech.speak("No. Follow the text on the screen.", rate: 0.9*(Defaults.rate), pitchMultiplier: 2.5*Defaults.pitch, volume: Defaults.volume)
            UIView.animate(withDuration: 1.0, animations: {
                self.smilingLabel.transform = .identity
                self.speech.speak("Please tap anywhere to begin.", rate: Defaults.rate, pitchMultiplier: Defaults.pitch, volume: Defaults.volume)
            })
        }
        self.speakWithSwipe = true
    }
    
    @objc private func gameStatusChanged(){
        gameTimer?.invalidate()
        if (status == .play || status == .ready){
            pauseGame()
        }else if status == .pause{
            resumeGame()
        }
    }
    func pauseGame(){
        self.status = .pause
        self.ringView.pause()
        if speech.isSpeaking(){speech.pauseSpeaking()}
        smilingLabel.text = "🤔"
        self.gamePauseButton.setBackgroundImage(Defaults.playImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        UIView.animate(withDuration: 1.0, animations: {
            self.view.insertSubview(self.visualEffectView, belowSubview: self.gamePauseButton)
        })
        self.removeGestures()
    }
    func resumeGame(){
        self.status = .play
        self.ringView.resume()
        smilingLabel.text = "😃"
        self.gamePauseButton.setBackgroundImage(Defaults.pauseImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        UIView.animate(withDuration: 1.0, animations: {
            self.visualEffectView.removeFromSuperview()
        })
        self.addGestures()
        if speech.isSpeaking(){ speech.continueSpeaking()}
        self.runTimer()
    }
    private func gameEnded(){
        self.status = .end
        self.view.insertSubview(self.visualEffectView, belowSubview: self.scoreLabel)
        if self.speech.isSpeaking(){ self.speech.stopSpeaking() }
        self.ringView.pause()
        if scoreCount > 10 {
            smilingLabel.text = "😡"
            self.speech.speak("Well Played. Huhhhh.", rate: 0.9*(Defaults.rate), pitchMultiplier: 2.5*Defaults.pitch, volume: Defaults.volume)
        }else{
            smilingLabel.text = "😂"
            self.speech.speak("Got confused. haha.", rate: 0.9*(Defaults.rate), pitchMultiplier: 2.5*Defaults.pitch, volume: Defaults.volume)
        }
        removeChildren()
    }
    func restartGame(){
        if status == .pause{
        removeChildren()
        self.status = .end
        }
        self.visualEffectView.removeFromSuperview()
        play()
    }
    
}

//MARK: Extensions
extension GameView: AVSpeechSynthesizerDelegate{
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        if showIntroduction{
        let mutableAttributedString = NSMutableAttributedString(string: utterance.speechString)
        mutableAttributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: characterRange)
            self.speechLabel.attributedText = mutableAttributedString
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
         if showIntroduction{
            self.speechLabel.attributedText = NSAttributedString(string: utterance.speechString)
        }
    }
}
extension GameView: UIGestureRecognizerDelegate{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
}
extension GameView: ProgressRingDelegate{
    public func finishedUpdatingProgress(for ring: ProgressRingView){
        
    }
}
