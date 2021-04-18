package com.a2zkajuser.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.a2zkajuser.R;
import com.a2zkajuser.core.dialog.PkDialog;
import com.a2zkajuser.hockeyapp.ActivityHockeyApp;
import com.a2zkajuser.iconstant.Iconstant;
import com.a2zkajuser.utils.ConnectionDetector;
import com.a2zkajuser.utils.SessionManager;

import java.util.HashMap;
import java.util.Locale;

public class Card_list_Details extends ActivityHockeyApp {
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager sessionManager;

    private RelativeLayout Rl_back;
    private ImageView Im_backIcon;
    private TextView Tv_headerTitle;

    private WebView webview;
    private ProgressBar progressBar;

    private String sMobileID = "";
    private String UserID = "";
    private String sJobID = "";
    RelativeLayout back;

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.package.finish.Cardpage")) {
                finish();
            }
        }
    }

    private RefreshReceiver finishReceiver;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.card_list__details);

        initialize();
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                final PkDialog mDialog = new PkDialog(Card_list_Details.this);
                mDialog.setDialogTitle(getResources().getString(R.string.plumbal_webView_label_cancel_transaction));
                mDialog.setDialogMessage(getResources().getString(R.string.plumbal_webView_label_cancel_transaction_proceed));
                mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mDialog.dismiss();

                        // close keyboard
