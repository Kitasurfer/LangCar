import ComposableArchitecture
#if canImport(SwiftUI)
import SwiftUI
import SceneKit
#if os(iOS)
import UIKit
typealias BezierPath = UIBezierPath
typealias Color = UIColor
#elseif os(macOS)
import AppKit
typealias BezierPath = NSBezierPath
typealias Color = NSColor
extension NSBezierPath {
    func addCurve(to: CGPoint, controlPoint1: CGPoint, controlPoint2: CGPoint) {
        curve(to: to, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
}
#endif
#endif

public struct RoadMapState: Equatable, Sendable {
    public var progress: Double = 0        // 0 … 1 (A1 → C2)
}
public enum RoadMapAction: Equatable, Sendable { case onAppear; case progressUpdated(Double) }

public struct RoadMapReducer: Reducer {
    public init() {}
    public var body: some Reducer<RoadMapState, RoadMapAction> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none   // TODO: load real progress
            case let .progressUpdated(val):
                state.progress = val; return .none
            }
        }
    }
}

#if canImport(SwiftUI) && canImport(SceneKit)
public struct RoadMapView: View {
    let store: StoreOf<RoadMapReducer>
    @Environment(\.colorScheme) private var scheme
    public init(store: StoreOf<RoadMapReducer>) { self.store = store }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            SceneView(scene: makeScene(progress: vs.progress), options: [.allowsCameraControl])
                .navigationTitle("Маршрут")
                .onAppear { vs.send(.onAppear) }
        }
    }

    private func makeScene(progress: Double) -> SCNScene {
        let scene = SCNScene()
        // Ground plane
        let ground = SCNFloor(); ground.reflectivity = 0
        scene.rootNode.addChildNode(SCNNode(geometry: ground))
        // Road path (simple bezier tube)
        let path = BezierPath()
        path.move(to: CGPoint.zero); path.addCurve(to: CGPoint(x: 0, y: 1000), controlPoint1: CGPoint(x: -300, y: 300), controlPoint2: CGPoint(x: 300, y: 700))
        let shape = SCNShape(path: path, extrusionDepth: 10)
        shape.firstMaterial?.diffuse.contents = Color.darkGray
        let roadNode = SCNNode(geometry: shape); roadNode.eulerAngles.x = -.pi/2
        scene.rootNode.addChildNode(roadNode)
        // Car marker
        let car = SCNBox(width: 20, height: 10, length: 40, chamferRadius: 2)
        car.firstMaterial?.diffuse.contents = Color.systemRed
        let carNode = SCNNode(geometry: car)
        carNode.position = SCNVector3(0, 5, Float(progress * 1000))
        scene.rootNode.addChildNode(carNode)
        // Light & camera
        let cam = SCNCamera(); cam.automaticallyAdjustsZRange = true
        let camNode = SCNNode(); camNode.camera = cam; camNode.position = SCNVector3(0, 200, 200); camNode.eulerAngles.x = -.pi/4
        scene.rootNode.addChildNode(camNode)
        let light = SCNLight(); light.type = .directional; light.intensity = 1000
        let lightNode = SCNNode(); lightNode.light = light; lightNode.eulerAngles.x = -.pi/3
        scene.rootNode.addChildNode(lightNode)
        return scene
    }
}
#endif
