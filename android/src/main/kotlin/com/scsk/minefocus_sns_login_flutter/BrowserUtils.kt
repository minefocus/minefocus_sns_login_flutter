package com.scsk.minefocus_sns_login_flutter

import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri

object BrowserUtils {
    /**
     * 外部リンクをシステムのブラウザで開くこと
     */
    fun systemBrowserInfo(context: Context?, strUrl: String) {
        if (context != null) {
            try {
                val intent = Intent()
                intent.action = "android.intent.action.VIEW"
                intent.setClassName("com.android.browser", "com.android.browser.BrowserActivity")
                val content_url = Uri.parse(strUrl)
                intent.data = content_url
                context.startActivity(intent)
            } catch (e: Exception) {
                systemBrowserInfos(context, strUrl)
            }
        }
    }

    /**
     * 外部リンクをシステムのブラウザで開くこと
     */
    fun systemBrowserInfo(context: Context?, uri: Uri) {
        if (context != null) {
            try {
                val intent = Intent()
                intent.action = "android.intent.action.VIEW"
                intent.setClassName("com.android.browser", "com.android.browser.BrowserActivity")
                intent.data = uri
                context.startActivity(intent)
            } catch (e: Exception) {
                systemBrowserInfos(context, strUri = uri)
            }
        }
    }

    // checking if the app is currently installed on the device
    @SuppressLint("WrongConstant")
    fun isInstalledApp(package_name: String, activity: Activity, isSpecifiedBrowser: Boolean = false): Boolean {

        var isInstall = true
        val pm = activity.packageManager
        if (isSpecifiedBrowser) {
            isInstall = false
            val intent = Intent(Intent.ACTION_VIEW);
            intent.addCategory(Intent.CATEGORY_BROWSABLE)
            intent.data = Uri.parse("http://")
            val list = pm.queryIntentActivities(intent, PackageManager.GET_INTENT_FILTERS)
            list.forEach {
                val packageName = it.activityInfo.packageName
                if (packageName == package_name) {
                    isInstall = true
                }
            }
        }
        var packageInfo: PackageInfo?
        try {
            packageInfo = pm.getPackageInfo(package_name, 0)
        } catch (e: PackageManager.NameNotFoundException) {
            packageInfo = null
            e.printStackTrace()
        }

        return (packageInfo != null) && isInstall

    }

    /**
     * 外部リンクをシステムのブラウザで開くこと
     */
    fun systemBrowserInfos(context: Context, strUrl: String? = null, strUri: Uri? = null, dialogCancelCallback: (() -> Unit)? = null) {
        val intent: Intent? = if (strUri == null) {
            Intent(Intent.ACTION_VIEW, Uri.parse(strUrl))
        } else if (strUrl == null) {
            Intent(Intent.ACTION_VIEW, strUri).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        } else {
            null
        }
        intent?.let {
            if (context.packageManager.resolveActivity(it, PackageManager.MATCH_DEFAULT_ONLY) != null) {
                context.startActivity(it)
            }
//            else {
//                if (CommonApplication.currentActivity == null) {
//                    showHintInfo(CommonApplication.activityList[CommonApplication.activityList.size - 1] as Context, R.string.hint_no_browser, R.string.close, dialogCancelCallback)
//                } else {
//                    showHintInfo(CommonApplication.currentActivity as Context, R.string.hint_no_browser, R.string.close, dialogCancelCallback)
//                }
//            }
        }
    }

    /**
     * Show dialog if the device without browser
     */
//    private fun showHintInfo(context: Context, msg: Int, textNBtn: Int, dialogCancelCallback: (() -> Unit)?) {
//        android.support.v7.app.AlertDialog.Builder(context)
//                .setMessage(msg)
//                .setNegativeButton(textNBtn) { _, _ ->
//                    dialogCancelCallback?.invoke()
//                }
//                .setCancelable(false)
//                .create()
//                .show()
//    }
}