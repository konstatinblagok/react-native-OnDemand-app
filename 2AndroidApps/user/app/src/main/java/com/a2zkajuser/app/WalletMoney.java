package com.a2zkajuser.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkajuser.R;
import com.a2zkajuser.core.dialog.LoadingDialog;
import com.a2zkajuser.core.dialog.PkDialog;
import com.a2zkajuser.core.volley.ServiceRequest;
import com.a2zkajuser.hockeyapp.ActivityHockeyApp;
import com.a2zkajuser.iconstant.Iconstant;
import com.a2zkajuser.utils.ConnectionDetector;
import com.a2zkajuser.utils.CurrencySymbolConverter;
import com.a2zkajuser.utils.SessionManager;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Casperon Technology on 1/5/2016.
 */
public class WalletMoney extends ActivityHockeyApp {
    private ConnectionDetector cd;
    private boolean isInternetPresent = false;
    private SessionManager sessionManager;
    private String UserID = "";
    private static Context context;

    private RelativeLayout Rl_back;
    private ImageView Im_backIcon;
    private TextView Tv_headerTitle,empty_text;

    private static TextView Tv_plumbalMoney_current_balance,or_Txt;
    private static Button Bt_plumbalMoney_minimum_amount;
    private static Button Bt_plumbalMoney_maximum_amount;
    private static Button Bt_plumbalMoney_between_amount;
    private Button Bt_add_plumbalMoney;
    private static EditText Et_plumbalMoney_enterAmount;
    private RelativeLayout Rl_current_transaction;

    private ServiceRequest mRequest;
    private LoadingDialog mLoadingDialog;
    private boolean isRechargeAvailable = false;
    private String sAuto_charge_status = "";
    private String sCurrentBalance = "", sMinimum_amt = "", sMaximum_amt = "", sMiddle_amt = "", sCurrencySymbol = "", sCurrency_code = "";
    private Button myPaypalBTN;
    ArrayList<String> payment_list = new ArrayList<>();
    String str_stripe = "",str_paypal = "";


    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.package.ACTION_CLASS_PLUMBAL_MONEY_REFRESH")) {
                if (isInternetPresent) {
                    postRequest_CabilyMoney(WalletMoney.this, Iconstant.plumbal_money_url);
                }
            }
        }
    }

    private RefreshReceiver refreshReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.plumbal_money);
        context = WalletMoney.this;
        initializeHeaderBar();
        initialize();

        Rl_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                // close keyboard
                InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);

                onBackPressed();
                finish();
                overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            }
        });

        Rl_current_transaction.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(WalletMoney.this, MaidacMoneyTransaction.class);
                startActivity(intent);
                overridePendingTransition(R.anim.enter, R.anim.exit);
            }
        });

        Et_plumbalMoney_enterAmount.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                if (event != null && (event.getKeyCode() == KeyEvent.KEYCODE_ENTER)) {
                    CloseKeyboard(Et_plumbalMoney_enterAmount);
                }
                return false;
            }
        });

        Bt_plumbalMoney_minimum_amount.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Et_plumbalMoney_enterAmount.setText(sMinimum_amt);
                Bt_plumbalMoney_minimum_amount.setBackgroundColor(0xFF009788);
                Bt_plumbalMoney_between_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                Bt_plumbalMoney_maximum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                Et_plumbalMoney_enterAmount.setSelection(Et_plumbalMoney_enterAmount.getText().length());
            }
        });

        Bt_plumbalMoney_between_amount.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Et_plumbalMoney_enterAmount.setText(sMiddle_amt);
                Bt_plumbalMoney_between_amount.setBackgroundColor(0xFF009788);
                Bt_plumbalMoney_minimum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                Bt_plumbalMoney_maximum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                Et_plumbalMoney_enterAmount.setSelection(Et_plumbalMoney_enterAmount.getText().length());
            }
        });

        Bt_plumbalMoney_maximum_amount.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Et_plumbalMoney_enterAmount.setText(sMaximum_amt);
                Bt_plumbalMoney_maximum_amount.setBackgroundColor(0xFF009788);
                Bt_plumbalMoney_minimum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                Bt_plumbalMoney_between_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                Et_plumbalMoney_enterAmount.setSelection(Et_plumbalMoney_enterAmount.getText().length());
            }
        });

        Bt_add_plumbalMoney.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String enteredValue = Et_plumbalMoney_enterAmount.getText().toString();

                int enter_value = 0;
                if (enteredValue.equals("")){
                }else {
                    Double enterval = new Double(enteredValue);
                    enter_value = enterval.intValue();
                }
