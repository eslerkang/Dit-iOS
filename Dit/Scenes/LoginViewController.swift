//
//  LoginViewController.swift
//  Dit
//
//  Created by 강태준 on 2022/09/23.
//

import UIKit
import CryptoKit
import AuthenticationServices

import SnapKit
import FirebaseAuth
import FirebaseFirestore
import CodableFirebase


final class LoginViewController: UIViewController {
    fileprivate var currentNonce: String?
    
    private let db = Firestore.firestore()
    
    private lazy var image: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "icon"))
        imageView.sizeToFit()
        
        return imageView
    }()
    private lazy var appleLoginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
    }
}


extension LoginViewController {
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        return hashString
    }

    @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}


extension LoginViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken
            else {
                print("Unable to fetch identity token")
                return
            }
                
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
                
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error {
                    print(error.localizedDescription)
                    return
                }
                                
                guard let user = authResult?.user
                else {
                    return
                }
                
                self.db.collection("users").document(user.uid).getDocument { documentSnapshot, error in
                    if let error {
                        print("ERROR: \(error.localizedDescription)")
                        try? Auth.auth().signOut()
                        return
                    }
                    
                    if let documentSnapshot,
                       documentSnapshot.exists {
                        self.goToTabBarController()
                    } else {
                        let currentDate = Date()
                        let displayname = user.displayName ?? user.email ?? "user"
                        let userEntity = UserEntity(
                            displayname: displayname,
                            id: user.uid,
                            createdAt: currentDate,
                            isActive: true,
                            updatedAt: currentDate
                        )
                        let userData = try! FirestoreEncoder().encode(userEntity)
                        self.db.collection("users").document(user.uid).setData(userData) { error in
                            if let error {
                                print("ERROR: \(error.localizedDescription)")
                                try? Auth.auth().signOut()
                            }
                            
                            self.goToTabBarController()
                        }
                    }
                }
            }
        }
    }
        
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }
}


private extension LoginViewController {
    func setupLayout() {
        [
            image,
            appleLoginButton
        ].forEach {
            view.addSubview($0)
        }
        
        image.snp.makeConstraints {
            $0.width.height.equalTo(view.frame.width / 2)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-150)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(image.snp.bottom).offset(150)
        }
    }
    
    func goToTabBarController() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        self.show(tabBarController, sender: nil)
    }
}