//                        InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
//                        mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);

                        onBackPressed();
                        overridePendingTransition(R.anim.enter, R.anim.exit);
                        finish();
                    }
                });
                mDialog.setNegativeButton(getResources().getString(R.string.action_cancel), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mDialog.dismiss();
                    }
                });
                mDialog.show();
            }
        });
    }


    private void initialize() {
        cd = new ConnectionDetector(Card_list_Details.this);
        isInternetPresent = cd.isConnectingToInternet();
        sessionManager = new SessionManager(Card_list_Details.this);
//        setLanguage(sessionManager.getLocaleLanguage());

        webview = (WebView) findViewById(R.id.cabily_money_webview);

        progressBar = (ProgressBar) findViewById(R.id.cabily_money_webview_progressbar);

        // Enable Javascript to run in WebView
        webview.getSettings().setJavaScriptEnabled(true);
        back = (RelativeLayout) findViewById(R.id.cabily_money_webview_header_back_layout);
        // Allow Zoom in/out controls
        webview.getSettings().setBuiltInZoomControls(true);
        webview.getSettings().setDomStorageEnabled(true);

        // Zoom out the best fit your screen
        webview.getSettings().setLoadWithOverviewMode(true);
        webview.getSettings().setUseWideViewPort(true);

        // get user data from session
        HashMap<String, String> user = sessionManager.getUserDetails();
        UserID = user.get(SessionManager.KEY_USER_ID);

        Intent i = getIntent();
        //  sMobileID = i.getStringExtra("MobileID");
        sJobID = i.getStringExtra("JOB_Id");
        sMobileID = i.getStringExtra("Mobile_Id");

        startWebView(Iconstant.Card_webview_url + sMobileID);
//        startWebView(Iconstant.Card_webview_url + sMobileID + "&lang=" + sessionManager.getLocaleLanguage());

        System.out.println("sMobileID-----------" + sMobileID);

        System.out.println("paymentwebview----------" + Iconstant.Card_webview_url + sMobileID);
//        System.out.println("paymentwebview----------" + Iconstant.Card_webview_url + sMobileID + "&lang=" + sessionManager.getLocaleLanguage());

        webview.setWebChromeClient(new WebChromeClient() {
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

        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.package.finish.Cardpage");

        registerReceiver(finishReceiver, intentFilter);
    }


    @Override
    protected void onDestroy() {
        super.onDestroy();
        unregisterReceiver(finishReceiver);
    }

    private void startWebView(String url) {
        webview.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                view.loadUrl(url);
                return true;
            }

            //Show loader on url load
            @Override
            public void onLoadResource(WebView view, String url) {
            }

//            @Override
//            public void onReceivedSslError(WebView view, final SslErrorHandler handler, SslError error) {
//                final AlertDialog.Builder builder = new AlertDialog.Builder(getApplicationContext());
//                builder.setMessage("SSL Error");
//                builder.setPositiveButton("continue", new DialogInterface.OnClickListener() {
//                    @Override
//                    public void onClick(DialogInterface dialog, int which) {
//                        handler.proceed();
//                    }
//                });
//                builder.setNegativeButton("cancel", new DialogInterface.OnClickListener() {
//                    @Override
//                    public void onClick(DialogInterface dialog, int which) {
//                        handler.cancel();
//                    }
//                });
//                final AlertDialog dialog = builder.create();
//                dialog.show();
//            }

            @Override
            public void onPageFinished(WebView view, String url) {

                System.out.println("------------url-$$$$$------" + url);

                try {

                    if (url.contains("pay-completed/bycard")) {

                        alertPaySuccess(getResources().getString(R.string.action_success), getResources().getString(R.string.make_payment_webView_label_transaction_success));
                        //finishMethod();
                    }
//                    else if (url.contains("paypalsucess")) {
//                        //webview.clearHistory();
//
//                        alertPaySuccess(getResources().getString(R.string.action_success), getResources().getString(R.string.make_payment_webView_label_transaction_success));
////                        Intent broadcastIntent = new Intent();
////                        broadcastIntent.setAction("com.package.ACTION_CLASS_CARDLIST_REFRESH");
////                        sendBroadcast(broadcastIntent);
////                        finishMethod();
//                    }

                } catch (Exception exception) {
                    exception.printStackTrace();
                }
            }
        });

        //Load url in webView
        webview.loadUrl(url);
    }

    //--------------Alert Method-----------
    private void alert(String title, String alert) {

        final PkDialog mDialog = new PkDialog(Card_list_Details.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(alert);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        mDialog.show();

    }

    //--------------Alert Pay Transaction Method-----------
    private void alertPay(String title, String alert) {

        final PkDialog mDialog = new PkDialog(Card_list_Details.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(alert);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
                finish();
                onBackPressed();
                overridePendingTransition(R.anim.enter, R.anim.exit);
            }
        });
        mDialog.show();

    }

    //--------------Alert Pay Transaction Success Method-----------
    private void alertPaySuccess(String title, String alert) {

//        Intent broadcastIntent = new Intent();
//        broadcastIntent.setAction("com.package.ACTION_CLASS_MY_JOBS_REFRESH");
//        broadcastIntent.putExtra("status","completed");
//        sendBroadcast(broadcastIntent);

        final PkDialog mDialog = new PkDialog(Card_list_Details.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(alert);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
                System.out.println("rat----------------");

                Intent intent = new Intent(Card_list_Details.this, RatingPage.class);
                intent.putExtra("JobID", sJobID);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.enter, R.anim.exit);


//                Intent finishBroadcastIntent = new Intent();
//                finishBroadcastIntent.setAction("com.package.finish.MyJobDetails");
//                sendBroadcast(finishBroadcastIntent);

//                Intent finishPaymentBroadcastIntent = new Intent();
//                finishPaymentBroadcastIntent.setAction("com.package.finish.PaymentPageDetails");
//                sendBroadcast(finishPaymentBroadcastIntent);
            }
        });
        mDialog.show();
    }

    public void finishMethod() {
        //----changing button of cabily money page----
        // Cardlist.changeButton();
        finish();
        onBackPressed();
        overridePendingTransition(R.anim.enter, R.anim.exit);
    }

    @Override
    public void onBackPressed() {
        if (webview.canGoBack()) {
            webview.goBack();
        } else {
            // Let the system handle the back button
            super.onBackPressed();
        }
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    //-----------------Move Back on pressed phone back button------------------
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {

            final PkDialog mDialog = new PkDialog(Card_list_Details.this);
            mDialog.setDialogTitle(getResources().getString(R.string.plumbal_webView_label_cancel_transaction));
            mDialog.setDialogMessage(getResources().getString(R.string.plumbal_webView_label_cancel_transaction_proceed));
            mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mDialog.dismiss();

                    // close keyboard
//                    InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
//                    mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);

                    onBackPressed();
                    finish();
                    overridePendingTransition(R.anim.enter, R.anim.exit);

                }
            });
            mDialog.setNegativeButton(getResources().getString(R.string.action_cancel), new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mDialog.dismiss();
                }
            });
            mDialog.show();

            return true;
        }
        return false;
    }

    //-----------------Move Back on pressed phone back button------------------
    //  @Override
   /* public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {


            final PkDialog mDialog = new PkDialog(Card_list_Details.this);
            mDialog.setDialogTitle(getResources().getString(R.string.cabily_webview_lable_cancel_transaction));
            mDialog.setDialogMessage(getResources().getString(R.string.cabily_webview_lable_cancel_transaction_proceed));
            mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mDialog.dismiss();

                    // close keyboard
                    InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                    mgr.hideSoftInputFromWindow(back.getWindowToken(), 0);

                    //----changing button of cabily money page----
                    //CabilyMoney.changeButton();

                    onBackPressed();
                    finish();
                    overridePendingTransition(R.anim.enter, R.anim.exit);

                }
            });
            mDialog.setNegativeButton(getResources().getString(R.string.action_cancel_alert), new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mDialog.dismiss();
                }
            });
            mDialog.show();

            return true;
        }
        return false;
    }*/

    public void setLanguage(String languagecode) {
        sessionManager.setLocaleLanguage(languagecode);
        Resources res = getApplicationContext().getResources();
        DisplayMetrics dm = res.getDisplayMetrics();
        android.content.res.Configuration conf = res.getConfiguration();
        conf.locale = new Locale(languagecode);
        res.updateConfiguration(conf, dm);
    }

}
