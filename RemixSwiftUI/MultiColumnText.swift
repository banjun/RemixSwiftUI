import SwiftUI
import UIKit

// refs. https://gist.github.com/banjun/b6ea9f025a290af4186da6875b55295e
struct MultiColumnText: View {
    private let storage: NSTextStorage
    private let layoutManager: NSLayoutManager = .init()
    private let containers: [NSTextContainer]
    let textViews: [TextView]

    init(text: NSAttributedString, columns: Int) {
        storage = .init(attributedString: text)
        storage.addLayoutManager(layoutManager)
        containers = (0..<columns).map {_ in .init()}
        textViews = containers.map {
            TextView(container: $0)
        }
        containers.forEach {
            $0.widthTracksTextView = true
            $0.heightTracksTextView = true
            layoutManager.addTextContainer($0)
        }
    }

    var body: some View {
        HStack(alignment: .top) {
            ForEach(Array(0..<textViews.count), id: \.self) {
                textViews[$0]
            }
        }
    }

    struct TextView: UIViewRepresentable {
        let container: NSTextContainer
        func makeUIView(context: Context) -> UIView {
            let v = UIView()
            let tv = UITextView(frame: .zero, textContainer: container)
            tv.isScrollEnabled = false
            tv.isEditable = false
            tv.isSelectable = false
            tv.translatesAutoresizingMaskIntoConstraints = false
            v.addSubview(tv)
            tv.leadingAnchor.constraint(equalTo: v.leadingAnchor).isActive = true
            tv.trailingAnchor.constraint(equalTo: v.trailingAnchor).isActive = true
            tv.topAnchor.constraint(equalTo: v.topAnchor).isActive = true
            tv.bottomAnchor.constraint(equalTo: v.bottomAnchor).isActive = true
            return v
        }
        func updateUIView(_ uiView: UIView, context: Context) {
        }
    }
}
