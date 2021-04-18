package com.a2zkaj.app;

import android.app.Activity;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.res.AssetFileDescriptor;
import android.graphics.Color;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.eyalbira.loadingdots.LoadingDots;
import com.a2zkaj.Pojo.ChatPojo;
import com.a2zkaj.Pojo.ReceiveMessageEvent;
import com.a2zkaj.Pojo.SendMessageEvent;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.HideSoftKeyboard;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.Utils.TouchImageView;
import com.a2zkaj.adapter.ChatAdapter;
import com.a2zkaj.hockeyapp.ActivityHockeyApp;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import org.greenrobot.eventbus.EventBus;
import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.Widgets.RoundedImageView;
import core.service.ServiceConstant;
import core.socket.ChatMessageService;
import core.socket.ChatMessageSocketManager;
import core.socket.SocketHandler;
import core.socket.SocketManager;

/**
 */
public class ChatPage extends ActivityHockeyApp implements View.OnClickListener {
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    SessionManager sessionManager;
    public static Context mContext;

    private RelativeLayout Rl_back;
    private TextView Tv_senderName;
    private static TextView Tv_status;
    private RoundedImageView Iv_senderImage;
    private ImageView refreshIcon;
    public static JSONObject message;

    public static ListView listView;
    private EditText Et_message;
    private ImageView Iv_send;
    private RelativeLayout Rl_ActiveChat, Rl_deActiveChat;
    private String sSenderName = "", sSenderID = "", sSenderImage = "";
    private static String sReceiverStatus = "online";
    private String sChatStatus = "open";
    private String sJobID = "";
    private String sToID = "";
    public static String sTaskerID = "", mTaskID = "";
    public static String mTaskerID = "";
    private String Str_UserId = "";
    private ServiceRequest mRequest;
    private LoadingDialog mLoadingDialog;
    public static String mUserID;

    public static String Chat_Id = "";
    public static String task_id = "";
    String userid = "";
    public static MediaPlayer mediaPlayer;
    public static boolean isChatPageAvailable;
    public static ChatAdapter adapter;
    public static ArrayList<ChatPojo> chatList;
    SimpleDateFormat df_time = new SimpleDateFormat("hh:mm a");
    private String providerID = "new message";

