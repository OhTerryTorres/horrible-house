//
//  ClockController.swift
//  horrible house
//
//  Created by TerryTorres on 5/5/16.
//  Copyright © 2016 Terry Torres. All rights reserved.
//

import UIKit
import Foundation

class ClockController: UIViewController {
    
    var house : House = (UIApplication.sharedApplication().delegate as! AppDelegate).house
    var fullView = UIView()
    var clockView = UIView()
    
    func rotateLayer(currentLayer:CALayer,dur:CFTimeInterval){
        
        let angle = degree2radian(360)
        
        // rotation http://stackoverflow.com/questions/1414923/how-to-rotate-uiimageview-with-fix-point
        let theAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        theAnimation.duration = dur
        // Make this view controller the delegate so it knows when the animation starts and ends
        theAnimation.delegate = self
        theAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        // Use fromValue and toValue
        theAnimation.fromValue = 0
        theAnimation.repeatCount = Float.infinity
        theAnimation.toValue = angle
        
        // Add the animation to the layer
        currentLayer.addAnimation(theAnimation, forKey:"rotate")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.clockView.removeFromSuperview()
        self.fullView.removeFromSuperview()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.house = (UIApplication.sharedApplication().delegate as! AppDelegate).house
        
        let endAngle = CGFloat(2*M_PI)
        
        fullView = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.size.height * 0.2, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        clockView = View(frame: CGRect(x: 0, y: 0, width: CGRectGetWidth(self.view.frame), height: CGRectGetWidth(self.view.frame)))
        
        fullView.addSubview(clockView)
        self.view.addSubview(fullView)
        self.view.backgroundColor = UIColor.darkGrayColor()
        self.fullView.backgroundColor = UIColor.darkGrayColor()
        self.clockView.backgroundColor = UIColor.darkGrayColor()
        
        let time = timeCoords(CGRectGetMidX(clockView.frame), y: CGRectGetMidY(clockView.frame), time: getTime(self.house.gameClock.currentTime), radius: 50)

        // Hours
        let hourLayer = CAShapeLayer()
        hourLayer.frame = clockView.frame
        let path = CGPathCreateMutable()
        
        CGPathMoveToPoint(path, nil, CGRectGetMidX(clockView.frame), CGRectGetMidY(clockView.frame))
        CGPathAddLineToPoint(path, nil, time.h.x, time.h.y)
        hourLayer.path = path
        hourLayer.lineWidth = 4
        hourLayer.lineCap = kCALineCapRound
        hourLayer.strokeColor = UIColor.blackColor().CGColor
        
        // see for rasterization advice http://stackoverflow.com/questions/24316705/how-to-draw-a-smooth-circle-with-cashapelayer-and-uibezierpath
        hourLayer.rasterizationScale = UIScreen.mainScreen().scale;
        hourLayer.shouldRasterize = true
        
        self.clockView.layer.addSublayer(hourLayer)
        // time it takes for hour hand to pass through 360 degress
        // rotateLayer(hourLayer,dur:43200)
        
        // Minutes
        let minuteLayer = CAShapeLayer()
        minuteLayer.frame = clockView.frame
        let minutePath = CGPathCreateMutable()
        
        CGPathMoveToPoint(minutePath, nil, CGRectGetMidX(clockView.frame), CGRectGetMidY(clockView.frame))
        CGPathAddLineToPoint(minutePath, nil, time.m.x, time.m.y)
        minuteLayer.path = minutePath
        minuteLayer.lineWidth = 3
        minuteLayer.lineCap = kCALineCapRound
        minuteLayer.strokeColor = UIColor.whiteColor().CGColor
        
        minuteLayer.rasterizationScale = UIScreen.mainScreen().scale;
        minuteLayer.shouldRasterize = true
        
        self.clockView.layer.addSublayer(minuteLayer)
        // rotateLayer(minuteLayer,dur: 3600)
        
        // Seconds
        let secondLayer = CAShapeLayer()
        secondLayer.frame = clockView.frame
        
        let secondPath = CGPathCreateMutable()
        CGPathMoveToPoint(secondPath, nil, CGRectGetMidX(clockView.frame), CGRectGetMidY(clockView.frame))
        CGPathAddLineToPoint(secondPath, nil, time.s.x, time.s.y)
        
        
        secondLayer.path = secondPath
        secondLayer.lineWidth = 1
        secondLayer.lineCap = kCALineCapRound
        secondLayer.strokeColor = UIColor.redColor().CGColor
        
        secondLayer.rasterizationScale = UIScreen.mainScreen().scale;
        secondLayer.shouldRasterize = true
        
        self.clockView.layer.addSublayer(secondLayer)
        // rotateLayer(secondLayer,dur: 60)
        let centerPiece = CAShapeLayer()
        
        let circle = UIBezierPath(arcCenter: CGPoint(x:CGRectGetMidX(clockView.frame),y:CGRectGetMidX(clockView.frame)), radius: 4.5, startAngle: 0, endAngle: endAngle, clockwise: true)
        // thanks to http://stackoverflow.com/a/19395006/1694526 for how to fill the color
        centerPiece.path = circle.CGPath
        centerPiece.fillColor = UIColor.whiteColor().CGColor
        self.clockView.layer.addSublayer(centerPiece)
        
        if self.house.gameClock.isBroken {
            // Make jagged line
            let crackLayer = CAShapeLayer()
            crackLayer.frame = clockView.frame
            
            var points : [CGPoint] = [
                CGPoint(x: clockView.frame.width * 0.3, y: clockView.frame.height * 0.29),
                CGPoint(x: clockView.frame.width * 0.35, y: clockView.frame.height * 0.32),
                CGPoint(x: clockView.frame.width * 0.34, y: clockView.frame.height * 0.35),
                CGPoint(x: clockView.frame.width * 0.55, y: clockView.frame.height * 0.6),
                CGPoint(x: clockView.frame.width * 0.71, y: clockView.frame.height * 0.70),
                CGPoint(x: clockView.frame.width * 0.55, y: clockView.frame.height * 0.6),
                CGPoint(x: clockView.frame.width * 0.46, y: clockView.frame.height * 0.68),
                CGPoint(x: clockView.frame.width * 0.47, y: clockView.frame.height * 0.71),
                CGPoint(x: clockView.frame.width * 0.42, y: clockView.frame.height * 0.75),
                CGPoint(x: clockView.frame.width * 0.4, y: clockView.frame.height * 0.77),
            ]
            
            let crackPath = CGPathCreateMutable()
            CGPathMoveToPoint(crackPath, nil, points[0].x, points[0].y)
            for i in 1 ..< points.count {
                CGPathAddLineToPoint (crackPath, nil, points[i].x, points[i].y)
            }
            
            crackLayer.path = crackPath
            crackLayer.lineWidth = 2
            crackLayer.lineCap = kCALineCapRound
            crackLayer.strokeColor = UIColor.whiteColor().CGColor
            crackLayer.fillColor = nil
            
            crackLayer.rasterizationScale = UIScreen.mainScreen().scale;
            crackLayer.shouldRasterize = true
            
            self.clockView.layer.addSublayer(crackLayer)
            
        }
        
    }
    
    
    
}


