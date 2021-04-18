package com.a2zkaj.app;

import android.content.Context;
import android.graphics.Color;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.Pojo.ReviewPojoInfo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.ReviewListAdapter;
import com.a2zkaj.hockeyapp.ActivityHockeyApp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import core.Dialog.PkDialog;
import core.Dialog.PkLoadingDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;

public class ReviewMenuActivity extends ActivityHockeyApp {
    private TextView myHeaderTitleTXT;
    private ImageView myBackIMG;
    private RelativeLayout myBackLAY;
    private boolean isInternetPresent = false;
    private ConnectionDetector myConnectionDetector;
    private Context myContext;
    private RelativeLayout myInternalLAY;
    private PkLoadingDialog myLoadingDialog;
    private SessionManager mySession;
    private String myUserIdStr = "";
    private String myRefreshStr = "normal";
    private ServiceRequest myRequest;
    private ListView myListview;
    private ArrayList<ReviewPojoInfo> myReviewInfoList;
    private TextView myEmptyTXT;
    private SwipeRefreshLayout mySwipeLAY;
    private ReviewListAdapter myAdapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_review_menu);
        initializeHeaderBar();
        classAndWidgetInitialize();
    }

    private void initializeHeaderBar() {


        RelativeLayout headerBar = (RelativeLayout) findViewById(R.id.headerBar_layout);
        myBackLAY = (RelativeLayout) headerBar.findViewById(R.id.headerBar_left_layout);
        myBackIMG = (ImageView) headerBar.findViewById(R.id.headerBar_imageView);
        myHeaderTitleTXT = (TextView) headerBar.findViewById(R.id.headerBar_title_textView);
        myHeaderTitleTXT.setText(getResources().getString(R.string.navigation_label_review));
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
        myContext = ReviewMenuActivity.this;
        myConnectionDetector = new ConnectionDetector(ReviewMenuActivity.this);
        isInternetPresent = myConnectionDetector.isConnectingToInternet();
        mySession = new SessionManager(ReviewMenuActivity.this);
        myRequest = new ServiceRequest(ReviewMenuActivity.this);
        mySwipeLAY = (SwipeRefreshLayout) findViewById(R.id.screen_getreview_LAY_swipe);
        myReviewInfoList = new ArrayList<>();

        myListview = (ListView) findViewById(R.id.screen_reviews_LV);
        myInternalLAY = (RelativeLayout) findViewById(R.id.review_noInternet_layout);
        myEmptyTXT = (TextView) findViewById(R.id.screen_reviews_TXT_empty);
        mySwipeLAY.setColorSchemeColors(Color.GREEN, Color.RED, Color.BLUE);
        mySwipeLAY.setEnabled(true);

        HashMap<String, String> user = mySession.getUserDetails();
        myUserIdStr = user.get(SessionManager.KEY_PROVIDERID);
        getReviewData();
        swipeListener();
    }

    private void swipeListener() {
        mySwipeLAY.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                if (isInternetPresent) {
                    myInternalLAY.setVisibility(View.GONE);
                    myRefreshStr = "swipe";
                    getData();
                } else {
                    mySwipeLAY.setEnabled(true);
                    mySwipeLAY.setRefreshing(false);
                    myInternalLAY.setVisibility(View.VISIBLE);
                }
            }
        });
    }

    private void getReviewData() {
        if (isInternetPresent) {
            myInternalLAY.setVisibility(View.GONE);
            getData();
        } else {
            mySwipeLAY.setEnabled(true);
            myInternalLAY.setVisibility(View.VISIBLE);
        }
    }

    private void getData() {
        startLoading();
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", myUserIdStr);
        jsonParams.put("role", "tasker");

        myRequest.makeServiceRequest(ServiceConstant.REVIEW_URL, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

                    @Override
                    public void onCompleteListener(String response) {
                        Log.e("response", response);
                        String sStatus = "";
                        try {
                            JSONObject aObject = new JSONObject(response);
                            JSONObject aDataObject = aObject.getJSONObject("data");
                            sStatus = aDataObject.getString("status");
                            if (sStatus.equalsIgnoreCase("1")) {
                                JSONObject response_Object = aDataObject.getJSONObject("response");
                                if (response_Object.length() > 0) {
                                    JSONArray aJobsArray = response_Object.getJSONArray("reviews");
                                    if (aJobsArray.length() > 0) {
                                        myReviewInfoList.clear();
                                        for (int i = 0; i < aJobsArray.length(); i++) {
                                            JSONObject aJsonObject = aJobsArray.getJSONObject(i);
                                            ReviewPojoInfo aReviewPojoInfo = new ReviewPojoInfo();
                                            aReviewPojoInfo.setReviewBookingId(aJsonObject.getString("booking_id"));
                                            aReviewPojoInfo.setReviewCategory(aJsonObject.getString("category"));
                                            aReviewPojoInfo.setReviewUser(aJsonObject.getString("user_name"));
                                            aReviewPojoInfo.setUserImage(aJsonObject.getString("user_image"));
                                            aReviewPojoInfo.setReviewImage(aJsonObject.getString("image"));
                                            aReviewPojoInfo.setReviewRating(aJsonObject.getString("rating"));
                                            aReviewPojoInfo.setReviewComments(aJsonObject.getString("comments"));
                                            aReviewPojoInfo.setReviewDate(aJsonObject.getString("date"));
                                            myReviewInfoList.add(aReviewPojoInfo);
                                        }
                                    }
                                }
                            } else {
                                String sResponse = aDataObject.getString("response");
                                alert(getResources().getString(R.string.my_rides_rating_header_sorry_textview), sResponse);
                            }

                            loadInfoData(myReviewInfoList);
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

    private void loadInfoData(final ArrayList<ReviewPojoInfo> aReviewInfoList) {
        if (aReviewInfoList.size() > 0) {
            myEmptyTXT.setVisibility(View.GONE);
            myAdapter = new ReviewListAdapter(myContext, aReviewInfoList);
            myListview.setAdapter(myAdapter);
        } else {
            myEmptyTXT.setVisibility(View.VISIBLE);
        }
    }

    private void startLoading() {
        if (myRefreshStr.equalsIgnoreCase("normal")) {
            myLoadingDialog = new PkLoadingDialog(ReviewMenuActivity.this);
            myLoadingDialog.show();
        } else {
            mySwipeLAY.setRefreshing(true);
        }
    }

    private void stopLoading() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (myRefreshStr.equalsIgnoreCase("normal")) {
                    myLoadingDialog.dismiss();
                } else {
                    mySwipeLAY.setRefreshing(false);
                }
            }
        }, 250);
    }
    //------Alert Method-----

    private void alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(ReviewMenuActivity.this);
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
