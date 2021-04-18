package com.a2zkaj.app;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.SubClassBroadCast.SubClassActivity;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;

import org.json.JSONObject;

import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 1/4/2016.
 */
public class ReceiveCashPage extends SubClassActivity {

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;
    private String provider_id = "";
    private Button Bt_Done;
    private LoadingDialog dialog;
    private String Jobid = "", Amount_received = "";

    private TextView Tv_received_amount;
private String otp="";
    private Handler mHandler;
    private RelativeLayout Rl_receivecash_back_layout;
    private SocketHandler socketHandler;
    private TextView receivecash_text,receivecash_warning_text;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.receive_cash);
        initialize();

        Bt_Done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cd = new ConnectionDetector(ReceiveCashPage.this);
                isInternetPresent = cd.isConnectingToInternet();
                if (isInternetPresent) {
                    receivedCashPost(ReceiveCashPage.this, ServiceConstant.JOB_CASH_RECEIVED_URL);
                    System.out.println("--------------cashreceivd-------------------" + ServiceConstant.JOB_CASH_RECEIVED_URL);
                } else {
                    Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                }
            }
        });


        Rl_receivecash_back_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

    }

    private void initialize() {
        session = new SessionManager(ReceiveCashPage.this);
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        Bt_Done = (Button) findViewById(R.id.Bt_receivecash_done_btn);
        Tv_received_amount = (TextView) findViewById(R.id.Tv_receivecash_amount);
        Rl_receivecash_back_layout = (RelativeLayout) findViewById(R.id.layout_receivecah_back);
        receivecash_text=(TextView)findViewById(R.id.receivecash_Tv);
        receivecash_warning_text=(TextView)findViewById(R.id.warning_text);
        socketHandler = SocketHandler.getInstance(this);
        mHandler = new Handler();

        Intent i = getIntent();
        Jobid = i.getStringExtra("jobId");
        Amount_received = i.getStringExtra("Amount");
        otp=i.getExtras().getString("otp");
        Tv_received_amount.setText(Amount_received);

        if(Amount_received.equalsIgnoreCase("$0.00")){

            Tv_received_amount.setEnabled(false);
            Tv_received_amount.setTextColor(Color.parseColor("#DCDCDC"));
            receivecash_text.setEnabled(false);
            receivecash_text.setTextColor(Color.parseColor("#DCDCDC"));
            receivecash_warning_text.setVisibility(View.VISIBLE);

        }else{

            receivecash_warning_text.setVisibility(View.GONE);
        }


    }

    //--------------Alert Method------------------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(ReceiveCashPage.this);
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


    //----------------Loading Method-----------
    Runnable dialogRunnable = new Runnable() {
        @Override
        public void run() {
            dialog = new LoadingDialog(ReceiveCashPage.this);
            dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
            dialog.show();
        }
    };

    //----------------------Post method for Payment Fare------------
    private void receivedCashPost(Context mContext, String url) {
        final HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", Jobid);
        jsonParams.put("otp",otp);

        System.out.println("provider_id---------" + provider_id);

        System.out.println("job_id---------" + Jobid);

        mHandler.post(dialogRunnable);

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                System.out.println("received--------" + response);
                Log.e("received", response);

                String Str_Status = "", Str_Response = "";

                try {

                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");
                    Str_Response = jobject.getString("response");
                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (Str_Status.equalsIgnoreCase("1")) {
                    final PkDialog mdialog = new PkDialog(ReceiveCashPage.this);
                    mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                    mdialog.setDialogMessage(Str_Response);
                    mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    mdialog.dismiss();

                                    Intent refreshBroadcastfare = new Intent();
                                    refreshBroadcastfare.setAction("com.finish.ReceiveCashPage");
                                    sendBroadcast(refreshBroadcastfare);

                                    Intent intent = new Intent(ReceiveCashPage.this, ReviwesPage.class);
                                    intent.putExtra("jobId", Jobid);
                                    startActivity(intent);
                                }
                            }
                    );
                    mdialog.show();

                } else {
                    Alert(getResources().getString(R.string.alert_label_title), Str_Response);
                }
                dialog.dismiss();
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });

    }

    @Override
    public void onResume() {
        super.onResume();
      /*  if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


}
