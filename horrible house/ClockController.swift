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
    
    var house : House = (UIApplication.shared.delegate as! AppDelegate).house
    var fullView = UIView()
    var clockView = UIView()
    var timer = Timer()
    
    func rotateLayer(currentLayer:CALayer,dur:CFTimeInterval){
        
        let angle = degree2radian(a: 360)
        
        // rotation http://stackoverflow.com/questions/1414923/how-to-rotate-uiimageview-with-fix-point
        let theAnimation = CABasicAnimation(keyPath:"transform.rotation.z")
        theAnimation.duration = dur
        // Make this view controller the delegate so it knows when the animation starts and ends
        
        // **********
        //theAnimation.delegate = self
        
        theAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        // Use fromValue and toValue
        theAnimation.fromValue = 0
        theAnimation.repeatCount = Float.infinity
        theAnimation.toValue = angle
        
        // Add the animation to the layer
        currentLayer.add(theAnimation, forKey:"rotate")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    func viewWillDisappear() {
        self.clockView.removeFromSuperview()
        self.fullView.removeFromSuperview()
        self.timer.invalidate()
    }
    
    func viewWillAppear() {
        self.house = (UIApplication.shared.delegate as! AppDelegate).house
        self.timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(drawClockFace), userInfo: nil, repeats: true)
        
        self.drawClockBase()
        self.drawClockFace()
        
        
        
        
        
    }
    
    func drawClockBase() {
        self.fullView = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.size.height * 0.2, width: self.view.frame.size.width, height: self.view.frame.size.height))
        
        self.clockView = View(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width))
        
        fullView.addSubview(clockView)
        self.view.addSubview(fullView)
        self.view.setStyleInverse()
        self.fullView.setStyleInverse()
        self.clockView.setStyleInverse()
    }
    
    func drawClockFace() {
        let time = timeCoords(x: clockView.frame.midX, y: clockView.frame.midY, time: getTime(time: self.house.gameClock.currentTime), radius: 50)
        
        self.clockView.layer.sublayers = []
        
        self.drawHours(time: time)
        self.drawMinutes(time: time)
        self.drawSeconds(time: time)
        
        self.drawCenter()
        
        if self.house.gameClock.reachedEndTime {
            self.drawCrack()
        }
        
    }
    
    func drawHours( time: (h:CGPoint, m:CGPoint,s:CGPoint) ) {
        // Hours
        let hourLayer = CAShapeLayer()
        hourLayer.frame = clockView.frame
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: clockView.frame.midX, y: clockView.frame.midY))
        path.addLine(to: CGPoint(x: time.h.x, y: time.h.y))
        hourLayer.path = path
        hourLayer.lineWidth = 4
        hourLayer.lineCap = kCALineCapRound
        hourLayer.strokeColor = Color.specialColor.cgColor
        
        // see for rasterization advice http://stackoverflow.com/questions/24316705/how-to-draw-a-smooth-circle-with-cashapelayer-and-uibezierpath
        hourLayer.rasterizationScale = UIScreen.main.scale;
        hourLayer.shouldRasterize = true
        
        self.clockView.layer.addSublayer(hourLayer)
        // time it takes for hour hand to pass through 360 degress
        // rotateLayer(hourLayer,dur:43200)
    }
    
    func drawMinutes( time: (h:CGPoint, m:CGPoint,s:CGPoint) ) {
        // Minutes
        let minuteLayer = CAShapeLayer()
        minuteLayer.frame = clockView.frame
        let minutePath = CGMutablePath()
        
        minutePath.move(to: CGPoint(x: clockView.frame.midX, y: clockView.frame.midY))
        minutePath.addLine(to: CGPoint(x: time.m.x, y: time.m.y))
        minuteLayer.path = minutePath
        minuteLayer.lineWidth = 3
        minuteLayer.lineCap = kCALineCapRound
        minuteLayer.strokeColor = Color.specialColor.cgColor
        
        minuteLayer.rasterizationScale = UIScreen.main.scale;
        minuteLayer.shouldRasterize = true
        
        self.clockView.layer.addSublayer(minuteLayer)
        // rotateLayer(minuteLayer,dur: 3600)
    }
    
    func drawSeconds( time: (h:CGPoint, m:CGPoint,s:CGPoint) ) {
        // Seconds
        let secondLayer = CAShapeLayer()
        secondLayer.frame = clockView.frame
        
        let secondPath = CGMutablePath()
        secondPath.move(to: CGPoint(x: clockView.frame.midX, y: clockView.frame.midY))
        secondPath.addLine(to: CGPoint(x: time.s.x, y: time.s.y))
        
        secondLayer.path = secondPath
        secondLayer.lineWidth = 1
        secondLayer.lineCap = kCALineCapRound
        secondLayer.strokeColor = Color.backgroundColor.cgColor
        
        secondLayer.rasterizationScale = UIScreen.main.scale;
        secondLayer.shouldRasterize = true
        
        self.clockView.layer.addSublayer(secondLayer)
        // rotateLayer(secondLayer,dur: 60)
    }
    
    func drawCenter() {
        let centerPiece = CAShapeLayer()
        let endAngle = CGFloat(2*M_PI)
        let circle = UIBezierPath(arcCenter: CGPoint(x:clockView.frame.midX,y:clockView.frame.midX), radius: 4.5, startAngle: 0, endAngle: endAngle, clockwise: true)
        // thanks to http://stackoverflow.com/a/19395006/1694526 for how to fill the color
        centerPiece.path = circle.cgPath
        centerPiece.fillColor = Color.specialColor.cgColor
        self.clockView.layer.addSublayer(centerPiece)
    }
    
    func drawCrack() {
        // Make jagged line
        let crackLayer = CAShapeLayer()
        crackLayer.frame = clockView.frame
        
        var points : [CGPoint] = [
            CGPoint(x: clockView.frame.width * 0.3, y: clockView.frame.height * 0.29),
            CGPoint(x: clockView.frame.width * 0.35, y: clockView.frame.height * 0.32),
            CGPoint(x: clockView.frame.width * 0.34, y: clockView.frame.height * 0.35),
            CGPoint(x: clockView.frame.width * 0.55, y: clockView.frame.height * 0.5),
            CGPoint(x: clockView.frame.width * 0.71, y: clockView.frame.height * 0.70),
            CGPoint(x: clockView.frame.width * 0.55, y: clockView.frame.height * 0.5),
            CGPoint(x: clockView.frame.width * 0.46, y: clockView.frame.height * 0.68),
            CGPoint(x: clockView.frame.width * 0.47, y: clockView.frame.height * 0.71),
            CGPoint(x: clockView.frame.width * 0.42, y: clockView.frame.height * 0.75),
            CGPoint(x: clockView.frame.width * 0.4, y: clockView.frame.height * 0.77),
            ]
        
        let crackPath = CGMutablePath()
        crackPath.move(to: CGPoint(x: points[0].x, y: points[0].y))
        for i in 1 ..< points.count {
            crackPath.addLine(to: CGPoint(x: points[i].x, y: points[i].y))
        }
        
        crackLayer.path = crackPath
        crackLayer.lineWidth = 2
        crackLayer.lineCap = kCALineCapRound
        crackLayer.strokeColor = Color.specialColor.cgColor
        crackLayer.fillColor = nil
        
        crackLayer.rasterizationScale = UIScreen.main.scale;
        crackLayer.shouldRasterize = true
        
        self.clockView.layer.addSublayer(crackLayer)
        
        self.timer.invalidate()
        
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
    var angle = degree2radian(a: 6)
    func newPoint (t:Int) {
        let xpo = cx - r * cos(angle * CGFloat(t)+degree2radian(a: adjustment))
        let ypo = cy - r * sin(angle * CGFloat(t)+degree2radian(a: adjustment))
        points.append(CGPoint(x: xpo, y: ypo))
    }
    
    
    
    // work out hours first
    var hours = time.h
    if hours > 12 {
        hours = hours-12
    }
    r = radius * 0.85
    let hoursInSeconds = time.h*3600 + time.m*60 + time.s
    newPoint(t: hoursInSeconds*5/3600)
    
    // work out minutes second
    r = radius * 1.25
    let minutesInSeconds = time.m*60 + time.s
    newPoint(t: minutesInSeconds/60)
    
    // work out seconds last
    r = radius * 1.5
    newPoint(t: time.s)
    
    return (h:points[0],m:points[1],s:points[2])
}
// END: Calculate coordinates of hour

