import SwiftUI
import RealityKit
import RealityKitContent

struct ControlView: View {
    @Binding var showImmersiveSpace: Bool

    var body: some View {
        Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
            .font(.title)
            .fixedSize()
            .padding()
    }
}

#Preview(windowStyle: .automatic) {
    struct V: View {
        @State var s: Bool = false
        var body: some View {
            ControlView(showImmersiveSpace: $s)
        }
    }
    return V()
}
