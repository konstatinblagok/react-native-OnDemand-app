package com.a2zkaj.app;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.Pojo.ChatPojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.Conversation_Adapter;
import com.a2zkaj.hockeyapp.ActivityHockeyApp;
import com.squareup.picasso.Picasso;

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
import core.socket.SocketHandler;

/**
 * Casperon Technology on 1/29/2016.
 */
public class ConversationPage extends ActivityHockeyApp {
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;
    private static Context mContext;

    private RelativeLayout Rl_back;
    private TextView Tv_senderName;
    private static TextView Tv_status;
    private RoundedImageView Iv_senderImage;
    private RelativeLayout Rl_chat_offline_sendmessage_layout, Rl_chat_online_sendmessage_layout;

    private String Sprovider_id = "";
    private String SenderId = "";

    private static ListView listView;
    private EditText Et_message;
    private ImageView Iv_send;

    private String sSenderID = "";
    private String sToID = "";

    private String JobId = "";

    private LoadingDialog dialog;

    private String ReceiverId = "";
    private static String Receiver_Status = "";

    private static Conversation_Adapter adapter;
    private static ArrayList<ChatPojo> chatList;
    SimpleDateFormat df_time = new SimpleDateFormat("hh:mm a");


    private SocketHandler socketHandler;

    /*Code to receive message*/
    public static class MessageHandler extends Handler {

        @Override
        public void handleMessage(Message message) {
            int state = message.arg1;
            String sMessage = (String) message.obj;
            System.out.println("---------------chat Message-----------------" + sMessage);

            if (sMessage.equalsIgnoreCase("PK-TYPING-START")) {
                Tv_status.setVisibility(View.VISIBLE);
                Tv_status.setText(mContext.getResources().getString(R.string.action_typing));
            } else if (sMessage.equalsIgnoreCase("PK-TYPING-STOP")) {
                if (Receiver_Status.equalsIgnoreCase("online")) {
                    Tv_status.setText(mContext.getResources().getString(R.string.chat_online));
                    //Tv_status.setVisibility(View.GONE);
                }

            } else {
                Tv_status.setVisibility(View.GONE);

                ChatPojo pojo = new ChatPojo();
                pojo.setMessage(sMessage);
                pojo.setType("OTHER");
                pojo.setTime("");

                chatList.add(pojo);
                adapter.notifyDataSetChanged();
                scrollMyListViewToBottom();
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.conversation);
        mContext = ConversationPage.this;
        initialize();

        Rl_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                // close keyboard
                InputMethodManager mgr = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                mgr.hideSoftInputFromWindow(Rl_back.getWindowToken(), 0);
                hideTyping();
                onBackPressed();
                finish();
                overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
            }
        });

        Iv_send.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                cd = new ConnectionDetector(ConversationPage.this);
                isInternetPresent = cd.isConnectingToInternet();
                if (isInternetPresent) {
                    String sMessage = Et_message.getText().toString();


                    if (sMessage != null && sMessage.length() > 0) {
                        try {

                            Calendar cal = Calendar.getInstance();
                            String sCurrentTime = df_time.format(cal.getTime());

                            ChatPojo pojo = new ChatPojo();
                            pojo.setMessage(sMessage);
                            pojo.setType("SELF");
                            pojo.setTime(sCurrentTime);

                            chatList.add(pojo);
                            adapter.notifyDataSetChanged();
                            scrollMyListViewToBottom();

                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        Et_message.getText().clear();
                    }

                } else {

                    Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                }
            }
        });

    }

    private void initialize() {
        cd = new ConnectionDetector(ConversationPage.this);
        isInternetPresent = cd.isConnectingToInternet();
        session = new SessionManager(ConversationPage.this);
        chatList = new ArrayList<ChatPojo>();
        socketHandler = SocketHandler.getInstance(this);

        // get user data from session
        HashMap<String, String> user = session.getUserDetails();
        Sprovider_id = user.get(SessionManager.KEY_PROVIDERID);

        Intent i = getIntent();
        JobId = i.getStringExtra("JOBID");

        Rl_back = (RelativeLayout) findViewById(R.id.chatPage_headerBar_back_layout);
        Tv_senderName = (TextView) findViewById(R.id.chatPage_headerBar_senderName_textView);
        Iv_senderImage = (RoundedImageView) findViewById(R.id.chatPage_header_senderImage);
        listView = (ListView) findViewById(R.id.chatPage_listView);
        Et_message = (EditText) findViewById(R.id.chatPage_message_editText);
        Iv_send = (ImageView) findViewById(R.id.chatPage_send_imageView);
        Tv_status = (TextView) findViewById(R.id.chatPage_headerBar_senderName_status);
        Rl_chat_offline_sendmessage_layout = (RelativeLayout) findViewById(R.id.chatPage_bottom_offline_layout);
        Rl_chat_online_sendmessage_layout = (RelativeLayout) findViewById(R.id.chatPage_online_bottom_layout);

        Et_message.addTextChangedListener(chatEditorWatcher);

        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            chat_OpenPageDetails(ConversationPage.this, ServiceConstant.OPEN_CHAT_PAGE_URL);
            System.out.println("--------------openchat-------------------" + ServiceConstant.OPEN_CHAT_PAGE_URL);
        } else {
            Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
        }

      /*  // sSenderID = intent.getStringExtra("SenderID-Intent");
        sSenderID = SenderId;
        sToID = sSenderID + "@" + ServiceConstant.XMPP_SERVICE_NAME;
*/

