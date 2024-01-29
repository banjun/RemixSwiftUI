import SwiftUI

struct PhysicalRectangle: View {
    var sideInCM: CGFloat
    @Environment(\.physicalMetrics) var physicalMetrics

    var body: some View {
        Rectangle()
            .frame(width: physicalMetrics.convert(sideInCM, from: .centimeters),
                   height: physicalMetrics.convert(sideInCM, from: .centimeters))
            .overlay {
                Text("\(NumberFormatter.shortFloat.string(from: sideInCM))cm")
                    .font(.title).foregroundStyle(Color.black)
            }
    }
}

private struct Preview: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("LogicalRectangles")
                HStack {
                    LogicalRectangle(sideInPt: 45)
                    LogicalRectangle(sideInPt: 90)
                    LogicalRectangle(sideInPt: 135)
                }
                Spacer()
                Text("PhysicalRectangles")
                HStack {
                    PhysicalRectangle(sideInCM: 7)
                    PhysicalRectangle(sideInCM: 14)
                    PhysicalRectangle(sideInCM: 20)
                }
            }
            .padding()
        }
    }
}

#Preview("Plain", windowStyle: .plain) {
    Preview()
}

#Preview("Mixed", immersionStyle: .mixed) {
    Preview()
}
