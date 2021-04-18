package com.a2zkajuser.app;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.a2zkajuser.R;
import com.a2zkajuser.core.dialog.LoadingDialog;
import com.a2zkajuser.core.dialog.PkDialog;
import com.a2zkajuser.core.socket.ChatMessageService;
import com.a2zkajuser.core.volley.ServiceRequest;
import com.a2zkajuser.hockeyapp.ActivityHockeyApp;
import com.a2zkajuser.iconstant.Iconstant;
import com.a2zkajuser.utils.ConnectionDetector;
import com.a2zkajuser.utils.CurrencySymbolConverter;
import com.a2zkajuser.utils.SessionManager;
import com.paypal.android.sdk.payments.PayPalConfiguration;
import com.paypal.android.sdk.payments.PayPalService;
import com.paypal.android.sdk.payments.PaymentActivity;
import com.paypal.android.sdk.payments.PaymentConfirmation;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by user146 on 10/4/2016.
 */
public class PaymentNew extends ActivityHockeyApp {
    ImageView card, cash, pay, wallet,
            add_coupon1;
    private ConnectionDetector cd;
    private boolean isInternetPresent = false;
    LinearLayout coupon;
    String couponcode;
    EditText add_coupon;
    String creditname = "";
    String payname = "";
    Button Apply_coupon;
    RelativeLayout Rl_book;
    TextView amount;
    String User_ID = "", Job_ID = "";
    private String sUserID = "", sJobID = "";
    private String sPaymentCode = "code";
    /*final int REQUEST_PAYPAL_PAYMENT=80;*/
    String currencyCode = "USD";
    String totalAmount = "33";
    private ServiceRequest mRequest;
    private LoadingDialog mLoadingDialog;
    String mobileId;
    private SessionManager sessionManager;
    String taskid = "";
    String jobid = "";
    String USER_ID = "";
    TextView jobtextid;
    TextView cardtext;
    TextView paypaltext;
    String cashname = "";
    String walletname = "";
    TextView cashtext;
    TextView wallettext;
    private static final String CONFIG_ENVIRONMENT = PayPalConfiguration.ENVIRONMENT_SANDBOX;
    ArrayList<String> array = new ArrayList<>();
    private static final String CONFIG_CLIENT_ID = "AQV_DV7Ist83_P8aREy8kzEtL1tAsk_eri7ydgsaiNBEHKcnx-lnq3LVJkdqiSxtxMG2keYwCU7r4gfm";
    String str_partiallyPaid = "";
    String Json_TaskId = "";
    private static final int REQUEST_PAYPAL_PAYMENT = 29;
    // String Url="http://45.55.241.170:3002/mobile/app/payment/by-gateway";
    String mobileidurl = "http://192.168.1.251:3002/mobile/app/payment/by-gateway";
    private static PayPalConfiguration config = new PayPalConfiguration()
            .environment(CONFIG_ENVIRONMENT)
            .clientId(CONFIG_CLIENT_ID)
            // The following are only used in PayPalFuturePaymentActivity.
            .merchantName("Casperon")
            .merchantPrivacyPolicyUri(Uri.parse("https://www.example.com/privacy"))
            .merchantUserAgreementUri(Uri.parse("https://www.example.com/legal"));
    CheckBox checkid;

    private String select_payment = "false";

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.package.finish.PaymentPageDetails")) {
                finish();
            } else if (intent.getAction().equals("com.package.refresh.MakePayment")) {
                if (isInternetPresent) {
                    if (mRequest != null) {
                        mRequest.cancelRequest();
                        mLoadingDialog.dismiss();
                    }
                    //  MakePayment_WebView_MobileID(mobileidurl);
                }
            } else if (intent.getAction().equals("com.package.refresh.paymentpage")) {
                if (isInternetPresent) {
                    paymentrequest(Iconstant.paymentpageurl);

                } else {

                    Toast.makeText(getApplicationContext(), getResources().getString(R.string.payment_new_check_internet), Toast.LENGTH_LONG).show();

                }
            }
        }
    }

    private RefreshReceiver finishReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.payment_new_layout);
        sessionManager = new SessionManager(this);
        HashMap<String, String> task = sessionManager.gettaskid();
        taskid = task.get(SessionManager.TASK_ID);

        HashMap<String, String> job = sessionManager.getjob();
        jobid = job.get(SessionManager.JOB_ID);

        HashMap<String, String> user = sessionManager.getUserDetails();
        User_ID = user.get(SessionManager.KEY_USER_ID);

        Intent intent = getIntent();
