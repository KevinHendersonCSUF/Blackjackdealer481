//
//  ViewController.swift
//  blackjack-481
//
//  Created by Kevin Henderson on 10/28/25.
//


import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        playerlbl.isHidden = true
        dealerlbl.isHidden = true
        hitbtn.isHidden = true
        standbtn.isHidden = true
    }
    
    //FOR CARD VISUALS
    // Where the first card label will be placed
    let playerCardStartX: CGFloat = 20
    // Changed gap from 16 to 6
    let playerCardGapX: CGFloat = 6
    
    // How many labels have been laid out for the player
    var playerCardCount = 0
    
    // Dealer card layout
    let dealerCardStartX: CGFloat = 20
    let dealerCardGapX: CGFloat = 6
    var dealerCardCount = 0
    
    @IBOutlet var standbtn: UIButton!
    @IBOutlet var hitbtn: UIButton!
    // ------------------------------------------
    var currentturn = "player"
    // Variable for player deck label
    @IBOutlet var playerlbl: UILabel!
    var playercnt = 0
    var playerstood = false
    //variable for dealer deck label
    @IBOutlet var dealerlbl: UILabel!
    var dealercnt = 0
    var dealerstood = false
    // Deck that the player and dealer will play from
    let deck: [String: Int] = ["2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10, "Jack": 10, "King": 10, "Queen": 10,"Ace": 11]
    
    // Test deck
//    let deck: [String: Int] = ["4": 4, "Ace": 11, "King": 10]
    let deck_pictures: [String: String] = ["2": "🂢", "3": "🂣", "4": "🂤", "5": "🂥", "6": "🂦", "7": "🂷", "8": "🂨", "9": "🂩", "10": "🂺", "Jack": "🂻", "King": "🂾", "Queen": "🂭", "Ace": "🂡"]
    @IBOutlet var gameaction: UILabel!
    
    var playerdeck: [String: Int] = [:]
    var dealerdeck: [String: Int] = [:]
    
    var playeracecnt = 0
    var playeraceturn = 0
    var dealeracecnt = 0
    var dealeraceturn = 0
    
    @IBOutlet var strtgamebtn: UIButton!
    @IBAction func StartGamebtn(_ sender: Any) {
        strtgamebtn.isHidden = true
        playerlbl.isHidden = false
        dealerlbl.isHidden = false
        hitbtn.isHidden = false
        standbtn.isHidden = false
        for i in 0..<2 {
            let (randomKey, randomValue) = deck.randomElement()!
            if randomKey == "Ace"{
                playeracecnt += 1
            }
            if playerdeck.keys.contains(randomKey) {
                if randomKey == "Ace" && playercnt + randomValue > 21{
                    print("double ace!")
                    playeraceturn += 1
                    playerdeck[randomKey] = randomValue + playeraceturn
                } else{
                    playerdeck[randomKey] = randomValue + randomValue
                }
            } else {
                if playerdeck.keys.contains("Ace") && playercnt + randomValue > 21 && randomKey != "Ace" {
                    playerdeck["Ace"] = (playerdeck["Ace"] ?? 11) - 10
                    print("card + deck > 21, turning ace to 1")
                }
                playerdeck[randomKey] = randomValue
            }
            let total = playerdeck.values.reduce(0, +)
            playercnt = total
            playerlbl.text = "Your Deck: \(playercnt)"
            // Add a label for the drawn card
            let picture = deck_pictures[randomKey] ?? "❓"
            addPlayerCardLabel(text: picture)
        }
        
        for j in 0..<2 {
            let (dealerrandomKey, dealerrandomValue) = deck.randomElement()!
            if dealerdeck.keys.contains(dealerrandomKey) {
                if dealerrandomKey == "Ace" && dealercnt + dealerrandomValue > 21{
                    print("double ace!")
                    dealeraceturn += 1
                    dealerdeck[dealerrandomKey] = dealerrandomValue + dealeraceturn
                } else{
                    dealerdeck[dealerrandomKey] = dealerrandomValue + dealerrandomValue
                }
            } else {
                if dealerdeck.keys.contains("Ace") && dealercnt + dealerrandomValue > 21 && dealerrandomKey != "Ace" {
                    dealerdeck["Ace"] = (dealerdeck["Ace"] ?? 11) - 10
                    print("card + deck > 21, turning ace to 1")
                }
                dealerdeck[dealerrandomKey] = dealerrandomValue
            }
            var total = dealerdeck.values.reduce(0, +)
            dealercnt = total
            dealerlbl.text = "Dealer's Deck: \(dealercnt)"
            let picture = deck_pictures[dealerrandomKey] ?? "❓"
            addDealerCardLabel(text: picture)
        }
        // Game ending scenarios
        if dealercnt == 21 && playercnt != 21 {
            gameaction.text = "Dealer got blackjack, you lose."
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.newgame()
            }
        }
        if dealercnt == 21 && playercnt == 21 {
            gameaction.text = "It's a push, resetting"
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.newgame()
            }
        }
        if dealercnt != 21 && playercnt == 21 {
            gameaction.text = "You got blackjack, you win!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.newgame()
            }
        }
    }
    
    // Primary Dealer AI
    func Dealer() {
        // if dealer is below 17, they HAVE to hit
        if dealercnt < 17 {
                print("while loop")
                // Delay 4 seconds before performing the hit and continuing
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    print("dispatch line")
                    self.dealerhit()
                    print("dealer hit line")
                    self.Dealer()
                }
            }
        
        
        //if dealer is at 17 or higher they have to stand
        else if dealercnt >= 17 && dealercnt <= 21 {
            print("dealer stand below this line")
            dealerstand()
        }
        else {
            gameaction.text = "Dealer Bust!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                self.newgame()
            }
        }
    }
    
    var dealeracetrack = 0
    func dealerhit() {
        let (randomKey, randomValue) = deck.randomElement()!
        if randomKey == "Ace" {
            dealeracetrack += 1
            if dealerdeck.keys.contains("Ace") {
                dealerdeck["Ace\(dealeracetrack)"] = dealerdeck["Ace\(dealeracetrack)"] ?? 0 + 1
            }
            else if dealercnt + randomValue > 21{
                    dealerdeck[randomKey] = 1
            }
            else {
                dealerdeck[randomKey] = randomValue
            }
        }
        else if dealerdeck.keys.contains(randomKey){
            if dealerdeck.keys.contains("Ace") && dealerdeck["Ace"]! == 11 && playercnt + randomValue > 21{
                dealerdeck["Ace"]! = 1
                print("should turn ace now")
            }
            dealerdeck[randomKey] = dealerdeck[randomKey]! + randomValue
            print("duplicate but didnt turn ace?")
        }
        else {
            dealerdeck[randomKey] = randomValue
            print("normal hit")
        }
        var total = dealerdeck.values.reduce(0, +)
        dealercnt = total
        gameaction.text = "Dealer Drew: \(randomKey)"
        dealerlbl.text = "Dealer's Deck: \(dealercnt)"
        let picture = deck_pictures[randomKey] ?? "❓"
        addDealerCardLabel(text: picture)
    }
        func addDealerCardLabel(text: String) {
            // Place cards just below the dealer label with a small vertical margin
            let verticalMargin: CGFloat = 8
            let y = dealerlbl.frame.maxY + verticalMargin
            
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 100, weight: .medium)
            label.textColor = .label
            label.textAlignment = .center
            label.backgroundColor = .systemGray6
            label.layer.cornerRadius = 6
            label.layer.masksToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = true
            let width: CGFloat = 70
            let height: CGFloat = 120
            // Recompute x based on card index and width + gap so cards don't overlap
            let computedX = dealerCardStartX + CGFloat(dealerCardCount) * (width + dealerCardGapX)
            label.frame = CGRect(x: computedX, y: y, width: width, height: height)
            
            // Insert above the gameaction label if present, so it stays visually above it
            if let gameLabel = gameaction {
                self.view.insertSubview(label, aboveSubview: gameLabel)
            } else {
                self.view.addSubview(label)
            }
            
            // Increment the count so the next label is placed to the right
            dealerCardCount += 1
        }
        func dealerstand() {
            if dealercnt >= 17 {
                gameaction.text = "Dealer chose to stand at \(dealercnt)"
            }
            if dealercnt > playercnt && dealercnt <= 21 {
                gameaction.text = "Dealer wins!"
                print("dealer > player")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.newgame()
                }
            }
            if dealercnt == playercnt {
                gameaction.text = "It's a push!"
                print("push")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.newgame()
                }
            }
            if dealercnt < playercnt {
                gameaction.text = "You win!"
                print("player win")
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    self.newgame()
                }
            }
        }
        // PLAYER FUNCTIONS
        //-------------------------------------------
        func addPlayerCardLabel(text: String) {
            // Place cards just below the player label with a small vertical margin
            let verticalMargin: CGFloat = 8
            let y = playerlbl.frame.maxY + verticalMargin
            
            let label = UILabel()
            label.text = text
            label.font = UIFont.systemFont(ofSize: 100, weight: .medium)
            label.textColor = .label
            label.textAlignment = .center
            label.backgroundColor = .systemGray6
            label.layer.cornerRadius = 6
            label.layer.masksToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = true
            let width: CGFloat = 70
            let height: CGFloat = 120
            // Recompute x based on card index and width + gap so cards don't overlap
            let computedX = playerCardStartX + CGFloat(playerCardCount) * (width + playerCardGapX)
            label.frame = CGRect(x: computedX, y: y, width: width, height: height)
            
            self.view.addSubview(label)
            
            // Increment the count so the next label is placed to the right
            playerCardCount += 1
        }
    var playeracetrack = 0
        @IBAction func playerhit(_ sender: Any) {
            if currentturn == "player" {
                let (randomKey, randomValue) = deck.randomElement()!
                if randomKey == "Ace" {
                    playeracetrack += 1
                    if playerdeck.keys.contains("Ace") {
                        playerdeck["Ace\(playeracetrack)"] = playerdeck["Ace\(playeracetrack)"] ?? 0 + 1
                    }
                    else if playercnt + randomValue > 21{
                            playerdeck[randomKey] = 1
                    }
                    else {
                        playerdeck[randomKey] = randomValue
                    }
                }
                else if playerdeck.keys.contains(randomKey){
                    if playerdeck.keys.contains("Ace") && playerdeck["Ace"]! == 11 && playercnt + randomValue > 21{
                        playerdeck["Ace"]! = 1
                        print("should turn ace now")
                    }
                    playerdeck[randomKey] = playerdeck[randomKey]! + randomValue
                    print("duplicate but didnt turn ace?")
                }
                else {
                    playerdeck[randomKey] = randomValue
                    print("normal hit")
                }
                var total = playerdeck.values.reduce(0, +)
                playercnt = total
                gameaction.text = "You Drew: \(randomKey)"
                playerlbl.text = "Your Deck: \(playercnt)"
                let picture = deck_pictures[randomKey] ?? "❓"
                addPlayerCardLabel(text: picture)
                if playercnt > 21 {
                    gameaction.text = "You Bust! Resetting game..."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        self.newgame()
                    }
                }
                if playercnt == 21 {
                    print("player hit 21")
                    gameaction.text = "you're at 21, standing..."
                    currentturn = "Dealer"
                    Dealer()
                }
            }
            else {
                gameaction.text = "it's not your turn!"
            }
        }
        
        
        @IBAction func playerstand(_ sender: Any) {
            playerstood = true
            gameaction.text = "You chose to stand"
            currentturn = "Dealer"
            print("standing.....")
            Dealer()
        }
        
        //used in the event of a bust
        func newgame() {
            // Remove dynamically added card labels while keeping the main labels
            for subview in self.view.subviews {
                // Keep the primary labels and the start button
                if subview === playerlbl || subview === dealerlbl || subview === gameaction || subview === strtgamebtn {
                    continue
                }
                // Remove any UILabels added for cards
                if subview is UILabel {
                    subview.removeFromSuperview()
                }
            }
            
            // Reset game state
            playerCardCount = 0
            dealerCardCount = 0
            playercnt = 0
            dealercnt = 0
            playerstood = false
            dealerstood = false
            currentturn = "player"
            playerdeck.removeAll()
            dealerdeck.removeAll()
            
            // Reset UI
            playerlbl.text = "Your Deck: 0"
            dealerlbl.text = "Dealer's Deck: 0"
            gameaction.text = ""
            strtgamebtn.isHidden = false
            playerlbl.isHidden = true
            dealerlbl.isHidden = true
            hitbtn.isHidden = true
            standbtn.isHidden = true
        }
    }
    

