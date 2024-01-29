import SwiftUI

struct Popup: View {
    @State private var isExpanded: Bool = false
    var offsetY: (_ isExpanded: Bool, _ physicalMetrics: PhysicalMetricsConverter) -> CGFloat = { isExpanded, physicalMetrics in
        isExpanded ? -physicalMetrics.convert(15, from: .centimeters) : 0
    }
    @Environment(\.physicalMetrics) private var physicalMetrics

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
        VStack {
            if isExpanded {
                AnyView(content())
            }
            AnyView(toggleText())
        }
        .padding()
        .glassBackgroundEffect()
        .hoverEffect()
        .onTapGesture {
            withAnimation(.spring) {
                isExpanded.toggle()
            }
        }
        .offset(y: offsetY(isExpanded, physicalMetrics))
    }
}
