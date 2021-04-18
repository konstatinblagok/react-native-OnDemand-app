package com.a2zkaj.Fragment;


import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Address;
import android.location.Geocoder;
import android.os.Bundle;
import android.support.v4.widget.SwipeRefreshLayout;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.FrameLayout;
import android.widget.ListView;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.a2zkaj.adapter.MyJobonGoing_Adapter;
import com.a2zkaj.Pojo.MyjobOngoingPojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.EditProfilePage;
import com.a2zkaj.app.MyJobs_OnGoingDetailPage;
import com.a2zkaj.app.R;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 12/11/2015.
 */
public class MyJob_OnGoing_Fragment extends FragmentHockeyApp {
    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private ConnectionDetector cd;
    private MyJobonGoing_Adapter adapter;
    private MyjobOngoingPojo pojo;
    public static String openjobs="";
    private LoadingDialog dialog;
    private ServiceRequest mRequest;
    BroadcastReceiver ongoingtReciver;

    private String provider_id = "", provider_name = "";
    private SessionManager session;
    private SwipeRefreshLayout swipeRefreshLayout = null;
    private boolean loadingMore = false;
    private String asyntask_name = "normal";

    private String Str_Pagination = "", Str_PageDateCount = "", Str_Nextpage = "";

    private ArrayList<MyjobOngoingPojo> ongoinglist;
    private boolean isMyJobOngoingsAvailable = false;

    String Str_type = "", Str_sortby = "", Str_orderby = "", Str_from = "", Str_to = "";

   String filter_type="";
    private ListView listView;
    private RelativeLayout layout_nojobs, Rl_myjobs_ongoing_main_layout, Rl_myjobs_ongoing_nointernet_layout, Rl_myjobongoing_empty_edit_profile_layout;
    private FrameLayout loadmore;
    private SocketHandler socketHandler;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootview = inflater.inflate(R.layout.myjob_ongoing, container, false);
        init(rootview);

        IntentFilter filter = new IntentFilter();
        filter.addAction("com.app.MyJob_OnGoing_Fragment");
        ongoingtReciver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                System.out.println("ongoing---------");
                Str_type = (String) intent.getExtras().get("Type");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");
                Str_from = (String) intent.getExtras().get("from");
                Str_to = (String) intent.getExtras().get("to");

                filter_type=(String) intent.getExtras().get("filter_type");

