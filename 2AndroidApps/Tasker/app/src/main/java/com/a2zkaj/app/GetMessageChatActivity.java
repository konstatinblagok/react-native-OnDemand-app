package com.a2zkaj.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.Pojo.MessageChatPojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.HideSoftKeyboard;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.GetMessageListAdapter;
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
import core.socket.ChatMessageService;

/**
 * Created by CAS61 on 12/30/2016.
 */
public class GetMessageChatActivity extends ActivityHockeyApp implements View.OnClickListener {
    private Context context;
    private ImageView myBackIMG;
    private ListView myListview;
    private ServiceRequest myRequest;
    private SessionManager mySession;
    private String myUserIdStr;
    private ArrayList<MessageChatPojo> myInfoList;
    private GetMessageListAdapter myAdapter;
    private ConnectionDetector myConnectionDetector;
    private boolean isInternetPresent = false;
    private SwipeRefreshLayout mySwipeLAY;
    private RelativeLayout myInternalLAY;
    private PkLoadingDialog myLoadingDialog;
    private String Str_Refresh_Name = "normal";
    private TextView myEmptyTXT;
    public static String Str_Userid = "";
    public static String mTaskID;

    private class Receiver extends BroadcastReceiver {


        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equalsIgnoreCase("com.refresh.message")) {
                if (isInternetPresent) {
                    getData();
                }

            }
        }
    }

    private Receiver receive;

    @Override

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.screen_getmessage);
        context = GetMessageChatActivity.this;
        initializeHeaderBar();
        classAndWidgetInitialize();
        clickListener();

    }

    private void classAndWidgetInitialize() {
        mySession = new SessionManager(GetMessageChatActivity.this);
        myRequest = new ServiceRequest(GetMessageChatActivity.this);
        myConnectionDetector = new ConnectionDetector(GetMessageChatActivity.this);
        isInternetPresent = myConnectionDetector.isConnectingToInternet();
        myInfoList = new ArrayList<>();
        myListview = (ListView) findViewById(R.id.screen_getmessage_LV);
        mySwipeLAY = (SwipeRefreshLayout) findViewById(R.id.screen_getmessage_LAY_swipe);
        myInternalLAY = (RelativeLayout) findViewById(R.id.myJobs_noInternet_layout);
        myEmptyTXT = (TextView) findViewById(R.id.screen_getmessage_TXT_empty);

        HashMap<String, String> user = mySession.getUserDetails();
        myUserIdStr = user.get(SessionManager.KEY_PROVIDERID);

        mySwipeLAY.setColorSchemeColors(Color.GREEN, Color.RED, Color.BLUE);
        mySwipeLAY.setEnabled(true);
        getMessageData();
        swipeListener();
    }

    private void swipeListener() {
        mySwipeLAY.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                if (isInternetPresent) {
                    //        Rl_Main.setVisibility(View.VISIBLE);
                    myInternalLAY.setVisibility(View.GONE);
                    Str_Refresh_Name = "swipe";
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

    private void getMessageData() {
        if (isInternetPresent) {
            myInternalLAY.setVisibility(View.GONE);
            getData();
        } else {
            mySwipeLAY.setEnabled(true);
            myInternalLAY.setVisibility(View.VISIBLE);
        }
    }

    private void loadInfoData(final ArrayList<MessageChatPojo> aInfoList) {
        if (aInfoList.size() > 0) {
            myEmptyTXT.setVisibility(View.GONE);
            myAdapter = new GetMessageListAdapter(context, aInfoList);
            myListview.setAdapter(myAdapter);
            myListview.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                @Override
                public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                    ChatMessageService.user_id="";
                    ChatMessageService.task_id="";
                    Intent intent = new Intent(context, ChatPage.class);
                    intent.putExtra("chatpage", true);
                    intent.putExtra("JOBID", aInfoList.get(position).getMessageBookingId());
                    intent.putExtra("TaskerId", aInfoList.get(position).getMessageUserId());
                    intent.putExtra("TaskId", aInfoList.get(position).getMessageTaskId());
                    context.startActivity(intent);
                }
            });
        } else {
            myEmptyTXT.setVisibility(View.VISIBLE);
        }
    }

    private void initializeHeaderBar() {

        myBackIMG = (ImageView) findViewById(R.id.screen_getmessage_IMG_back);
        myBackIMG.setImageResource(R.drawable.back_arrow);
        receive = new Receiver();
        IntentFilter intentfilter = new IntentFilter();
        intentfilter.addAction("com.refresh.message");
        registerReceiver(receive, intentfilter);
    }

    private void clickListener() {
        myBackIMG.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.screen_getmessage_IMG_back:
                HideSoftKeyboard.hideSoftKeyboard(GetMessageChatActivity.this);
                onBackPressed();
                finish();
                overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
                break;
        }
    }

    private void getData() {
        startLoading();
        Log.e("userid", myUserIdStr);
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("userId", myUserIdStr);
        jsonParams.put("type", "0");


        myRequest.makeServiceRequest(ServiceConstant.GETMESSAGECHAT_URL, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

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
                                    JSONArray aMessageArray = response_Object.getJSONArray("message");
                                    if (aMessageArray.length() > 0) {
                                        myInfoList.clear();
                                        for (int i = 0; i < aMessageArray.length(); i++) {
                                            JSONObject aJsonObject = aMessageArray.getJSONObject(i);
                                            MessageChatPojo aMessageInfo = new MessageChatPojo();
                                            aMessageInfo.setMessageTaskId(aJsonObject.getString("task_id"));
                                            aMessageInfo.setMessageBookingId(aJsonObject.getString("booking_id"));
                                            aMessageInfo.setMessageUserNameId(aJsonObject.getString("user_name"));
                                            aMessageInfo.setMessageUserId(aJsonObject.getString("user_id"));
                                            aMessageInfo.setMessageUserImageId(aJsonObject.getString("user_image"));
                                            aMessageInfo.setCategory(aJsonObject.getString("category"));
                                            aMessageInfo.setstatus(aJsonObject.getString("tasker_status"));
                                            aMessageInfo.setdate(aJsonObject.getString("created"));
                                            myInfoList.add(aMessageInfo);
                                        }
                                    }
                                }
                            } else {
                                String sResponse = aObject.getString("response");
                                alert(getResources().getString(R.string.my_rides_rating_header_sorry_textview), sResponse);
                            }

                            loadInfoData(myInfoList);
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
        if (Str_Refresh_Name.equalsIgnoreCase("normal")) {
            myLoadingDialog = new PkLoadingDialog(GetMessageChatActivity.this);
            myLoadingDialog.show();
        } else {
            mySwipeLAY.setRefreshing(true);
        }
    }

    private void stopLoading() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                if (Str_Refresh_Name.equalsIgnoreCase("normal")) {
                    myLoadingDialog.dismiss();
                } else {
                    mySwipeLAY.setRefreshing(false);
                }
            }
        }, 250);
    }

    //------Alert Method-----

    private void alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(GetMessageChatActivity.this);
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
