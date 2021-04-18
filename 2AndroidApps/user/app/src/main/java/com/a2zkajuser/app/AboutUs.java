package com.a2zkajuser.app;

import android.content.Intent;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.a2zkajuser.R;
import com.a2zkajuser.hockeyapp.ActivityHockeyApp;


/**
 * Casperon Technology on 10/12/2015.
 */
public class AboutUs extends ActivityHockeyApp {

    private RelativeLayout back;
    private TextView header_txt;
    private WebView aboutus_webview;
    String web_url = "",header = "";
    private ProgressBar progressBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.aboutus);

        Intent data = getIntent();
        web_url = data.getStringExtra("url");
        header = data.getStringExtra("header");

        aboutus_webview=(WebView)findViewById(R.id.aboutus_webview);
        progressBar = (ProgressBar) findViewById(R.id.webView_progressbar);
        back = (RelativeLayout) findViewById(R.id.aboutus_header_back_layout);
        header_txt = (TextView)findViewById(R.id.aboutus_header_textview);
        header_txt.setText(header);
        aboutus_webview.loadUrl(web_url);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                finish();
                overridePendingTransition(R.anim.enter, R.anim.exit);
            }
        });

        aboutus_webview.setWebChromeClient(new WebChromeClient() {
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

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {
            onBackPressed();
            finish();
            overridePendingTransition(R.anim.enter, R.anim.exit);
            return true;
        }
        return false;
    }
}
