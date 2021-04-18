package com.a2zkaj.app;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.RelativeLayout;

import com.afollestad.materialdialogs.DialogAction;
import com.andexert.library.RippleView;
import com.google.android.gms.appindexing.Action;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.appindexing.Thing;
import com.google.android.gms.common.api.GoogleApiClient;
import com.jaredrummler.materialspinner.MaterialSpinner;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.CustomPagerAdapter;
import com.a2zkaj.hockeyapp.ActivityHockeyApp;

import java.util.HashMap;
import java.util.Locale;

import cn.trinea.android.view.autoscrollviewpager.AutoScrollViewPager;
import core.Dialog.PkDialog;
import core.socket.SocketHandler;
import me.relex.circleindicator.CircleIndicator;

/**
 * Created by user88 on 11/28/2015.
 */
public class MainPage extends ActivityHockeyApp implements RippleView.OnRippleCompleteListener {

    private RippleView mySignRPLVW, myRegisterRPLVW;
    private SocketHandler socketHandler;
    private AutoScrollViewPager myViewPager;
    private CustomPagerAdapter myAdapter;
    int[] myImageInt = {
            R.drawable.plumber1,
            R.drawable.plumber2,
            R.drawable.plumber3,
            R.drawable.plumber4,
    };
    String[] myText;
    private CircleIndicator myViewPageIndicator;

    MaterialSpinner spinner;
    private String Item1 = "";
    private String Item2 = "";
    SessionManager session;
    RelativeLayout back;
    String selected_lang;
    private String[] myLanguageSPNArrayItems;
    String User_id = "";
    public static Activity navigation_Drawer;

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


    private class Receiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equalsIgnoreCase("com.app.device.back.button.pressed")) {
                finish();
            }
        }
    }

    private Receiver receive;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.main);
        initilize();

        navigation_Drawer = MainPage.this;

        session = new SessionManager(MainPage.this);

        HashMap<String, String> user = session.getUserDetails();
        User_id = user.get(SessionManager.KEY_PROVIDERID);

        selected_lang = session.getLocaleLanguage();

        myLanguageSPNArrayItems = new String[]{
                getResources().getString(R.string.english_text),
                getResources().getString(R.string.other_text)};

        initialize();


        spinner.setOnItemSelectedListener(new MaterialSpinner.OnItemSelectedListener<String>() {

            @Override
            public void onItemSelected(MaterialSpinner view, int position, long id, String item) {
                showAlertDialog(item);
            }
        });

        // ATTENTION: This was auto-generated to implement the App Indexing API.
        // See https://g.co/AppIndexing/AndroidStudio for more information.
        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();

    }


    public void initilize() {
        myText = new String[]{getResources().getString(R.string.text1), getResources().getString(R.string.text2),
                getResources().getString(R.string.text3), getResources().getString(R.string.text4),};
        socketHandler = SocketHandler.getInstance(this);
        mySignRPLVW = (RippleView) findViewById(R.id.main_RPL_signin);
        myRegisterRPLVW = (RippleView) findViewById(R.id.main_RPL_register);
        myViewPager = (AutoScrollViewPager) findViewById(R.id.main_page_VWPGR);
        myViewPageIndicator = (CircleIndicator) findViewById(R.id.main_page_VWPGR_indicator);
        loadData();
        clickListener();
        receive = new Receiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.app.device.back.button.pressed");
        registerReceiver(receive, intentFilter);
    }

    private void clickListener() {
        mySignRPLVW.setOnRippleCompleteListener(this);
        myRegisterRPLVW.setOnRippleCompleteListener(this);
    }

    @Override
    public void onComplete(RippleView aRippleView) {
        switch (aRippleView.getId()) {
            case R.id.main_RPL_signin:
                Intent aSignInIntent = new Intent(MainPage.this, LoginPage.class);
                startActivity(aSignInIntent);
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                break;
            case R.id.main_RPL_register:
                Intent aIntent = new Intent(MainPage.this, mageweb.class);
                startActivity(aIntent);
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                break;
        }

    }

    private void loadData() {
        try {
            myAdapter = new CustomPagerAdapter(getApplicationContext(), myImageInt, myText);
            myViewPager.setAdapter(myAdapter);
            myViewPageIndicator.setViewPager(myViewPager);
            myViewPager.startAutoScroll();
            myViewPager.setInterval(2900);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(MainPage.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        mDialog.show();
    }

    public void initialize() {
        session = new SessionManager(MainPage.this);
        spinner = (MaterialSpinner) findViewById(R.id.spinner);
        spinner.setItems(myLanguageSPNArrayItems);
        if (selected_lang.equalsIgnoreCase("en")) {
            spinner.setSelectedIndex(0);
        } else {
            spinner.setSelectedIndex(1);
        }

    }

    private void showAlertDialog(final String item) {
        try {
            new com.afollestad.materialdialogs.MaterialDialog.Builder(this)
                    .title(R.string.title)
                    .content(R.string.content)
                    .positiveText(R.string.btn_TXT_positive)
                    .titleColor(getResources().getColor(R.color.black_color))
                    .contentColor(getResources().getColor(R.color.black_color))
                    .negativeText(R.string.btn_TXT_negative)
                    .positiveColor(getResources().getColor(R.color.appmain_color))
                    .negativeColor(getResources().getColor(R.color.pink_background_color))
                    .onPositive(new com.afollestad.materialdialogs.MaterialDialog.SingleButtonCallback() {
                        @Override
                        public void onClick(@NonNull com.afollestad.materialdialogs.MaterialDialog dialog, @NonNull DialogAction which) {
                            try {
                                if (item.equalsIgnoreCase(getResources().getString(R.string.other_text))) {
//                                    setLanguage("en1");
                                } else if (item.equalsIgnoreCase(getResources().getString(R.string.english_text))) {
//                                    setLanguage("en");
                                }
                                dialog.dismiss();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    })
                    .onNegative(new com.afollestad.materialdialogs.MaterialDialog.SingleButtonCallback() {
                        @Override
                        public void onClick(@NonNull com.afollestad.materialdialogs.MaterialDialog dialog, @NonNull DialogAction which) {
                            dialog.dismiss();
                        }
                    })
                    .show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void setLanguage(String languagecode) {
        session.setLocaleLanguage(languagecode);
        Resources res = getApplicationContext().getResources();
        DisplayMetrics dm = res.getDisplayMetrics();
        android.content.res.Configuration conf = res.getConfiguration();
        conf.locale = new Locale(languagecode);
        res.updateConfiguration(conf, dm);
        MainPage.navigation_Drawer.finish();
        Intent i = new Intent(getApplicationContext(), MainPage.class);
        startActivity(i);
        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
        finish();
    }


    @Override
    protected void onResume() {
        super.onResume();
        /*if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


}
