package com.a2zkaj.app;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.a2zkaj.SubClassBroadCast.SubClassActivity;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.CurrencySymbolConverter;
import com.a2zkaj.Utils.SessionManager;

import org.json.JSONObject;

import java.text.NumberFormat;
import java.util.HashMap;
import java.util.Locale;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 12/31/2015.
 */
public class OtpPage extends SubClassActivity {

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;
    EditText Et_otp;
    Button BT_otp_confirm;
    private String Str_receive_amount = "";
    String Str_otp = "", Str_amount = "";
    private String StrjobId = "", provider_id = "";

    private Handler mHandler;
    private LoadingDialog dialog;

    private RelativeLayout layout_back;
    private SocketHandler socketHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.otp_page);
        initialize();

        BT_otp_confirm.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
               String otp=Et_otp.getText().toString();

                if(Et_otp.getText().toString().length()==0){
                    Alert(getResources().getString(R.string.lbel_notification), getResources().getString(R.string.lbel_otp_code_enter_alert));

                }else{

                    Intent refreshBroadcastIntent = new Intent();
                    refreshBroadcastIntent.setAction("com.finish.OtpPage");
                    sendBroadcast(refreshBroadcastIntent);

                    Intent refreshBroadcastfare = new Intent();
                    refreshBroadcastfare.setAction("com.finish.PaymentFareSummeryPage");
                    sendBroadcast(refreshBroadcastfare);

                    Intent intent = new Intent(OtpPage.this, ReceiveCashPage.class);
                    intent.putExtra("jobId", StrjobId);
                    intent.putExtra("Amount", Str_receive_amount);
                    intent.putExtra("otp",otp);

                    startActivity(intent);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

                }


            }
        });

        layout_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


    }

    private void initialize() {
        session = new SessionManager(OtpPage.this);

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        Et_otp = (EditText) findViewById(R.id.otp_enter_code);
        BT_otp_confirm = (Button) findViewById(R.id.otp_confirm_btn);
        layout_back = (RelativeLayout) findViewById(R.id.layout_otp_back);
        socketHandler = SocketHandler.getInstance(this);
        mHandler = new Handler();

        Intent i = getIntent();
        StrjobId = i.getStringExtra("jobId");

      //  Et_otp.setFocusable(false);

        cd = new ConnectionDetector(OtpPage.this);
        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            otpPost(OtpPage.this, ServiceConstant.JOB_RECEIVECSH_OTP_URL);
            System.out.println("--------------otp-------------------" + ServiceConstant.JOB_RECEIVECSH_OTP_URL);
        } else {
            Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
        }

    }

    //--------------Alert Method------------------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(OtpPage.this);
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
            dialog = new LoadingDialog(OtpPage.this);
            dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
            dialog.show();
        }
    };


    //----------------------Post method for Otp------------
    private void otpPost(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", StrjobId);

        System.out.println("provider_id------------" + provider_id);
        System.out.println("job_id------------" + StrjobId);

        mHandler.post(dialogRunnable);


        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                System.out.println("otpresponse--------" + response);

                Log.e("otp", response);

                String Str_status = "", Str_response = "", Str_otp_code = "", Str_currency = "", Str_otp_status = "", Str_jobId = "", Str_message = "";
                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");

                        Str_otp_code = object.getString("otp_string");
                        Str_currency = object.getString("currency");
                        //Currency currencycode = Currency.getInstance(getLocale(Str_currency));
                        String currencyCode = CurrencySymbolConverter.getCurrencySymbol(Str_currency);

                        Str_otp_status = object.getString("otp_status");
                        Str_jobId = object.getString("job_id");
                        Str_receive_amount = currencyCode + object.getString("receive_amount");

                        System.out.println("otpcode-------" + Str_otp_code);
                        System.out.println("otpstatus-------" + Str_otp_status);
                        System.out.println("jobid-------" + Str_jobId);



                    } else {
                        Str_response = jobject.getString("response");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                dialog.dismiss();

                if (Str_status.equalsIgnoreCase("1")) {

                    if (Str_otp_status.equalsIgnoreCase("development")) {

                        System.out.println("otpstatus---inside----" + Str_otp_status);
                        System.out.println("otp---inside----" + Str_otp_code);

                        Et_otp.setText(Str_otp_code);
                    }
                } else {
                    Alert(getResources().getString(R.string.server_lable_header), Str_response);
                }
                dialog.dismiss();
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }

    //method to convert currency code to currency symbol
    private static Locale getLocale(String strCode) {

        for (Locale locale : NumberFormat.getAvailableLocales()) {
            String code = NumberFormat.getCurrencyInstance(locale).getCurrency().getCurrencyCode();
            if (strCode.equals(code)) {
                return locale;
            }
        }
        return null;
    }

    @Override
    public void onResume() {
        super.onResume();

       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


}
