import Flutter
import UIKit
import MFYConnect
import AuthenticationServices

enum appleAuthType {
    case login
    case draw
}

class AuthSDKHelper: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    // yahooAuth
    var yahooAuthHandler:((_ accessToken: String?) -> Void)?
    // appleAuth
    var appleAuthHandler:((_ accessToken: String?) -> Void)?

    private static let s_share = AuthSDKHelper()
    private var appleAuth = appleAuthType.login
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

    func handleAuthorizationAppleID(auth: appleAuthType = appleAuthType.login) {
        appleAuth = auth
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
            if appleAuth == appleAuthType.draw {
                if let token = appleIDCredential.authorizationCode, let tokenString = String(bytes: token, encoding: .utf8){
                    self.appleAuthHandler?(tokenString)
                } else {
                    self.appleAuthHandler?("")
                }
            } else {
                if let token = appleIDCredential.identityToken, let tokenString = String(bytes: token, encoding: .utf8){
                    self.appleAuthHandler?(tokenString)
                } else {
                    self.appleAuthHandler?("")
                }
            }
        default:
            break
        }
    }

    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
         let authorArror: ASAuthorizationError = ASAuthorizationError(_nsError: error as NSError)
         switch authorArror{
              case ASAuthorizationError.canceled:
                   self.appleAuthHandler?(nil)
                   debugPrint("取消")
              case ASAuthorizationError.failed:
                   self.appleAuthHandler?("")
                   debugPrint("授权请求失败")
              case ASAuthorizationError.invalidResponse:
                   self.appleAuthHandler?("")
                   debugPrint("授权请求响应无效")
              case ASAuthorizationError.notHandled:
                    self.appleAuthHandler?("")
                    debugPrint("未能处理授权请求")
              case ASAuthorizationError.unknown:
                    self.appleAuthHandler?("")
                    debugPrint("授权请求失败未知原因")
              default:
                  self.appleAuthHandler?("")
                  debugPrint("error")
               }
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
            AuthSDKHelper.share.handleAuthorizationAppleID(auth: .login)
            AuthSDKHelper.share.appleAuthHandler = { value in
                if let accessToken = value {
                    if accessToken == "" {
                        result(["success": false, "appleAccessToken": accessToken])
                    }else{
                        result(["success": true, "appleAccessToken": accessToken])
                    }
                } else {
                    result(["success": false])
                }
            }
        }
        if (call.method == "appleDraw") {
            AuthSDKHelper.share.handleAuthorizationAppleID(auth: .draw)
            AuthSDKHelper.share.appleAuthHandler = { value in
                if let accessToken = value {
                    if accessToken == "" {
                        result(["success": false, "authorizationCode": accessToken])
                    }else{
                        result(["success": true, "authorizationCode": accessToken])
                    }
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
