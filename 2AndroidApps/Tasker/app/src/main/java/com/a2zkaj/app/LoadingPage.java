package com.a2zkaj.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;

import com.a2zkaj.SubClassBroadCast.SubClassActivity;

import core.socket.SocketHandler;


/**
 * Created by user115 on 2/18/2016.
 */
public class LoadingPage extends SubClassActivity {


    private String SdriverId = "";
    private String SrideId = "";
    Button checkstatuss;
    private SocketHandler socketHandler;
    private RelativeLayout myBackLAY;

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.package.finish_LOADINGPAGE")) {
                finish();
            }
        }
    }

    private RefreshReceiver refreshReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.waiting);
        socketHandler = SocketHandler.getInstance(this);

        classAndWidgetInitialize();
        // -----code to finish using broadcast receiver-----
        refreshReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.package.finish_LOADINGPAGE");
        registerReceiver(refreshReceiver, intentFilter);

        //checkstatuss = (Button)findViewById(R.id.checkstatus);

        // ChatingService.startDriverAction(LoadingPage.this);

        Intent i = getIntent();
        SdriverId = i.getStringExtra("Driverid");
        SrideId = i.getStringExtra("RideId");

    }

    private void classAndWidgetInitialize() {
        myBackLAY = (RelativeLayout) findViewById(R.id.waiting_back_layout);
        clickListener();
    }

    private void clickListener() {
        myBackLAY.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }


    //-----------------Move Back on  phone pressed  back button------------------
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {
            // nothing
            return true;
        }
        return false;
    }

    @Override
    protected void onResume() {
        super.onResume();
        /*if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


    @Override
    public void onDestroy() {
        // Unregister the logout receiver
        unregisterReceiver(refreshReceiver);
        super.onDestroy();
    }

}
