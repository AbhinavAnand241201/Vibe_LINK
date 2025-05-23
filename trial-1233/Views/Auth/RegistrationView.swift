import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var passwordsMatch = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 30)
                    
                    Text("Join VibeLink and start connecting")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    
                    // Registration form
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
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(Constants.UI.cornerRadius)
                            .onChange(of: confirmPassword) { oldValue, newValue in
                                passwordsMatch = password == newValue || newValue.isEmpty
                            }
                        
                        // Password match error
                        if !passwordsMatch {
                            Text("Passwords do not match")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        
                        // Error message
                        if let error = viewModel.error {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        
                        // Sign up button
                        Button(action: {
                            if password == confirmPassword {
                                viewModel.register(email: email, password: password)
                            } else {
                                passwordsMatch = false
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Sign Up")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.UI.buttonHeight)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(Constants.UI.cornerRadius)
                        .disabled(viewModel.isLoading || !passwordsMatch || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal, Constants.UI.standardPadding)
                    
                    Spacer()
                }
            }
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(.primary)
            })
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
