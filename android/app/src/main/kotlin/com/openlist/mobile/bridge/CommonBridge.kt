package com.openlist.mobile.bridge

import android.content.Context
import android.content.Intent
import android.os.Build
import com.openlist.mobile.BuildConfig
import com.openlist.mobile.utils.ToastUtils.longToast
import com.openlist.mobile.utils.ToastUtils.toast
import com.openlist.pigeon.GeneratedApi

class CommonBridge(private val context: Context) : GeneratedApi.NativeCommon {
    override fun startActivityFromUri(intentUri: String): Boolean {
        val intent = Intent.parseUri(intentUri, Intent.URI_INTENT_SCHEME)
        return if (intent.resolveActivity(context.packageManager) != null){
            context.startActivity(intent)
            true
        }else{
            false
        }
    }

    /// 用系统查看器/播放器打开本地文件：
    /// ACTION_VIEW + FileProvider content URI + MIME 类型，
    /// 全程不需要媒体权限（本应用持有存储授权 + URI 只读授权）
    override fun openFileWithViewer(path: String): Boolean {
        return try {
            val file = java.io.File(path)
            if (!file.exists()) return false
            val uri = androidx.core.content.FileProvider.getUriForFile(
                context, context.packageName + ".fileprovider", file)
            val ext = file.extension.lowercase()
            val mime = android.webkit.MimeTypeMap.getSingleton()
                .getMimeTypeFromExtension(ext) ?: "application/octet-stream"
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, mime)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    override fun getDeviceSdkInt(): Long {
        return Build.VERSION.SDK_INT.toLong()
    }


    override fun getDeviceCPUABI(): String {
        return Build.SUPPORTED_ABIS[0]
    }

    override fun getVersionName() = BuildConfig.VERSION_NAME
    override fun getVersionCode() = BuildConfig.VERSION_CODE.toLong()


    override fun toast(msg: String) {
        context.toast(msg)
    }

    override fun longToast(msg: String) {
        context.longToast(msg)
    }
}