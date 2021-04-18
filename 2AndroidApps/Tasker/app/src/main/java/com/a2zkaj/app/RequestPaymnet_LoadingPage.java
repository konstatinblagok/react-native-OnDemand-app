package com.a2zkaj.app;

import android.graphics.PorterDuff;
import android.os.Bundle;
import android.view.KeyEvent;
import android.widget.ProgressBar;

import com.a2zkaj.SubClassBroadCast.SubClassActivity;

import core.socket.SocketHandler;

/**
 * Created by user88 on 2/23/2016.
 */
public class RequestPaymnet_LoadingPage extends SubClassActivity {

    private ProgressBar progressbar;
    private SocketHandler socketHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.request_payment_loadingpage);
        socketHandler = SocketHandler.getInstance(this);
        progressbar = (ProgressBar)findViewById(R.id.progressBar);

        progressbar.getProgressDrawable().setColorFilter(getResources().getColor(R.color.progresscolor), PorterDuff.Mode.SRC_IN);

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


}
