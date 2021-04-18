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
 * Created by user88 on 12/11/2015.
 */
public class BankDetails extends ActionBarActivityHockeyApp {

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;

    private LoadingDialog dialog;

    private String provider_id = "";

    private EditText Et_bank_holdername, Et_bank_holder_acount_no, Et_bank_holder_address, Et_bankname, Et_branch, Et_branch_address, Et_ifsc_code, Et_routing_no;
    private Button Bt_save;

    private RelativeLayout Rl_bank_no_internet_layout, Rl_bank_main_layout, Rl_bank_back_layout;
    private SocketHandler socketHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.bank_details);
        initilize();

        Rl_bank_back_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

        Bt_save.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (Et_bank_holdername.length() == 0) {
                    erroredit(Et_bank_holdername, getResources().getString(R.string.action_alert_bank_Username));
                }
//                else if (Et_bank_holder_address.length() == 0) {
//                    erroredit(Et_bank_holder_address, getResources().getString(R.string.action_alert_bank_address));
//                }

                else if (Et_bank_holder_acount_no.length() == 0) {
                    erroredit(Et_bank_holder_acount_no, getResources().getString(R.string.action_alert_bank_accountno));
                } else if (Et_bankname.length() == 0) {
                    erroredit(Et_bankname, getResources().getString(R.string.action_alert_bank_name));
                } else if (Et_branch.length() == 0) {
                    erroredit(Et_branch, getResources().getString(R.string.action_alert_branch_name));
                }
//                else if (Et_branch_address.length() == 0) {
//                    erroredit(Et_branch_address, getResources().getString(R.string.action_alert_branch_address));
//                }
                else if (Et_ifsc_code.length() == 0) {
                    erroredit(Et_ifsc_code, getResources().getString(R.string.action_alert_bank_ifs_code));
                }
