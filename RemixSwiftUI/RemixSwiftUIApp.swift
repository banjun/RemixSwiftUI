import SwiftUI
import RealityKit
import RealityKitContent
import SwiftHotReload

extension RemixSwiftUIApp {
    static let reloader = StandaloneReloader(monitoredSwiftFile: URL(filePath: #filePath).deletingLastPathComponent()
        .appendingPathComponent("RuntimeOverrides.swift"))
}

@main
struct RemixSwiftUIApp: SwiftUI.App {
    @ObservedObject private var reloader = RemixSwiftUIApp.reloader

    @State private var showImmersiveSpace: Bool = false
    @State private var immersiveSpaceIsShown = false
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    // NOTE: app level metrics does not work. see PhysicalMetricsContainer.swift
    // @Environment(\.physicalMetrics) var physicalMetrics

    @State private var toggleValue: Bool = false
    @State private var sliderValue: Float = 0.5
    @State private var rotationValue: (x: Angle, y: Angle) = (.zero, .zero)
    let multiColumnText = MultiColumnText(text: .init(string: "Apple Vision Pro offers an infinite spatial canvas to explore, experiment, and play, giving you the freedom to completely rethink your experience in 3D. People can interact with your app while staying connected to their surroundings, or immerse themselves completely in a world of your creation. And your experiences can be fluid: start in a window, bring in 3D content, transition to a fully immersive scene, and come right back.", attributes: [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 30)]), columns: 4)
    @State private var height0: Bool = false
    @State private var height1: Bool = false
    @State private var height2: Bool = false
    @State private var height3: Bool = false

    var body: some SwiftUI.Scene {
        let sample1: [any View] = [
            Text("SwiftUI in RealityKit →").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .rotation3DEffect(rotationValue.x, axis: .x).rotation3DEffect(rotationValue.y, axis: .y)
                .gesture(DragGesture().onChanged {
                    rotationValue = (x: -.degrees($0.location.y - $0.startLocation.y), y: .degrees($0.location.x - $0.startLocation.x))
                }.onEnded { _ in withAnimation { rotationValue = (.zero, .zero) } }),
            PhysicalRectangle(sideInCM: 20),
            LogicalRectangle(sideInPt: 135),
            Toggle("Toggle", isOn: $toggleValue).fixedSize().padding().glassBackgroundEffect(),
            PhysicalMetricsContainer { Slider(value: $sliderValue).frame(maxWidth: $0.convert(30, from: .centimeters)).padding() },
            Popup(),
            Popup { Text("Open Toggle").font(.extraLargeTitle) } content: {
                Toggle("Toggle", isOn: $toggleValue).fixedSize().padding()
            },
            multiColumnText.textViews[0].frame(width: 300, height: height0 ? 400 : 300).onTapGesture {withAnimation{height0.toggle()}}.glassBackgroundEffect(),
            multiColumnText.textViews[1].frame(width: 300, height: height1 ? 400 : 300).onTapGesture {withAnimation{height1.toggle()}}.glassBackgroundEffect(),
            multiColumnText.textViews[2].frame(width: 300, height: height2 ? 400 : 300).onTapGesture {withAnimation{height2.toggle()}}.glassBackgroundEffect(),
            multiColumnText.textViews[3].frame(width: 300, height: height3 ? 400 : 300).onTapGesture {withAnimation{height3.toggle()}}.glassBackgroundEffect(),
            Text("Text 1").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("Text 2").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("Text 3").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            DismissImmersiveSpaceButton(showImmersiveSpace: $showImmersiveSpace).font(.extraLargeTitle),
        ]

        WindowGroup {
            ControlView(showImmersiveSpace: $showImmersiveSpace)
            WindowView(sample1)
        }.onChange(of: showImmersiveSpace, onChangeOfShowImmersiveSpace)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(sample1)
        }

        // ImmersiveSpace but not in RealityView
        // TODO: place button or any UI to open this immersive space
        ImmersiveSpace(id: "ImmersiveSpaceWithoutRealityView") {
            BottomAlignedLayout { // <- with this, the bottom of the content is placed at y=0 (floor). otherwise the middle.y of the content = 0
                WindowView(sample1) // same as contents in the WindowGroup above
            }
            .offset(z: -600)
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
