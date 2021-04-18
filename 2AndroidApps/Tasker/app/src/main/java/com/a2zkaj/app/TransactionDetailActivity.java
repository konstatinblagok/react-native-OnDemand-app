package com.a2zkaj.app;

import android.location.Address;
import android.location.Geocoder;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.CurrencySymbolConverter;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActivityHockeyApp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import core.Dialog.PkDialog;
import core.Dialog.PkLoadingDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;

public class TransactionDetailActivity extends ActivityHockeyApp {
    private String myUsedIdStr = "", myBookingIdStr = "";
    private TextView myHeaderTitleTXT;
    private ImageView myBackIMG;
    private RelativeLayout myBackLAY;
    private boolean isInternetPresent = false;
    private ConnectionDetector myConnectionDetector;
    private RelativeLayout myInternalLAY;
    private String myRefreshStr = "normal", myCurrencySymbol = "";
    private ServiceRequest myRequest;
    private PkLoadingDialog myLoadingDialog;
    private TextView myCategoryNameTXT, myTaskerNameTXT, myAddressTXT, myTotalHourTXT, myPerhourTXT, myHourlyRateTXT,
            myTaskAmountTXT, myServiceTaxTXT, myTotalAmountTXT, myBookingIDTXT, myBookingTaskTimeTXT, myPaymentModeTXT,material_fees;
    private LinearLayout material_layout;
    private String lat_address="",long_address="",Address="";
    private SessionManager mySession;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_transaction_detail);
        initializeHeaderBar();
        classAndWidgetInitialize();
    }


    private void initializeHeaderBar() {
        RelativeLayout headerBar = (RelativeLayout) findViewById(R.id.headerBar_layout);
        myBackLAY = (RelativeLayout) headerBar.findViewById(R.id.headerBar_left_layout);
        myBackIMG = (ImageView) headerBar.findViewById(R.id.headerBar_imageView);
        myHeaderTitleTXT = (TextView) headerBar.findViewById(R.id.headerBar_title_textView);
        myHeaderTitleTXT.setText(getResources().getString(R.string.activity_transaction_TXT_view_task_details));
        myBackIMG.setImageResource(R.drawable.back_arrow);
        myBackLAY.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                finish();
                overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            }
        });
    }


    private void classAndWidgetInitialize() {
        myConnectionDetector = new ConnectionDetector(TransactionDetailActivity.this);
        myRequest = new ServiceRequest(TransactionDetailActivity.this);
        mySession = new SessionManager(TransactionDetailActivity.this);
        isInternetPresent = myConnectionDetector.isConnectingToInternet();

        myInternalLAY = (RelativeLayout) findViewById(R.id.transaction_detail_noInternet_layout);
        myCategoryNameTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_categoryname);
        myTaskerNameTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_taskername);
        myAddressTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_address);
        myTotalHourTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_totalhours);
        myPerhourTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_perhour);
        myHourlyRateTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_hourlyrate);
        myTaskAmountTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_taskamount);
        myServiceTaxTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_servicetax);
        myTotalAmountTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_totalamount);
        myBookingIDTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_bookingid);
        myBookingTaskTimeTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_bookingtasktime);
        myPaymentModeTXT = (TextView) findViewById(R.id.screen_transaction_detail_TXT_payment_mode);
        material_fees=(TextView)findViewById(R.id.material_fees);
        material_layout=(LinearLayout)findViewById(R.id.material_layout);
        HashMap<String, String> aAmountMap = mySession.getWalletDetails();
        String aCurrencyCode = aAmountMap.get(SessionManager.KEY_CURRENCY_CODE);
        myCurrencySymbol = CurrencySymbolConverter.getCurrencySymbol(aCurrencyCode);

        getIntentValues();
        getTransactionDetailsData();
    }


    private void getIntentValues() {
        if (getIntent() != null) {
            myUsedIdStr = getIntent().getExtras().getString("ProviderId");
            myBookingIdStr = getIntent().getExtras().getString("BookingId");
        }
    }

    private void getTransactionDetailsData() {
        if (isInternetPresent) {
            myInternalLAY.setVisibility(View.GONE);
            getDetailData();
        } else {
            // mySwipeLAY.setEnabled(true);
            myInternalLAY.setVisibility(View.VISIBLE);
        }
    }

    private void getDetailData() {
        startLoading();
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", myUsedIdStr);
        jsonParams.put("booking_id", myBookingIdStr);

        myRequest.makeServiceRequest(ServiceConstant.TRANSACTION_DETAIL_URL, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

                    @Override
                    public void onCompleteListener(String response) {
                        Log.e("response", response);
                        String sStatus = "";
                        try {
                            JSONObject aObject = new JSONObject(response);
                            sStatus = aObject.getString("status");
                            if (sStatus.equalsIgnoreCase("1")) {
                                JSONObject response_Object = aObject.getJSONObject("response");
                                if (response_Object.length() > 0) {
                                    JSONArray aJobsArray = response_Object.getJSONArray("jobs");
                                    if (aJobsArray.length() > 0) {
                                        JSONObject aArrayObject = aJobsArray.getJSONObject(0);
                                        myBookingIDTXT.setText(aArrayObject.getString("job_id"));
                                        myCategoryNameTXT.setText(aArrayObject.getString("category_name"));
                                        myTotalAmountTXT.setText(myCurrencySymbol + " " + aArrayObject.getString("total_amount"));
                                        myTaskerNameTXT.setText(aArrayObject.getString("user_name"));
                                       // myAddressTXT.setText(aArrayObject.getString("location"));
                                        myTotalHourTXT.setText(aArrayObject.getString("total_hrs"));
                                        lat_address=aArrayObject.getString("lat_provider");
                                        long_address=aArrayObject.getString("lng_provider");
                                        myPerhourTXT.setText(myCurrencySymbol + aArrayObject.getString("per_hour"));
                                        myHourlyRateTXT.setText(myCurrencySymbol + aArrayObject.getString("min_hrly_rate"));
                                        myTaskAmountTXT.setText(myCurrencySymbol + aArrayObject.getString("task_amount"));
                                        myServiceTaxTXT.setText(myCurrencySymbol + aArrayObject.getString("admin_commission"));
                                        myPaymentModeTXT.setText(aArrayObject.getString("payment_mode"));
                                        myBookingTaskTimeTXT.setText(aArrayObject.getString("booking_time"));
                                        String material_fee = aArrayObject.getString("meterial_fee");
                                        if (material_fee.equalsIgnoreCase("")) {
                                            material_fees.setText("---");
                                        } else {
                                            material_fees.setText(myCurrencySymbol + aArrayObject.getString("meterial_fee"));
                                        }
                                        if(!lat_address.equalsIgnoreCase("")&&!long_address.equalsIgnoreCase("")){
                                            Address=getCompleteAddressString(Double.parseDouble(lat_address),Double.parseDouble(long_address));
                                            myAddressTXT.setText(Address);
                                        }else{
                                            myAddressTXT.setText("---");
                                        }
                                    }
                                }
                            } else {
                                myBookingIDTXT.setText("---");
                                myCategoryNameTXT.setText("---");
                                myTaskerNameTXT.setText("---");
                                myAddressTXT.setText("---");
                                myTotalHourTXT.setText("---");
                                myPerhourTXT.setText("---");
                                myHourlyRateTXT.setText("---");
                                myTaskAmountTXT.setText("---");
                                myServiceTaxTXT.setText("---");
                                myTotalAmountTXT.setText("---");
                                myBookingTaskTimeTXT.setText("---");
                                myPaymentModeTXT.setText("---");
                                material_fees.setText("---");
                                String sResponse = aObject.getString("response");
                                alert(getResources().getString(R.string.my_rides_rating_header_sorry_textview), sResponse);
                            }
                            // loadInfoData(myTransactionInfoList);
                            stopLoading();
                        } catch (JSONException e) {
                            stopLoading();
                            e.printStackTrace();
                        }
                    }


                    @Override
                    public void onErrorListener() {
                        stopLoading();
                    }
                }

        );
    }

    private void startLoading() {
        if (myRefreshStr.equalsIgnoreCase("normal")) {
            myLoadingDialog = new PkLoadingDialog(TransactionDetailActivity.this);
            myLoadingDialog.show();
        } else {
            //  mySwipeLAY.setRefreshing(true);
        }
    }

    private void stopLoading() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (myRefreshStr.equalsIgnoreCase("normal")) {
                    myLoadingDialog.dismiss();
                } else {
                    //     mySwipeLAY.setRefreshing(false);
                }
            }
        }, 250);
    }

    private void alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(TransactionDetailActivity.this);
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

    //-------------Method to get Complete Address------------
    private String getCompleteAddressString(double LATITUDE, double LONGITUDE) {
        String strAdd = "";
        String loc_addr="";
        Geocoder geocoder = new Geocoder(TransactionDetailActivity.this, Locale.getDefault());
        try {
            List<android.location.Address> addresses = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addresses != null) {
                Address returnedAddress = addresses.get(0);
                StringBuilder strReturnedAddress = new StringBuilder("");
                loc_addr=returnedAddress.getAddressLine(0);

            } else {
                Log.e("Current loction address", "No Address returned!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("Current loction address", "Canont get Address!");
        }
        return loc_addr;
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {
            onBackPressed();
            finish();
            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);

            return true;
        }
        return false;
    }
}
