package com.a2zkaj.Fragment;

import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.FrameLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.toolbox.StringRequest;
import com.a2zkaj.adapter.MissedLeadsFragment_Adapter;
import com.a2zkaj.Pojo.MissedLeads_Pojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.EditProfilePage;
import com.a2zkaj.app.R;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;

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
 * Created by user88 on 12/15/2015.
 */
public class MissedLeads_Fragment extends FragmentHockeyApp {

    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private boolean isMissedsLeadsAvailable = false;

    private ConnectionDetector cd;

    private MissedLeadsFragment_Adapter adapter;
    private Dialog dialogs;

    private StringRequest postrequest;
    private String provider_id = "", provider_name = "";
    private String Str_Pagination = "", Str_PageDateCount = "", Str_Nextpage = "";

    private SessionManager session;
    private String asyntask_name = "normal";
    private boolean loadingMore = false;
    BroadcastReceiver misedleadsReciver;

    private ArrayList<MissedLeads_Pojo> missed_leads_list;

    private ListView listView;
    private TextView Tv_noList, empty_txtview;
    private SwipeRefreshLayout swipeRefreshLayout = null;
    private FrameLayout loadmore;


    String Str_type = "", Str_sortby = "", Str_orderby = "", Strfrom = "", Strto = "";

    private Handler mHandler;
    private ServiceRequest mRequest;

    private RelativeLayout layout_nojobs, Rl_missedleads_nointernet_layout, Rl_missedleads_mainlayout, Rl_missedleads_empytjob_editprofile;

    private SocketHandler socketHandler;
    private LoadingDialog dialog;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootview = inflater.inflate(R.layout.missedleads_fragment, container, false);

        init(rootview);

        IntentFilter filter = new IntentFilter();
        filter.addAction("com.app.MissedLeads_Fragment");
        misedleadsReciver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                System.out.println("missed---------");
                // Str_type  = (String) intent.getExtras().get("Type");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");
                Strfrom = (String) intent.getExtras().get("from");
                Strto = (String) intent.getExtras().get("to");

