//: Playground - noun: a place where people can play

import PlaygroundSupport
/*:
 # Follow My Voice !
 Follow my voice is a game which tries to trick the user into following the wrong
 instructions, by offering text inputs that contradict what the oral instructions which
 guide the user to perform certain gestures on the playground liveView screen.
 
 The user's vision will always try to distract his/her focus of synchronisation with
 hearing.
 
 Gestures include directional swipes, taps on the screen and the correct implementation
 of oral instruction surges to fetch high scores.
 * 👉 Swipe Left
 * 👆 Swipe Down
 * 👇 Swipe Up
 * 👈 Swipe Right
 * 👆 Tap

 All these instructions have to be followed in a stipulated time period, which starts at
 3 seconds per instruction, and reduces linearly with the increase in score.
 
 To add a thrill-factor to the game, a distracting feature has been introduced with the
 help of an irritating emoji 😄 for the player. In a way, emoji jealously reacts to your
 progress, and is delighted at your failures.
 */

let game = GameView()
//#-editable-code
game.showIntroduction = true
game.play()
//#-end-editable-code

//#-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(literal, show, array, boolean, color, integer, string)
//#-code-completion(bookauxiliarymodule, show)
//#-code-completion(identifier, show, if, for, while, func, var, let, ., =, (, ))
//#-code-completion(identifier, hide, GameView)
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = game
//#-end-hidden-code


