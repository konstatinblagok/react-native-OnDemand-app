package com.a2zkajuser.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Bundle;
import android.util.DisplayMetrics;

import com.andexert.library.RippleView;
import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.appindexing.Thing;
import com.google.android.gms.common.api.GoogleApiClient;
import com.a2zkajuser.R;
import com.a2zkajuser.adapter.MainPageAdapter;
import com.a2zkajuser.core.socket.SocketHandler;
import com.a2zkajuser.hockeyapp.ActivityHockeyApp;
import com.a2zkajuser.utils.SessionManager;

import java.util.Locale;

import cn.trinea.android.view.autoscrollviewpager.AutoScrollViewPager;
import me.relex.circleindicator.CircleIndicator;

public class MainPage extends ActivityHockeyApp implements RippleView.OnRippleCompleteListener {

    private RippleView mySignRPLVW;
    private SocketHandler socketHandler;
    private AutoScrollViewPager myViewPager;
    private MainPageAdapter myAdapter;
    int[] myImageInt = {
            R.drawable.slide1,
            R.drawable.slide2,
            R.drawable.slide3,
            R.drawable.slide4,
            R.drawable.slide5,
    };

    SessionManager sessionManager;

    private CircleIndicator myViewPageIndicator;

    private GoogleApiClient client;

    public Action getIndexApiAction() {
        Thing object = new Thing.Builder()
                .setName("MainPage Page") // TODO: Define a title for the content shown.
                // TODO: Make sure this auto-generated URL is correct.
                .setUrl(Uri.parse("http://[ENTER-YOUR-URL-HERE]"))
                .build();
        return new Action.Builder(Action.TYPE_VIEW)
                .setObject(object)
                .setActionStatus(Action.STATUS_TYPE_COMPLETED)
                .build();
    }

    @Override
    public void onStart() {
        super.onStart();

        client.connect();
        AppIndex.AppIndexApi.start(client, getIndexApiAction());
    }

    @Override
    public void onStop() {
        super.onStop();

        AppIndex.AppIndexApi.end(client, getIndexApiAction());
        client.disconnect();
    }


    private class Receiver extends BroadcastReceiver
    {

        @Override
        public void onReceive(Context context, Intent intent) {
            if(intent.getAction().equalsIgnoreCase("com.app.device.back.button.pressed"))
            {
                finish();
            }
        }
    }
    private Receiver receive;

    String[] title;
    String[] text;
    String[] text1;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main_page);
        title = new String[]{getResources().getString(R.string.book_screen), getResources().getString(R.string.payment_screen), getResources().getString(R.string.alert_screen)
                 , getResources().getString(R.string.track_screen), getResources().getString(R.string.chat_screen)};
        text = new String[]{getResources().getString(R.string.book_text), getResources().getString(R.string.payment_text), getResources().getString(R.string.alert_text)
                 , getResources().getString(R.string.track_text), getResources().getString(R.string.chat_text)};
        text1 = new String[]{getResources().getString(R.string.book_text1), getResources().getString(R.string.payment_text1), getResources().getString(R.string.alert_text1)
               , getResources().getString(R.string.track_text1), getResources().getString(R.string.chat_text1)};
        initilize();
        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();

    }

    public void initilize() {
        socketHandler = SocketHandler.getInstance(this);
        mySignRPLVW = (RippleView) findViewById(R.id.main_skip);
        myViewPager = (AutoScrollViewPager) findViewById(R.id.main_page_VWPGR);
        myViewPageIndicator = (CircleIndicator) findViewById(R.id.main_page_VWPGR_indicator);
        sessionManager = new SessionManager(this);
//        setLanguage(sessionManager.getLocaleLanguage());
        loadData();
        clickListener();
        receive = new Receiver();
        IntentFilter intentFilter=new IntentFilter();
        intentFilter.addAction("com.app.device.back.button.pressed");
        registerReceiver(receive,intentFilter);
    }

    private void clickListener() {
        mySignRPLVW.setOnRippleCompleteListener(this);

    }

    private void loadData() {
        try {
            myAdapter = new MainPageAdapter(getApplicationContext(), myImageInt,title,text,text1);
            myViewPager.setAdapter(myAdapter);
            myViewPageIndicator.setViewPager(myViewPager);
            myViewPager.startAutoScroll();
            myViewPager.setInterval(2900);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    @Override
    public void onDestroy() {
        super.onDestroy();
        try {
            if (receive != null) {
               unregisterReceiver(receive);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onComplete(RippleView rippleView) {
        switch (rippleView.getId()) {
            case R.id.main_skip:
                Intent intent = new Intent(MainPage.this, NavigationDrawer.class);
                startActivity(intent);
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                break;

        }
    }

    public void setLanguage(String languagecode) {
        sessionManager.setLocaleLanguage(languagecode);
        Resources res = getApplicationContext().getResources();
        DisplayMetrics dm = res.getDisplayMetrics();
        android.content.res.Configuration conf = res.getConfiguration();
        conf.locale = new Locale(languagecode);
        res.updateConfiguration(conf, dm);
    }
}
