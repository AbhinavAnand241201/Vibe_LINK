import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?
    
    init(message: String, retryAction: (() -> Void)? = nil) {
        self.message = message
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text(message)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Text("Try Again")
                        .fontWeight(.semibold)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}

// Banner style error notification that appears at the top of the screen
struct ErrorBanner: View {
    @Binding var isPresented: Bool
    let message: String
    
    var body: some View {
        if isPresented {
            VStack {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.red)
                .cornerRadius(8)
                .padding(.horizontal)
                .transition(.move(edge: .top))
                
                Spacer()
            }
            .zIndex(100) // Ensure it appears above other content
            .onAppear {
                // Auto-dismiss after 5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation {
                        isPresented = false
                    }
                }
            }
        }
    }
}

// Extension to easily show error banners from any view
extension View {
    func errorBanner(isPresented: Binding<Bool>, message: String) -> some View {
        ZStack {
            self
            
            ErrorBanner(isPresented: isPresented, message: message)
        }
    }
}

// Preview for design-time visualization
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ErrorView(message: "Failed to load data. Please check your internet connection.", retryAction: {
                print("Retry tapped")
            })
            
            ErrorView(message: "Something went wrong.", retryAction: nil)
        }
    }
}