//        User_ID = intent.getStringExtra("User_id");
        Job_ID = intent.getStringExtra("JobID_INTENT");

        if (taskid.equals("") && intent.getStringExtra("TaskId") != null) {
            taskid = intent.getStringExtra("TaskId");
        }

        cd = new ConnectionDetector(PaymentNew.this);
        isInternetPresent = cd.isConnectingToInternet();


        if (isInternetPresent) {
            paymentrequest(Iconstant.paymentpageurl);
        } else {
            Toast.makeText(getApplicationContext(), getResources().getString(R.string.payment_new_check_internet), Toast.LENGTH_LONG).show();
        }

        wallettext = (TextView) findViewById(R.id.Wallet_text);
        cashtext = (TextView) findViewById(R.id.Cash_text);
        cardtext = (TextView) findViewById(R.id.Card_text);
        paypaltext = (TextView) findViewById(R.id.Nte_text);
        amount = (TextView) findViewById(R.id.amounttext);
        jobtextid = (TextView) findViewById(R.id.jobidtext);
        card = (ImageView) findViewById(R.id.Card);
        cash = (ImageView) findViewById(R.id.Cash);
        pay = (ImageView) findViewById(R.id.pay);
        wallet = (ImageView) findViewById(R.id.Wallet);
        add_coupon1 = (ImageView) findViewById(R.id.add_coupon);

        coupon = (LinearLayout) findViewById(R.id.Linear_Coupon);
        add_coupon = (EditText) findViewById(R.id.coupon_edit);
        Apply_coupon = (Button) findViewById(R.id.coupon_apply);
        Rl_book = (RelativeLayout) findViewById(R.id.linearlayout_footer_additem_final1);


        Intent intent1 = new Intent(this, PayPalService.class);
        intent1.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config);
        startService(intent1);
        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.package.finish.PaymentPageDetails");
        intentFilter.addAction("com.package.refresh.MakePayment");
        intentFilter.addAction("com.package.refresh.paymentpage");
        registerReceiver(finishReceiver, intentFilter);


        System.out.println("-------------User_ID in payment page----------------" + User_ID);
        System.out.println("-------------Jod_ID in payment page----------------" + Job_ID);

        Apply_coupon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                couponcode = add_coupon.getText().toString();
                couponcode(Iconstant.couponcode_url);

            }
        });


