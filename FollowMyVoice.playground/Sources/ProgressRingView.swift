//
//  ProgressRingView.swift
//  ProgressRing
//
//  Created by Kush Taneja
//  Copyright © 2017 Kush Taneja. All rights reserved.
//


import UIKit

/**
 
 # UICiruclarProgressRingView
 
 This is the UIView subclass that creates and handles everything
 to do with the progress ring
 
 This class has a custom CAShapeLayer (ProgressRingLayer) which
 handels the drawing and animating of the view
 */


/*
 This is the protocol declaration for the ProgressRingView delegate property
 
 ## Important ##
 When progress is done updating via ProgressRingView.setValue(_:), the
 finishedUpdatingProgress(forRing: ProgressRingView) will be called.
 
 The ring will be passed to the delegate in order to keep track of multiple ring updates if needed.
*/

public protocol ProgressRingDelegate: class {
    /**
     Delegate call back, called when progress ring is done animating for current value
     
     - Parameter ring: The ring which finished animating
     
     */
    func finishedUpdatingProgress(for ring: ProgressRingView)
}
@IBDesignable open class ProgressRingView: UIView {
    
    // MARK: Delegate
    /**
     The delegate for the ProgressRingView
     
     ## Important ##
     When progress is done updating via ProgressRingView.setValue(_:), the
     finishedUpdatingProgressFor(_ ring: ProgressRingView) will be called.
     
     The ring will be passed to the delegate in order to keep track of multiple ring updates if needed.
     */
    open weak var delegate: ProgressRingDelegate?
    
    // MARK: Value Properties
    
    /**
     The value property for the progress ring. ex: (23)/100
     
     This cannot be used to get the value while the ring is animating, to get current value while animating use `currentValue`
     
     The current value of the progress ring, use setProgress(value:) to alter the value with the option
     to animate and have a completion handler.
     */
    @IBInspectable open var value: CGFloat = 0 {
        didSet {
            self.ringLayer.value = self.value
        }
    }
    
    /**
     The current value of the progress ring
     
     This will return the current value of the progress ring, if the ring is animating it will be updated in real time. 
     If the ring is not currently animating then the value returned will be the `value` property of the ring
     */
    open var currentValue: CGFloat? {
        get {
            if isAnimating && !isPaused{
                return self.layer.presentation()?.value(forKey: "value") as? CGFloat
            } else if isAnimating && isPaused{
                return pausedValue
            }else {
                return self.value
            }
        }
    }
    
    /**
     */
    open var pausedValue: CGFloat?
    /**
     The max value for the progress ring. ex: 23/(100)
     Used to calculate amount of progress depending on self.value and self.maxValue
     */
    @IBInspectable open var maxValue: CGFloat = 100 {
        didSet {
            self.ringLayer.maxValue = self.maxValue
        }
    }
    
    // MARK: View Style
    
    /**
     Variable for the style of the progress ring.
     
     Range: [1,4]
     
     The four styles are
     - 1: Radius of the inner ring is smaller (inner ring inside outer ring)
     - 2: Radius of inner ring is equal to outer ring (both at same location)
     - 3: Radius of inner ring is equal to outer ring, and the outer ring is dashed
     - 4: Radius of inner ring is equal to outer ring, and the outer ring is dotted
     */
    @IBInspectable open var viewStyle: Int = 4 {
        didSet {
            self.ringLayer.viewStyle = self.viewStyle
        }
    }
    
    /**
     An array of CGFloats, used to calculate the dash length for viewStyle = 3
     */
    open var patternForDashes: [CGFloat] = [7.0, 7.0] {
        didSet {
            self.ringLayer.patternForDashes = self.patternForDashes
        }
    }
    
    /**
     The start angle for the entire progress ring view.
     Values should be in degrees (they're converted to radians internally)
     */
    @IBInspectable open var startAngle: CGFloat = 0 {
        didSet {
            self.ringLayer.startAngle = self.startAngle
        }
    }
    
    /**
     The end angle for the entire progress ring
     Values should be in degrees (they're converted to radians internally)
     */
    @IBInspectable open var endAngle: CGFloat = 360 {
        didSet {
            self.ringLayer.endAngle = self.endAngle
        }
    }
    
    // MARK: Outer Ring properties
    
    /**
     The width of the outer ring for the progres bar
     */
    @IBInspectable open var outerRingWidth: CGFloat = 10.0 {
        didSet {
            self.ringLayer.outerRingWidth = self.outerRingWidth
        }
    }
    
