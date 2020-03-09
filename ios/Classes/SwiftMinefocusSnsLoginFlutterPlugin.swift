import Flutter
import UIKit
import MFYConnect

class AuthSDKHelper {

    // yahooAuth
    var yahooAuthHandler:((_ accessToken: String?) -> Void)?

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
}

public class SwiftMinefocusSnsLoginFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "minefocus_sns_login_flutter", binaryMessenger: registrar.messenger())
        let instance = SwiftMinefocusSnsLoginFlutterPlugin()
        registrar.addApplicationDelegate(instance)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    var yahooKey: String = "";

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if (call.method == "yahooLogIn") {
            let arguments = call.arguments as? Dictionary<String, String>
            yahooKey = arguments?["yahooKey"] ?? ""
            AuthSDKHelper.share.yahooOpenURL(UIApplication.shared.keyWindow?.rootViewController)
            AuthSDKHelper.share.yahooAuthHandler = { value in
                if let accessToken = value {
                    result(["success": true, "yahooAccessToken": accessToken])
                } else {
                    result(["success": false])
                }
            }
        }
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let scheme = url.scheme {
            switch scheme {
            case yahooKey:
                AuthSDKHelper.share.yahooAuth(url: url)
                break
            default:
                break
            }
        }
        return true
    }
}
