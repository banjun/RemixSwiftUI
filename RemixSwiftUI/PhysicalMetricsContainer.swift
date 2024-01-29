import SwiftUI

struct PhysicalMetricsContainer<T: View>: View {
    @Environment(\.physicalMetrics) private var physicalMetrics

    var content: (PhysicalMetricsConverter) -> T
    init(_ content: @escaping (PhysicalMetricsConverter) -> T) {
        self.content = content
    }

    var body: some View {
        content(physicalMetrics)
    }
}