                if(filter_type.equalsIgnoreCase("today") ||filter_type.equalsIgnoreCase("recent") || filter_type.equalsIgnoreCase("upcoming") ){

                    postJobRequestSorting(ServiceConstant.Filter_booking_url, filter_type);
                }else{

                    postJobRequestSorting(ServiceConstant.myjobs_sortingurl, Str_type);
                }

            }
        };
        getActivity().registerReceiver(ongoingtReciver, filter);


        Rl_myjobongoing_empty_edit_profile_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), EditProfilePage.class);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                isInternetPresent = cd.isConnectingToInternet();
                if (isInternetPresent) {
                    Intent intent = new Intent(getActivity(), MyJobs_OnGoingDetailPage.class);
                    intent.putExtra("JobId", ongoinglist.get(position).getOrder_id());
                    startActivity(intent);
                    getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                } else {
                    Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                }
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
                                    Rl_myjobs_ongoing_main_layout.setVisibility(View.VISIBLE);
                                    Rl_myjobs_ongoing_nointernet_layout.setVisibility(View.GONE);

                                    myJobOngoing_LoadMore_PostReques(getActivity(), ServiceConstant.MYJOBON_LIST_URL);
                                    System.out.println("--------------newleads_loadmore-------------------" + ServiceConstant.MYJOBON_LIST_URL);
                                } else {
                                    Rl_myjobs_ongoing_main_layout.setVisibility(View.GONE);
                                    Rl_myjobs_ongoing_nointernet_layout.setVisibility(View.VISIBLE);
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
                    Rl_myjobs_ongoing_main_layout.setVisibility(View.VISIBLE);
                    Rl_myjobs_ongoing_nointernet_layout.setVisibility(View.GONE);
                    asyntask_name = "swipe";
                    myjobOngoingPostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);
                } else {
                    swipeRefreshLayout.setRefreshing(false);
                    Rl_myjobs_ongoing_main_layout.setVisibility(View.GONE);
                    Rl_myjobs_ongoing_nointernet_layout.setVisibility(View.VISIBLE);
                    layout_nojobs.setVisibility(View.GONE);
                }
            }
        });


        return rootview;

    }

    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        ongoinglist = new ArrayList<MyjobOngoingPojo>();
        socketHandler = SocketHandler.getInstance(getActivity());
        openjobs="1";
        listView = (ListView) rootview.findViewById(R.id.myjobs_ongoing_listView);
        layout_nojobs = (RelativeLayout) rootview.findViewById(R.id.no_jobs_layout);
        loadmore = (FrameLayout) rootview.findViewById(R.id.myjobongoing_fragment_loadmoreprogress);
        Rl_myjobs_ongoing_main_layout = (RelativeLayout) rootview.findViewById(R.id.myjobs_ongoing_main_layout);
        Rl_myjobs_ongoing_nointernet_layout = (RelativeLayout) rootview.findViewById(R.id.myjobs_ongoing_noInternet_layout);
        Rl_myjobongoing_empty_edit_profile_layout = (RelativeLayout) rootview.findViewById(R.id.layout_go_profile_myjob_ongoing);


        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        provider_name = user.get(SessionManager.KEY_PROVIDERNAME);


        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            Rl_myjobs_ongoing_main_layout.setVisibility(View.VISIBLE);
            Rl_myjobs_ongoing_nointernet_layout.setVisibility(View.GONE);
            layout_nojobs.setVisibility(View.GONE);
            myjobOngoingPostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);

            System.out.println("ongoingurl---------" + ServiceConstant.MYJOBON_LIST_URL);


        } else {
            Rl_myjobs_ongoing_main_layout.setVisibility(View.GONE);
            Rl_myjobs_ongoing_nointernet_layout.setVisibility(View.VISIBLE);
            layout_nojobs.setVisibility(View.GONE);
        }

        swipeRefreshLayout = (SwipeRefreshLayout) rootview.findViewById(R.id.myjob_ongoing_swipe_refresh_layout);
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

    //-----------------------Code for Ongoing post request-----------------
    private void myjobOngoingPostRequest(Context mContext, String url) {

        loadingDialog();

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", "2");
        jsonParams.put("page", "1");
        jsonParams.put("perPage", "100");

        System.out.println("ongoing------------provider_id---" + provider_id);
        System.out.println("ongoing------------type---" + "2");
        System.out.println("ongoing------------page---" + "1");
        System.out.println("ongoing------------perPage---" + "2");

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------------ongoingreponse-------------------" + response);
                Log.e("ongoing", response);
                String Str_status = "", Str_totaljobs = "", Str_response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_totaljobs = object.getString("total_jobs");
                        Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");

                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {
                                ongoinglist.clear();
                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyjobOngoingPojo pojo = new MyjobOngoingPojo();
                                    pojo.setOngoing_address(object2.getString("location"));
                                    pojo.setOngoing_category(object2.getString("category_name"));
                                    pojo.setOngoing_date(object2.getString("booking_time"));
                                    pojo.setOngoing_user_name(object2.getString("user_name"));
                                    pojo.setOngoing_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setJob_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    ongoinglist.add(pojo);
                                    isMyJobOngoingsAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isMyJobOngoingsAvailable = false;
                            }
                        } else {

                            isMyJobOngoingsAvailable = false;
                        }

                    } else {

                        Str_response = jobject.getString("response");
                    }
                    if (Str_status.equalsIgnoreCase("1")) {

                        if (isMyJobOngoingsAvailable) {
                            adapter = new MyJobonGoing_Adapter(getActivity(), ongoinglist);
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
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
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


    private void myJobOngoing_LoadMore_PostReques(Context mContext, String url) {

        loadmore.setVisibility(View.VISIBLE);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", "ongoing");
        jsonParams.put("page", Str_Pagination);
        jsonParams.put("perPage", Str_PageDateCount);

        System.out.println("--------------loadmore page-------------------" + Str_Nextpage);

        System.out.println("--------------loadmore perpage--------------------" + Str_PageDateCount);

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {


            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------------reponse-------------------" + response);
                Log.e("ongoing", response);
                String Str_status = "", Str_response = "", Str_currentpage = "", Str_perpage = "", Str_totaljobs = "";

                try {

                    loadingMore = true;

                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                       // Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");
                        Str_totaljobs = object.getString("total_jobs");

                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {

                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyjobOngoingPojo pojo = new MyjobOngoingPojo();
                                    pojo.setOngoing_address(object2.getString("location"));
                                    pojo.setOngoing_category(object2.getString("category_name"));
                                    pojo.setOngoing_date(object2.getString("booking_time"));
                                    pojo.setOngoing_user_name(object2.getString("user_name"));
                                    pojo.setOngoing_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setJob_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    ongoinglist.add(pojo);
                                    isMyJobOngoingsAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isMyJobOngoingsAvailable = false;
                            }

                        } else {
                            isMyJobOngoingsAvailable = false;
                        }

                    } else {
                        Str_response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {

                        if (show_progress_status) {
                            adapter.notifyDataSetChanged();
                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
                    }
                    if (swipeRefreshLayout.isRefreshing()) {
                        swipeRefreshLayout.setRefreshing(false);
                    }
                    loadingMore = false;
                    loadmore.setVisibility(View.GONE);

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


    //-------------My Jobs Post Request---------------
    private void postJobRequestSorting(String url, String sType) {

        loadingDialog();
        HashMap<String, String> jsonParams = new HashMap<String, String>();

        if(sType.equalsIgnoreCase("today") ||sType.equalsIgnoreCase("recent") || sType.equalsIgnoreCase("upcoming")){
            jsonParams.put("provider_id", provider_id);
            jsonParams.put("type", sType);
            jsonParams.put("page", "1");
            jsonParams.put("perPage", "20");
            jsonParams.put("orderby", Str_orderby);
            jsonParams.put("sortby", Str_sortby);


        }else{

            jsonParams.put("provider_id", provider_id);
            jsonParams.put("type", sType);
            jsonParams.put("page", "1");
            jsonParams.put("perPage", "20");
            jsonParams.put("orderby", Str_orderby);
            jsonParams.put("sortby", Str_sortby);
            jsonParams.put("from", Str_from);
            jsonParams.put("to", Str_to);

        }
        System.out.println("---------from------------" + Str_from);
        System.out.println("---------to------------" + Str_to);

        System.out.println("---------orderby------------" + Str_orderby);
        System.out.println("---------sortby------------" + Str_sortby);

        System.out.println("---------My Jobs user_id------------" + provider_id);
        System.out.println("---------My Jobs type------------" + sType);
        System.out.println("---------My Jobs Page page------------" + "1");
        System.out.println("---------My Jobs url------------" + url);


        mRequest = new ServiceRequest(getActivity());
        mRequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------- sortingname response------------" + response);

                String Str_status = "", Str_totaljobs = "", Str_response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        ongoinglist.clear();
                        JSONObject object = jobject.getJSONObject("response");
                        Str_totaljobs = object.getString("total_jobs");
                       // Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");

                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {
                                ongoinglist.clear();
                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyjobOngoingPojo pojo = new MyjobOngoingPojo();
                                    pojo.setOngoing_address(object2.getString("location"));
                                    pojo.setOngoing_category(object2.getString("category_name"));
                                    pojo.setOngoing_date(object2.getString("booking_time"));
                                    pojo.setOngoing_user_name(object2.getString("user_name"));
                                    pojo.setOngoing_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setJob_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    ongoinglist.add(pojo);
                                    isMyJobOngoingsAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isMyJobOngoingsAvailable = false;
                            }
                        } else {

                            isMyJobOngoingsAvailable = false;
                        }

                    } else {

                        Str_response = jobject.getString("response");
                    }
                    if (Str_status.equalsIgnoreCase("1")) {

                        if (isMyJobOngoingsAvailable) {
                            adapter = new MyJobonGoing_Adapter(getActivity(), ongoinglist);
                            listView.setAdapter(adapter);
                            adapter.notifyDataSetChanged();
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

                        Alert(getResources().getString(R.string.server_lable_header), Str_response);

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

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.app.MyJob_OnGoing_Fragment")) {
                System.out.println("opensort----------------------");

                Str_type = (String) intent.getExtras().get("Type");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");
                filter_type=(String) intent.getExtras().get("filter_type");

                if(filter_type.equalsIgnoreCase("today") ||filter_type.equalsIgnoreCase("recent") || filter_type.equalsIgnoreCase("upcoming") ){

                    postJobRequestSorting(ServiceConstant.Filter_booking_url, filter_type);
                }else{

                    postJobRequestSorting(ServiceConstant.myjobs_sortingurl, Str_type);
                }




            } else if (intent.getAction().equals("com.app.MyJob_Completed_Fragment")) {
                System.out.println("completesort----------------------");

                Str_type = (String) intent.getExtras().get("Type");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");

                postJobRequestSorting(ServiceConstant.myjobs_sortingurl, Str_type);

            } else if (intent.getAction().equals("com.app.MyJob_Cancelled_Fragment")) {

                Str_type = (String) intent.getExtras().get("Type");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");

                postJobRequestSorting(ServiceConstant.myjobs_sortingurl, Str_type);
            }

        }
    }


    //-------------Method to get Complete Address------------
    private String getCompleteAddressString(double LATITUDE, double LONGITUDE) {
        String strAdd = "";
        Geocoder geocoder = new Geocoder(getActivity(), Locale.getDefault());
        try {
            List<Address> addresses = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addresses != null) {
                Address returnedAddress = addresses.get(0);
                StringBuilder strReturnedAddress = new StringBuilder("");

                for (int i = 0; i <= returnedAddress.getMaxAddressLineIndex(); i++) {
                    strReturnedAddress.append(returnedAddress.getAddressLine(i)).append("\n");
                }
                strAdd = strReturnedAddress.toString();
            } else {
                Log.e("Current loction address", "No Address returned!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("Current loction address", "Canont get Address!");
        }
        return strAdd;
    }


    @Override
    public void onResume() {
        super.onResume();

        /*if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


    @Override
    public void onDestroy() {
        getActivity().unregisterReceiver(ongoingtReciver);
        super.onDestroy();
    }
}
