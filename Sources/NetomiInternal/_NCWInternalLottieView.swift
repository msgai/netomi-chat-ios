import UIKit
import Lottie

/// Internal dependency-side renderer. NetomiCore controls it only through
/// Objective-C selectors and never links against Lottie implementation types.
@objc(_NCWInternalLottieView)
final class _NCWInternalLottieView: UIView {
    private let animationView = LottieAnimationView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        installAnimationView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        installAnimationView()
    }

    @objc(netomi_updateWithConfiguration:)
    func update(with configuration: NSDictionary) -> NSNumber {
        guard let data = configuration["data"] as? Data,
              let animation = try? LottieAnimation.from(data: data) else {
            return false
        }

        animationView.animation = animation
        animationView.loopMode = loopMode(from: configuration["loopMode"] as? String)
        if configuration["autoPlay"] as? Bool == true {
            animationView.play()
        }
        return true
    }

    @objc(netomi_play)
    func play() {
        animationView.play()
    }

    @objc(netomi_stop)
    func stop() {
        animationView.stop()
    }

    @objc(netomi_pause)
    func pause() {
        animationView.pause()
    }

    @objc(netomi_setProgress:)
    func setProgress(_ value: NSNumber) {
        animationView.currentProgress = CGFloat(value.doubleValue)
    }

    @objc(netomi_setSpeed:)
    func setSpeed(_ value: NSNumber) {
        animationView.animationSpeed = CGFloat(value.doubleValue)
    }

    @objc(netomi_isPlaying)
    func isPlaying() -> NSNumber {
        NSNumber(value: animationView.isAnimationPlaying)
    }

    @objc(netomi_animationProgress)
    func animationProgress() -> NSNumber {
        NSNumber(value: Double(animationView.currentProgress))
    }

    @objc(netomi_setColorWithConfiguration:)
    func setColor(with configuration: NSDictionary) {
        guard let keypath = configuration["keypath"] as? String,
              let color = configuration["color"] as? UIColor else { return }
        let provider = ColorValueProvider(color.lottieColorValue)
        animationView.setValueProvider(provider, keypath: AnimationKeypath(keypath: keypath))
    }

    @objc(netomi_setGradientWithConfiguration:)
    func setGradient(with configuration: NSDictionary) {
        guard let keypath = configuration["keypath"] as? String,
              let colors = configuration["colors"] as? [UIColor] else { return }
        let provider = GradientValueProvider(colors.map(\.lottieColorValue), locations: [0, 1])
        animationView.setValueProvider(provider, keypath: AnimationKeypath(keypath: keypath))
    }

    @objc(netomi_cleanup)
    func cleanup() {
        animationView.stop()
        animationView.animation = nil
        removeFromSuperview()
    }

    private func installAnimationView() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationView.topAnchor.constraint(equalTo: topAnchor),
            animationView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func loopMode(from rawValue: String?) -> LottieLoopMode {
        switch rawValue {
        case "playOnce": return .playOnce
        case "autoReverse": return .autoReverse
        default: return .loop
        }
    }
}