                postJobRequestSorting(ServiceConstant.myjobs_sortingurl);
                System.out.println("sortopen-------" + ServiceConstant.myjobs_sortingurl);

            }
        };
        getActivity().registerReceiver(misedleadsReciver, filter);


        Rl_missedleads_empytjob_editprofile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Intent intent = new Intent(getActivity(), EditProfilePage.class);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

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
                                ConnectionDetector cd = new ConnectionDetector(getActivity());
                                boolean isInternetPresent = cd.isConnectingToInternet();

                                if (isInternetPresent) {
                                    Rl_missedleads_mainlayout.setVisibility(View.VISIBLE);
                                    Rl_missedleads_nointernet_layout.setVisibility(View.GONE);
                                    layout_nojobs.setVisibility(View.GONE);

                                    missedLeads_LoadMore_PostRequest(getActivity(), ServiceConstant.NEWLEADS_URL);

                                    System.out.println("--------------missedleads_loadmore-------------------" + ServiceConstant.NEWLEADS_URL);
                                } else {

                                    Rl_missedleads_mainlayout.setVisibility(View.GONE);
                                    Rl_missedleads_nointernet_layout.setVisibility(View.VISIBLE);
                                    layout_nojobs.setVisibility(View.GONE);

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
                ConnectionDetector cd = new ConnectionDetector(getActivity());
                boolean isInternetPresent = cd.isConnectingToInternet();

                if (isInternetPresent) {
                    Rl_missedleads_mainlayout.setVisibility(View.VISIBLE);
                    Rl_missedleads_nointernet_layout.setVisibility(View.GONE);
                    layout_nojobs.setVisibility(View.GONE);
                    asyntask_name = "swipe";
                    missedLeadsPostRequest(getActivity(), ServiceConstant.NEWLEADS_URL);
                } else {
                    swipeRefreshLayout.setRefreshing(false);
                    Rl_missedleads_mainlayout.setVisibility(View.GONE);
                    Rl_missedleads_nointernet_layout.setVisibility(View.VISIBLE);
                    layout_nojobs.setVisibility(View.GONE);
                }
            }
        });

        return rootview;

    }


    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        missed_leads_list = new ArrayList<MissedLeads_Pojo>();
        mHandler = new Handler();

        socketHandler = SocketHandler.getInstance(getActivity());

        listView = (ListView) rootview.findViewById(R.id.missedleads_listView);
        layout_nojobs = (RelativeLayout) rootview.findViewById(R.id.no_leads_missedleads_layout);
        loadmore = (FrameLayout) rootview.findViewById(R.id.missedleads_fragment_loadmoreprogress);
        Rl_missedleads_nointernet_layout = (RelativeLayout) rootview.findViewById(R.id.missed_leads_noInternet_layout);
        Rl_missedleads_mainlayout = (RelativeLayout) rootview.findViewById(R.id.missedleads_main_layout);
        Rl_missedleads_empytjob_editprofile = (RelativeLayout) rootview.findViewById(R.id.layout_go_profile_missedleads);


        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        provider_name = user.get(SessionManager.KEY_PROVIDERNAME);

        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            Rl_missedleads_mainlayout.setVisibility(View.VISIBLE);
            Rl_missedleads_nointernet_layout.setVisibility(View.GONE);
            layout_nojobs.setVisibility(View.GONE);

            missedLeadsPostRequest(getActivity(), ServiceConstant.MISSEDJOB_URL);
            System.out.println("--------------missedlead-------------------" + ServiceConstant.MISSEDJOB_URL);
        } else {
            Rl_missedleads_mainlayout.setVisibility(View.GONE);
            Rl_missedleads_nointernet_layout.setVisibility(View.VISIBLE);
            layout_nojobs.setVisibility(View.GONE);
        }


        swipeRefreshLayout = (SwipeRefreshLayout) rootview.findViewById(R.id.missedleads_swipe_refresh_layout);
        swipeRefreshLayout.setColorSchemeResources(android.R.color.holo_blue_bright,
                android.R.color.holo_green_light,
                android.R.color.holo_orange_light,
                android.R.color.holo_red_light);
        swipeRefreshLayout.setEnabled(true);

    }

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(getActivity());
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
            dialog = new LoadingDialog(getActivity());
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

    //-----------------------Code forMissedLeads post request-----------------
    private void missedLeadsPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("page", "1");
        jsonParams.put("perPage", "2");
        System.out.println("provider_id-----------" + provider_id);
        System.out.println("page-----------" + "1");
        System.out.println("perPage-----------" + "10");

        loadingDialog();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                System.out.println("--------------reponsemissedleads-------------------" + response);
                Log.e("missedleads", response);
                String Str_status = "", Str_totaljobs = "", Str_Response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");

                        Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");

                        Str_totaljobs = object.getString("total_jobs");

                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarray = object.getJSONArray("jobs");

                            if (jarray.length() > 0) {

                                missed_leads_list.clear();
                                for (int i = 0; i < jarray.length(); i++) {
                                    JSONObject object2 = jarray.getJSONObject(i);

                                    MissedLeads_Pojo pojo = new MissedLeads_Pojo();
                                    pojo.setMissedleads_user_name(object2.getString("user_name"));
                                    pojo.setMissedleads_jabtimeand_date(object2.getString("booking_time"));
                                    pojo.setMissedleads_order_id(object2.getString("job_id"));
                                    pojo.setMissedleads_user_image(object2.getString("user_image"));
                                    pojo.setMissedleads_location(object2.getString("location"));
                                    pojo.setMissedleads_jobTime(object2.getString("job_time"));
                                    pojo.setMossedleads_jobstatus(object2.getString("job_status"));
                                    pojo.setMissedleads_jobtype(object2.getString("category_name"));
                                    missed_leads_list.add(pojo);
                                    isMissedsLeadsAvailable = true;
                                }
                                show_progress_status = true;

                            } else {
                                show_progress_status = false;
                                isMissedsLeadsAvailable = false;
                            }

                        } else {
                            isMissedsLeadsAvailable = false;
                        }
                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        if (isMissedsLeadsAvailable) {
                            adapter = new MissedLeadsFragment_Adapter(getActivity(), missed_leads_list);
                            listView.setAdapter(adapter);

                            if (show_progress_status) {
                                layout_nojobs.setVisibility(View.GONE);
                            } else {
                                layout_nojobs.setVisibility(View.VISIBLE);
                                listView.setEmptyView(layout_nojobs);
                            }
                        } else {
                            layout_nojobs.setVisibility(View.VISIBLE);
                            listView.setEmptyView(layout_nojobs);
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
            }
        });

    }

