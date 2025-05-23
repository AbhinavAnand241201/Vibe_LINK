import SwiftUI

struct MatchesView: View {
    @StateObject private var viewModel = MatchViewModel()
    @State private var selectedMatch: Match?
    @State private var showingMatchDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.matches.isEmpty && !viewModel.isLoading {
                    VStack(spacing: 20) {
                        Image(systemName: "person.2.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Matches Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Join moments to connect with people nearby!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.matches) { match in
                            MatchRow(match: match)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedMatch = match
                                    showingMatchDetail = true
                                }
                                .onAppear {
                                    // Load more when reaching the end
                                    if match.id == viewModel.matches.last?.id && viewModel.hasMorePages {
                                        viewModel.loadNextPage()
                                    }
                                }
                        }
                        
                        if viewModel.isLoading && !viewModel.matches.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        viewModel.refreshMatches()
                    }
                }
                
                // Error view
                if let error = viewModel.error {
                    VStack {
                        Spacer()
                        
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(Constants.UI.cornerRadius)
                            .padding()
                        
                        Spacer().frame(height: 40)
                    }
                }
                
                // Loading indicator for initial load
                if viewModel.isLoading && viewModel.matches.isEmpty {
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationTitle("Matches")
            .sheet(isPresented: $showingMatchDetail, onDismiss: {
                selectedMatch = nil
            }) {
                if let match = selectedMatch {
                    MatchDetailView(match: match)
                }
            }
            .onAppear {
                viewModel.loadMyMatches()
            }
        }
    }
}

// Individual match row
struct MatchRow: View {
    let match: Match
    
    var body: some View {
        HStack(spacing: 12) {
            // User avatar
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(otherUser.email.prefix(1)).uppercased())
                        .fontWeight(.bold)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                // User email
                Text(otherUser.email)
                    .font(.headline)
                
                // Match status
                HStack {
                    StatusBadge(status: match.status)
                    
                    Text(match.momentId.caption)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Timestamp
            Text(timeAgo(from: match.createdAt))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // Get the other user in the match (not the current user)
    private var otherUser: User {
        // In a real app, we would compare with the current user ID
        // For now, we'll just return the creator
        return match.creatorId
    }
    
    // Format relative time
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// Status badge component
struct StatusBadge: View {
    let status: MatchStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending:
            return .orange
        case .accepted:
            return .green
        case .rejected:
            return .red
        }
    }
}

// Match detail view
struct MatchDetailView: View {
    let match: Match
    @StateObject private var viewModel = MatchViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAcceptAlert = false
    @State private var showingRejectAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Moment details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Moment")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(match.momentId.userId.email.prefix(1)).uppercased())
                                    .fontWeight(.bold)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(match.momentId.userId.email)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(timeAgo(from: match.momentId.createdAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text(match.momentId.caption)
                        .padding(.vertical, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(Constants.UI.cornerRadius)
                .padding(.horizontal)
                
                // Match details
                VStack(alignment: .leading, spacing: 12) {
                    Text("Match Request")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(match.userId.email.prefix(1)).uppercased())
                                    .fontWeight(.bold)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(match.userId.email)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(timeAgo(from: match.createdAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !match.message.isEmpty {
                        Text("Message:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(match.message)
                            .padding(10)
                            .background(Color(.systemGray5))
                            .cornerRadius(10)
                    }
                    
                    HStack {
                        Text("Status:")
                        StatusBadge(status: match.status)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(Constants.UI.cornerRadius)
                .padding(.horizontal)
                
                Spacer()
                
                // Action buttons for pending matches
                if match.status == .pending && isCreator {
                    HStack(spacing: 20) {
                        Button(action: {
                            showingRejectAlert = true
                        }) {
                            Text("Decline")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(Constants.UI.cornerRadius)
                        }
                        
                        Button(action: {
                            showingAcceptAlert = true
                        }) {
                            Text("Accept")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(Constants.UI.cornerRadius)
                        }
                    }
                    .padding()
                    .disabled(viewModel.isLoading)
                }
            }
            .navigationTitle("Match Details")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert("Accept Match", isPresented: $showingAcceptAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Accept") {
                    updateMatchStatus(.accepted)
                }
            } message: {
                Text("Accept this match request? This will allow you to chat and meet up with this person.")
            }
            .alert("Decline Match", isPresented: $showingRejectAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Decline", role: .destructive) {
                    updateMatchStatus(.rejected)
                }
            } message: {
                Text("Decline this match request? The user will be notified that you declined.")
            }
            .overlay(
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.2))
                    }
                }
            )
        }
    }
    
    // Check if current user is the creator of the moment
    private var isCreator: Bool {
        // In a real app, we would compare with the current user ID
        // For now, we'll just return true for demo purposes
        return true
    }
    
    // Update match status
    private func updateMatchStatus(_ status: MatchStatus) {
        viewModel.updateMatchStatus(matchId: match.id, status: status) { result in
            switch result {
            case .success(_):
                // Close the detail view
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error updating match status: \(error.localizedDescription)")
                // Error is already handled in the viewModel
            }
        }
    }
    
    // Format relative time
    private func timeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct MatchesView_Previews: PreviewProvider {
    static var previews: some View {
        MatchesView()
    }
}
