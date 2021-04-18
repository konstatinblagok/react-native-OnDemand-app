package com.a2zkaj.app;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.github.javiersantos.bottomdialogs.BottomDialog;
import com.a2zkaj.Utils.ConnectionDetector;

import core.Dialog.PkDialog;
import core.service.ServiceConstant;


/**
 */
public class RegisterPageWebview extends Activity {

    private WebView mWebView;
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private String weburl = ServiceConstant.Register_URL;
    //private String weburl = "http://192.168.0.87:3002/app/test.html";
    private ProgressBar progressBar;
    private Dialog photo_dialog;
    private ValueCallback<Uri> mUploadMessage;
    private final static int FILECHOOSER_RESULTCODE = 1;


    final Activity activity = this;
    public Uri imageUri;


    private Uri mCapturedImageURI = null;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.register_webview);
        initilize();

        mWebView.setWebChromeClient(new WebChromeClient() {
            @Override
            public void onProgressChanged(WebView view, int progress) {
                if (progress < 100 && progressBar.getVisibility() == ProgressBar.GONE) {
                    progressBar.setVisibility(ProgressBar.VISIBLE);
                }
                progressBar.setProgress(progress);

                if (progress == 100) {
                    progressBar.setVisibility(ProgressBar.GONE);
                }
            }
        });
    }


    private void initilize() {
        mWebView = (WebView) findViewById(R.id.register_webView);
        RelativeLayout mBackLayout = (RelativeLayout) findViewById(R.id.register_header_back_layout);
        mBackLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });


        mWebView.setWebViewClient(new Callback());
        cd = new ConnectionDetector(RegisterPageWebview.this);
        isInternetPresent = cd.isConnectingToInternet();

        progressBar = (ProgressBar) findViewById(R.id.plumbal_money_webView_progressbar);

        // Enable Javascript to run in WebView
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.addJavascriptInterface(new WebAppInterface(this), "Android");
        mWebView.getSettings().setDomStorageEnabled(true);
        mWebView.requestFocus(View.FOCUS_DOWN);
        // Allow Zoom in/out controls
        mWebView.getSettings().setBuiltInZoomControls(true);

        // Zoom out the best fit your screen
        mWebView.getSettings().setLoadWithOverviewMode(true);
        mWebView.getSettings().setUseWideViewPort(true);
        mWebView.getSettings().setAllowFileAccess(true);
        if (isInternetPresent) {
            //  mWebView.loadUrl(weburl);
            mWebView.loadUrl(weburl);

        } else {
            Alert(getResources().getString(R.string.my_rides_rating_header_sorry_textview), getResources().getString(R.string.alert_nointernet));
        }
    }


    public class WebAppInterface {
        Context mContext;

        /**
         * Instantiate the interface and set the context
         */
        WebAppInterface(Context c) {
            mContext = c;
        }

        @JavascriptInterface   // must be added for API 17 or higher
        public void showToast(String toast) {
            Toast.makeText(mContext, "Hello", Toast.LENGTH_SHORT).show();


        }
    }


    private class Callback extends WebViewClient {  //HERE IS THE MAIN CHANGE.

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {


            return (true);
        }

        //Show loader on url load
        @Override
        public void onLoadResource(WebView view, String url) {
        }

        @Override
        public void onPageFinished(WebView view, String url) {

            try {
                if (url.contains(ServiceConstant.Register_Return_URL)) {
                    mWebView.clearHistory();
                    finish();
                } else if (url.contains(ServiceConstant.REGISTER_SUCCESS)) {
                    showRegistrationSuccessDialog();
                } else if (url.contains(ServiceConstant.REGISTER_CANCEL)) {
                    showRegistrationCancelDialog();
                }
            } catch (Exception exception) {
                exception.printStackTrace();
            }
        }
    }

    private void showRegistrationSuccessDialog() {
        BottomDialog.Builder bottomDialog = new BottomDialog.Builder(this);
        bottomDialog.setTitle(R.string.dialog_registration_success);
        bottomDialog.setContent(R.string.dialog_registration_message);
        bottomDialog.setPositiveText(R.string.action_ok);
        bottomDialog.onPositive(new BottomDialog.ButtonCallback() {
            @Override
            public void onClick(BottomDialog dialog) {
                Intent intent = new Intent(getBaseContext(), LoginPage.class);
                startActivity(intent);
                finish();
            }
        });
        bottomDialog.show();
    }

    private void showRegistrationCancelDialog() {
        BottomDialog.Builder bottomDialog = new BottomDialog.Builder(this);
        bottomDialog.setTitle(R.string.dialog_registration_cancel);
        bottomDialog.setContent(R.string.dialog_registration_cancel_message);
        bottomDialog.setPositiveText(R.string.action_ok);
        bottomDialog.onPositive(new BottomDialog.ButtonCallback() {
            @Override
            public void onClick(BottomDialog dialog) {
                finish();
            }
        });
        bottomDialog.show();

    }

    @Override
    public void onBackPressed() {
        if (mWebView != null && mWebView.canGoBack()) {
            mWebView.goBack();
        } else {
            super.onBackPressed();
        }
    }

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(RegisterPageWebview.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        mDialog.show();
    }
}
