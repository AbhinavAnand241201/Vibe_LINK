import SwiftUI

struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    var bounce: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: phase - 0.2),
                            .init(color: .white.opacity(0.5), location: phase),
                            .init(color: .clear, location: phase + 0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(content)
                    .blendMode(.screen)
                }
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: duration)
                        .repeatForever(autoreverses: bounce)
                ) {
                    self.phase = 1
                }
            }
    }
}

extension View {
    func shimmer(duration: Double = 1.5, bounce: Bool = false) -> some View {
        modifier(ShimmerEffect(duration: duration, bounce: bounce))
    }
}

// Skeleton loading views for different content types
struct MomentCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack {
                Circle()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                VStack(alignment: .leading, spacing: 4) {
                    Rectangle()
                        .frame(width: 120, height: 16)
                        .foregroundColor(Color.gray.opacity(0.3))
                    
                    Rectangle()
                        .frame(width: 80, height: 12)
                        .foregroundColor(Color.gray.opacity(0.3))
                }
            }
            
            // Content placeholder
            Rectangle()
                .frame(height: 200)
                .foregroundColor(Color.gray.opacity(0.3))
            
            // Caption placeholder
            Rectangle()
                .frame(height: 16)
                .foregroundColor(Color.gray.opacity(0.3))
            
            Rectangle()
                .frame(width: 250, height: 16)
                .foregroundColor(Color.gray.opacity(0.3))
        }
        .padding()
        .shimmer()
    }
}

struct ProfileSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            // Profile image
            Circle()
                .frame(width: 100, height: 100)
                .foregroundColor(Color.gray.opacity(0.3))
            
            // Name
            Rectangle()
                .frame(width: 150, height: 24)
                .foregroundColor(Color.gray.opacity(0.3))
            
            // Bio
            VStack(spacing: 8) {
                Rectangle()
                    .frame(height: 16)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Rectangle()
                    .frame(height: 16)
                    .foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.horizontal)
            
            // Stats
            HStack(spacing: 24) {
                ForEach(0..<3) { _ in
                    VStack(spacing: 8) {
                        Rectangle()
                            .frame(width: 40, height: 24)
                            .foregroundColor(Color.gray.opacity(0.3))
                        
                        Rectangle()
                            .frame(width: 60, height: 16)
                            .foregroundColor(Color.gray.opacity(0.3))
                    }
                }
            }
            .padding(.top)
        }
        .padding()
        .shimmer()
    }
}

// Preview
struct ShimmerEffect_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            MomentCardSkeleton()
                .frame(width: 350)
            
            ProfileSkeleton()
                .frame(width: 350)
        }
    }
}
