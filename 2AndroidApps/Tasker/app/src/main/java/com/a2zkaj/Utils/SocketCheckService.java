package com.a2zkaj.Utils;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;

import java.util.HashMap;

import core.Volley.ServiceRequest;
import core.socket.SocketHandler;

/**
 * Created by user145 on 1/12/2018.
 */
public class SocketCheckService extends Service {
    private Context myContext;
    private String UserID = "";
    private SessionManager session;
    private ServiceRequest mRequest;
    private SocketHandler socketHandler;
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;

    @Override
    public void onCreate() {
        super.onCreate();
        myContext = getApplicationContext();
        cd = new ConnectionDetector(getApplicationContext());
        isInternetPresent = cd.isConnectingToInternet();
        socketHandler = SocketHandler.getInstance(this);
        session = new SessionManager(myContext);

        HashMap<String, String> user = session.getUserDetails();
        UserID = user.get(SessionManager.KEY_PROVIDERID);

        final Handler handler = new Handler(Looper.getMainLooper());
        handler.postDelayed(new Runnable() {
           @Override
           public void run() {
               isInternetPresent = cd.isConnectingToInternet();
               SocketCheckMethod();
               handler.postDelayed(this,1000);
           }
       },1000);
    }

    private void SocketCheckMethod() {
        if (!socketHandler.getSocketManager().isConnected && isInternetPresent) {
            socketHandler.getSocketManager().connect();
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {

        //TODO do something useful

        return Service.START_STICKY;
    }



    @Override
    public IBinder onBind(Intent intent) {
        //TODO for communication return IBinder implementation
        return null;
    }




}
