import SwiftUI

struct WindowView: View {
    var views: [any View] = []

    var body: some View {
        List(Array(views.enumerated()), id: \.offset) {
            AnyView($0.element)
        }
    }
}

extension WindowView {
    init(_ views: [any View]) {
        self.views = views
    }
}
