import SwiftUI

// MARK: - Horizon Fluid Audio Orb Visualizer (Reconstructed from Android Horizon Shaders)

public struct HorizonAudioVisualizerView: View {
    public let audioPower: Float // 0.0 to 1.0
    public let state: VoiceSessionState

    @State private var phase: Double = 0.0

    public init(audioPower: Float, state: VoiceSessionState) {
        self.audioPower = audioPower
        self.state = state
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let baseRadius = min(size.width, size.height) * 0.28
                let dynamicScale = 1.0 + Double(audioPower) * 0.45

                // Draw multi-layered glowing fluid orb
                for layer in 0..<4 {
                    let layerRadius = (baseRadius + Double(layer * 8)) * dynamicScale
                    let path = createFluidPath(
                        center: center,
                        radius: layerRadius,
                        time: time + Double(layer) * 1.5,
                        layer: layer
                    )

                    let colors: [Color] = {
                        switch state {
                        case .listening:
                            return [Color.blue.opacity(0.85), Color.cyan.opacity(0.7), Color.white]
                        case .thinking:
                            return [Color.purple.opacity(0.8), Color.indigo.opacity(0.7), Color.blue]
                        case .speaking:
                            return [Color.cyan.opacity(0.9), Color.teal.opacity(0.8), Color.white]
                        default:
                            return [Color.gray.opacity(0.4), Color.secondary.opacity(0.3)]
                        }
                    }()

                    context.fill(
                        path,
                        with: .radialGradient(
                            Gradient(colors: colors),
                            center: center,
                            startRadius: 0,
                            endRadius: layerRadius * 1.2
                        )
                    )
                }
            }
        }
        .frame(width: 280, height: 280)
        .blur(radius: 12)
        .overlay {
            // Core crisp specular highlight
            Circle()
                .fill(Color.white.opacity(0.6))
                .frame(width: 80, height: 80)
                .blur(radius: 20)
                .scaleEffect(1.0 + CGFloat(audioPower) * 0.3)
                .animation(.easeInOut(duration: 0.1), value: audioPower)
        }
    }

    private func createFluidPath(center: CGPoint, radius: Double, time: Double, layer: Int) -> Path {
        var path = Path()
        let points = 64
        let angleStep = (2 * Double.pi) / Double(points)

        for i in 0..<points {
            let angle = Double(i) * angleStep
            // Multi-octave wave noise simulation (Voronoi approximation)
            let wave1 = sin(angle * 3 + time * 1.8 + Double(layer)) * 14.0 * (0.3 + Double(audioPower))
            let wave2 = cos(angle * 5 - time * 2.2) * 8.0 * (0.2 + Double(audioPower))
            let r = radius + wave1 + wave2

            let x = center.x + CGFloat(r * cos(angle))
            let y = center.y + CGFloat(r * sin(angle))

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
