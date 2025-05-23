import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingRegistration = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and app name
                VStack(spacing: 10) {
                    Image(systemName: "bolt.heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.pink)
                    
                    Text(Constants.App.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(Constants.App.tagline)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                
                // Login form
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(Constants.UI.cornerRadius)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(Constants.UI.cornerRadius)
                    
                    // Error message
                    if let error = viewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    
                    // Sign in button
                    Button(action: {
                        viewModel.login(email: email, password: password)
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.UI.buttonHeight)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(Constants.UI.cornerRadius)
                    .disabled(viewModel.isLoading)
                    .padding(.top, 10)
                    
                    // Register link
                    Button("Don't have an account? Sign Up") {
                        isShowingRegistration = true
                    }
                    .font(.footnote)
                    .foregroundColor(.blue)
                    .padding(.top, 10)
                }
                .padding(.horizontal, Constants.UI.standardPadding)
                
                Spacer()
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingRegistration) {
                RegistrationView()
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
