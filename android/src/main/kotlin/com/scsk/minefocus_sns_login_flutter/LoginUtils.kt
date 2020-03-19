package com.scsk.minefocus_sns_login_flutter

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import android.widget.Toast
import jp.co.yahoo.yconnect.YConnectHybrid
import jp.co.yahoo.yconnect.core.oauth2.AuthorizationException
import jp.co.yahoo.yconnect.core.oidc.OIDCDisplay
import jp.co.yahoo.yconnect.core.oidc.OIDCPrompt
import jp.co.yahoo.yconnect.core.oidc.OIDCScope

class LoginUtils(private val putConnectData: ((ConnectDataServiceType, String?) -> Unit)) {
    companion object {
        var RC_SIGN_IN = 100
        var yahooLoginCancel = false
        var yahooLoginFlag = false
    }

    // 現在の類の対象
    private var mActivity: Context? = null

    private val YAHOO_CLIENT_ID = "com.sns.yahoo_clientId"
    private val YAHOO_SCHEME = "com.sns.yahoo_scheme"

    //Google
    //Yahoo
    var yconnect: YConnectHybrid? = null
    var display = OIDCDisplay.TOUCH
    var prompt = arrayOf(OIDCPrompt.DEFAULT)
    var scope = arrayOf(OIDCScope.OPENID, OIDCScope.EMAIL)
    //1を指定した場合、同意キャンセル時にredirect_uri設定先へ遷移する
    val BAIL = "1"
    //最大認証経過時間
    val MAX_AGE = "3600"

    var clientId = ""
    var customUriScheme = ""
    val state = "44GC44GC54Sh5oOF"
    val nonce = "U0FNTCBpcyBEZWFkLg=="

    /**
     * Yahoo init
     */
    fun yahooInit(act: Context) {
        mActivity = act
        val data = act.packageManager.getApplicationInfo(act.packageName, PackageManager.GET_META_DATA)
        clientId = data.metaData.get(YAHOO_CLIENT_ID) as String
        customUriScheme = data.metaData.get(YAHOO_SCHEME) as String
        // YConnectインスタンス取得
        yconnect = YConnectHybrid.getInstance()
    }

    /**
     * Yahoo sign in
     */
    fun yahooSignIn() {
        // 各パラメーターを設定
        yconnect!!.init(clientId, customUriScheme, state, display, prompt, scope, nonce, BAIL, MAX_AGE)
        // Authorizationエンドポイントにリクエスト
        BrowserUtils.systemBrowserInfos(mActivity!!, strUri = yconnect!!.generateAuthorizationUri()) {
            yahooLoginCancel = false
            yahooLoginFlag = false
        }
        yahooLoginCancel = true
        yahooLoginFlag = true
    }

    /**
     * YahooID連携
     */
    fun yahooOnResume(intentParam: Intent) {

        // ログレベル設定（必要に応じてレベルを設定してください）
        if (Intent.ACTION_VIEW == intentParam.action) {
            yahooLoginCancel = false
            /**********************************************************
             * Parse the Callback URI and Save the Access Token.
             */
            try {
//                showLoading()
                // コールバックURLから各パラメーターを抽出
                val uri = intentParam.data
                // response Url(Authorizationエンドポイントより受け取ったコールバックUrl)から各パラメーターを抽出
                yconnect!!.parseAuthorizationResponse(uri, customUriScheme, state)
//                hideLoading()
                // 認可コード、Access Token、ID Tokenを取得
                putConnectData.invoke(ConnectDataServiceType.YAHOO, yconnect!!.accessToken)
                intentParam.action = "android.intent.action.DELETE"
            } catch (e: AuthorizationException) {
//                hideDialog()
                Log.e("error=", "error=" + e.error + ", error_description=" + e.errorDescription)
                e.printStackTrace()
            } catch (e: Exception) {
//                hideDialog()
                e.printStackTrace()
            }
        } else {
            if (yahooLoginCancel) {
                yahooLoginCancel = false
                Toast.makeText(mActivity, "Yahooアカウントでのログインをキャンセルしました。", Toast.LENGTH_SHORT).show()
            }

        }
    }

}