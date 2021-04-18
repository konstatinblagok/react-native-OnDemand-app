package com.a2zkaj.app;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.ExpandableListView;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.Pojo.NotificationMessageInfo;
import com.a2zkaj.Pojo.NotificationPojoInfo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.NotificationExpandListAdapter;
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

public class NotificationMenuActivity extends ActivityHockeyApp {
    private Context myContext;
    private TextView myHeaderTitleTXT;
    private ImageView myBackIMG;
    private RelativeLayout myBackLAY;
    private boolean isInternetPresent = false;
    private ConnectionDetector myConnectionDetector;
    private SessionManager mySession;
    private PkLoadingDialog myLoadingDialog;
    private ServiceRequest myRequest;
    private RelativeLayout myInternalLAY;
    private TextView myEmptyTXT;
    private SwipeRefreshLayout mySwipeLAY;
    private String myRefreshStr = "normal";
    private ArrayList<NotificationPojoInfo> myNotificationInfoList = null;
    private String myProviderIdStr = "";
    private NotificationExpandListAdapter myAdapter;
    private ExpandableListView myEXPLV;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_notification_menu);
        initializeHeaderBar();
        classAndWidgetInitialize();
    }

    private void initializeHeaderBar() {
        RelativeLayout headerBar = (RelativeLayout) findViewById(R.id.headerBar_layout);
        myBackLAY = (RelativeLayout) headerBar.findViewById(R.id.headerBar_left_layout);
        myBackIMG = (ImageView) headerBar.findViewById(R.id.headerBar_imageView);
        myHeaderTitleTXT = (TextView) headerBar.findViewById(R.id.headerBar_title_textView);
        myHeaderTitleTXT.setText(getResources().getString(R.string.navigation_label_notification));
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
        myNotificationInfoList = new ArrayList<>();
        myConnectionDetector = new ConnectionDetector(NotificationMenuActivity.this);
        mySession = new SessionManager(NotificationMenuActivity.this);
        myRequest = new ServiceRequest(NotificationMenuActivity.this);
        isInternetPresent = myConnectionDetector.isConnectingToInternet();
        myEmptyTXT = (TextView) findViewById(R.id.screen_notification_TXT_empty);
        myInternalLAY = (RelativeLayout) findViewById(R.id.notification_noInternet_layout);
        mySwipeLAY = (SwipeRefreshLayout) findViewById(R.id.screen_notification_LAY_swipe);
        myEXPLV = (ExpandableListView) findViewById(R.id.screen_notification_EXPLV);

        mySwipeLAY.setColorSchemeColors(Color.GREEN, Color.RED, Color.BLUE);
        mySwipeLAY.setEnabled(true);
        HashMap<String, String> provider = mySession.getUserDetails();
        myProviderIdStr = provider.get(SessionManager.KEY_PROVIDERID);

        getNotificationData();
        swipeListener();
    }

    private void swipeListener() {
        mySwipeLAY.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                if (isInternetPresent) {
                    //        Rl_Main.setVisibility(View.VISIBLE);
                    myInternalLAY.setVisibility(View.GONE);
                    myRefreshStr = "swipe";
                    getData();
                } else {
                    mySwipeLAY.setEnabled(true);
                    mySwipeLAY.setRefreshing(false);
                    // Rl_Main.setVisibility(View.GONE);
                    myInternalLAY.setVisibility(View.VISIBLE);
                }
            }
        });
    }

    private void getNotificationData() {
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
        jsonParams.put("user_id", myProviderIdStr);
        jsonParams.put("role", "tasker");

        myRequest.makeServiceRequest(ServiceConstant.NOTIFICATION_URL, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

                    @Override
                    public void onCompleteListener(String response) {
                        Log.e("response", response);
                        String sStatus = "";
                        try {
                            JSONObject aObject = new JSONObject(response);
                            Log.e("notification_url",aObject.toString(1));
                            sStatus = aObject.getString("status");
                            if (sStatus.equalsIgnoreCase("1")) {
                                myNotificationInfoList.clear();
                                JSONArray aResponseArray = aObject.getJSONArray("response");
                                if (aResponseArray.length() > 0) {
                                    for (int i = 0; i < aResponseArray.length(); i++) {
                                        ArrayList<NotificationMessageInfo> myNotificationMessageInfoList = new ArrayList<NotificationMessageInfo>();
                                        JSONObject aResponseObject = aResponseArray.getJSONObject(i);
                                        NotificationPojoInfo aNotificationInfo = new NotificationPojoInfo();
                                        //aNotificationInfo.setNotificationTaskId(aResponseObject.getString("task"));
                                        aNotificationInfo.setNotificationBookingId(aResponseObject.getString("booking_id"));
                                        aNotificationInfo.setNotificationCategory(aResponseObject.getString("category"));

                                        if (aResponseObject.has("messages")) {
                                            JSONArray aMessageArrayInfo = aResponseObject.getJSONArray("messages");
                                            for (int j = 0; j < aMessageArrayInfo.length(); j++) {
                                                JSONObject aMessageResponseObject = aMessageArrayInfo.getJSONObject(j);
                                                NotificationMessageInfo aNotificationMessageInfo = new NotificationMessageInfo();
                                                aNotificationMessageInfo.setNotificationMessageCreatedAt(aMessageResponseObject.getString("createdAt"));
                                                aNotificationMessageInfo.setNotificationMessage(aMessageResponseObject.getString("message"));
                                                myNotificationMessageInfoList.add(aNotificationMessageInfo);
                                            }
                                        }
                                        aNotificationInfo.setNotificationMessageInfo(myNotificationMessageInfoList);
                                        myNotificationInfoList.add(aNotificationInfo);
                                    }
                                }
                            } else {
                                String sResponse = aObject.getString("response");
                                alert(getResources().getString(R.string.my_rides_rating_header_sorry_textview), sResponse);
                            }

                            loadInfoData(myNotificationInfoList);
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

    private void loadInfoData(final ArrayList<NotificationPojoInfo> aNotificationList) {

        if (aNotificationList.size() > 0) {
            myEmptyTXT.setVisibility(View.GONE);
            myAdapter = new NotificationExpandListAdapter(NotificationMenuActivity.this, aNotificationList);
            myEXPLV.setAdapter(myAdapter);

            myEXPLV.setOnGroupExpandListener(new ExpandableListView.OnGroupExpandListener() {
                int previousGroup = -1;

                @Override
                public void onGroupExpand(int groupPosition) {
                    if (groupPosition != previousGroup)
                        myEXPLV.collapseGroup(previousGroup);
                    previousGroup = groupPosition;
                }
            });
        } else {
            myEmptyTXT.setVisibility(View.VISIBLE);
        }
    }

    private void startLoading() {
        if (myRefreshStr.equalsIgnoreCase("normal")) {
            myLoadingDialog = new PkLoadingDialog(NotificationMenuActivity.this);
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
        final PkDialog mDialog = new PkDialog(NotificationMenuActivity.this);
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
