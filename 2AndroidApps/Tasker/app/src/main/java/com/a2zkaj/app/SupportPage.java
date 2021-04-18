package com.a2zkaj.app;

import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;

import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import java.util.List;

import core.socket.SocketHandler;

/**
 * Created by user88 on 1/8/2016.
 */
public class SupportPage extends ActionBarActivityHockeyApp {
    private SocketHandler socketHandler;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
       // setContentView(R.layout.otp_page);
        shareToGMail("plumbal@gmail.com","","");
        socketHandler = SocketHandler.getInstance(this);
    }

    public void shareToGMail(String email, String subject, String content) {
        Intent emailIntent = new Intent(Intent.ACTION_SEND);
        //  emailIntent.putExtra(Intent.EXTRA_EMAIL, email);
        emailIntent.putExtra(Intent.EXTRA_EMAIL, new String[] {"info@zoplay.com"});
        emailIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        emailIntent.setType("text/plain");
        emailIntent.putExtra(Intent.EXTRA_TEXT, content);
        final PackageManager pm = SupportPage.this.getPackageManager();
        final List<ResolveInfo> matches = pm.queryIntentActivities(emailIntent, 0);
        ResolveInfo best = null;
        for(final ResolveInfo info : matches)
            if (info.activityInfo.packageName.endsWith(".gm") || info.activityInfo.name.toLowerCase().contains("gmail"))
                best = info;
        if (best != null)
            emailIntent.setClassName(best.activityInfo.packageName, best.activityInfo.name);
        SupportPage.this.startActivity(emailIntent);
    }

    @Override
    public void onBackPressed() {
        finish();
        super.onBackPressed();
    }

    @Override
    protected void onResume() {
        super.onResume();
       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }
}