    /**
     The color for the outer ring
     */
    @IBInspectable open var outerRingColor: UIColor = UIColor.gray {
        didSet {
            self.ringLayer.outerRingColor = self.outerRingColor
        }
    }
    
    /**
     The style for the outer ring end cap (how it is drawn on screen)
     Range [1,3]
     - 1: Line with a squared off end
     - 2: Line with a rounded off end
     - 3: Line with a square end
     - <1 & >3: Defaults to style 1
     */
    @IBInspectable open var outerRingCapStyle: Int = 1 {
        didSet {
            switch self.outerRingCapStyle{
            case 1:
                self.outStyle = .butt
                self.ringLayer.outerCapStyle = .butt
            case 2:
                self.outStyle = .round
                self.ringLayer.outerCapStyle = .round
            case 3:
                self.outStyle = .square
                self.ringLayer.outerCapStyle = .square
            default:
                self.outStyle = .butt
                self.ringLayer.outerCapStyle = .butt
            }
        }
    }
    
    /**
     A internal outerRingCapStyle variable, this is set whenever the
     IB compatible variable above is set.
     
     Basically in here because IB doesn't support CGLineCap selection.
     
     */
    internal var outStyle: CGLineCap = .butt
    
    // MARK: Inner Ring properties
    
    /**
     The width of the inner ring for the progres bar
     */
    @IBInspectable open var innerRingWidth: CGFloat = 5.0 {
        didSet {
            self.ringLayer.innerRingWidth = self.innerRingWidth
        }
    }
    
    /**
     The color of the inner ring for the progres bar
     */
    @IBInspectable open var innerRingColor: UIColor = UIColor.blue {
        didSet {
            self.ringLayer.innerRingColor = self.innerRingColor
        }
    }
    
    /**
     The spacing between the outer ring and inner ring
     */
    @IBInspectable open var innerRingSpacing: CGFloat = 1 {
        didSet {
            self.ringLayer.innerRingSpacing = self.innerRingSpacing
        }
    }
    
    /**
     The style for the inner ring end cap (how it is drawn on screen)
     
     Range [1,3]
     
     - 1: Line with a squared off end
     - 2: Line with a rounded off end
     - 3: Line with a square end
     - <1 & >3: Defaults to style 2
     */
    @IBInspectable open var innerRingCapStyle: Int = 2 {
        didSet {
            switch self.innerRingCapStyle {
            case 1:
                self.inStyle = .butt
                self.ringLayer.innerCapStyle = .butt
            case 2:
                self.inStyle = .round
                self.ringLayer.innerCapStyle = .round
            case 3:
                self.inStyle = .square
                self.ringLayer.innerCapStyle = .square
            default:
                self.inStyle = .butt
                self.ringLayer.innerCapStyle = .butt
            }
        }
    }
    
    
    /**
     
     A internal innerRingCapStyle variable, this is set whenever the
     IB compatible variable above is set.
     
     Basically in here because IB doesn't support CGLineCap selection.
     
     */
    internal var inStyle: CGLineCap = .round
    
    // MARK: Label
    
    /**
     A toggle for showing or hiding the value label.
     If false the current value will not be shown.
     */
    @IBInspectable open var shouldShowValueText: Bool = true {
        didSet {
            self.ringLayer.shouldShowValueText = self.shouldShowValueText
        }
    }
    
    /**
     The text color for the value label field
     */
    @IBInspectable open var fontColor: UIColor = UIColor.black {
        didSet {
            self.ringLayer.fontColor = self.fontColor
        }
    }
    