//------------------------------------------------URL----------------------------------

        MakePayment_WebView_MobileID(Iconstant.Mobile_Id_url);

        //------------------------------------------------URL----------------------------------

        sessionManager = new SessionManager(PaymentNew.this);


        checkid = (CheckBox) findViewById(R.id.check_id);

        add_coupon1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (coupon.getVisibility() == View.VISIBLE) {
                    coupon.setVisibility(View.GONE);
                } else {
                    coupon.setVisibility(View.VISIBLE);
                }
            }
        });
        Rl_book.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkid.isChecked()) {
                    if (select_payment.equalsIgnoreCase("false")) {
                        Toast.makeText(PaymentNew.this, getResources().getString(R.string.payment_option_toast), Toast.LENGTH_SHORT).show();
                    }
                } else {
                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_SHORT).show();

                }
            }

        });


        card.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (checkid.isChecked()) {
                    // clickButtons((ImageView) v);
                    select_payment = "card";
                    Rl_book.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {

                            if (select_payment.equalsIgnoreCase("card")) {
                                if (checkid.isChecked()) {
                                    Intent intent = new Intent(PaymentNew.this, Card_list_Details.class);
                                    intent.putExtra("USER_Id", User_ID);
                                    intent.putExtra("JOB_Id", Job_ID);
                                    intent.putExtra("Mobile_Id", mobileId);
                                    System.out.println("-------------chan ,mobilr_id----------------" + mobileId);
                                    startActivity(intent);
                                    overridePendingTransition(R.anim.enter, R.anim.exit);
                                } else {
                                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                                }
                            } else if (select_payment.equalsIgnoreCase("false")) {
                                Toast.makeText(PaymentNew.this, getResources().getString(R.string.payment_option_toast), Toast.LENGTH_SHORT).show();
                            }

                        }

                    });
                    clickButtons((ImageView) v);

                    //    Toast.makeText(PaymentNew.this, "card process", Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                }

                //clickButtons((ImageView) v);


            }
        });

        cash.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (checkid.isChecked()) {
                    // clickButtons((ImageView) v);
                    select_payment = "cash";
                    Rl_book.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {

                            if (select_payment.equalsIgnoreCase("cash")) {
                                if (checkid.isChecked()) {
                                MakePayment_Cash(Iconstant.paybycah_url);
                                } else {
                                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                                }
                            } else if (select_payment.equalsIgnoreCase("false")) {
                                Toast.makeText(PaymentNew.this, getResources().getString(R.string.payment_option_toast), Toast.LENGTH_SHORT).show();
                            }

                        }

                    });
                    clickButtons((ImageView) v);

                } else {
                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                }


            }
        });


        pay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkid.isChecked()) {
                    select_payment = "pay";
                    Rl_book.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {

                            if (select_payment.equalsIgnoreCase("pay")) {
                                if (checkid.isChecked()) {
                                paypalmethod(Iconstant.paypalurl);
                                } else {
                                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                                }
                            } else if (select_payment.equalsIgnoreCase("false")) {
                                Toast.makeText(PaymentNew.this, getResources().getString(R.string.payment_option_toast), Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
                    clickButtons((ImageView) v);

                    //   Toast.makeText(PaymentNew.this, "Paypal process", Toast.LENGTH_LONG).show();
                } else {
                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                }


            }
        });


        wallet.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (checkid.isChecked()) {
                    select_payment = "wallet";
                    Rl_book.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (select_payment.equalsIgnoreCase("wallet")) {
                                if (checkid.isChecked()) {
                                MakePayment_Wallet(Iconstant.paybywallet_url);
                                } else {
                                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                                }
                            } else if (select_payment.equalsIgnoreCase("false")) {
                                Toast.makeText(PaymentNew.this, getResources().getString(R.string.payment_option_toast), Toast.LENGTH_SHORT).show();
                            }

                        }
                    });
                    clickButtons((ImageView) v);

                } else {
                    Toast.makeText(PaymentNew.this, getResources().getString(R.string.terms_condition_toast), Toast.LENGTH_LONG).show();
                }

            }
        });


    }

    private void clickButtons(ImageView btn) {
        if (btn == card) {
            Log.e("card", "TAG  " + card.getTag());
            if (card.getTag() == "card_inactive") {
                card.setImageResource(R.drawable.card_active);
                cash.setImageResource(R.drawable.cash);
                pay.setImageResource(R.drawable.paypal);
                wallet.setImageResource(R.drawable.wallet);

                card.setTag("card_active");
                cash.setTag("cash_inactive");
                pay.setTag("pay_inactive");
                wallet.setTag("wallet_inactive");

                Log.e("card", "IF  " + card.getTag());

            } else {
                card.setImageResource(R.drawable.card);
                card.setTag("card_inactive");
                select_payment = "false";
                Log.e("card", "ELSE " + card.getTag());
            }
        } else if (btn == cash) {
            Log.e("cash", "TAG  " + cash.getTag());
            if (cash.getTag() == "cash_inactive") {
                cash.setImageResource(R.drawable.cash_active);
                card.setImageResource(R.drawable.card);
                pay.setImageResource(R.drawable.paypal);
                wallet.setImageResource(R.drawable.wallet);

                cash.setTag("cash_active");
                card.setTag("card_inactive");
                pay.setTag("pay_inactive");
                wallet.setTag("wallet_inactive");

                Log.e("cash", "IF  " + cash.getTag());

            } else {
                cash.setImageResource(R.drawable.cash);
                cash.setTag("cash_inactive");
                select_payment = "false";
                Log.e("cash", "ELSE " + cash.getTag());
            }
        } else if (btn == pay) {
            Log.e("pay", "TAG  " + pay.getTag());
            if (pay.getTag() == "pay_inactive") {
                pay.setImageResource(R.drawable.paypal_active);
                cash.setImageResource(R.drawable.cash);
                card.setImageResource(R.drawable.card);
                wallet.setImageResource(R.drawable.wallet);

                pay.setTag("pay_active");
                card.setTag("card_inactive");
                cash.setTag("cash_inactive");
                wallet.setTag("wallet_inactive");

                Log.e("pay", "IF  " + pay.getTag());

            } else {
                pay.setImageResource(R.drawable.paypal);
                pay.setTag("pay_inactive");
                select_payment = "false";
                Log.e("pay", "ELSE " + pay.getTag());
            }
        } else if (btn == wallet) {
            Log.e("wallet", "TAG  " + wallet.getTag());
            if (wallet.getTag() == "wallet_inactive") {
                wallet.setImageResource(R.drawable.wallet_active);
                cash.setImageResource(R.drawable.cash);
                pay.setImageResource(R.drawable.paypal);
                card.setImageResource(R.drawable.card);

                wallet.setTag("wallet_active");
                card.setTag("card_inactive");
                cash.setTag("cash_inactive");
                pay.setTag("pay_inactive");


                Log.e("wallet", "IF  " + wallet.getTag());

            } else {
                wallet.setImageResource(R.drawable.wallet);
                wallet.setTag("wallet_inactive");
                select_payment = "false";
                Log.e("wallet", "ELSE " + wallet.getTag());
            }
        }


    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_PAYPAL_PAYMENT) {
            if (resultCode == Activity.RESULT_OK) {
                PaymentConfirmation confirm = data
                        .getParcelableExtra(PaymentActivity.EXTRA_RESULT_CONFIRMATION);
                if (confirm != null) {
                    try {
                        System.out.println("Responseeee" + confirm);
                        Log.i("paymentExample", confirm.toJSONObject().toString());


                        JSONObject jsonObj = new JSONObject(confirm.toJSONObject().toString());

                        String paymentId = jsonObj.getJSONObject("response").getString("id");
                        System.out.println("payment id:-==" + paymentId);
                        Toast.makeText(getApplicationContext(), "Payment Successful, Payment id is " + paymentId, Toast.LENGTH_LONG).show();

                    } catch (JSONException e) {
                        Log.e("paymentExample", "an extremely unlikely failure occurred: ", e);
                    }
                }
            } else if (resultCode == Activity.RESULT_CANCELED) {
                Log.i("paymentExample", "The user canceled.");
            } else if (resultCode == PaymentActivity.RESULT_EXTRAS_INVALID) {
                Log.i("paymentExample", "An invalid Payment was submitted. Please see the docs.");
            }
        }

    }

    private void alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(PaymentNew.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (str_partiallyPaid.equalsIgnoreCase("partially paid")) {
                    str_partiallyPaid = "";
                    paymentrequest(Iconstant.paymentpageurl);
                    mDialog.dismiss();
                } else {
                    mDialog.dismiss();
                }
            }
        });
        mDialog.show();
    }

    private void partially_payment_alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(PaymentNew.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                checkid.setChecked(false);
                paymentrequest(Iconstant.paymentpageurl);
                mDialog.dismiss();
            }
        });
        mDialog.show();
    }

    //-----------------------MakePayment WebView-MobileID Post Request by card payment-----------------
    private void MakePayment_WebView_MobileID(String Url) {
        // startLoading();

        // System.out.println("=========Abdul==user================>"+JOBID);
        // System.out.println("==========Abdul=====user==========>"+USERID);
        System.out.println("-------------MakePayment WebView-MobileID Url----------------" + Url);
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", User_ID);
        jsonParams.put("job_id", Job_ID);
        jsonParams.put("gateway", sPaymentCode);

        mRequest = new ServiceRequest(PaymentNew.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------MakePayment WebView-MobileID Response----------------" + response);

                String sStatus = "";
                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    if (sStatus.equalsIgnoreCase("1")) {
                        mobileId = object.getString("mobile_id");
                        System.out.println("=============mobileId===============>" + mobileId);
                        /*Intent intent = new Intent(PaymentPage.this, PaymentWebView.class);
                        intent.putExtra("MobileID", mobileId);
                        intent.putExtra("JobID", sJobID);
                        startActivity(intent);
                        overridePendingTransition(R.anim.enter, R.anim.exit);*/
                    } else {
                        //  String sResponse = object.getString("response");
                        //alert(getResources().getString(R.string.action_sorry), sResponse);
                    }

                } catch (JSONException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }
                // stopLoading();
            }

            @Override
            public void onErrorListener() {
                // stopLoading();
            }
        });
    }
