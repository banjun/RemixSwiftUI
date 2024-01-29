import SwiftUI

struct DismissImmersiveSpaceButton: View {
    @Binding var showImmersiveSpace: Bool

    var body: some View {
        Button("Dismiss Immersive Space") {
            showImmersiveSpace = false
        }
    }
}
