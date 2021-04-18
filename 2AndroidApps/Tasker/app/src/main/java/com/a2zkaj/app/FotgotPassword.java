package com.a2zkaj.app;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.text.SpannableStringBuilder;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.EditText;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.android.volley.toolbox.StringRequest;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import org.json.JSONObject;

import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 1/27/2016.
 */
public class FotgotPassword extends ActionBarActivityHockeyApp {

    private RelativeLayout Rl_layout_forgtpwd_done, layout_forgot_pwd_back;
    private  EditText Et_Email_Edittext;
    private LoadingDialog dialog;
    private StringRequest postrequest;

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;

    private SocketHandler socketHandler;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.forgot_password);

        initilize();

        Rl_layout_forgtpwd_done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cd = new ConnectionDetector(FotgotPassword.this);
                isInternetPresent = cd.isConnectingToInternet();

                if (Et_Email_Edittext.getText().toString().length()==0){
                    erroredit(Et_Email_Edittext, getResources().getString(R.string.mainpage_logineithemail_validate_lable));
                }



                else{
                    if (isInternetPresent) {
                        forgotpasswordPostRequest(FotgotPassword.this,ServiceConstant.FORGOT_PASSWORD_URL);
                        System.out.println("forgotpwd-----------"+ServiceConstant.FORGOT_PASSWORD_URL);
                    } else {

                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                }

            }
        });


        layout_forgot_pwd_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

    }

    private void initilize() {

        cd = new ConnectionDetector(FotgotPassword.this);
        session = new SessionManager(FotgotPassword.this);
        socketHandler = SocketHandler.getInstance(this);

        Rl_layout_forgtpwd_done = (RelativeLayout) findViewById(R.id.settings_forgotpwd_button);
        layout_forgot_pwd_back = (RelativeLayout) findViewById(R.id.layout_forgot_pwd_back);
        Et_Email_Edittext = (EditText)findViewById(R.id.editText_email_forgotpwd);
    }


    // --------------------Code to set error for EditText-----------------------
    private void erroredit(EditText editname, String msg) {
        Animation shake = AnimationUtils.loadAnimation(FotgotPassword.this,
                R.anim.shake);
        editname.startAnimation(shake);

        ForegroundColorSpan fgcspan = new ForegroundColorSpan(
                Color.parseColor("#cc0000"));
        SpannableStringBuilder ssbuilder = new SpannableStringBuilder(msg);
        ssbuilder.setSpan(fgcspan, 0, msg.length(), 0);
        editname.setError(ssbuilder);
    }


    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(FotgotPassword.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
                onBackPressed();
            }
        });
        mDialog.show();
    }


    //-----------------------Code Forgotpassword post request-----------------
    private void forgotpasswordPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("email",Et_Email_Edittext.getText().toString() );

        dialog = new LoadingDialog(FotgotPassword.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                Log.e("forgotpwd",response);

                String Str_status = "", Str_response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");
                    Str_response = object.getString("response");
                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }

                if (Str_status.equalsIgnoreCase("1")) {
                    Alert(getResources().getString(R.string.label_pushnotification_cashreceived), Str_response);

                } else {
                    Alert(getResources().getString(R.string.alert_servererror), Str_response);
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
    protected void onResume() {
        super.onResume();
       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }

}