func degree2radian(a:CGFloat)->CGFloat {
    let b = CGFloat(M_PI) * a/180
    return b
}


func circleCircumferencePoints(sides:Int,x:CGFloat,y:CGFloat,radius:CGFloat,adjustment:CGFloat=0)->[CGPoint] {
    let angle = degree2radian(a: 360/CGFloat(sides))
    let cx = x // x origin
    let cy = y // y origin
    let r  = radius // radius of circle
    var i = sides
    var points = [CGPoint]()
    while points.count <= sides {
        let xpo = cx - r * cos(angle * CGFloat(i)+degree2radian(a: adjustment))
        let ypo = cy - r * sin(angle * CGFloat(i)+degree2radian(a: adjustment))
        points.append(CGPoint(x: xpo, y: ypo))
        i -= 1;
    }
    return points
}

func secondMarkers(ctx: CGContext, x: CGFloat, y: CGFloat, radius: CGFloat, sides: Int, color: UIColor) {
    // retrieve points
    let points = circleCircumferencePoints(sides: sides, x: x, y: y, radius: radius)
    // create path
    let path = CGMutablePath()
    // determine length of marker as a fraction of the total radius
    var divider:CGFloat = 1/16
    
    var i = 0
    for p in points.enumerated() {
        if i % 5 == 0 {
            divider = 1/8
        }
        else {
            divider = 1/16
        }
        
        let xn = p.element.x + divider*(x-p.element.x)
        let yn = p.element.y + divider*(y-p.element.y)
        // build path
        
        path.move(to: CGPoint(x: p.element.x, y: p.element.y))
        path.addLine(to: CGPoint(x: xn, y: yn))
        path.closeSubpath()
        // add path to context
        ctx.addPath(path)
        i += 0
    }
    // set path color
    let cgcolor = color.cgColor
    ctx.setStrokeColor(cgcolor)
    ctx.setLineWidth(3.0)
    ctx.strokePath()
    
}
func drawText(rect: CGRect, ctx: CGContext, x: CGFloat, y: CGFloat, radius: CGFloat, sides: NumberOfNumerals, color: UIColor) {
    
    // Flip text co-ordinate space, see: http://blog.spacemanlabs.com/2011/08/quick-tip-drawing-core-text-right-side-up/
    ctx.translateBy(x: 0.0, y: rect.height)
    ctx.scaleBy(x: 1.0, y: -1.0)
    // dictates on how inset the ring of numbers will be
    let inset:CGFloat = radius/3.5
    // An adjustment of 270 degrees to position numbers correctly
    let points = circleCircumferencePoints(sides: sides.rawValue, x: x, y: y, radius: radius-inset, adjustment: 270)
    // multiplier enables correcting numbering when fewer than 12 numbers are featured, e.g. 4 sides will display 12, 3, 6, 9
    
    var i = 0
    for p in points.enumerated() {
        if i > 0 {
            // Font name must be written exactly the same as the system stores it (some names are hyphenated, some aren't) and must exist on the user's device. Otherwise there will be a crash. (In real use checks and fallbacks would be created.) For a list of iOS 7 fonts see here: http://support.apple.com/en-us/ht5878
            let aFont = UIFont(name: "DamascusBold", size: radius/5)
            // create a dictionary of attributes to be applied to the string
            let attr = [NSFontAttributeName:aFont!,NSForegroundColorAttributeName:Color.specialColor]
            // create the attributed string
            
            var str = ""
            
            switch i {
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
            let text = CFAttributedStringCreate(nil, str as CFString!, attr as CFDictionary!)
            // create the line of text
            let line = CTLineCreateWithAttributedString(text!)
            // retrieve the bounds of the text
            let bounds = CTLineGetBoundsWithOptions(line, CTLineBoundsOptions.useOpticalBounds)
            // set the line width to stroke the text with
            ctx.setLineWidth(1.5)
            // set the drawing mode to stroke
            ctx.setTextDrawingMode(CGTextDrawingMode.stroke)
            // Set text position and draw the line into the graphics context, text length and height is adjusted for
            let xn = p.element.x - bounds.width/2
            let yn = p.element.y - bounds.midY
            ctx.textPosition = CGPoint(x: xn, y: yn)
            // the line of text is drawn - see https://developer.apple.com/library/ios/DOCUMENTATION/StringsTextFonts/Conceptual/CoreText_Programming/LayoutOperations/LayoutOperations.html
            // draw the line of text
            CTLineDraw(line, ctx)
        }
        i += 1
    }
    
}

enum NumberOfNumerals:Int {
    case two = 2, four = 4, twelve = 12
}

class View: UIView {
    
    
    func drawRect(rect:CGRect)
        
    {
        
        // obtain context
        let ctx = UIGraphicsGetCurrentContext()
        
        // decide on radius
        let rad = rect.width/3.5
        
        let endAngle = CGFloat(2*M_PI)
        
        // add the circle to the context
        ctx?.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rad, startAngle: 0, endAngle: endAngle, clockwise: true)
        
        // set fill color
        ctx!.setFillColor(Color.foregroundColor.cgColor)
        
        // set stroke color
        ctx!.setStrokeColor(Color.specialColor.cgColor)
        
        // set line width
        ctx!.setLineWidth(4.0)
        // use to fill and stroke path (see http://stackoverflow.com/questions/13526046/cant-stroke-path-after-filling-it )
        
        // draw the path
        ctx!.drawPath(using: CGPathDrawingMode.fillStroke);
        
        secondMarkers(ctx: ctx!, x: rect.midX, y: rect.midY, radius: rad, sides: 60, color: Color.specialColor)
        
        drawText(rect: rect, ctx: ctx!, x: rect.midX, y: rect.midY, radius: rad, sides: .twelve, color: Color.specialColor)
        
        
        
        
    }
}
