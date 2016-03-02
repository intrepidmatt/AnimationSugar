//
//  Animate.swift
//
//  Created by Matt Bridges on 2/27/16.
//  Copyright © 2016 Matt Bridges. All rights reserved.
//

import Foundation
import UIKit

public func animate(duration duration: NSTimeInterval, animations: () -> ()) -> Animation {
    return Animation(duration: duration, animations: animations)
}

public class Animation {
    
    private let animations: () -> ()
    private let duration: NSTimeInterval
    private var delay: NSTimeInterval = 0
    private var options: UIViewAnimationOptions?
    private var completion: ((Bool) -> ())?
    private var springDampingRatio: CGFloat?
    private var springInitialVelocity: CGFloat?
    private var prevAnimation: Animation?
    private var nextAnimation: Animation?
    
    init(duration: NSTimeInterval, animations: () -> (), startNow: Bool = true) {
        self.duration = duration
        self.animations = animations
        
        if (startNow) {
            dispatch_async(dispatch_get_main_queue()) {
                self.start()
            }
        }
    }
    
    public func withOption(option: UIViewAnimationOptions) -> Animation {
        if let options = options {
            self.options = options.union(option)
        } else {
            self.options = option
        }
        
        return self
    }
    
    public func withDelay(delay: NSTimeInterval) -> Animation {
        self.delay = delay
        return self
    }
    
    public func withCompletion(completion: (Bool) -> ()) -> Animation {
        self.completion = completion
        return self
    }
    
    public func withSpring(dampingRatio dampingRatio: CGFloat, initialVelocity: CGFloat) -> Animation {
        self.springDampingRatio = dampingRatio
        self.springInitialVelocity = initialVelocity
        return self
    }
    
    public func thenAnimate(duration duration: NSTimeInterval, animations: () -> ()) -> Animation {
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