// MARK: Retrieve time
func getTime (time: GameTime)->(h:Int,m:Int,s:Int) {
    // see here for details about date formatter https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/DataFormatting/Articles/dfDateFormatting10_4.html#//apple_ref/doc/uid/TP40002369
    
    /*
    let dateFormatter = NSDateFormatter()
    let formatStrings = ["hh","mm","ss"]
    var hms = [Int]()
    
    
    for f in formatStrings {
        
        dateFormatter.dateFormat = f
        let date = NSDate()
        if let formattedDateString = Int(dateFormatter.stringFromDate(date)) {
            hms.append(formattedDateString)
        }
        
    }
    */
    
    return (h: time.hours ,m: time.minutes, s: time.seconds)
}

// END: Retrieve time

// MARK: Calculate coordinates of time
func  timeCoords(x:CGFloat,y:CGFloat,time:(h:Int,m:Int,s:Int),radius:CGFloat,adjustment:CGFloat=90)->(h:CGPoint, m:CGPoint,s:CGPoint) {
    let cx = x // x origin
    let cy = y // y origin
    var r  = radius // radius of circle
    var points = [CGPoint]()
    var angle = degree2radian(6)
    func newPoint (t:Int) {
        let xpo = cx - r * cos(angle * CGFloat(t)+degree2radian(adjustment))
        let ypo = cy - r * sin(angle * CGFloat(t)+degree2radian(adjustment))
        points.append(CGPoint(x: xpo, y: ypo))
    }
    // work out hours first
    var hours = time.h
    if hours > 12 {
        hours = hours-12
    }
    let hoursInSeconds = time.h*3600 + time.m*60 + time.s
    newPoint(hoursInSeconds*5/3600)
    
    // work out minutes second
    r = radius * 1.25
    let minutesInSeconds = time.m*60 + time.s
    newPoint(minutesInSeconds/60)
    
    // work out seconds last
    r = radius * 1.5
    newPoint(time.s)
    
    return (h:points[0],m:points[1],s:points[2])
}
// END: Calculate coordinates of hour