//-----------------------MakePayment Wallet Post Request-----------------

    private void MakePayment_Wallet(String Url) {
        startLoading();

        System.out.println("-------------MakePayment Wallet Url----------------" + Url);
        sUserID = User_ID;
        sJobID = Job_ID;
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", sUserID);
        jsonParams.put("job_id", sJobID);


        System.out.println("$$$$$$$$$$$$$$$$$$----user_id--------------" + sUserID);
        System.out.println("$$$$$$$$$$$$$$$$$$----job_id--------------" + sJobID);


        mRequest = new ServiceRequest(PaymentNew.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------MakePayment Wallet Response----------------" + response);

                String sStatus = "", sUserAmount = "", sCurrent_wallet_balance = "", message = "";
                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    if (sStatus.equalsIgnoreCase("0")) {
                        stopLoading();
                        alert(getResources().getString(R.string.action_sorry), getResources().getString(R.string.make_payment_empty_wallet));
                    } else if (sStatus.equalsIgnoreCase("1")) {

                        //Updating wallet amount on Navigation Drawer Slide
                        sStatus = object.getString("message");
                        sUserAmount = object.getString("used_amount");
                        sCurrent_wallet_balance = object.getString("available_wallet_amount");
                        NavigationDrawer.navigationNotifyChange();
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {

                                stopLoading();

                                final PkDialog mDialog = new PkDialog(PaymentNew.this);
                                mDialog.setDialogTitle(getResources().getString(R.string.action_success));
                                mDialog.setDialogMessage(getResources().getString(R.string.make_payment_wallet_success));
                                mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mDialog.dismiss();
                                        finish();

//                                            Intent finishBroadcastIntent = new Intent();
//                                            finishBroadcastIntent.setAction("com.package.finish.MyJobDetails");
//                                            sendBroadcast(finishBroadcastIntent);
                                        Intent intent = new Intent(PaymentNew.this, RatingPage.class);
                                        intent.putExtra("JobID", Job_ID);
                                        startActivity(intent);
                                        overridePendingTransition(R.anim.enter, R.anim.exit);
                                    }
                                });
                                mDialog.show();

                            }
                        }, 2000);


                    } else if (sStatus.equalsIgnoreCase("2")) {
                        stopLoading();
                        str_partiallyPaid = "partially paid";
                        String sResponse = object.getString("response");
                        partially_payment_alert(getResources().getString(R.string.action_sorry), sResponse);
                        // paymentrequest(Iconstant.paymentpageurl);

                    } else {
                        stopLoading();
                        String sResponse = object.getString("response");
                        alert(getResources().getString(R.string.action_sorry), sResponse);
                    }

                } catch (JSONException e) {
                    stopLoading();
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                stopLoading();
            }
        });
    }

    //-----------------------MakePayment Cash Post Request-----------------
    private void MakePayment_Cash(String Url) {
        startLoading();

        System.out.println("-------------MakePayment Cash Url----------------" + Url);
        sUserID = User_ID;
        sJobID = Job_ID;
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", sUserID);
        jsonParams.put("job_id", sJobID);

        System.out.println("user_id------------" + sUserID);
        System.out.println("job_id------------" + sJobID);

        mRequest = new ServiceRequest(PaymentNew.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------MakePayment Cash Response----------------" + response);

                String sStatus = "";
                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    if (sStatus.equalsIgnoreCase("1")) {

                        stopLoading();
                        final PkDialog mDialog = new PkDialog(PaymentNew.this);
                        mDialog.setDialogTitle(getResources().getString(R.string.view_profile_sucssslabel_call));
                        mDialog.setDialogMessage(getResources().getString(R.string.make_payment_cash_plumber_confirm_label));
                        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mDialog.dismiss();
                                finish();

                                Intent intent = new Intent(PaymentNew.this, RatingPage.class);
                                intent.putExtra("JobID", sJobID);
                                startActivity(intent);
                                finish();
                                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                            }
                        });
                        mDialog.show();


                    } else {
                        stopLoading();
                        String sResponse = object.getString("response");
                        alert(getResources().getString(R.string.action_sorry), sResponse);
                    }

                } catch (JSONException e) {
                    stopLoading();
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                stopLoading();
            }
        });
    }


    //-------------------------------------------------------------------------paybal Url-------------------------------------------

    private void paypalmethod(String Url) {
        startLoading();


        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user", User_ID);
        jsonParams.put("task", Json_TaskId);

        System.out.println("user_id------------" + sUserID);
        System.out.println("task------------" + Json_TaskId);

        mRequest = new ServiceRequest(PaymentNew.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------MakePayment Cash Response----------------" + response);

                String sStatus = "";
                String payurl = "", paymode = "";
                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    if (sStatus.equalsIgnoreCase("1")) {
                        payurl = object.getString("redirectUrl");
                        object.getString("payment_mode");
                        stopLoading();
                    } else {
                        stopLoading();
                        String sResponse = object.getString("response");
                        alert(getResources().getString(R.string.action_sorry), sResponse);
                    }

                    Intent i = new Intent(getApplicationContext(), Paypalwebview.class);
                    i.putExtra("weburl", payurl);
                    i.putExtra("job_id", Job_ID);
                    startActivity(i);

                } catch (JSONException e) {
                    stopLoading();
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                stopLoading();
            }
        });
    }


    //----------------------------------------------------------------------Paypal Url--------------------------------------------------

