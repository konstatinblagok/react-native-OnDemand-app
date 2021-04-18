package com.a2zkaj.app;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.adapter.PaymentFareSummeryAdapter;
import com.a2zkaj.Pojo.PaymentFareSummeryPojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.CurrencySymbolConverter;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import org.json.JSONArray;
import org.json.JSONObject;

import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 1/8/2016.
 */
public class MoreInfoPage extends ActionBarActivityHockeyApp {
    private ConnectionDetector cd;
    private Context context;
    private SessionManager session;

    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private Handler mHandler;

    private String provider_id = "";
    private ListView fare_listview;
    private RelativeLayout Rl_layout_main, Rl_layout_no_Internet, Rl_layout_Nofare;
    private TextView Tv_JobId, Tv_JobDescription;
    private String asyntask_name = "normal";

    PaymentFareSummeryAdapter adapter;
    private ArrayList<PaymentFareSummeryPojo> farelist;


    private LoadingDialog dialog;
    private String Job_id = "";
    private boolean isPaymetFare = false;


    private RelativeLayout Rl_layout_farepayment_methods, Rl_layout_back;
    private Button Bt_Request_payment, Bt_Receivecash;
    private SocketHandler socketHandler;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.more_info);
        initialize();

        Rl_layout_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


    }

    private void initialize() {
        session = new SessionManager(MoreInfoPage.this);
        cd = new ConnectionDetector(MoreInfoPage.this);
        mHandler = new Handler();
        socketHandler = SocketHandler.getInstance(this);

        // get user data from session
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        farelist = new ArrayList<PaymentFareSummeryPojo>();

        Intent i = getIntent();
        Job_id = i.getStringExtra("JobId");

        fare_listview = (ListView) findViewById(R.id.cancelreason_listView);
        Tv_JobId = (TextView) findViewById(R.id.paymentfare_jobId_);
        Tv_JobDescription = (TextView) findViewById(R.id.Tvpaymentfare_job_description);
        Rl_layout_main = (RelativeLayout) findViewById(R.id.layout_faresummery_main);
        Rl_layout_no_Internet = (RelativeLayout) findViewById(R.id.layout_payment_noInternet);
        Rl_layout_Nofare = (RelativeLayout) findViewById(R.id.layoutpayment_nofare);
        Rl_layout_farepayment_methods = (RelativeLayout) findViewById(R.id.layout_fare_summery_btns);
        Bt_Request_payment = (Button) findViewById(R.id.Bt_faresummery_requestpaymet);
        Bt_Receivecash = (Button) findViewById(R.id.Bt_faresummery_receivecash);
        Rl_layout_back = (RelativeLayout) findViewById(R.id.layout_jobfare_back);


        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            paymentPost(MoreInfoPage.this, ServiceConstant.PAYMENT_URL);
            System.out.println("--------------payment-------------------" + ServiceConstant.PAYMENT_URL);
        } else {
            Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
        }

    }

    //----------------Loading Method-----------
    Runnable dialogRunnable = new Runnable() {
        @Override
        public void run() {
            dialog = new LoadingDialog(MoreInfoPage.this);
            dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
            dialog.show();
        }
    };

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(MoreInfoPage.this);
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

    //----------------------Post method for Payment Fare------------
    private void paymentPost(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", Job_id);

        System.out.println("provider_id------------" + provider_id);
        System.out.println("job_id------------" + Job_id);

        mHandler.post(dialogRunnable);

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("payment", response);

                String Str_status = "", Str_response = "", Str_jobDescription = "", Str_NeedPayment = "", Str_Currency = "", Str_BtnGroup = "";


                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");
                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        JSONObject object2 = object.getJSONObject("job");
                        Str_jobDescription = object2.getString("job_summary");
                        Str_NeedPayment = object2.getString("need_payment");
                        Str_Currency = object2.getString("currency");

                        // Currency currencycode = Currency.getInstance(getLocale(Str_Currency));

                        String currencyCode = CurrencySymbolConverter.getCurrencySymbol(Str_Currency);

                        Str_BtnGroup = object2.getString("btn_group");

                        JSONArray jarry = object2.getJSONArray("billing");

                        if (jarry.length() > 0) {

                            for (int i = 0; i < jarry.length(); i++) {
                                JSONObject jobjects_amount = jarry.getJSONObject(i);
                                PaymentFareSummeryPojo pojo = new PaymentFareSummeryPojo();

                                String title = jobjects_amount.getString("title");
                                pojo.setPayment_title(jobjects_amount.getString("title"));
                                if (title.contains("Hours")) {
                                    pojo.setPayment_amount(jobjects_amount.getString("amount"));
                                }
                                else if(title.contains("Payment mode")){
                                    pojo.setPayment_amount(jobjects_amount.getString("amount"));
                                }
                                else {
                                    pojo.setPayment_amount(currencyCode + jobjects_amount.getString("amount"));
                                }
                                /*pojo.setPayment_title(jobjects_amount.getString("title"));
                                pojo.setPayment_amount(currencyCode+jobjects_amount.getString("amount"));*/

                                farelist.add(pojo);
                            }
                            show_progress_status = true;
                        } else {
                            show_progress_status = false;
                        }

                    } else {
                        Str_response = jobject.getString("response");
                    }

                    System.out.println("payment1---------------------------");

                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (Str_status.equalsIgnoreCase("1")) {

                    System.out.println();

                    Tv_JobDescription.setText(Str_jobDescription);
                    Tv_JobId.setText(Job_id);

                    System.out.println();

                    adapter = new PaymentFareSummeryAdapter(MoreInfoPage.this, farelist);
                    fare_listview.setAdapter(adapter);

                    if (Str_NeedPayment.equalsIgnoreCase("1")) {
                        Rl_layout_farepayment_methods.setVisibility(View.VISIBLE);
                    } else {
                        Rl_layout_farepayment_methods.setVisibility(View.GONE);
                    }

                    if (show_progress_status) {
                        Rl_layout_Nofare.setVisibility(View.GONE);
                    } else {
                        Rl_layout_Nofare.setVisibility(View.VISIBLE);
                        fare_listview.setEmptyView(Rl_layout_Nofare);
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
//starting XMPP service
      /*  if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


}
