import SwiftUI

struct LaunchAnimation: View {
    @State private var isAnimating = false
    @State private var showTagline = false
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // App logo/icon
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Constants.UI.primaryColor)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // App name
                Text(Constants.App.name)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(Constants.UI.primaryColor)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                
                // Tagline
                Text(Constants.App.tagline)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .opacity(showTagline ? 1.0 : 0.0)
            }
        }
        .onAppear {
            // First animation - logo and app name
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0)) {
                isAnimating = true
            }
            
            // Second animation - tagline
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showTagline = true
                }
            }
            
            // Complete animation and move to main app
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    onComplete()
                }
            }
        }
    }
}

struct LaunchAnimation_Previews: PreviewProvider {
    static var previews: some View {
        LaunchAnimation {
            print("Animation completed")
        }
    }
}