//---------------------------------------------------------------------Coupon code url----------------------------------------------------------//


    private void couponcode(final String Url) {
        startLoading();


        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", User_ID);
        jsonParams.put("code", couponcode);
        jsonParams.put("booking_id", Job_ID);

        System.out.println("user_id------------" + sUserID);
        System.out.println("job_id------------" + sJobID);

        mRequest = new ServiceRequest(PaymentNew.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------MakePayment Cash Response----------------" + response);

                String sStatus = "";
                String successmsg = "", discount = "";
                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    if (sStatus.equalsIgnoreCase("1")) {

                        successmsg = object.getString("response");
                        discount = object.getString("discount");

                        MakePayment_WebView_MobileID(Iconstant.Mobile_Id_url);
                        Intent refreshBroadcastIntent = new Intent();
                        refreshBroadcastIntent.setAction("com.package.refresh.paymentpage");
                        sendBroadcast(refreshBroadcastIntent);

                        final PkDialog mDialog = new PkDialog(PaymentNew.this);
                        mDialog.setDialogTitle(getResources().getString(R.string.view_profile_sucssslabel_call));
                        mDialog.setDialogMessage(successmsg);
                        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                stopLoading();
                                mDialog.dismiss();
                                MakePayment_WebView_MobileID(Iconstant.Mobile_Id_url);
                                Intent refreshBroadcastIntent = new Intent();
                                refreshBroadcastIntent.setAction("com.package.refresh.paymentpage");
                                sendBroadcast(refreshBroadcastIntent);
                            }
                        });
                        mDialog.show();

                    } else {
                        stopLoading();
                        String sResponse = object.getString("response");
                        alert(getResources().getString(R.string.action_sorry), sResponse);
                    }


                } catch (JSONException e) {
                    stopLoading();
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                stopLoading();
            }
        });
    }