//----------------------------------code for MissedLeads Loadmore------------------------

    private void missedLeads_LoadMore_PostRequest(Context mContext, String url) {

        loadmore.setVisibility(View.VISIBLE);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("page", Str_Pagination);
        jsonParams.put("perPage", Str_PageDateCount);

        System.out.println("provider_id-----------" + provider_id);
        System.out.println("page-----------" + Str_Nextpage);
        System.out.println("perPage-----------" + Str_PageDateCount);

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                System.out.println("--------------reponsemissedleadsloadmore-------------------" + response);
                Log.e("missedleads", response);
                String Str_status = "", Str_Response = "", Str_totaljobs = "";

                try {
                    loadingMore = true;
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");

                        Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");
                        Str_totaljobs = object.getString("total_jobs");


                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarray = object.getJSONArray("jobs");

                            if (jarray.length() > 0) {

                                for (int i = 0; i < jarray.length(); i++) {
                                    JSONObject object2 = jarray.getJSONObject(i);

                                    MissedLeads_Pojo pojo = new MissedLeads_Pojo();
                                    pojo.setMissedleads_user_name(object2.getString("user_name"));
                                    pojo.setMissedleads_jabtimeand_date(object2.getString("booking_time"));
                                    pojo.setMissedleads_order_id(object2.getString("job_id"));
                                    pojo.setMissedleads_user_image(object2.getString("user_image"));
                                    pojo.setMissedleads_location(object2.getString("location"));
                                    pojo.setMissedleads_jobTime(object2.getString("job_time"));
                                    pojo.setMossedleads_jobstatus(object2.getString("job_status"));
                                    pojo.setMissedleads_jobtype(object2.getString("category_name"));
                                    missed_leads_list.add(pojo);
                                    isMissedsLeadsAvailable = true;
                                }
                                show_progress_status = true;

                            } else {
                                show_progress_status = false;
                                isMissedsLeadsAvailable = false;
                            }
                        } else {

                            isMissedsLeadsAvailable = false;
                        }
                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        if (isMissedsLeadsAvailable) {
                            loadingMore = false;
                            loadmore.setVisibility(View.GONE);

                            if (show_progress_status) {
                                adapter.notifyDataSetChanged();
                            }
                        } else {
                            layout_nojobs.setVisibility(View.VISIBLE);
                            listView.setEmptyView(layout_nojobs);
                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_Response);
                    }
                    if (swipeRefreshLayout.isRefreshing()) {
                        swipeRefreshLayout.setRefreshing(false);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                dialog.dismiss();
                loadingMore = false;

            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });

    }


    //-------------My Jobs Post Request---------------
    private void postJobRequestSorting(String url) {

        loadingDialog();

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        // jsonParams.put("type", sType);
        jsonParams.put("page", "0");
        jsonParams.put("perPage", "20");
        jsonParams.put("orderby", Str_orderby);
        jsonParams.put("sortby", Str_sortby);
        jsonParams.put("from", Strfrom);
        jsonParams.put("to", Strto);

        System.out.println("---------from------------" + Strfrom);
        System.out.println("---------to------------" + Strto);

        System.out.println("---------orderby------------" + Str_orderby);
        System.out.println("---------sortby------------" + Str_sortby);

        System.out.println("---------My Jobs user_id------------" + provider_id);
        // System.out.println("---------My Jobs type------------" + sType);
        System.out.println("---------My Jobs Page page------------" + "1");
        System.out.println("---------My Jobs url------------" + url);

        mRequest = new ServiceRequest(getActivity());
        mRequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------- sortingname response------------" + response);

                String Str_status = "", Str_totaljobs = "", Str_Response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");

                        Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");

                        Str_totaljobs = object.getString("total_jobs");

                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarray = object.getJSONArray("jobs");

                            if (jarray.length() > 0) {

                                missed_leads_list.clear();
                                for (int i = 0; i < jarray.length(); i++) {
                                    JSONObject object2 = jarray.getJSONObject(i);

                                    MissedLeads_Pojo pojo = new MissedLeads_Pojo();
                                    pojo.setMissedleads_user_name(object2.getString("user_name"));
                                    pojo.setMissedleads_jabtimeand_date(object2.getString("booking_time"));
                                    pojo.setMissedleads_order_id(object2.getString("job_id"));
                                    pojo.setMissedleads_user_image(object2.getString("user_image"));
                                    pojo.setMissedleads_location(object2.getString("location"));
                                    pojo.setMissedleads_jobTime(object2.getString("job_time"));
                                    pojo.setMossedleads_jobstatus(object2.getString("job_status"));
                                    pojo.setMissedleads_jobtype(object2.getString("category_name"));
                                    missed_leads_list.add(pojo);
                                    isMissedsLeadsAvailable = true;
                                }
                                show_progress_status = true;

                            } else {
                                show_progress_status = false;
                                isMissedsLeadsAvailable = false;
                            }

                        } else {
                            isMissedsLeadsAvailable = false;
                        }
                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        if (isMissedsLeadsAvailable) {
                            adapter = new MissedLeadsFragment_Adapter(getActivity(), missed_leads_list);
                            listView.setAdapter(adapter);

                            if (show_progress_status) {
                                layout_nojobs.setVisibility(View.GONE);
                            } else {
                                layout_nojobs.setVisibility(View.VISIBLE);
                                listView.setEmptyView(layout_nojobs);
                            }
                        } else {
                            layout_nojobs.setVisibility(View.VISIBLE);
                            listView.setEmptyView(layout_nojobs);
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
            }
        });
    }


    @Override
    public void onResume() {
        super.onResume();

       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }

    @Override
    public void onDestroy() {
        getActivity().unregisterReceiver(misedleadsReciver);
        super.onDestroy();
    }


}
