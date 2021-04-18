package com.a2zkaj.app;

import android.content.Context;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.View;
import android.widget.AbsListView;
import android.widget.ListView;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.a2zkaj.adapter.ChatListAdapter;
import com.a2zkaj.Pojo.ChatList_Pojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 2/3/2016.
 */
public class ChatList extends ActionBarActivityHockeyApp {

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;
    private LoadingDialog dialog;
    private String asyntask_name = "normal";

    private String providerId = "";
    private boolean isChatAvailable = false;
    private boolean show_progress_status = false;

    private SwipeRefreshLayout swipeRefreshLayout = null;

    ChatListAdapter adapter;
    private ArrayList<ChatList_Pojo> chatlistst;

    private RelativeLayout Rl_chatlist_main_layout, RL_chatlist_empty_layout, Rl_chatlist_nointernet_layout;
    private ListView listView;

    private boolean loadingMore = false;
    private SocketHandler socketHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_list);
        initilize();


        listView.setOnScrollListener(new AbsListView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(AbsListView view, int scrollState) {
                int threshold = 1;
                int count = listView.getCount();

                if (scrollState == SCROLL_STATE_IDLE) {
                    if (listView.getLastVisiblePosition() >= count - threshold && !(loadingMore)) {
                        if (swipeRefreshLayout.isRefreshing()) {
                            //nothing happen(code to block loadMore functionality when swipe to refresh is loading)
                        } else {
                            if (show_progress_status) {
                                ConnectionDetector cd = new ConnectionDetector(ChatList.this);
                                boolean isInternetPresent = cd.isConnectingToInternet();

                                if (isInternetPresent) {
                                    Rl_chatlist_main_layout.setVisibility(View.VISIBLE);
                                    Rl_chatlist_nointernet_layout.setVisibility(View.GONE);
                                    RL_chatlist_empty_layout.setVisibility(View.GONE);
                                    chataListPostRequest(ChatList.this, ServiceConstant.OPEN_CHAT_LIST_URL);
                                    System.out.println("--------------chatlist_loadmore-------------------" + ServiceConstant.OPEN_CHAT_LIST_URL);
                                } else {

                                    Rl_chatlist_main_layout.setVisibility(View.GONE);
                                    Rl_chatlist_nointernet_layout.setVisibility(View.VISIBLE);
                                    RL_chatlist_empty_layout.setVisibility(View.GONE);

                                }
                            }
                        }
                    }
                }
            }

            @Override
            public void onScroll(AbsListView view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
                boolean enable = false;

                if (firstVisibleItem == 0) {
                    swipeRefreshLayout.setEnabled(true);
                } else {
                    swipeRefreshLayout.setEnabled(false);
                }

            }
        });

        swipeRefreshLayout.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh() {
                ConnectionDetector cd = new ConnectionDetector(ChatList.this);
                boolean isInternetPresent = cd.isConnectingToInternet();

                if (isInternetPresent) {
                    Rl_chatlist_main_layout.setVisibility(View.VISIBLE);
                    Rl_chatlist_nointernet_layout.setVisibility(View.GONE);
                    RL_chatlist_empty_layout.setVisibility(View.GONE);
                    asyntask_name = "swipe";
                    chataListPostRequest(ChatList.this, ServiceConstant.OPEN_CHAT_LIST_URL);
                } else {
                    swipeRefreshLayout.setRefreshing(false);
                    Rl_chatlist_main_layout.setVisibility(View.GONE);
                    Rl_chatlist_nointernet_layout.setVisibility(View.VISIBLE);
                    RL_chatlist_empty_layout.setVisibility(View.GONE);
                }
            }
        });


    }

    private void initilize() {
        cd = new ConnectionDetector(ChatList.this);
        session = new SessionManager(ChatList.this);
        socketHandler = SocketHandler.getInstance(this);

        HashMap<String, String> user = session.getUserDetails();
        providerId = user.get(SessionManager.KEY_PROVIDERID);
        chatlistst = new ArrayList<ChatList_Pojo>();

        Rl_chatlist_main_layout = (RelativeLayout) findViewById(R.id.chatlist_main_layout);
        RL_chatlist_empty_layout = (RelativeLayout) findViewById(R.id.chatlist_empty_layout);
        Rl_chatlist_nointernet_layout = (RelativeLayout) findViewById(R.id.chatlist_noInternet_layout);
        listView = (ListView) findViewById(R.id.chatlist_listView);
        swipeRefreshLayout = (SwipeRefreshLayout) findViewById(R.id.chatlist_swipe_refresh_layout);

        isInternetPresent = cd.isConnectingToInternet();

        if (isInternetPresent) {
            Rl_chatlist_main_layout.setVisibility(View.VISIBLE);
            Rl_chatlist_nointernet_layout.setVisibility(View.GONE);
            RL_chatlist_empty_layout.setVisibility(View.GONE);
            chataListPostRequest(ChatList.this, ServiceConstant.OPEN_CHAT_LIST_URL);
            System.out.println("chatlisturl-----------------" + ServiceConstant.OPEN_CHAT_LIST_URL);

        } else {
            Rl_chatlist_main_layout.setVisibility(View.GONE);
            Rl_chatlist_nointernet_layout.setVisibility(View.VISIBLE);
            RL_chatlist_empty_layout.setVisibility(View.GONE);

        }

        swipeRefreshLayout.setColorSchemeResources(android.R.color.holo_blue_bright,
                android.R.color.holo_green_light,
                android.R.color.holo_orange_light,
                android.R.color.holo_red_light);
        swipeRefreshLayout.setEnabled(true);

    }


    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(ChatList.this);
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

    private void loadingDialog() {

        if (asyntask_name.equalsIgnoreCase("normal")) {
            dialog = new LoadingDialog(ChatList.this);
            dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
            dialog.show();
        } else {
            swipeRefreshLayout.setRefreshing(true);
        }
    }


    private void dismissDialog() {

        if (asyntask_name.equalsIgnoreCase("normal")) {
            dialog.dismiss();
        } else {
            swipeRefreshLayout.setRefreshing(false);
        }
    }


    private void chataListPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_type", "provider");
        jsonParams.put("id", providerId);

        System.out.println("id-----------" + providerId);
        System.out.println("user_type-----------" + "provider");

        loadingDialog();
        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("Chatlist", response);

                String Str_Status = "", Str_Response = "";

                try {

                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");
                    if (Str_Status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");

                        Object check_list_object = object.get("list");
                        if (check_list_object instanceof JSONArray) {
                            JSONArray jarry = object.getJSONArray("list");

                            if (jarry.length() > 0) {

                                for (int i = 0; i < jarry.length(); i++) {

                                    JSONObject object2 = jarry.getJSONObject(i);
                                    ChatList_Pojo pojo = new ChatList_Pojo();

                                    pojo.setChatlist_name(object2.getString("name"));
                                    pojo.setChatlist_image(object2.getString("image"));
                                    pojo.setChatlist_message(object2.getString("msg"));
                                    pojo.setChatlist_messageTime(object2.getString("msg_time"));
                                    pojo.setChatlist_plumbalId(object2.getString("p_id"));
                                    pojo.setChatlist_jobId(object2.getString("job_id"));

                                    System.out.println("chantnme---------" + object2.getString("name"));

                                    chatlistst.add(pojo);
                                    isChatAvailable = true;

                                }
                                show_progress_status = true;

                            } else {
                                isChatAvailable = false;

                                show_progress_status = false;
                            }

                        } else {
                            isChatAvailable = false;
                        }

                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_Status.equalsIgnoreCase("1")) {
                        if (isChatAvailable) {
                            adapter = new ChatListAdapter(ChatList.this, chatlistst);
                            listView.setAdapter(adapter);

                            if (show_progress_status) {
                                RL_chatlist_empty_layout.setVisibility(View.GONE);
                            } else {
                                RL_chatlist_empty_layout.setVisibility(View.VISIBLE);
                                listView.setEmptyView(RL_chatlist_empty_layout);
                            }
                        } else {
                            RL_chatlist_empty_layout.setVisibility(View.VISIBLE);
                            listView.setEmptyView(RL_chatlist_empty_layout);
                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_Response);
                    }
                    if (swipeRefreshLayout.isRefreshing()) {
                        swipeRefreshLayout.setRefreshing(false);
                    }

                } catch (Exception e) {
                    dismissDialog();
                    e.printStackTrace();
                }
                dismissDialog();
            }

            @Override
            public void onErrorListener() {
                dismissDialog();
                ;
            }
        });


    }


    @Override
    protected void onResume() {
        super.onResume();
       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }

}