func degree2radian(a:CGFloat)->CGFloat {
    let b = CGFloat(M_PI) * a/180
    return b
}


func circleCircumferencePoints(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
    let angle = degree2radian(360/CGFloat(sides))
    let cx = x // x origin
    let cy = y // y origin
    let r  = radius // radius of circle
    var i = sides
    var points = [CGPoint]()
    while points.count <= sides {
        let xpo = cx - r * cos(angle * CGFloat(i)+degree2radian(adjustment))
        let ypo = cy - r * sin(angle * CGFloat(i)+degree2radian(adjustment))
        points.append(CGPoint(x: xpo, y: ypo))
        i -= 1;
    }
    return points
}

func secondMarkers(ctx: CGContextRef, x: CGFloat, y: CGFloat, radius: CGFloat, sides: Int, color: UIColor) {
    // retrieve points
    let points = circleCircumferencePoints(sides, x: x, y: y, radius: radius)
    // create path
    let path = CGPathCreateMutable()
    // determine length of marker as a fraction of the total radius
    var divider:CGFloat = 1/16
    for p in points.enumerate() {
        if p.index % 5 == 0 {
            divider = 1/8
        }
        else {
            divider = 1/16
        }
        
        let xn = p.element.x + divider*(x-p.element.x)
        let yn = p.element.y + divider*(y-p.element.y)
        // build path
        CGPathMoveToPoint(path, nil, p.element.x, p.element.y)
        CGPathAddLineToPoint(path, nil, xn, yn)
        CGPathCloseSubpath(path)
        // add path to context
        CGContextAddPath(ctx, path)
    }
    // set path color
    let cgcolor = color.CGColor
    CGContextSetStrokeColorWithColor(ctx,cgcolor)
    CGContextSetLineWidth(ctx, 3.0)
    CGContextStrokePath(ctx)
    
}
func drawText(rect: CGRect, ctx: CGContextRef, x: CGFloat, y: CGFloat, radius: CGFloat, sides: NumberOfNumerals, color: UIColor) {
    
    // Flip text co-ordinate space, see: http://blog.spacemanlabs.com/2011/08/quick-tip-drawing-core-text-right-side-up/
    CGContextTranslateCTM(ctx, 0.0, CGRectGetHeight(rect))
    CGContextScaleCTM(ctx, 1.0, -1.0)
    // dictates on how inset the ring of numbers will be
    let inset:CGFloat = radius/3.5
    // An adjustment of 270 degrees to position numbers correctly
    let points = circleCircumferencePoints(sides.rawValue, x: x, y: y, radius: radius-inset, adjustment: 270)
    // multiplier enables correcting numbering when fewer than 12 numbers are featured, e.g. 4 sides will display 12, 3, 6, 9
    
    for p in points.enumerate() {
        if p.index > 0 {
            // Font name must be written exactly the same as the system stores it (some names are hyphenated, some aren't) and must exist on the user's device. Otherwise there will be a crash. (In real use checks and fallbacks would be created.) For a list of iOS 7 fonts see here: http://support.apple.com/en-us/ht5878
            let aFont = UIFont(name: "DamascusBold", size: radius/5)
            // create a dictionary of attributes to be applied to the string
            let attr:CFDictionaryRef = [NSFontAttributeName:aFont!,NSForegroundColorAttributeName:UIColor.whiteColor()]
            // create the attributed string
            
            var str = ""
            
            switch p.index {
            case 1:
                str = "I"
            case 2:
                str = "II"
            case 3:
                str = "III"
            case 4:
                str = "IV"
            case 5:
                str = "V"
            case 6:
                str = "VI"
            case 7:
                str = "VII"
            case 8:
                str = "VIII"
            case 9:
                str = "IX"
            case 10:
                str = "X"
            case 11:
                str = "XI"
            case 12:
                str = "XII"
            default:
                break
            }
            let text = CFAttributedStringCreate(nil, str, attr)
            // create the line of text
            let line = CTLineCreateWithAttributedString(text)
            // retrieve the bounds of the text
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.UseOpticalBounds)
            // set the line width to stroke the text with
            CGContextSetLineWidth(ctx, 1.5)
            // set the drawing mode to stroke
            CGContextSetTextDrawingMode(ctx, CGTextDrawingMode.Stroke)
            // Set text position and draw the line into the graphics context, text length and height is adjusted for
            let xn = p.element.x - bounds.width/2
            let yn = p.element.y - bounds.midY
            CGContextSetTextPosition(ctx, xn, yn)
            // the line of text is drawn - see https://developer.apple.com/library/ios/DOCUMENTATION/StringsTextFonts/Conceptual/CoreText_Programming/LayoutOperations/LayoutOperations.html
            // draw the line of text
            CTLineDraw(line, ctx)
        }
    }
    
}