/*
        chat = ChatingService.createChat(sToID);
        ChatingService.setChatMessenger(new Messenger(new MessageHandler()));
        ChatingService.enableChat();

        System.out.println("--------------Created chat intent----------------");

        Intent intent = getIntent();
        if (intent == null) {

            System.out.println("--------------inside intent----------------");

          *//* // sSenderID = intent.getStringExtra("SenderID-Intent");
            sSenderID="564af208e7a1b639168b4568";
            sToID = sSenderID + "@" + ServiceConstant.XMPP_SERVICE_NAME;
            chat = ChatingService.createChat(sToID);
            ChatingService.setChatMessenger(new Messenger(new MessageHandler()));
            ChatingService.enableChat();*//*
        }*/

       /* adapter = new Conversation_Adapter(ConversationPage.this, chatList);
        listView.setAdapter(adapter);*/
    }

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(ConversationPage.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
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
                listView.setSelection(adapter.getCount() - 1);
            }
        });
    }

    //----Show typing text----
    private void showTyping() {
    }

    //----Hide typing text----
    private void hideTyping() {
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

            if (Et_message.getText().toString().length() == 0) {
                Iv_send.setImageResource(R.drawable.chat_send);
                Iv_send.setEnabled(false);
            } else {
                Iv_send.setImageResource(R.drawable.sent);
                Iv_send.setEnabled(true);
            }
            if (Et_message.getText().toString().length() > 0) {
                showTyping();
            } else {
                hideTyping();
            }
        }
    };

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    //---------------------------code for display chat page details--------------
    private void chat_OpenPageDetails(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_type", "provider");
        jsonParams.put("id", Sprovider_id);
        jsonParams.put("job_id", JobId);

        System.out.println("user_type---------------" + "provider");
        System.out.println("id---------------" + Sprovider_id);
        System.out.println("job_id---------------" + JobId);

        dialog = new LoadingDialog(ConversationPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("chapopenrespnse", response);

                String Str_Status = "", Str_Response = "", SenderName = "", SenderImg = "", ReceiverName = "", Receiver_img = "", Chat_JobId = "",
                        Chat_Status = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    System.out.println("chat1------------");

                    if (Str_Status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");

                        System.out.println("chat2------------");

                        JSONObject object_sender = object.getJSONObject("sender");
                        if (object_sender.length() > 0) {
                            SenderName = object_sender.getString("name");
                            SenderId = object_sender.getString("id");
                            SenderImg = object_sender.getString("image");

                            System.out.println("chat3------------");
                            System.out.println("sender------------" + SenderId);
                        }

                        JSONObject object_receiver = object.getJSONObject("receiver");
                        if (object_receiver.length() > 0) {
                            ReceiverName = object_receiver.getString("name");
                            ReceiverId = object_receiver.getString("id");
                            Receiver_img = object_receiver.getString("image");

                            System.out.println("receiverName------------" + ReceiverName);
                            System.out.println("receiveeer------------" + ReceiverId);
                        }

                        JSONObject object_chatstatus = object.getJSONObject("chat");
                        if (object_chatstatus.length() > 0) {
                            Chat_JobId = object_chatstatus.getString("job_id");
                            Chat_Status = object_chatstatus.getString("chat_status");
                            Receiver_Status = object_chatstatus.getString("receiver_status");

                            System.out.println("chatstatus------------" + Chat_JobId);
                        }

                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_Status.equalsIgnoreCase("1")) {
                        Tv_senderName.setText(ReceiverName);
                        Picasso.with(ConversationPage.this).load(String.valueOf(Receiver_img)).placeholder(R.drawable.nouserimg).into(Iv_senderImage);

                        if (Receiver_Status.equalsIgnoreCase("online") && Chat_Status.equalsIgnoreCase("open")) {
                            Tv_status.setText(getResources().getString(R.string.chat_online));
                            Rl_chat_online_sendmessage_layout.setVisibility(View.VISIBLE);
                            Rl_chat_offline_sendmessage_layout.setVisibility(View.GONE);
                        } else {
                            Tv_status.setText(getResources().getString(R.string.chat_offline));
                            Rl_chat_online_sendmessage_layout.setVisibility(View.GONE);
                            Rl_chat_offline_sendmessage_layout.setVisibility(View.VISIBLE);
                        }
                        sSenderID = ReceiverId;
                        sToID = sSenderID + "@" + ServiceConstant.XMPP_SERVICE_NAME;
                        adapter = new Conversation_Adapter(ConversationPage.this, chatList);
                        listView.setAdapter(adapter);

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_Response);

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
    public boolean isDestroyed() {
        hideTyping();
        return super.isDestroyed();
    }

    @Override
    protected void onStop() {
        hideTyping();
        super.onStop();
    }

    @Override
    protected void onResume() {
        super.onResume();
    }
}
