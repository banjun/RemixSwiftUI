import SwiftUI

struct RealityViewAttachment: Identifiable {
    var id: String
    var body: () -> any View
    init(_ id: String, body: @escaping () -> any View) {
        self.id = id
        self.body = body
    }
}
