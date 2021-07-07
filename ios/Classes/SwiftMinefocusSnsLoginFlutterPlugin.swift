import Flutter
import UIKit
import MFYConnect
import AuthenticationServices

class AuthSDKHelper: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    // yahooAuth
    var yahooAuthHandler:((_ accessToken: String?) -> Void)?
    // appleAuth
    var appleAuthHandler:((_ accessToken: String?) -> Void)?

    private static let s_share = AuthSDKHelper()
    class var share: AuthSDKHelper {
        return s_share
    }

    //ユーザー切替処理
    func yahooOpenURL(_ vc: UIViewController? = nil) {
        guard  let util = YConnectStringUtil.init() else {return}
        let state = util.generateState()
        let nonce = util.generateNonce()
        if let yconnect = YConnectManager.sharedInstance() {
            yconnect.requestAuthorization(withState: state, prompt: nil, nonce: nonce, presenting: vc)
        }
    }

    func yahooAuth(url: URL) {
        if let yconnect = YConnectManager.sharedInstance() {
            yconnect.parseAuthorizationResponse(url) { (error) in
                if error != nil {
                    self.yahooAuthHandler?(nil)
                } else {
                    let accessTokenString = yconnect.accessTokenString()
                    self.yahooAuthHandler?(accessTokenString)
                }
            }
        }
    }

    func handleAuthorizationAppleID() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }

    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.keyWindow!
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            if let token = appleIDCredential.identityToken, let tokenString = String(bytes: token, encoding: .utf8){
                self.appleAuthHandler?(tokenString)
            } else {
                self.appleAuthHandler?(nil)
            }
        default:
            break
        }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.appleAuthHandler?(nil)
    }
}

public class SwiftMinefocusSnsLoginFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "minefocus_sns_login_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMinefocusSnsLoginFlutterPlugin()
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "yahooLogIn") {
            AuthSDKHelper.share.yahooOpenURL(UIApplication.shared.keyWindow?.rootViewController)
            AuthSDKHelper.share.yahooAuthHandler = { value in
                if let accessToken = value {
                    result(["success": true, "yahooAccessToken": accessToken])
                } else {
                    result(["success": false])
                }
            }
        }
        if (call.method == "appleLogIn") {
            AuthSDKHelper.share.handleAuthorizationAppleID()
            AuthSDKHelper.share.appleAuthHandler = { value in
                if let accessToken = value {
                    result(["success": true, "appleAccessToken": accessToken])
                } else {
                    result(["success": false])
                }
            }
        }
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let scheme = url.scheme {
            if let yahooScheme = getYahooScheme(), yahooScheme == scheme {
                AuthSDKHelper.share.yahooAuth(url: url)
            }
        }
        return true
    }

    // 获取yahoo的Scheme
    func getYahooScheme() -> String? {
        if let yahooRedirectUri = Bundle.main.infoDictionary?["YConnectRedirectUri"] as? String {
            if let yahooScheme = yahooRedirectUri.components(separatedBy: ":").first {
                return yahooScheme
            }
        }
        return nil
    }
}