//--------------------------------------------------------Coupon code url--------------------------------------------------------------------//

    private void paymentrequest(String Url) {
        //startLoading();

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", User_ID);
        jsonParams.put("job_id", Job_ID);


        System.out.println("user_id------------" + sUserID);
        System.out.println("job_id------------" + sJobID);

        mRequest = new ServiceRequest(PaymentNew.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------MakePayment Cash Response----------------" + response);
                //  stopLoading();
                String sStatus = "";
                String successmsg = "", discount = "";
                String Str_status = "", Str_response = "", Str_currency = "", Str_rideid = "", Str_action = "", currency = "";
                String totalamount = "", Job_id = "";
                try {
                    JSONObject object = new JSONObject(response);
                    Str_response = object.getString("response");
                    Str_status = object.getString("status");
                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject response_object = object.getJSONObject("response");
                        totalamount = response_object.getString("balancetotal");
                        if (response_object.length() > 0) {
                            //  String ScurrencyCode = response_object.getString("infso");
                            JSONObject infoobject = response_object.getJSONObject("info");
                            Job_id = infoobject.getString("job_id");
                            Json_TaskId = infoobject.getString("task_id");
                            currency = infoobject.getString("currency");

//                            String currencyCode = CurrencySymbolConverter.getCurrencySymbol(currency);
                            jobtextid.setText(Job_id);
                            add_coupon.setText("");

                            JSONArray payment = response_object.getJSONArray("payment");
                            array.clear();
                            for (int i = 0; i < payment.length(); i++) {
                                JSONObject ob = payment.getJSONObject(i);
                                String name = ob.getString("name");
                                String code = ob.getString("code");
                                array.add(name);
                                array.add(code);

                            }

                            String currencyCode = CurrencySymbolConverter.getCurrencySymbol(currency);
                            amount.setText(currencyCode + totalamount);

                            coupon.setVisibility(View.GONE);


                        }
                    } else {
                        // stopLoading();
                        String sResponse = object.getString("response");
                        alert(getResources().getString(R.string.action_sorry), sResponse);
                    }

                    for (int i = 0; i < array.size(); i++) {
                        String name = array.get(i);
                        String code = array.get(i);
                        if (name.equalsIgnoreCase("Credit card")) {
                            creditname = name;

                        } else if (name.equalsIgnoreCase("Pay by PayPal")) {
                            payname = name;

                        } else if (name.equalsIgnoreCase("Pay by Cash")) {
                            cashname = name;
                        } else if (name.equalsIgnoreCase("wallet")) {
                            walletname = name;
                        }


                    }


                    if (creditname.equalsIgnoreCase("Credit card")) {
                        card.setVisibility(View.VISIBLE);
                        cardtext.setVisibility(View.VISIBLE);
                        creditname = "";
                    } else {
                        card.setVisibility(View.GONE);
                        cardtext.setVisibility(View.GONE);
                    }

                    if (payname.equalsIgnoreCase("Pay by PayPal")) {
                        pay.setVisibility(View.VISIBLE);
                        paypaltext.setVisibility(View.VISIBLE);
                        payname = "";

                    } else {
                        pay.setVisibility(View.GONE);
                        paypaltext.setVisibility(View.GONE);
                    }

                    if (cashname.equalsIgnoreCase("Pay by Cash")) {
                        cash.setVisibility(View.VISIBLE);
                        cashtext.setVisibility(View.VISIBLE);
                        cashname = "";
                    } else {
                        cash.setVisibility(View.GONE);
                        cashtext.setVisibility(View.GONE);
                    }


                    if (walletname.equalsIgnoreCase("wallet")) {
                        wallet.setVisibility(View.VISIBLE);
                        wallettext.setVisibility(View.VISIBLE);
                        walletname = "";
                    } else {
                        wallet.setVisibility(View.GONE);
                        wallettext.setVisibility(View.GONE);
                    }


                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }

            }

            @Override
            public void onErrorListener() {
                // stopLoading();
            }
        });


//---------------------------------------------paymentrequest url------------------------------------------------------------------//


//--------------------------------------------Payment request url-----------------------------------------------------------------------//


    }

    private void startLoading() {
        mLoadingDialog = new LoadingDialog(PaymentNew.this);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.action_processing));
        mLoadingDialog.show();
    }

    private void stopLoading() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                mLoadingDialog.dismiss();
            }
        }, 500);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (!ChatMessageService.isStarted()) {
            Intent intent = new Intent(PaymentNew.this, ChatMessageService.class);
            startService(intent);
        }
    }
}