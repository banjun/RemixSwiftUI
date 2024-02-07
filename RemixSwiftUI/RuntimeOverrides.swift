import RemixSwiftUI
import SwiftUI

extension Popup {
    @_dynamicReplacement(for: body)
    var body2: some View {
        VStack {
            Spacer()
            VStack {
                !isExpanded ? AnyView(toggleText()) : AnyView(Text("Close").font(.extraLargeTitle2))
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
            //            .offset(y: offsetY(isExpanded, physicalMetrics))
        }
    }
}