    private boolean isDataAvailable = false, isSenderAvailable = false, isReceiverAvailable = false, isChatAvailable = false;
    boolean chatvalue;
    private SocketHandler socketHandler;
    static SocketManager smanager;
    public static String data = "";
    public static String fromID = "";
    public static String updatedAt = "";
    public static String jsonUSER = "";
    public static String msgid = "";
    public static String send_msg_id = "";
    public static String task = "";
    public static String tasker = "", aUserStatusStr = "";
    public static String msgstatus = "";
    public static Activity myChatPages;
    private Receiver receive;
    public static String chat_msg_id = "";
    public static Activity chat_activity;
    public static String server_date="";
    public static LoadingDots dots;
    public class Receiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equalsIgnoreCase("com.avail.finish")) {
                finish();
            }
        }
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_page);
        mContext = ChatPage.this;
        myChatPages = ChatPage.this;
        ChatPage.isChatPageAvailable = true;
        sessionManager = new SessionManager(ChatPage.this);
        chat_activity = ChatPage.this;
        mediaPlayer = MediaPlayer.create(this,R.raw.solemn);
        try {
            AssetFileDescriptor descriptor = getAssets().openFd("tone.mp3");
            mediaPlayer.setDataSource(descriptor.getFileDescriptor(), descriptor.getStartOffset(), descriptor.getLength());
            descriptor.close();
        } catch (Exception e) {
        }


        initialize();
        Rl_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (isInternetPresent) {
                    postRequest_ChatDetail(ServiceConstant.chat_detail_url);
                }
                Intent s = new Intent();
                s.setAction("com.refresh.message");
                sendBroadcast(s);
                Intent i = new Intent();
                i.setAction("com.refresh.jobpage");
                sendBroadcast(i);
                HideSoftKeyboard.hideSoftKeyboard(ChatPage.this);
                ChatPage.isChatPageAvailable = false;
                Chat_Id = "";
                task_id = "";
                finish();
            }
        });

        Iv_send.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                String data = Et_message.getText().toString();
                try {
                    JSONObject object = new JSONObject();
                    object.put("tasker", mUserID);
                    object.put("user", mTaskerID);
                    object.put("message", data);
                    object.put("task", mTaskID);
                    object.put("from", mUserID);

                    System.out.println("tasker------" + mUserID);
                    System.out.println("user------" + mTaskerID);
                    System.out.println("message------" + data);
                    System.out.println("task------" + mTaskID);
                    System.out.println("from------" + mUserID);
                    SendMessageEvent sendMessageEvent = new SendMessageEvent();
                    sendMessageEvent.setEventName(ChatMessageSocketManager.EVENT_NEW_MESSAGE);
                    sendMessageEvent.setMessageObject(object);
                    EventBus.getDefault().post(sendMessageEvent);


                } catch (JSONException e) {
                    e.printStackTrace();
                }
                //Et_message.getText().clear();
				
				Et_message.setText("");

            }
        });

    }

    public void loadChatHistory() {
        chatList.clear();
        String url = ServiceConstant.BASE_URL + "chat/chathistory";
        mRequest = new ServiceRequest(ChatPage.this);
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("tasker", mUserID);
        jsonParams.put("user", mTaskerID);
        jsonParams.put("task", mTaskID);
        jsonParams.put("read_status", "tasker");
        jsonParams.put("type", "tasker");

        mRequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                try {
                    JSONObject responseObject = new JSONObject(response);
                    JSONArray arrayObject = responseObject.getJSONArray("messages");
                    for (int i = 0; i < arrayObject.length(); i++) {
                        JSONObject msgObject = (JSONObject) arrayObject.get(i);
                        String fromID = msgObject.getString("from");
                        String data = msgObject.getString("message");
                        ChatPojo pojo = new ChatPojo();
                        pojo.setMessage(data);
                        pojo.setDate(msgObject.getString("date"));
                        if (fromID != null && fromID.equalsIgnoreCase(mUserID)) {
                            pojo.setType("SELF");
                            pojo.setSeenstatus(msgObject.getString("user_status"));
                        } else {
                            pojo.setType("OTHER");
                        }
                        pojo.setTime("");
                        chatList.add(pojo);
                    }
                } catch (Exception e) {
                }
                adapter.notifyDataSetChanged();
            }

            @Override
            public void onErrorListener() {

            }
        });


    }


    //-----------------------------------------------------------Receive Chat Via Socket Bus------------------------------------------


    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onMessageEvent(ReceiveMessageEvent event) {

        String eventName = event.getEventName();

        switch (eventName) {

            case ChatMessageSocketManager.EVENT_UPDATE_CHAT:
                addOtherMessage(event.getObjectsArray());
                break;

            case ChatMessageSocketManager.EVENT_TYPING:
                Tv_status.setText(getResources().getString(R.string.chat_page_label_typing_without_dots));
                dots.setVisibility(View.VISIBLE);
                break;
            case ChatMessageSocketManager.EVENT_STOP_TYPING:
                Tv_status.setText("");
                dots.setVisibility(View.GONE);
                break;

            case ChatMessageSocketManager.EVENT_SINGLE_MESSAGE_STATUS:
                addOtherMessage(event.getObjectsArray());
                break;
        }
    }

    public static String uAt = new String();

    public static void addOtherMessage(Object[] response) {

        ChatPojo pojo = new ChatPojo();
        try {

            JSONObject object = new JSONObject(response[0].toString());
            jsonUSER = object.getString("user");
            task = object.getString("task");
            tasker = object.getString("tasker");
            if (object.has("messages")) {
                JSONArray messagesArray = object.getJSONArray("messages");
                message = (JSONObject) messagesArray.get(0);
                data = (String) message.getString("message");
                fromID = message.getString("from");
                msgid = (String) message.getString("_id");
                msgstatus = "normal";
                server_date=message.getString("date");
            } else {
                JSONArray message_array = object.getJSONArray("message");
                JSONObject message_obj = message_array.getJSONObject(0);

                aUserStatusStr = message_obj.getString("user_status");
                msgstatus = message_obj.getString("status");
                pojo.setSeenstatus(message_obj.getString("user_status"));
                pojo.setDate(getCurrentDateTime());
                pojo.setMessage(message_obj.getString("message"));
                // chatList.get(chatList.size() - 1).setSeenstatus(object.getString("user_status"));
                for (int i = 0; i < chatList.size(); i++) {
                    chatList.get(i).setSeenstatus("2");
                }
                adapter.notifyDataSetChanged();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }


        if (mUserID.equalsIgnoreCase(fromID)) {
            pojo.setType("SELF");
            if (!msgid.equalsIgnoreCase(send_msg_id)) {
                pojo.setDate(server_date);
                pojo.setSeenstatus("1");
                pojo.setMessage(data);
                chatList.add(pojo);
                send_msg_id = msgid;
                adapter.notifyDataSetChanged();
            }

        } else if (mUserID.equalsIgnoreCase(jsonUSER)) {
            pojo.setType("TYPING");
        } else if (data.equalsIgnoreCase("")) {
            pojo.setType("TYPING");
        } else {
            pojo.setMessage(data);
            pojo.setType("OTHER");
            //pojo.setDate(getCurrentDateTime());
            pojo.setDate(server_date);
            if (isChatPageAvailable) {
                sendSingleMessageStatus();
            }
            if (mediaPlayer != null) {
                if (!mediaPlayer.isPlaying()) {
                    mediaPlayer.start();
                }
            }
            pojo.setTime("");
            if (!pojo.getType().equalsIgnoreCase("TYPING") && Chat_Id.equalsIgnoreCase(jsonUSER) && !pojo.getType().equalsIgnoreCase("SELF") &&
                    task_id.equalsIgnoreCase(task) && !msgstatus.equalsIgnoreCase("resume") && !chat_msg_id.equalsIgnoreCase(msgid)) {
                try {
                    chat_msg_id = (String) message.getString("_id");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                chatList.add(pojo);
                adapter.notifyDataSetChanged();
            }

           // adapter.notifyDataSetChanged();
            listView.post(new Runnable() {
                @Override
                public void run() {
                    // Select the last row so it will scroll into view...
                    listView.setSelection(adapter.getCount() - 1);
                }
            });
        }


    }


    private void sendMessageStatus() {
        try {

            JSONArray jArray = new JSONArray();
            JSONObject finalObj = new JSONObject();


            JSONObject aObject = new JSONObject();
            aObject.put("user", mTaskerID);
            aObject.put("tasker", mUserID);
            aObject.put("task", mTaskID);
            aObject.put("type", "user");

            finalObj.put("message status",aObject);
            jArray.put(finalObj);

            SendMessageEvent event = new SendMessageEvent();
            event.setEventName(ChatMessageSocketManager.EVENT_MESSAGE_STATUS);
            event.setMessageObject(jArray);

            EventBus.getDefault().post(event);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    public static void sendSingleMessageStatus() {
        try {
            JSONArray jArray = new JSONArray();
            JSONObject finalObj = new JSONObject();

            JSONObject aObject = new JSONObject();
            aObject.put("currentuserid", mUserID);
            aObject.put("_id", msgid);
            aObject.put("from", fromID);
            aObject.put("status", "normal");
            aObject.put("tasker_status", "2");
            aObject.put("message", data);

            jArray.put(aObject);
            finalObj.put("user", mTaskerID);
            finalObj.put("tasker", mUserID);
            finalObj.put("task", mTaskID);
            finalObj.put("usertype", "tasker");
            finalObj.put("message" , jArray);

            SendMessageEvent event = new SendMessageEvent();
            event.setEventName(ChatMessageSocketManager.EVENT_SINGLE_MESSAGE_STATUS);
            event.setMessageObject(finalObj);
            EventBus.getDefault().post(event);

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public static void sendSingleMessageStatus1() {
        try {
            JSONArray jArray = new JSONArray();
            JSONObject finalObj = new JSONObject();

            JSONObject aObject = new JSONObject();
            aObject.put("currentuserid", Chat_Id);
            aObject.put("_id", msgid);
            aObject.put("status", "resume");
            aObject.put("from", fromID);
            aObject.put("tasker_status", "2");
            aObject.put("message", data);

            jArray.put(aObject);
            finalObj.put("user", mTaskerID);
            finalObj.put("tasker", mUserID);
            finalObj.put("task", mTaskID);
            finalObj.put("usertype", "tasker");
            finalObj.put("message" , jArray);

            SendMessageEvent event = new SendMessageEvent();
            event.setEventName(ChatMessageSocketManager.EVENT_SINGLE_MESSAGE_STATUS);
            event.setMessageObject(finalObj);
            EventBus.getDefault().post(event);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    /**
     * Method for get the current date and Time
     *
     * @return
     */
    public static String getCurrentDateTime() {
        String aCurrentDateStr = "";
        try {
            Calendar c = Calendar.getInstance();
            SimpleDateFormat df = new SimpleDateFormat("MM/dd/yyyy, hh:mm a");
            aCurrentDateStr = df.format(c.getTime());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return aCurrentDateStr;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.chatPage_header_senderImage:
                showProfileImgInDialog();
                break;
        }
    }

    /**
     * Method for show the profile image in the dialog
     */
    private void showProfileImgInDialog() {
        try {
            Dialog aDialog = new Dialog(this);
            aDialog.getWindow().requestFeature(Window.FEATURE_NO_TITLE);
            aDialog.setContentView(getLayoutInflater().inflate(R.layout.appointment_profile_imageview
                    , null));
            TouchImageView aProfileIMG = (TouchImageView) aDialog.findViewById(R.id.appointment_profile_imageview_IMG);
            Picasso.with(ChatPage.this).load(sSenderImage).error(R.drawable.placeholder_icon)
                    .placeholder(R.drawable.placeholder_icon).memoryPolicy(MemoryPolicy.NO_CACHE).into(aProfileIMG);
            aDialog.show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void updateChat(String data, String fromID) {
        if (mUserID.equalsIgnoreCase(fromID)) {
            //          pojo.setType("SELF");
        } else {
            ChatPojo pojo = new ChatPojo();
            pojo.setMessage(data);
            pojo.setType("OTHER");
            if (mediaPlayer != null) {
                if (!mediaPlayer.isPlaying()) {
                    //mediaPlayer.start();
                }
            }
            pojo.setTime("");
            chatList.add(pojo);
            adapter.notifyDataSetChanged();


        }
    }


    private void initialize() {
        cd = new ConnectionDetector(ChatPage.this);
        // ChatSocketService.disconnect();

        isInternetPresent = cd.isConnectingToInternet();
        socketHandler = SocketHandler.getInstance(ChatPage.this);
        chatList = new ArrayList<ChatPojo>();
        Rl_back = (RelativeLayout) findViewById(R.id.chatPage_headerBar_back_layout);
        Tv_status = (TextView) findViewById(R.id.chatPage_headerBar_senderName_textView);
        Iv_senderImage = (RoundedImageView) findViewById(R.id.chatPage_header_senderImage);
        listView = (ListView) findViewById(R.id.chatPage_listView);
        Et_message = (EditText) findViewById(R.id.chatPage_message_editText);
        Iv_send = (ImageView) findViewById(R.id.chatPage_send_imageView);
        Tv_senderName = (TextView) findViewById(R.id.chatPage_headerBar_senderName_status);
        Rl_ActiveChat = (RelativeLayout) findViewById(R.id.chatPage_bottom_layout);
        Rl_deActiveChat = (RelativeLayout) findViewById(R.id.chatPage_noChat_layout);
        refreshIcon = (ImageView) findViewById(R.id.refresh_img);
        dots=(LoadingDots)findViewById(R.id.dots);

        Et_message.addTextChangedListener(chatEditorWatcher);

        // get user data from session
        HashMap<String, String> user = sessionManager.getUserDetails();
        mUserID = user.get(SessionManager.KEY_PROVIDERID);

        Intent intent = getIntent();
        if (intent != null) {

            mTaskerID = ChatMessageService.user_id;
            mTaskID = ChatMessageService.task_id;
            if (mTaskerID.equalsIgnoreCase("")) {
                if (intent.getStringExtra("TaskerId") != null && intent.getStringExtra("TaskId") != null) {
                    mTaskerID = intent.getStringExtra("TaskerId");
                    mTaskID = intent.getStringExtra("TaskId");
                }
            }

            sessionManager.setchatuserid(mTaskerID);
            sessionManager.settaskid(mTaskID);

            HashMap<String, String> chatid = sessionManager.getUserDetails();
            Chat_Id = chatid.get(SessionManager.KEY_Chat_userid);
            HashMap<String, String> taskids = sessionManager.getUserDetails();
            task_id = taskids.get(SessionManager.KEY_Task_id);

            if (isInternetPresent) {
                postRequest_ChatDetail(ServiceConstant.chat_detail_url);
            } else {
                alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
            }
        }
        adapter = new ChatAdapter(ChatPage.this, chatList);
        listView.setAdapter(adapter);
        clickListener();

        receive = new Receiver();
        IntentFilter intentfilter = new IntentFilter();
        intentfilter.addAction("com.chat.refresh");
        intentfilter.addAction("com.chat.refresh.typing");
        intentfilter.addAction("com.chat.message.send");
        intentfilter.addAction("com.avail.finish");
        registerReceiver(receive, intentfilter);
    }

    private void clickListener() {
        Iv_senderImage.setOnClickListener(this);
    }


    //--------Alert Method------
    private void alert(String title, String alert) {

        final PkDialog mDialog = new PkDialog(ChatPage.this);
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


    //---Scroll ListView to bottom---
    private static void scrollMyListViewToBottom() {
        listView.post(new Runnable() {
            @Override
            public void run() {
                // Select the last row so it will scroll into view...
                if (adapter.getCount() > 2)
                    listView.setSelection(adapter.getCount() - 1);
            }
        });
    }


    //-----------Code for TextWatcher----------
    private TextWatcher chatEditorWatcher = new TextWatcher() {
        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {
        }

        @Override
        public void afterTextChanged(Editable s) {

            String messages = Et_message.getText().toString();
            String message = messages.trim();

            if (message.length() == 0) {
                Iv_send.setImageResource(R.drawable.send_icon_dim);
                Iv_send.setEnabled(false);
            } else {
                Iv_send.setImageResource(R.drawable.send_icon_dark);
                Iv_send.setEnabled(true);
            }
            if (Et_message.getText().toString().length() > 0) {
                showTyping();
            } else {
                hideTyping();
            }

        }
    };


    //----Show typing text----
    private void showTyping() {
        try {
            JSONObject object = new JSONObject();
            object.put("tasker", mUserID);
            object.put("user", mTaskerID);

            object.put("task", mTaskID);
            object.put("from", mUserID);
            object.put("to", mTaskerID);
            SendMessageEvent event = new SendMessageEvent();
            event.setEventName(ChatMessageSocketManager.EVENT_TYPING);
            event.setMessageObject(object);

            EventBus.getDefault().post(event);
        } catch (JSONException e) {
            e.printStackTrace();
        }


    }


    //----Hide typing text----
    private void hideTyping() {
        try {
            JSONObject object = new JSONObject();
            object.put("tasker", mUserID);
            object.put("user", mTaskerID);

            object.put("task", mTaskID);
            object.put("from", mUserID);
            object.put("to", mTaskerID);
            SendMessageEvent event = new SendMessageEvent();
            event.setEventName(ChatMessageSocketManager.EVENT_STOP_TYPING);
            event.setMessageObject(object);

            EventBus.getDefault().post(event);

        } catch (JSONException e) {
            e.printStackTrace();
        }

    }


    //-----------------------Chat Detail Post Request-----------------
    private void postRequest_ChatDetail(String Url) {

        mLoadingDialog = new LoadingDialog(ChatPage.this);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        mLoadingDialog.show();
        System.out.println("-------------Chat Detail Url----------------" + Url);
        System.out.println("-----------id------------" + sTaskerID);
        System.out.println("-----------job_id------------" + sJobID);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user", mTaskerID);
        jsonParams.put("tasker", mUserID);
        jsonParams.put("task", mTaskID);
        jsonParams.put("type", "tasker");
        jsonParams.put("read_status", "tasker");

        mRequest = new ServiceRequest(ChatPage.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("------------Chat Detail Response----------------" + response);
                String sStatus = "";
                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    if (sStatus.equalsIgnoreCase("1")) {

                        Object check_response_object = object.get("user");
                        if (check_response_object instanceof JSONObject) {
                            JSONObject response_object = object.getJSONObject("user");
                            if (response_object.length() > 0) {
                                //Object check_receiver_object = response_object.get("user");
                                //if (check_receiver_object instanceof JSONObject) {
                                //   JSONObject receiver_object = response_object.getJSONObject("user");
                                // if (receiver_object.length() > 0) {
                                sSenderID = response_object.getString("_id");
                                sSenderName = response_object.getString("username");
                                sSenderImage = response_object.getString("avatar");

                                isReceiverAvailable = true;
                                isChatAvailable = true;
                                isDataAvailable = true;
                            } else {
                                isReceiverAvailable = false;
                                isChatAvailable = false;
                                isDataAvailable = false;
                            }
//                                } else {
//                                    isReceiverAvailable = false;
//                                    isChatAvailable = false;
//                                    isDataAvailable = false;
//                                }


//                                Object check_chat_object = response_object.get("chat");
//                                if (check_chat_object instanceof JSONObject) {
//                                    JSONObject chat_object = response_object.getJSONObject("chat");
//
//                                    if (chat_object.length() > 0) {
//                                        sReceiverStatus = chat_object.getString("receiver_status");
//                                        sChatStatus = chat_object.getString("chat_status");
//
//                                        isChatAvailable = true;
//                                    } else {
//                                        isChatAvailable = false;
//                                    }
//                                } else {
//                                    isChatAvailable = false;
//                                }
//                                isDataAvailable = true;
//                            } else {
//                                isDataAvailable = false;
//                            }
                        } else {
                            isDataAvailable = false;
                        }
                    }
                    if (sStatus.equalsIgnoreCase("1")) {
                        if (isDataAvailable) {
                            if (isChatAvailable) {
                                if (sReceiverStatus.equalsIgnoreCase("online") && sChatStatus.equalsIgnoreCase("open")) {
                                    Rl_ActiveChat.setVisibility(View.VISIBLE);
                                    Rl_deActiveChat.setVisibility(View.GONE);
                                    Tv_status.setText("");
                                    Tv_status.setTextColor(Color.parseColor("#FFFFFF"));
                                    Tv_status.setVisibility(View.VISIBLE);
                                } else {
                                    Rl_ActiveChat.setVisibility(View.GONE);
                                    Rl_deActiveChat.setVisibility(View.VISIBLE);
                                    Tv_status.setText(getResources().getString(R.string.chat_page_label_offline));
                                    Tv_status.setTextColor(Color.parseColor("#C5C5C5"));
                                    Tv_status.setVisibility(View.VISIBLE);
                                }

                                if (isReceiverAvailable) {
                                    sToID = sSenderID + "@" + ServiceConstant.XMPP_SERVICE_NAME;
                                    Tv_senderName.setText(sSenderName);
                                    Picasso.with(ChatPage.this).load(sSenderImage).error(R.drawable.placeholder_icon)
                                            .placeholder(R.drawable.placeholder_icon).memoryPolicy(MemoryPolicy.NO_CACHE).into(Iv_senderImage);
                                } else {
                                    final PkDialog mDialog = new PkDialog(ChatPage.this);
                                    mDialog.setDialogTitle(getResources().getString(R.string.my_rides_rating_header_sorry_textview));
                                    mDialog.setDialogMessage(getResources().getString(R.string.chat_page_label_server_error));
                                    mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                                        @Override
                                        public void onClick(View v) {
                                            mDialog.dismiss();
                                            onBackPressed();
                                            finish();
                                            overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
                                        }
                                    });
                                    mDialog.show();
                                }
                            }
                        }
                    } else {
                    }
                } catch (JSONException e) {
                    mLoadingDialog.dismiss();
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
    protected void onStart() {
        super.onStart();
        EventBus.getDefault().register(ChatPage.this);
        ChatPage.isChatPageAvailable = true;
    }

    @Override
    protected void onStop() {
        super.onStop();
        EventBus.getDefault().unregister(ChatPage.this);
        ChatPage.isChatPageAvailable = false;
    }

    @Override
    protected void onResume() {
        try {
            if (!ChatMessageService.isStarted()) {
                Intent intent = new Intent(ChatPage.this, ChatMessageService.class);
                startService(intent);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        ChatPage.isChatPageAvailable = true;
        loadChatHistory();
        sendMessageStatus();
        sendSingleMessageStatus1();
        super.onResume();
    }

    @Override
    protected void onPause() {
        ChatPage.isChatPageAvailable = false;
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        if (mediaPlayer != null && mediaPlayer.isPlaying()) {
            mediaPlayer.stop();
        }

        Chat_Id = "";
        task_id = "";
        super.onDestroy();
    }


    //-----------------Move Back on pressed phone back button------------------
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {
            // close keyboard
            InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
            mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);

            return true;
        }
        return false;
    }


    //-----------------------------------------------Notification Mode-----------------------------------------------------------------
    //-----------------------Chat Detail Post Request-----------------
    private void postRequest_Notificationmode(String Url) {

        mLoadingDialog = new LoadingDialog(ChatPage.this);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        mLoadingDialog.show();

        System.out.println("-------------Chat Detail Url----------------" + Url);

        System.out.println("-----------id------------" + mTaskerID);
        System.out.println("-----------job_id------------" + sJobID);


        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user", mTaskerID);
        jsonParams.put("user_type", "tasker");
        jsonParams.put("mode", "gcm");
        jsonParams.put("type", "android");

        mRequest = new ServiceRequest(ChatPage.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("------------Chat Detail Response----------------" + response);

                String sStatus = "";
                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");


                } catch (JSONException e) {
                    mLoadingDialog.dismiss();
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


    //------------------------------------------Notification Mode--------------------------------------------------------------------------
}

