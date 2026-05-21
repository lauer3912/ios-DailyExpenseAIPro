import Foundation
import AuthenticationServices

@MainActor
final class SignInWithAppleManager: NSObject, ObservableObject {
    static let shared = SignInWithAppleManager()

    @Published private(set) var isSignedIn = false
    @Published private(set) var userID: String?
    @Published private(set) var fullName: String?
    @Published private(set) var email: String?
    @Published var errorMessage: String?

    private let userIDKey = "apple_user_id"
    private let fullNameKey = "apple_user_full_name"
    private let emailKey = "apple_user_email"

    override init() {
        super.init()
        checkSignInStatus()
    }

    // MARK: - Check Sign In Status
    func checkSignInStatus() {
        guard let savedUserID = UserDefaults.standard.string(forKey: userIDKey), !savedUserID.isEmpty else {
            isSignedIn = false
            return
        }

        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: savedUserID) { [weak self] state, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    self.isSignedIn = false
                    return
                }

                switch state {
                case .authorized:
                    self.isSignedIn = true
                    self.userID = savedUserID
                    self.fullName = UserDefaults.standard.string(forKey: self.fullNameKey)
                    self.email = UserDefaults.standard.string(forKey: self.emailKey)
                case .revoked:
                    self.clearCredentials()
                    self.isSignedIn = false
                case .notFound:
                    self.clearCredentials()
                    self.isSignedIn = false
                default:
                    self.isSignedIn = false
                }
            }
        }
    }

    // MARK: - Sign In With Apple
    func signInWithApple() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    // MARK: - Sign Out
    func signOut() {
        clearCredentials()
        isSignedIn = false
    }

    // MARK: - Private
    private func saveCredentials(userID: String, fullName: String?, email: String?) {
        UserDefaults.standard.set(userID, forKey: userIDKey)
        if let fullName = fullName {
            UserDefaults.standard.set(fullName, forKey: fullNameKey)
        }
        if let email = email {
            UserDefaults.standard.set(email, forKey: emailKey)
        }
        self.userID = userID
        self.fullName = fullName
        self.email = email
    }

    private func clearCredentials() {
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.removeObject(forKey: fullNameKey)
        UserDefaults.standard.removeObject(forKey: emailKey)
        userID = nil
        fullName = nil
        email = nil
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension SignInWithAppleManager: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }

        let userID = appleIDCredential.user
        let fullName = appleIDCredential.fullName?.givenName ?? ""
        let email = appleIDCredential.email ?? ""

        Task { @MainActor in
            saveCredentials(userID: userID, fullName: fullName.isEmpty ? nil : fullName, email: email.isEmpty ? nil : email)
            isSignedIn = true
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Task { @MainActor in
            errorMessage = error.localizedDescription
            isSignedIn = false
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension SignInWithAppleManager: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}