import SwiftUI
import RealityKit
import RealityKitContent

@main
struct RemixSwiftUIApp: SwiftUI.App {
    @State private var showImmersiveSpace: Bool = false
    @State private var immersiveSpaceIsShown = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    // NOTE: app level metrics does not work. see PhysicalMetricsContainer.swift
    // @Environment(\.physicalMetrics) var physicalMetrics

    @State private var toggleValue: Bool = false
    @State private var sliderValue: Float = 0.5

    var body: some SwiftUI.Scene {
        let sample1: [any View] = [
            Text("SwiftUI in RealityKit →").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Model3D(named: "Scene", bundle: realityKitContentBundle),
            PhysicalRectangle(sideInCM: 20),
            LogicalRectangle(sideInPt: 135),
            Toggle("Toggle", isOn: $toggleValue).fixedSize().padding().glassBackgroundEffect(),
            PhysicalMetricsContainer { Slider(value: $sliderValue).frame(maxWidth: $0.convert(30, from: .centimeters)).padding() },
            Popup(),
            Popup(offsetY: { $0 ? $1.convert(-5, from: .centimeters) : 0 }) { Text("Open Toggle").font(.extraLargeTitle) } content: {
                Toggle("Toggle", isOn: $toggleValue).fixedSize().padding()
            },
            SafarishTabOverview(),
            Text("Text 1").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("Text 2").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("Text 3").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("Text 4").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("Text 5").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            DismissImmersiveSpaceButton(showImmersiveSpace: $showImmersiveSpace).font(.extraLargeTitle),
        ]

        WindowGroup {
            ControlView(showImmersiveSpace: $showImmersiveSpace)
            WindowView(sample1)
        }.onChange(of: showImmersiveSpace, onChangeOfShowImmersiveSpace)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(sample1)
        }
    }

    @MainActor
    private func onChangeOfShowImmersiveSpace(oldValue: Bool, newValue: Bool) {
        Task {
            if newValue {
                switch await openImmersiveSpace(id: "ImmersiveSpace") {
                case .opened:
                    immersiveSpaceIsShown = true
                case .error, .userCancelled:
                    fallthrough
                @unknown default:
                    immersiveSpaceIsShown = false
                    showImmersiveSpace = false
                }
            } else if immersiveSpaceIsShown {
                await dismissImmersiveSpace()
                immersiveSpaceIsShown = false
            }
        }
    }
}

struct SafarishTabOverview: View {
    @State private var showsOverview: Bool = false
    private let cells: [any View] = [
        Text("Cell").font(.extraLargeTitle).fixedSize().padding(EdgeInsets(top: 50, leading: 150, bottom: 50, trailing: 150)),
        Text("Cell").font(.extraLargeTitle).fixedSize().padding(EdgeInsets(top: 50, leading: 150, bottom: 50, trailing: 150)),
        Text("Cell").font(.extraLargeTitle).fixedSize().padding(EdgeInsets(top: 50, leading: 150, bottom: 50, trailing: 150)),
        Text("Cell").font(.extraLargeTitle).fixedSize().padding(EdgeInsets(top: 50, leading: 150, bottom: 50, trailing: 150)),
        Text("Cell").font(.extraLargeTitle).fixedSize().padding(EdgeInsets(top: 50, leading: 150, bottom: 50, trailing: 150)),
        Text("Cell").font(.extraLargeTitle).fixedSize().padding(EdgeInsets(top: 50, leading: 150, bottom: 50, trailing: 150)),
        Text("Cell").font(.extraLargeTitle).fixedSize().padding(EdgeInsets(top: 50, leading: 150, bottom: 50, trailing: 150)),
    ]
    private var rows: [[any View]] {
        stride(from: 0, to: cells.count, by: 3).map { Array(cells[$0..<min($0+3, cells.count)]) }
    }

    var body: some View {
        Button("SafarishTabOverview") {
            showsOverview = true
        }
        .font(.extraLargeTitle)

        // NOTE: Safari Tab Overview style is difficult for mimic
        // - present pages with clear background: .sheet nor .fullScreenCover in visionOS cannot clear background using .presentationBackground(.clear)
        // - transition animation between the current page and page cells: how do we can this if transition is between Window <-> Immersive Space?
        // - non-clipped tab overview: plain window tightly clips its content...
        // - non-hiding other apps in the shared space: something different from nominal immersive...
        // - dimming (non-accumulated): slightly dim environment, but 2 Safari windows do not dim 2 step of depth. simply dim on showing overview and un-dim on going back from the overview

        //        if showsOverview {
//        .fullScreenCover(isPresented: $showsOverview) {
//            //        .sheet(isPresented: $showsOverview) {
//        }
//        .presentationBackground(.clear)
        if !showsOverview {
            if let cell = cells.first {
                AnyView(cell.id(0))
                    .glassBackgroundEffect()
            }
        } else {
            RealityView { content, attachments in
            } update: { content, attachments in
                guard let e = attachments.entity(for: "x") else { return }
                guard e.parent == nil else { return }
                content.add(e)
            } attachments: {
                Attachment(id: "x") {
                    Button("Close") { withAnimation(.spring) { showsOverview = false } } // TODO: toolbar?
                    Spacer().frame(height: 44)
                    ScrollView(.vertical) {
                        Grid(alignment: .topLeading, horizontalSpacing: 44, verticalSpacing: 44) {
                            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                                GridRow(alignment: .top) {
                                    ForEach(Array(row.enumerated()), id: \.offset) { offset, cell in
                                        AnyView(cell.id(offset))
                                            .glassBackgroundEffect()
                                            .rotation3DEffect(.init(radians: -(CGFloat(offset) / CGFloat(rows.count - 1) - 0.5) * .pi / 6), axis: (0, 1, 0))
                                    }
                                }
                            }
                        }
                    }
                }
            }
//            .frame(width: 1024, height: 1024)
//            .frame(depth: 1024)
        }
    }
}