    /**
     The font to be used for the progress indicator.
     All font attributes are specified here except for font color, which is done using `fontColor`.
     */
    @IBInspectable open var font: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.ringLayer.font = self.font
        }
    }
    
    /**
     The name of the value indicator the value label will
     appened to the value
     */
    @IBInspectable open var valueIndicator: String = "%" {
        didSet {
            self.ringLayer.valueIndicator = self.valueIndicator
        }
    }
    
    /**
     A toggle for showing or hiding floating points from
     the value in the value label

     */
    @IBInspectable open var showFloatingPoint: Bool = false {
        didSet {
            self.ringLayer.showFloatingPoint = self.showFloatingPoint
        }
    }
    
    /**
     The amount of decimal places to show in the value label
     */
    @IBInspectable open var decimalPlaces: Int = 2 {
        didSet {
            self.ringLayer.decimalPlaces = self.decimalPlaces
        }
    }
    
    // MARK: Animation properties
    
    /**
     The type of animation function the ring view will use
     
     ## Important ##
     Default = kCAMediaTimingFunctionEaseIn
     
     String should be from kCAMediaTimingFunction_____
     
     Only used when calling .setValue(animated: true)

     */
    open var animationStyle: String = kCAMediaTimingFunctionEaseIn {
        didSet {
            self.ringLayer.animationStyle = self.animationStyle
        }
    }
    
    /**
     This returns whether or not the ring is currently animating
     */
    open var isAnimating: Bool {
        get { return (self.layer.animation(forKey: "value") != nil) ? true : false }
    }
    
    open var isPaused: Bool = false
    
    // MARK: Layer
    
    /**
     Set the ring layer to the default layer, cated as custom layer
     */
    internal var ringLayer: ProgressRingLayer {
        return self.layer as! ProgressRingLayer
    }
    
    /**
     Overrides the default layer with the custom ProgressRingLayer class
     */
    override open class var layerClass: AnyClass {
        get {
            return ProgressRingLayer.self
        }
    }
    
    // MARK: Methods
    
    /**
     Overriden public init to initialize the layer and view
     */
    override public init(frame: CGRect) {
        super.init(frame: frame)
        // Call the internal initializer
        initialize()
    }
    
    /**
     Overriden public init to initialize the layer and view
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Call the internal initializer
        initialize()
    }
    
    /**
     This method initializes the custom CALayer
     For some reason didSet doesnt get called during initializing, so
     has to be done manually in here or else nothing would be drawn.
     */
    internal func initialize() {
        // Helps with pixelation and blurriness on retina devices
        self.layer.contentsScale = UIScreen.main.scale
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale * 2
        self.ringLayer.value = value
        self.ringLayer.maxValue = maxValue
        self.ringLayer.viewStyle = viewStyle
        self.ringLayer.patternForDashes = patternForDashes
        self.ringLayer.startAngle = startAngle
        self.ringLayer.endAngle = endAngle
        self.ringLayer.outerRingWidth = outerRingWidth
        self.ringLayer.outerRingColor = outerRingColor
        self.ringLayer.outerCapStyle = outStyle
        self.ringLayer.innerRingWidth = innerRingWidth
        self.ringLayer.innerRingColor = innerRingColor
        self.ringLayer.innerCapStyle = inStyle
        self.ringLayer.innerRingSpacing = innerRingSpacing
        self.ringLayer.shouldShowValueText = shouldShowValueText
        self.ringLayer.valueIndicator = valueIndicator
        self.ringLayer.fontColor = fontColor
        self.ringLayer.font = font
        self.ringLayer.showFloatingPoint = showFloatingPoint
        self.ringLayer.decimalPlaces = decimalPlaces
        
        // Sets background color to clear, this fixes a bug when placing view in tableview cells
        self.backgroundColor = UIColor.clear
        self.ringLayer.backgroundColor = UIColor.clear.cgColor
    }
    
    /**
     Overriden because of custom layer drawing in ProgressRingLayer
     */
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    
    /**
     Typealias for the setProgress(:) method closure
    */
    public typealias ProgressCompletion = (() -> Void)
    
    /**
     Sets the current value for the progress ring, calling this method while ring is animating will cancel the previously set animation and start a new one.
     
     - Parameter newVal: The value to be set for the progress ring
     - Parameter animationDuration: The time interval duration for the animation
     - Parameter completion: The completion closure block that will be called when animtion is finished (also called when animationDuration = 0), default is nil
     */
    open func setProgress(value: CGFloat, animationDuration: TimeInterval, completion: ProgressCompletion? = nil) {
        // Remove the current animation, so that new can be processed
        if isAnimating { self.layer.removeAnimation(forKey: "value") }
        // Create a transaction to be notified when animation is complete
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            // Call the closure block
                self.delegate?.finishedUpdatingProgress(for: self)
                completion?()
        }
        // Only animate if duration sent is greater than zero
        self.ringLayer.animated = animationDuration > 0
        self.ringLayer.animationDuration = animationDuration
        self.value = value
        self.ringLayer.value = value
        CATransaction.commit()
    }
    open func stop(){
        CATransaction.commit()
        self.value = 0
        self.ringLayer.value = 0
    }
    open func pause(){
        isPaused = true
        pausedValue = self.currentValue
        self.ringLayer.pause()
    }
    open func resume(){
        isPaused = false
        self.ringLayer.resume()
    }
}