//                Double enterval=new Double(enteredValue);
//                int enter_value=enterval.intValue();
                Double s=new Double(sMinimum_amt);
                int min_amount=s.intValue();
                Double s1=new Double(sMaximum_amt);
                int max_amount=s1.intValue();
                Double s2=new Double(sMinimum_amt);
                int maxx_amount=s2.intValue();

                if (sMinimum_amt != null && sMinimum_amt.length() > 0) {
                    if (enteredValue.length() == 0) {
                        alert(getResources().getString(R.string.action_error), getResources().getString(R.string.action_loading_plumbal_money_empty_field));
                    } else if (enter_value < min_amount || enter_value > max_amount) {
                        alert(getResources().getString(R.string.action_error), getResources().getString(R.string.plumbalMoney_label_rechargeMoney_alert) + " " + sCurrencySymbol + sMinimum_amt + " " + "-" + " " + sCurrencySymbol + sMaximum_amt);
                    } else {
                        cd = new ConnectionDetector(WalletMoney.this);
                        isInternetPresent = cd.isConnectingToInternet();

                        if (isInternetPresent) {
                            if (sAuto_charge_status.equalsIgnoreCase("1")) {
                                postRequest_AddMoney(WalletMoney.this, Iconstant.plumbal_add_money_url);

                                System.out.println("WalletMoney-------------" + Iconstant.plumbal_add_money_url);

                            } else {

                                System.out.println("payrechargrweb---------");
                                Intent intent = new Intent(WalletMoney.this, MaidacMoneyWebView.class);
                                intent.putExtra("cabilyMoney_recharge_amount", Et_plumbalMoney_enterAmount.getText().toString());
                                intent.putExtra("cabilyMoney_currency_symbol", sCurrencySymbol);
                                intent.putExtra("cabilyMoney_currentBalance", sCurrentBalance);
                                startActivity(intent);
                                overridePendingTransition(R.anim.enter, R.anim.exit);
                            }
                        } else {
                            alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                        }
                    }
                }
            }
        });

        myPaypalBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String enteredValue = Et_plumbalMoney_enterAmount.getText().toString();

                if (sMinimum_amt != null && sMinimum_amt.length() > 0) {
                    if (enteredValue.length() == 0) {
                        alert(getResources().getString(R.string.action_error), getResources().getString(R.string.action_loading_plumbal_money_empty_field));
                    } else if (Integer.parseInt(enteredValue) < Integer.parseInt(sMinimum_amt) || Integer.parseInt(enteredValue) > Integer.parseInt(sMaximum_amt)) {
                        alert(getResources().getString(R.string.action_error), getResources().getString(R.string.plumbalMoney_label_rechargeMoney_alert) + " " + sCurrencySymbol + sMinimum_amt + " " + "-" + " " + sCurrencySymbol + sMaximum_amt);
                    } else {
                        cd = new ConnectionDetector(WalletMoney.this);
                        isInternetPresent = cd.isConnectingToInternet();

                        if (isInternetPresent) {
                            postRequest_AddMoney_paypal(WalletMoney.this, Iconstant.plumbal_money_paypal_webView_url);

                            System.out.println("MaidacMoney-------------" + Iconstant.plumbal_add_money_url);

                            System.out.println("payrechargrweb---------");
                        } else {
                            alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                        }
                    }
                }
            }
        });
    }

    private void initializeHeaderBar() {
        RelativeLayout headerBar = (RelativeLayout) findViewById(R.id.headerBar_layout);
        Rl_back = (RelativeLayout) headerBar.findViewById(R.id.headerBar_left_layout);
        Im_backIcon = (ImageView) headerBar.findViewById(R.id.headerBar_imageView);
        Tv_headerTitle = (TextView) headerBar.findViewById(R.id.headerBar_title_textView);

        Tv_headerTitle.setText(getResources().getString(R.string.plumbal_label_header_textView));
        Im_backIcon.setImageResource(R.drawable.back_arrow);
    }

    private void initialize() {
        cd = new ConnectionDetector(WalletMoney.this);
        isInternetPresent = cd.isConnectingToInternet();
        sessionManager = new SessionManager(WalletMoney.this);

        Bt_add_plumbalMoney = (Button) findViewById(R.id.plumbal_money_add_money_button);
        Et_plumbalMoney_enterAmount = (EditText) findViewById(R.id.plumbal_money_enter_amount_editText);
        Bt_plumbalMoney_minimum_amount = (Button) findViewById(R.id.plumbal_money_minimum_amt_button);
        Bt_plumbalMoney_maximum_amount = (Button) findViewById(R.id.plumbal_money_maximum_amt_button);
        Bt_plumbalMoney_between_amount = (Button) findViewById(R.id.plumbal_money_between_amt_button);
        Tv_plumbalMoney_current_balance = (TextView) findViewById(R.id.plumbal_money_your_balance_textView);
        Rl_current_transaction = (RelativeLayout) findViewById(R.id.plumbal_money_current_balance_layout);
        myPaypalBTN = (Button) findViewById(R.id.plumbal_money_add_money_button_paypal);
        or_Txt = (TextView)findViewById(R.id.plumbal_money_add_plumbal_TXT_or);
        empty_text = (TextView)findViewById(R.id.empty_text);
        Et_plumbalMoney_enterAmount.addTextChangedListener(EditorWatcher);

        // get user data from session
        HashMap<String, String> user = sessionManager.getUserDetails();
        UserID = user.get(SessionManager.KEY_USER_ID);

        // -----code to refresh drawer using broadcast receiver-----
        refreshReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.package.ACTION_CLASS_PLUMBAL_MONEY_REFRESH");
        registerReceiver(refreshReceiver, intentFilter);

        if (isInternetPresent) {
            postRequest_CabilyMoney(WalletMoney.this, Iconstant.plumbal_money_url);
        } else {
            alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
        }
    }

    //----------------------Code for TextWatcher-------------------------
    private final TextWatcher EditorWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
        }

        @Override
        public void afterTextChanged(Editable s) {

            String strEnteredVal = Et_plumbalMoney_enterAmount.getText().toString();
            if (!strEnteredVal.equals("")) {
                if (Et_plumbalMoney_enterAmount.getText().toString().equals(sMinimum_amt)) {
                    Bt_plumbalMoney_minimum_amount.setBackgroundColor(0xFF009788);
                    Bt_plumbalMoney_between_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                    Bt_plumbalMoney_maximum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                } else if (Et_plumbalMoney_enterAmount.getText().toString().equals(sMiddle_amt)) {
                    Bt_plumbalMoney_between_amount.setBackgroundColor(0xFF009788);
                    Bt_plumbalMoney_minimum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                    Bt_plumbalMoney_maximum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                } else if (Et_plumbalMoney_enterAmount.getText().toString().equals(sMaximum_amt)) {
                    Bt_plumbalMoney_maximum_amount.setBackgroundColor(0xFF009788);
                    Bt_plumbalMoney_minimum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                    Bt_plumbalMoney_between_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                } else {
                    Bt_plumbalMoney_minimum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                    Bt_plumbalMoney_between_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                    Bt_plumbalMoney_maximum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                }
            }
        }
    };

    //--------------Alert Method-----------
    private void alert(String title, String alert) {

        final PkDialog mDialog = new PkDialog(WalletMoney.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(alert);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        mDialog.show();
    }

    //--------------Close KeyBoard Method-----------
    private void CloseKeyboard(EditText edittext) {
        InputMethodManager in = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        in.hideSoftInputFromWindow(edittext.getApplicationWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
    }


    public static void changeButton() {
        Et_plumbalMoney_enterAmount.setText("");
        Bt_plumbalMoney_minimum_amount.setBackground(context.getResources().getDrawable(R.drawable.grey_border_background));
        Bt_plumbalMoney_between_amount.setBackground(context.getResources().getDrawable(R.drawable.grey_border_background));
        Bt_plumbalMoney_maximum_amount.setBackground(context.getResources().getDrawable(R.drawable.grey_border_background));
    }


    //-----------------------Plumbal Money Post Request-----------------
    private void postRequest_CabilyMoney(Context mContext, String Url) {
        mLoadingDialog = new LoadingDialog(mContext);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        mLoadingDialog.show();

        System.out.println("-------------WalletMoney Url----------------" + Url);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", UserID);
        mRequest = new ServiceRequest(mContext);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------WalletMoney Response----------------" + response);

                String sStatus = "";

                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    sAuto_charge_status = object.getString("auto_charge_status");
                    if (sStatus.equalsIgnoreCase("1")) {
                        JSONObject response_object = object.getJSONObject("response");
                        if (response_object.length() > 0) {
                            sCurrency_code = response_object.getString("currency");
                            sCurrentBalance = response_object.getString("current_balance");
                            sCurrencySymbol = CurrencySymbolConverter.getCurrencySymbol(sCurrency_code);

                            Object check_recharge_boundary_object = response_object.get("recharge_boundary");
                            if (check_recharge_boundary_object instanceof JSONObject) {
                                JSONObject recharge_object = response_object.getJSONObject("recharge_boundary");
                                if (recharge_object.length() > 0) {
                                    sMinimum_amt = recharge_object.getString("min_amount");
                                    sMaximum_amt = recharge_object.getString("max_amount");
                                    sMiddle_amt = recharge_object.getString("middle_amount");
                                    isRechargeAvailable = true;
                                } else {
                                    isRechargeAvailable = false;
                                }
                            } else {
                                isRechargeAvailable = false;
                            }
                        }


                        JSONArray payment_array = object.getJSONArray("Payment");
                        if (payment_array.length()>0) {
                            payment_list.clear();
                            for (int j=0;j<payment_array.length();j++) {
                               JSONObject payment_object = payment_array.getJSONObject(j);
                                String name = payment_object.getString("name");
                                String code = payment_object.getString("code");

                                payment_list.add(name);
                                payment_list.add(code);
                            }
                        }

                    } else {
                        isRechargeAvailable = false;
                    }


                    for (int i = 0; i < payment_list.size(); i++) {
                        String name = payment_list.get(i);
                        String code = payment_list.get(i);
                        if (name.equalsIgnoreCase("Credit card")) {
                            str_stripe = name;
                        } else if (name.equalsIgnoreCase("Pay by PayPal")) {
                            str_paypal = name;
                        }
                    }

                    if (str_stripe.equalsIgnoreCase("Credit card")) {
                        Bt_add_plumbalMoney.setVisibility(View.VISIBLE);
                    } else {
                        Bt_add_plumbalMoney.setVisibility(View.GONE);
                    }


                    if (str_paypal.equalsIgnoreCase("Pay by PayPal")) {
                        myPaypalBTN.setVisibility(View.VISIBLE);
                    } else {
                        myPaypalBTN.setVisibility(View.GONE);
                    }

                    if (Bt_add_plumbalMoney.getVisibility() == View.VISIBLE && myPaypalBTN.getVisibility() == View.VISIBLE) {
                        or_Txt.setVisibility(View.VISIBLE);
                    } else {
                        or_Txt.setVisibility(View.GONE);
                    }

                    if (payment_list.size() != 0) {
                        empty_text.setVisibility(View.GONE);
                    } else {
                        empty_text.setVisibility(View.VISIBLE);
                    }


                    if (sStatus.equalsIgnoreCase("1") && isRechargeAvailable) {
                        sessionManager.createWalletSession(sCurrentBalance, sCurrency_code);
                        NavigationDrawer.navigationNotifyChange();

                        Bt_plumbalMoney_minimum_amount.setText(sCurrencySymbol + sMinimum_amt);
                        Bt_plumbalMoney_maximum_amount.setText(sCurrencySymbol + sMaximum_amt);
                        Bt_plumbalMoney_between_amount.setText(sCurrencySymbol + sMiddle_amt);

                        double d = Double.parseDouble(sCurrentBalance);
                        DecimalFormat df = new DecimalFormat("#.00");
                        System.out.print(df.format(d));
                        Tv_plumbalMoney_current_balance.setText(sCurrencySymbol + df.format(d));
                        Et_plumbalMoney_enterAmount.setHint(getResources().getString(R.string.plumbalMoney_label_rechargeMoney_editText_hint) + " " + sCurrencySymbol + sMinimum_amt + " " + "-" + " " + sCurrencySymbol + sMaximum_amt);
                    } else {
                        String sResponse = object.getString("response");
                        alert(getResources().getString(R.string.action_sorry), sResponse);
                    }

                    mLoadingDialog.dismiss();
                } catch (JSONException e) {
                    // TODO Auto-generated catch block
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


    //-----------------------Plumbal Money Add Post Request-----------------
    private void postRequest_AddMoney(Context mContext, String Url) {
        mLoadingDialog = new LoadingDialog(mContext);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.action_processing));
        mLoadingDialog.show();

        System.out.println("-------------Plumbal ADD Money Url----------------" + Url);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", UserID);
        jsonParams.put("total_amount", Et_plumbalMoney_enterAmount.getText().toString());

        System.out.println("user_id---------------" + UserID);

        System.out.println("total_amount---------------" + Et_plumbalMoney_enterAmount.getText().toString());


        mRequest = new ServiceRequest(mContext);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("-------------Plumbal ADD Money Response----------------" + response);

                String sStatus = "", sMessage = "", sWallet_money = "";

                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    sMessage = object.getString("msg");
                    sWallet_money = object.getString("wallet_amount");

                    if (sStatus.equalsIgnoreCase("1")) {
                        sessionManager.createWalletSession(sWallet_money, sCurrency_code);
                        NavigationDrawer.navigationNotifyChange();

                        alert(getResources().getString(R.string.action_success), getResources().getString(R.string.action_loading_plumbalMoney_transaction_wallet_success));
                        Et_plumbalMoney_enterAmount.setText("");
                        Tv_plumbalMoney_current_balance.setText(sCurrencySymbol + sWallet_money);
                        Bt_plumbalMoney_minimum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                        Bt_plumbalMoney_between_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                        Bt_plumbalMoney_maximum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                    } else {
                        alert(getResources().getString(R.string.action_sorry), sMessage);
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

    //------------------------------------------------------------Add A2zkaj User Wallet money via paypal request--------------------------------

    private void postRequest_AddMoney_paypal(Context mContext, String Url) {
        mLoadingDialog = new LoadingDialog(mContext);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.action_processing));
        mLoadingDialog.show();

        System.out.println("-------------Plumbal ADD Money Url----------------" + Url);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", UserID);
        jsonParams.put("total_amount", Et_plumbalMoney_enterAmount.getText().toString());

        System.out.println("user_id---------------" + UserID);

        System.out.println("total_amount---------------" + Et_plumbalMoney_enterAmount.getText().toString());


        mRequest = new ServiceRequest(mContext);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("-------------Plumbal ADD Money Response----------------" + response);
                Log.e("paypal response", response);

                String sStatus = "", sMessage = "", sWallet_money = "", aRedirectUrlstr = "";

                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");

                    if (sStatus.equalsIgnoreCase("1")) {
                        sessionManager.createWalletSession(sWallet_money, sCurrency_code);
                        NavigationDrawer.navigationNotifyChange();
                        aRedirectUrlstr = object.getString("redirectUrl");
                        Intent intent = new Intent(WalletMoney.this, MaidacPaypalMoneyWebView.class);
                        intent.putExtra("REDIRECT_URL", aRedirectUrlstr);
                        startActivity(intent);
                        overridePendingTransition(R.anim.enter, R.anim.exit);


//                        alert(getResources().getString(R.string.action_success), getResources().getString(R.string.action_loading_plumbalMoney_transaction_wallet_success));
//                        Et_plumbalMoney_enterAmount.setText("");
//                        Tv_plumbalMoney_current_balance.setText(sCurrencySymbol + sWallet_money);
//                        Bt_plumbalMoney_minimum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
//                        Bt_plumbalMoney_between_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
//                        Bt_plumbalMoney_maximum_amount.setBackground(getResources().getDrawable(R.drawable.grey_border_background));
                    } else {
                        alert(getResources().getString(R.string.action_sorry), sMessage);
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



    @Override
    public void onResume() {
        super.onResume();
    }

    //-----------------Move Back on pressed phone back button------------------
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {

            // close keyboard
            InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);

            onBackPressed();
            finish();
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            return true;
        }
        return false;
    }

    @Override
    public void onDestroy() {
        // Unregister the logout receiver
        unregisterReceiver(refreshReceiver);
        super.onDestroy();
    }
}
