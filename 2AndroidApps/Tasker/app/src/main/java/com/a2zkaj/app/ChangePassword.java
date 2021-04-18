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
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.HideSoftKeyboard;
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
public class ChangePassword extends ActionBarActivityHockeyApp {

    private EditText Et_current_password, Et_new_password, Et_confirm_newpassworf;

    private Button Bt_done;

    private ConnectionDetector cd;
    private SessionManager session;
    private Boolean isInternetPresent = false;
    private LoadingDialog dialog;
    private String provider_id;

    private RelativeLayout Rl_layout_back;
    private SocketHandler socketHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.change_password);

        init();

        HideSoftKeyboard.setupUI(
                ChangePassword.this.getWindow().getDecorView(),
                ChangePassword.this);

        Rl_layout_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                HideSoftKeyboard.setupUI(
                        ChangePassword.this.getWindow().getDecorView(),
                        ChangePassword.this);
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


        Bt_done.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cd = new ConnectionDetector(ChangePassword.this);
                isInternetPresent = cd.isConnectingToInternet();
                if (Et_current_password.length() == 0) {
                    Et_current_password.setError(getResources().getString(R.string.changepassword_currentpwd_label));
                } else if (Et_new_password.length() == 0) {
                    Et_new_password.setError(getResources().getString(R.string.changepassword_newpwd_label));
                } else if (Et_confirm_newpassworf.length() == 0) {
                    Et_confirm_newpassworf.setError(getResources().getString(R.string.changepassword_confirmpwd_label));
                } else if (!Et_new_password.getText().toString().equals(Et_confirm_newpassworf.getText().toString())) {
                    Et_confirm_newpassworf.setError(getResources().getString(R.string.matc_password));
                } else {
                    if (isInternetPresent) {
                        change_password_PostRequest(ChangePassword.this, ServiceConstant.CHANGE_PASSWORD_URL);
                        System.out.println("changepwd-----------" + ServiceConstant.CHANGE_PASSWORD_URL);
                    } else {

                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                }
            }
        });
        return;
    }

    private void init() {
        cd = new ConnectionDetector(ChangePassword.this);
        session = new SessionManager(ChangePassword.this);
        socketHandler = SocketHandler.getInstance(this);

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

        Et_current_password = (EditText) findViewById(R.id.change_password_ET_current_password);
        Et_new_password = (EditText) findViewById(R.id.change_password_ET_new_password);
        Et_confirm_newpassworf = (EditText) findViewById(R.id.change_password_ET_confirm_password);
        Bt_done = (Button) findViewById(R.id.change_password_done_btn);
        Rl_layout_back = (RelativeLayout) findViewById(R.id.layout__change_pwd_back);

    }

    private void Alert(final String title, String message) {
        final PkDialog mDialog = new PkDialog(ChangePassword.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
                if (title.equalsIgnoreCase(getResources().getString(R.string.alert_label_title))) {
                } else {
                    onBackPressed();
                }
            }
        });
        mDialog.show();
    }


    private void erroredit(EditText editname, String msg) {
        Animation shake = AnimationUtils.loadAnimation(ChangePassword.this, R.anim.shake);
        editname.startAnimation(shake);
        ForegroundColorSpan fgcspan = new ForegroundColorSpan(Color.parseColor("#CC0000"));
        SpannableStringBuilder ssbuilder = new SpannableStringBuilder(msg);
        ssbuilder.setSpan(fgcspan, 0, msg.length(), 0);
        editname.setError(ssbuilder);
    }


    //-----------------------Code Forgotpassword post request-----------------
    private void change_password_PostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("password", Et_current_password.getText().toString());
        jsonParams.put("new_password", Et_new_password.getText().toString());


        System.out.println("provider_idpwd-----------" + provider_id);
        System.out.println("password-----------" + Et_current_password.getText().toString());
        System.out.println("new_password-----------" + Et_new_password.getText().toString());


        dialog = new LoadingDialog(ChangePassword.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("changepwdresponse", response);
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
                    Alert(getResources().getString(R.string.alert_label_title), Str_response);
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
      /*  if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }

}
