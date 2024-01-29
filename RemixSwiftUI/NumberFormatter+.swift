import Foundation

extension NumberFormatter {
    static let shortFloat = {
        let f = NumberFormatter()
        f.maximumFractionDigits = 1
        return f
    }()
    func string(from value: CGFloat) -> String { string(from: NSNumber(value: value))! }
}