//                else if (Et_routing_no.length() == 0) {
//                    erroredit(Et_routing_no, getResources().getString(R.string.action_alert_bank_routingno));
//                }

                else {
                    cd = new ConnectionDetector(BankDetails.this);

                    isInternetPresent = cd.isConnectingToInternet();
                    if (isInternetPresent) {
                        Rl_bank_main_layout.setVisibility(View.VISIBLE);
                        Rl_bank_no_internet_layout.setVisibility(View.GONE);

                        saveBankInfoPostRequest(BankDetails.this, ServiceConstant.SAVE_BANK_INFO_URL);
                        System.out.println("banksave------------------" + ServiceConstant.SAVE_BANK_INFO_URL);
                    } else {
                        Rl_bank_no_internet_layout.setVisibility(View.VISIBLE);
                        Rl_bank_main_layout.setVisibility(View.GONE);

                    }
                }

            }
        });


    }


    private void initilize() {
        session = new SessionManager(BankDetails.this);
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        cd = new ConnectionDetector(BankDetails.this);
        socketHandler = SocketHandler.getInstance(this);

        Et_bank_holdername = (EditText) findViewById(R.id.account_holder_name_Et);
        Et_bank_holder_acount_no = (EditText) findViewById(R.id.account_holder_accountno_Et);
        Et_bank_holder_address = (EditText) findViewById(R.id.account_holder_address_Et);
        Et_bankname = (EditText) findViewById(R.id.account_holder_bankname_Et);
        Et_branch = (EditText) findViewById(R.id.account_branch_name_Et);
        Et_branch_address = (EditText) findViewById(R.id.account_branch_address_Et);
        Et_ifsc_code = (EditText) findViewById(R.id.account_ifsc_Et);
        Et_routing_no = (EditText) findViewById(R.id.account_routingno_Et);
        Bt_save = (Button) findViewById(R.id.bank_ac_save_button);
        Rl_bank_back_layout = (RelativeLayout) findViewById(R.id.layout_back_bankdetails);
        Rl_bank_no_internet_layout = (RelativeLayout) findViewById(R.id.layout_bankdetails_noInternet);
        Rl_bank_main_layout = (RelativeLayout) findViewById(R.id.layout_main_bank_details);


        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            Rl_bank_main_layout.setVisibility(View.VISIBLE);
            Rl_bank_no_internet_layout.setVisibility(View.GONE);
            getBankInfoPostRequest(BankDetails.this, ServiceConstant.GET_BANK_INFO_URL);
            System.out.println("myprofile---------" + ServiceConstant.GET_BANK_INFO_URL);
        } else {
            Rl_bank_main_layout.setVisibility(View.GONE);
            Rl_bank_no_internet_layout.setVisibility(View.VISIBLE);

        }

    }


    private void erroredit(EditText editname, String msg) {
        Animation shake = AnimationUtils.loadAnimation(BankDetails.this, R.anim.shake);
        editname.startAnimation(shake);
        ForegroundColorSpan fgcspan = new ForegroundColorSpan(Color.parseColor("#CC0000"));
        SpannableStringBuilder ssbuilder = new SpannableStringBuilder(msg);
        ssbuilder.setSpan(fgcspan, 0, msg.length(), 0);
        editname.setError(ssbuilder);
    }


    //-----------------------Getting bank info post request-------------------
    private void getBankInfoPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        dialog = new LoadingDialog(BankDetails.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_gettinginfo));
        dialog.show();
        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("bankinfo", response);

                String Str_Status = "", Str_response = "", Str_accountholder_name = "", Str_accountholder_address = "", Str_account_number = "", Str_bank_name = "",
                        Str_branch_name = "", Str_branch_address = "", Str_ifsc_code = "", Str_routing_number = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    if (Str_Status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");
                        JSONObject object1 = object.getJSONObject("banking");

                        Str_accountholder_name = object1.getString("acc_holder_name");
                        Str_accountholder_address = object1.getString("acc_holder_address");
                        Str_account_number = object1.getString("acc_number");
                        Str_bank_name = object1.getString("bank_name");
                        Str_branch_name = object1.getString("branch_name");
                        Str_branch_address = object1.getString("branch_address");
                        Str_ifsc_code = object1.getString("swift_code");
                        Str_routing_number = object1.getString("routing_number");

                    } else {
                        Str_response = jobject.getString("response");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (Str_Status.equalsIgnoreCase("1")) {
                    Et_bank_holdername.setText(Str_accountholder_name);
                    Et_bank_holder_address.setText(Str_accountholder_address);
                    Et_branch_address.setText(Str_branch_address);
                    Et_branch.setText(Str_branch_name);
                    Et_bankname.setText(Str_bank_name);
                    Et_bank_holder_acount_no.setText(Str_account_number);
                    Et_ifsc_code.setText(Str_ifsc_code);
                    Et_routing_no.setText(Str_routing_number);

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


    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(BankDetails.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.alert_label_title), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        mDialog.show();
    }


    //--------------------------saving bank info request----------------
    private void saveBankInfoPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("acc_holder_name", Et_bank_holdername.getText().toString());
        jsonParams.put("acc_holder_address", Et_bank_holder_address.getText().toString());
        jsonParams.put("acc_number", Et_bank_holder_acount_no.getText().toString());
        jsonParams.put("bank_name", Et_bankname.getText().toString());
        jsonParams.put("branch_name", Et_branch.getText().toString());
        jsonParams.put("branch_address", Et_branch_address.getText().toString());
        jsonParams.put("swift_code", Et_ifsc_code.getText().toString());
        jsonParams.put("routing_number", Et_routing_no.getText().toString());
        dialog = new LoadingDialog(BankDetails.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_saving));
        dialog.show();
        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("savebank", response);
                String Str_Status = "", Str_response = "", Str_accountholder_name = "", Str_accountholder_address = "", Str_account_number = "", Str_bank_name = "",
                        Str_branch_name = "", Str_branch_address = "", Str_ifsc_code = "", Str_routing_number = "";
                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    if (Str_Status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");
                        JSONObject object1 = object.getJSONObject("banking");

                        Str_accountholder_name = object1.getString("acc_holder_name");
                        Str_accountholder_address = object1.getString("acc_holder_address");
                        Str_account_number = object1.getString("acc_number");
                        Str_bank_name = object1.getString("bank_name");
                        Str_branch_name = object1.getString("branch_name");
                        Str_branch_address = object1.getString("branch_address");
                        Str_ifsc_code = object1.getString("swift_code");
                        Str_routing_number = object1.getString("routing_number");

                    } else {
                        Str_response = jobject.getString("response");
                    }

                    if (Str_Status.equalsIgnoreCase("1")) {
                        Et_bank_holdername.setText(Str_accountholder_name);
                        Et_bank_holder_address.setText(Str_accountholder_address);
                        Et_branch_address.setText(Str_branch_address);
                        Et_branch.setText(Str_branch_name);
                        Et_bankname.setText(Str_bank_name);
                        Et_bank_holder_acount_no.setText(Str_account_number);
                        Et_ifsc_code.setText(Str_ifsc_code);
                        Et_routing_no.setText(Str_routing_number);

                        final PkDialog mdialog = new PkDialog(BankDetails.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(getResources().getString(R.string.alertsaved_label_title));
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();
                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), Str_response);
                    }


                } catch (Exception e) {
                    e.printStackTrace();
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
    }

}
