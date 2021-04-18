package com.a2zkajuser.app;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.a2zkajuser.R;
import com.a2zkajuser.core.pushnotification.GCMInitializer;
import com.a2zkajuser.hockeyapp.ActivityHockeyApp;
import com.a2zkajuser.iconstant.Iconstant;
import com.a2zkajuser.core.socket.SocketHandler;
import com.a2zkajuser.utils.ConnectionDetector;
import com.a2zkajuser.utils.SessionManager;
import com.a2zkajuser.core.dialog.LoadingDialog;
import com.a2zkajuser.core.dialog.PkDialog;
import com.a2zkajuser.core.volley.ServiceRequest;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

/**
 * Casperon Technology on 12/9/2015.
 */
public class OtpPage extends ActivityHockeyApp {

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager sessionManager;

    private RelativeLayout Rl_back;
    private EditText Et_otp;
    private Button Bt_send;

    private String Str_username = "", Str_email = "", Str_password = "", Str_phone = "", Str_countryCode = "", Str_referralCode = "", Str_gcmId = "";
    private String Str_otp_Status = "", Str_otp = "";
    private String sCheckClass="";
    private String first_name = "", last_name = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.otp_page);
        initialize();

        Rl_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // close keyboard
                InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);

                finish();
                overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);

            }
        });

        Bt_send.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (Et_otp.getText().toString().length() == 0) {
                    errorEdit(Et_otp, getResources().getString(R.string.otp_label_alert_otp));
                } else if (!Str_otp.equals(Et_otp.getText().toString())) {
                    errorEdit(Et_otp, getResources().getString(R.string.otp_label_alert_invalid));
                } else {
                    cd = new ConnectionDetector(OtpPage.this);
                    isInternetPresent = cd.isConnectingToInternet();

                    if (isInternetPresent) {
                       Register();

                        System.out.println("otp------------"+Iconstant.OtpUrl);

                    } else {
                        alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                    }
                }
            }
        });
    }

    private void initialize() {
        sessionManager = new SessionManager(OtpPage.this);
        cd = new ConnectionDetector(OtpPage.this);
        isInternetPresent = cd.isConnectingToInternet();

        Rl_back = (RelativeLayout) findViewById(R.id.otp_header_back_layout);
        Et_otp = (EditText) findViewById(R.id.otp_edittext);
        Bt_send = (Button) findViewById(R.id.otp_submit_button);

        Et_otp.addTextChangedListener(EditorWatcher);

        Intent intent = getIntent();
        Str_username = intent.getStringExtra("UserName");
        Str_email = intent.getStringExtra("Email");
        Str_password = intent.getStringExtra("Password");
        Str_phone = intent.getStringExtra("Phone");
        Str_countryCode = intent.getStringExtra("CountryCode");
        Str_referralCode = intent.getStringExtra("ReferralCode");
        Str_gcmId = intent.getStringExtra("GcmID");
        Str_otp_Status = intent.getStringExtra("Otp_Status");
        Str_otp = intent.getStringExtra("Otp");
        first_name = intent.getStringExtra("firstname");
        last_name = intent.getStringExtra("lastname");
       System.out.println("Gcm id-------------"+Str_gcmId);
        if (Str_otp_Status.equalsIgnoreCase("development")) {
            Et_otp.setText(Str_otp);
        } else {
            Et_otp.setText("");
        }

        sCheckClass=intent.getStringExtra("IntentClass");
    }

    //-------Code for TextWatcher------
    private final TextWatcher EditorWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
        }

        @Override
        public void afterTextChanged(Editable s) {
            //clear error symbol after entering text
            if (Et_otp.getText().length() > 0) {
                Et_otp.setError(null);
            }
        }
    };

    // --------Code to set error for EditText--------
    private void errorEdit(EditText editName, String msg) {
        Animation shake = AnimationUtils.loadAnimation(OtpPage.this, R.anim.shake);
        editName.startAnimation(shake);
        editName.setError(msg);
    }

    //--------Alert Method--------
    private void alert(String title, String message) {
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

    private void Register(){

        cd = new ConnectionDetector(OtpPage.this);
        isInternetPresent = cd.isConnectingToInternet();

        if (isInternetPresent) {
            //---------Getting GCM Id----------
            GCMInitializer initializer = new GCMInitializer(OtpPage.this, new GCMInitializer.CallBack() {
                @Override
                public void onRegisterComplete(String registrationId) {

                    Str_gcmId = registrationId;
                    postOtpRequest(OtpPage.this, Iconstant.OtpUrl);

                    System.out.println("register----------------" + Iconstant.OtpUrl);
                }

                @Override
                public void onError(String errorMsg) {
                    postOtpRequest(OtpPage.this, Iconstant.OtpUrl);
                    System.out.println("register_Error----------------" + Iconstant.OtpUrl);
                }
            });
            initializer.init();

        } else {
            alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
        }
    }



    //----------Otp Post Request--------
    private void postOtpRequest(final Context mContext, String url) {

        final LoadingDialog mLoadingDialog = new LoadingDialog(mContext);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.action_otp));
        mLoadingDialog.show();

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("first_name", first_name);
        jsonParams.put("last_name", last_name);
        jsonParams.put("email", Str_email);
        jsonParams.put("password", Str_password);
        jsonParams.put("user_name", Str_username);
        jsonParams.put("country_code", Str_countryCode);
        jsonParams.put("phone_number", Str_phone);
        jsonParams.put("unique_code", Str_referralCode);
         jsonParams.put("gcm_id", Str_gcmId);

        ServiceRequest mRequest = new ServiceRequest(mContext);
        mRequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("---------otp response------------" + response);

                String Str_status = "", Str_message = "";
                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {

                        String userId = object.getString("user_id");
                        String userName = object.getString("user_name");
                        String userEmail = object.getString("email");
                        String userImage = object.getString("user_image");
                        String countryCode = object.getString("country_code");
                        String phoneNumber = object.getString("phone_number");
                        String referralCode = object.getString("referal_code");
                        String newrefercode=object.getString("new_referel_code");
                        String categoryId = object.getString("category");
                        String walletAmount = object.getString("wallet_amount");
                        String currencyCode = object.getString("currency");
                        String gcmId = object.getString("key");
                        String sSoc_Key = object.getString("soc_key");

                        sessionManager.createLoginSession(userId, userName, userEmail, userImage, countryCode, phoneNumber, categoryId, referralCode);
                        sessionManager.createWalletSession(walletAmount, currencyCode);
                        sessionManager.setXmppKey(userId, sSoc_Key);

                        sessionManager.setSocketTaskId("");
                        SocketHandler.getInstance(OtpPage.this).getSocketManager().connect();

                        Intent intent = new Intent(OtpPage.this, NavigationDrawer.class);
                        startActivity(intent);
                        finish();
                        RegisterPage.register_page.finish();
                        LogInPage.logInPageClass.finish();
                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

                    }

                     if(Str_status.equalsIgnoreCase("3")){
                        mLoadingDialog.dismiss();
                        Register();
                    }

                        if (Str_status.equalsIgnoreCase("0")) {

                        Str_message = object.getString("message");
                        alert(getResources().getString(R.string.otp_label_alert_verification_failed), Str_message);

                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                mLoadingDialog.dismiss();
            }

            @Override
            public void onErrorListener() {
                mLoadingDialog.dismiss();
            }
        });
    }


    //-------------Move Back on pressed phone back button-----------
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {

            // close keyboard
            InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);

            finish();
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            return true;
        }
        return false;
    }
}
