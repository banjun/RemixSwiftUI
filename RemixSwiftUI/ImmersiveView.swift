import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    var attachments: [RealityViewAttachment] = []
    @State private var scale: CGFloat = 1
    @State private var radius: CGFloat = 1
    @State private var dragAngle: CGFloat = 0
    @State private var dragAngleAccumulated: CGFloat = 0

    var layout: (_ index: Int, _ count: Int, _ entity: Entity, _ radius: CGFloat, _ scale: CGFloat, _ dragAngle: CGFloat) -> Transform = { index, count, entity, radius, scale, dragAngle in
        // layout attachments radially in the horizontal plane on the anchor
        Transform(AffineTransform3D()
            .rotated(by: .init(angle: .init(radians: -CGFloat(index) * 2 * .pi / CGFloat(count) + dragAngle), axis: .init(x: 0, y: 1, z: 0)))
            .translated(by: .init(x: 0, y: 0, z: -radius))
            .scaled(by: .init(width: scale, height: scale, depth: 1))
        )
    }

    var body: some View {
        RealityView { content, attachments  in
            let scene = try! await Entity(named: "Immersive", in: realityKitContentBundle)
            content.add(scene)

            // add collision to the model entity named "Handle" in the Immersive scene in the RealityKitContent.rcp
            // we can't add a collision generated from the mesh in RCP(GUI)?
            let handle = content.entities.first!.findEntity(named: "Handle") as! ModelEntity
            handle.collision = try! await .init(shapes: [.generateConvex(from: handle.model!.mesh)])

//            // add an invisible gesture target
//            let eventCollector = ModelEntity(mesh: .generateSphere(radius: 3), materials: [])
//            eventCollector.components[InputTargetComponent.self] = .init(allowedInputTypes: .all)
//            eventCollector.collision = .init(shapes: [.generateSphere(radius: 3)])
//            content.add(eventCollector)
        } update: { content, attachments in
            let anchor = content.entities.first!.findEntity(named: "EyeHeight")!
//            let anchor = content.entities.first!.findEntity(named: "DeskHeight")!

            self.attachments
                .map { attachments.entity(for: $0.id) }
                .enumerated()
                .compactMap { (index: Int, entity: Entity?) -> Entity? in
                    guard let entity else { return nil }
                    entity.transform = layout(index, self.attachments.count, entity, radius, scale, dragAngleAccumulated + dragAngle)
                    // NOTE: make entity bottom-aligned. only works for Model3D
                    entity.transform.translation.y = entity.visualBounds(relativeTo: nil).extents.y / 2
                    return entity
                }
                .filter { $0.parent == nil }
                .forEach { entity in
                    // entity.components[InputTargetComponent.self] = .init(allowedInputTypes: .all)
                    // NOTE: we can't add a collision here?
                    anchor.addChild(entity)
                }
        } attachments: {
            ForEach(attachments) { a in
                Attachment(id: a.id) {
                    AnyView(a.body())
//                        .gesture(DragGesture(minimumDistance: 0)
//                                 //.targetedToAnyEntity() // this prevents working
//                            .onChanged { value in
//                                // print("RealityView.attachments.gesture(DragGesture).value = \(value)")
//                                print("RealityView.attachments.gesture(DragGesture).value.startLocation = \(value.startLocation3D), location = \(value.location3D)")
//                                let delta = value.location3D - value.startLocation3D
//                                dragAngle = -CGFloat(atan(delta.x)) / 10
//                            }
//                        )
                }
            }
        }
        .gesture(DragGesture(minimumDistance: 0)
            .targetedToAnyEntity() // it also converts value type to `EntityTargetValue<DragGesture.Value>`
            .onChanged { value in
                let location3D = value.convert(value.location3D, from: .local, to: .scene)
                let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                let delta = location3D - startLocation3D
                let sensitivity = 2.0
                dragAngle = CGFloat(atan(delta.x / startLocation3D.z)) * sensitivity
                // print("RealityView.gesture(DragGesture).value = \(value),\n")
                // print("  startLocation3D = \(startLocation3D),\n  location3D = \(location3D),\n  delta = \(delta),\n  dragAngle = \(dragAngle)")
            }
            .onEnded { value in
                dragAngleAccumulated += dragAngle
                dragAngle = 0
            }
        )
    }
}

extension ImmersiveView {
    init(_ views: [any SwiftUI.View]) {
        self.init(attachments: views.enumerated().map { offset, element in
            .init(String(offset), body: { element })
        })
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView([
            Text("SwiftUI in RealityKit →").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("B").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("C").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("D").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("E").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("F").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("G").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("H").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("I").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("J").font(.extraLargeTitle).padding().glassBackgroundEffect(),
            Text("K").font(.extraLargeTitle).padding().glassBackgroundEffect(),
    ])
}