enum NumberOfNumerals:Int {
    case two = 2, four = 4, twelve = 12
}

class View: UIView {
    
    
    override func drawRect(rect:CGRect)
        
    {
        
        // obtain context
        let ctx = UIGraphicsGetCurrentContext()
        
        // decide on radius
        let rad = CGRectGetWidth(rect)/3.5
        
        let endAngle = CGFloat(2*M_PI)
        
        // add the circle to the context
        CGContextAddArc(ctx, CGRectGetMidX(rect), CGRectGetMidY(rect), rad, 0, endAngle, 1)
        
        // set fill color
        CGContextSetFillColorWithColor(ctx,UIColor.grayColor().CGColor)
        
        // set stroke color
        CGContextSetStrokeColorWithColor(ctx,UIColor.whiteColor().CGColor)
        
        // set line width
        CGContextSetLineWidth(ctx, 4.0)
        // use to fill and stroke path (see http://stackoverflow.com/questions/13526046/cant-stroke-path-after-filling-it )
        
        // draw the path
        CGContextDrawPath(ctx, CGPathDrawingMode.FillStroke);
        
        secondMarkers(ctx!, x: CGRectGetMidX(rect), y: CGRectGetMidY(rect), radius: rad, sides: 60, color: UIColor.whiteColor())
        
        drawText(rect, ctx: ctx!, x: CGRectGetMidX(rect), y: CGRectGetMidY(rect), radius: rad, sides: .twelve, color: UIColor.whiteColor())
        
        
        
        
    }
}
