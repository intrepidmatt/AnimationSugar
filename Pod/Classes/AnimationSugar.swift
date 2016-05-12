//
//  Animate.swift
//
//  Created by Matt Bridges on 2/27/16.
//  Copyright © 2016 Matt Bridges. All rights reserved.
//

import Foundation
import UIKit

/**
 Animate changes to one or more `UIView` objects.
 
 - Parameter duration: The length over which the animation(s) occur.
 - Parameter animations: A block containing changes to `UIView` animatable properties.
 - Returns An `Animation` object that can be further modified (e.g. changing an
 animation curve) or chained with further animations.
 */
public func animate(duration duration: NSTimeInterval = Animation.defaultAnimationDuration, animations: () -> ()) -> Animation {
    return Animation(duration: duration, animations: animations)
}

public class Animation {
    
    private struct Constants {
        static let DefaultAnimationDuration: NSTimeInterval = 0.3
    }
    
    public static var defaultAnimationDuration = Constants.DefaultAnimationDuration
    private let animations: () -> ()
    private let duration: NSTimeInterval
    private var delay: NSTimeInterval = 0
    private var options: UIViewAnimationOptions?
    private var completion: ((Bool) -> ())?
    private var springDampingRatio: CGFloat?
    private var springInitialVelocity: CGFloat?
    private var prevAnimation: Animation?
    private var nextAnimation: Animation?
    
    /**
     Initialize an `Animation` object.
     
     - Parameter duration: The length over which the animation(s) occur
     - Parameter animations: A block containing changes to `UIView` animatable properties.
     - Parameter startNow: A boolean indicating whether to immediately start the animation
     or wait to be triggered later. Chained animations set this parameter to false.
     */
    init(duration: NSTimeInterval, animations: () -> (), startNow: Bool = true) {
        self.duration = duration
        self.animations = animations
        
        if (startNow) {
            dispatch_async(dispatch_get_main_queue()) {
                self.start()
            }
        }
    }
    
    /**
     Modify the animation options.
     
     - Parameter option: The option(s) to set. E.g. `.withOption(.AnimationCurveEaseOut)`
     - Returns An `Animation` object that can be modified or chained with further animations.
     */
    public func withOption(option: UIViewAnimationOptions) -> Animation {
        if let options = options {
            self.options = options.union(option)
        } else {
            self.options = option
        }
        
        return self
    }
    
    /**
     Add a delay before an animation begins.
     
     - Parameter delay: The amount of time to delay.
     - Returns An `Animation` object to be modified or chained with further animations.
     */
    public func withDelay(delay: NSTimeInterval) -> Animation {
        self.delay = delay
        return self
    }
    
    /**
     Set a completion block that runs when the animation has completed.
     
     - Parameter completion: A block of code to run.
     - Returns An `Animation` object to be modified or chained with further animations.
     */
    public func withCompletion(completion: (Bool) -> ()) -> Animation {
        self.completion = completion
        return self
    }
    
    /**
     Animate using "spring" physics.
     
     - Parameter dampingRatio: The damping ratio for the spring animation as it approaches
     its quiescent state.
     
     To smoothly decelerate the animation without oscillation, use a value of 1. Employ
     a damping ratio closer to zero to increase oscillation.
     - Parameter initialVelocity: The initial spring velocity. For smooth start to the
     animation, match this value to the view’s velocity as it was prior to attachment.
     A value of 1 corresponds to the total animation distance traversed in one second.
     
     For example, if the total animation distance is 200 points and you want the start of the
     animation to match a view velocity of 100 pt/s, use a value of 0.5.
     - Returns An `Animation` object to be modified or chained with further animations.
     */
    public func withSpring(dampingRatio dampingRatio: CGFloat, initialVelocity: CGFloat) -> Animation {
        self.springDampingRatio = dampingRatio
        self.springInitialVelocity = initialVelocity
        return self
    }
    
    /**
     Chain a new animation to begin immediately after a previous animation finishes.
     
     Use this method to prevent excessive nesting of animations inside completion blocks.
     
     - Parameter duration: The length over which the animation occurs.
     - Parameter animations: A block containing changes to `UIView` animatable properties.
     - Returns An `Animation` object to be modified or chained with further animations
     */
    public func thenAnimate(duration duration: NSTimeInterval = defaultAnimationDuration, animations: () -> ()) -> Animation {
        let nextAnimation = Animation(duration: duration, animations: animations, startNow: false)
        nextAnimation.prevAnimation = self
        self.nextAnimation = nextAnimation
        
        // Run current completion block, then run next animation
        let completionBlock = self.completion
        self.completion = {
            finished in
            completionBlock?(finished)
            self.nextAnimation?.start()
        }
        
        return nextAnimation
    }
    
