import SwiftUI

struct LogicalRectangle: View {
    var sideInPt: CGFloat

    var body: some View {
        Rectangle()
            .frame(width: sideInPt,
                   height: sideInPt)
            .overlay {
                Text("\(NumberFormatter.shortFloat.string(from: sideInPt))pt")
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
                Spacer().frame(height: 40)
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
