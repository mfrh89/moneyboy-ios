import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Logo / Title
                VStack(spacing: 8) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.primary)
                    Text("Moneyboy")
                        .font(.largeTitle.bold())
                }
                .padding(.top, 60)

                Spacer()

                // Glass card
                VStack(spacing: 16) {
                    Text(isRegistering ? "Konto erstellen" : "Anmelden")
                        .font(.title2.bold())

                    VStack(spacing: 12) {
                        TextField("E-Mail", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textContentType(.emailAddress)
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))

                        SecureField("Passwort", text: $password)
                            .textContentType(isRegistering ? .newPassword : .password)
                            .padding()
                            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        Task { await submit() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Text(isRegistering ? "Registrieren" : "Anmelden")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                        .foregroundStyle(.white)
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty)

                    Button {
                        withAnimation { isRegistering.toggle() }
                        errorMessage = nil
                    } label: {
                        Text(isRegistering ? "Bereits ein Konto? Anmelden" : "Noch kein Konto? Registrieren")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.regularMaterial)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
    }

    private func submit() async {
        isLoading = true
        errorMessage = nil
        do {
            if isRegistering {
                try await authService.register(email: email, password: password)
            } else {
                try await authService.signIn(email: email, password: password)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