    /**
     Start an animation.
     */
    private func start() {
        if let prevAnimation = self.prevAnimation {
            prevAnimation.start()
        } else {
            if let nextAnimation = self.nextAnimation {
                nextAnimation.prevAnimation = nil
            }
            
            guard let dampingRatio = springDampingRatio, initialVelocity = springInitialVelocity else {
                UIView.animateWithDuration(duration,
                    delay: delay,
                    options: options ?? [],
                    animations: animations,
                    completion: completion)
                return
            }
            
            UIView.animateWithDuration(duration,
                delay: delay,
                usingSpringWithDamping: dampingRatio,
                initialSpringVelocity: initialVelocity,
                options: options ?? [],
                animations: animations,
                completion: completion)
        }
    }
}

extension UIView {
    /**
     Translate the view using its `transform` property.
     
     - Parameter tx: Translation distance along the x axis
     - Parameter ty: Translation distance along the y axis
     */
    public func translate(tx tx: CGFloat = 0, ty: CGFloat = 0) {
        self.transform = CGAffineTransformTranslate(self.transform, tx, ty)
    }
    
    /**
     Scale the view using its `transform` property.
     
     - Parameter sx: Scale factor in the x dimension
     - Parameter xy: Scale factor in the y dimension
     */
    public func scale(sx sx: CGFloat, sy: CGFloat) {
        self.transform = CGAffineTransformScale(self.transform, sx, sy)
    }
    
    /**
     Rotate the view using its `transform` property.
     
     - Parameter angle: The angle to rotate in radians
     */
    public func rotate(angle angle: CGFloat) {
        self.transform = CGAffineTransformRotate(self.transform, angle)
    }
    
    /**
     Translate the view by altering its `frame` property.
     
     - Parameter tx: Translation distance along the x axis
     - Parameter ty: Translation distance along the y axis
     */
    public func translateFrame(tx tx: CGFloat = 0, ty: CGFloat = 0) {
        var frame = self.frame
        frame.origin.x = frame.origin.x + tx
        frame.origin.y = frame.origin.y + ty
        self.frame = frame
    }
    
    /**
     Stretch or shring the view using its `frame` property.
     
     - Parameter deltaWidth: The amount to stretch the frame in the x direction
     - Parameter deltaHeight: The amount to stretch the frame in the y direction
     */
    public func stretchFrame(deltaWidth deltaWidth: CGFloat, deltaHeight: CGFloat) {
        var frame = self.frame
        frame.size.width = frame.size.width + deltaWidth
        frame.size.height = frame.size.height + deltaHeight
        self.frame = frame
    }
    
    /**
     Resize the view's `frame` property.
     
     - Parameter width: The new width
     - Parameter height: The new height
     */
    public func resizeFrame(width width: CGFloat, height: CGFloat) {
        var frame = self.frame
        frame.size.width = width
        frame.size.height = height
        self.frame = frame
    }
    
    /**
     Flip the view 180 degrees horizontally (along the y axis)
     
     - Parameter perspectiveDistance: The simulated distance between the observer
     and the view, in points. Since the flip is in three dimensions, a perspective
     transform is applied. Smaller values will have an exaggerated perspective.
     Default value is 1000 points.
     */
    public func flipHorizontal(perspectiveDistance: CGFloat = 1000.0) {
        self.layer.transform.m34 = -1.0 / perspectiveDistance
        self.layer.transform = CATransform3DRotate(self.layer.transform, CGFloat(M_PI), 0, 1.0, 0)
    }
    
    /**
     Flip the view 180 degrees vertically (along the x axis)
     
     - Parameter perspectiveDistance: The simulated distance between the observer
     and the view, in points. Since the flip is in three dimensions, a perspective
     transform is applied. Smaller values will have an exaggerated perspective.
     Default value is 1000 points.
     */
    public func flipVertical(perspectiveDistance: CGFloat = 1000.0) {
        self.layer.transform.m34 = -1.0 / perspectiveDistance
        self.layer.transform = CATransform3DRotate(self.layer.transform, CGFloat(M_PI), 1.0, 0, 0)
    }
    
    /**
     Fade in a view by animating its `alpha`.
     
     - Parameter duration: The duration of the animation
     - Returns: An `Animation` that can be chained or altered.
     */
    public func fadeIn(duration duration: NSTimeInterval = Animation.defaultAnimationDuration) -> Animation {
        self.alpha = 0.0
        return animate(duration: duration) {
            self.alpha = 1.0
        }
    }
    
    /**
     Fade out a view by animating its `alpha`.
     
     - Parameter duration: The duration of the animation
     - Returns An `Animation` that can be chained or altered.
     */
    public func fadeOut(duration duration: NSTimeInterval = Animation.defaultAnimationDuration) -> Animation {
        return animate(duration: duration) {
            self.alpha = 0.0
        }
    }
}
