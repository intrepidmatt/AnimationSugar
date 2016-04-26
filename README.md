![AnimationSugar](Images/AnimationSugar_logo.png)

## AnimationSugar

AnimationSugar is a tiny Swift library that can make iOS animation code slightly less ugly.

When iterating on animations, it can be a pain to swap between the many method signatures of `UIView.animateWithDuration`. Also, multi-step animations that nest inside of completion blocks can quickly become an unreadabe mess. 

It was built at [Intrepid](http://intrepid.io).

##Examples

    animate {
        view.transform.tx += 150
    }

![Image of animation to the right](Images/AnimationSugar_1.gif)

    animate {
        view.transform.tx += 150
    }
    .withSpring(dampingRatio: 0.5, initialVelocity: 0)

![Image of animation with spring](Images/AnimationSugar_2.gif)

    animate {
        view.transform.tx += 150
    }
    .thenAnimate {
        view.transform.ty += 150
    }
    .thenAnimate {
        view.transform.tx -= 150
    }
    .thenAnimate {
        view.transform.ty -= 150
    }

![Image of animation in a square](Images/AnimationSugar_3.gif)

    animate(duration: 0.3) {
        view.transform.tx += 150
    }
    .withOption(.CurveEaseOut)
    .withCompletion { _ in
        view.backgroundColor = UIColor(white: 0.8, alpha: 1.0)
    }

![Image of animation with completion](Images/AnimationSugar_4.gif)

## Usage

### Cocoapods

    pod install 'AnimationSugar'

## Reference

`func animate(duration duration: NSTimeInterval = defaultAnimationDuration, animations: () -> ()) -> Animation`

- Starts an animation. Use trailing closure syntax to write your animations, e.g.: `animate(duration: 0.3) { ... }`. Without the duration argument, a default duration is used (see `defaultAnimationDuration`). 

`func withDelay(delay: NSTimeInterval) -> Animation`
- Set a delay to wait before the animation starts.

`func withOption(option: UIViewAnimationOptions) -> Animation`
- Set an animation option for the animation. For multiple options, either chain them e.g. `.withOption(.Autoreverse).withOption(.Repeat)` or use once with an array e.g. `.withOption([.Autoreverse, .Repeat])`.

`func withSpring(dampingRatio dampingRatio: CGFloat, initialVelocity: CGFloat) -> Animation`
- Use a spring animation curve with the given damping ratio and initial velocity.

`func withCompletion(completion: (Bool) -> ()) -> Animation`
- Set a completion block for when the animation finishes. Use trailing closure syntax e.g. `animate { ... }.withCompletion { ... }`

`func thenAnimate(duration duration: NSTimeInterval = defaultAnimationDuration, animations: () -> ()) -> Animation`
- Chain a new animation to occur after the previous animation is completed. See the "square" example above. Without the duration argument, a default duration is used (see `defaultAnimationDuration`)

`static var defaultAnimationDuration`
- Change the default animation duration, to use `animate()` or `thenAnimate()` without a duration argument. This value is initialized to 0.3 seconds and can be changed at any time, i.e. `Animation.defaultAnimationDuration = 0.25`.
