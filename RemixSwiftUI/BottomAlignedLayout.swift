import SwiftUI

/// for Entities converted from SwiftUI via RealityView attachments
struct BottomAlignedLayout: Layout {
    /// for clipped views, use `BottomAlignedLayout { VStack { Spacer(); content } }` or avoidClippingByDoubleHeight.
    var avoidClippingByDoubleHeight: Bool = false

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        // assume vertically stacked in case multiple subviews are passed
        let idealSizes = subviews.map { $0.sizeThatFits(proposal) }
        let idealWidth = idealSizes.map(\.width).max() ?? proposal.width ?? 0
        let idealHeight = idealSizes.map(\.height).reduce(0, +)
        // print("\(#function) proposal = \(proposal), BttomAlignedLayout = \((idealWidth, idealHeight))")
        return CGSize(width: idealWidth, height: idealHeight * (avoidClippingByDoubleHeight ? 2 : 1))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        // expected result
        // using Self { content1 }, consume much height to place content1:
        // V:|[ s p a c e T ][content1][spaceB]|
        // or
        // V:|[spaceT][c o n t e n t 1][spaceB]|
        // , where spaceB.top == view.centerY
        // but we cannot pre-calculate content sizes for all possible view states.
        //
        // as RealityView matches midY, use offset by (- consumed / 2) to adjust,
        // allowing entities to overflow (as Entities can overflow from bounds sizeThatFits)
        let (consumed, offsetsFromBottom): (CGFloat, [(CGFloat, ProposedViewSize)]) = subviews.reversed().reduce((0, [])) { r, subview in
            let (offsetFromBottom, offsets) = r
            let proposalForSubview = ProposedViewSize(width: proposal.width, height: proposal.height.map {$0 - offsetFromBottom})
            let height = subview.sizeThatFits(proposalForSubview).height
            return (offsetFromBottom + height, offsets + [(offsetFromBottom, proposalForSubview)])
        }
        let offsetBias = -(consumed / (avoidClippingByDoubleHeight ? 1 : 2))
        zip(offsetsFromBottom, subviews.reversed()).forEach { offsets, subview in
            subview.place(at: CGPoint(x: bounds.midX, y: bounds.maxY - offsets.0 + offsetBias), anchor: .bottom, proposal: offsets.1)
        }
        // print("\(#function) proposal = \(proposal), consumed = \(consumed)")
    }
}
