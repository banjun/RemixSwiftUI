import SwiftUI

struct Popup: View {
    @State private var isExpanded: Bool = false

    var toggleText: () -> any View = {
        Text("Expand / Hide")
            .font(.extraLargeTitle)
    }

    var content: () -> any View = {
        VStack {
            Text("Content").font(.title)
            PhysicalRectangle(sideInCM: 20)
        }
        .padding()
    }

    var body: some View {
        BottomAlignedLayout {
            VStack {
                AnyView(toggleText())
                if isExpanded {
                    AnyView(content())
                }
            }
            .padding()
            .glassBackgroundEffect()
            .hoverEffect()
            .onTapGesture {
                withAnimation(.spring) {
                    isExpanded.toggle()
                }
            }
        }
    }
}
