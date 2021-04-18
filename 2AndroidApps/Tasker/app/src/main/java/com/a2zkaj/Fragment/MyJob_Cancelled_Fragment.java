package com.a2zkaj.Fragment;


import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Address;
import android.location.Geocoder;
import android.os.Bundle;
import android.os.Handler;
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
import android.widget.TextView;

import com.android.volley.Request;
import com.android.volley.toolbox.StringRequest;
import com.a2zkaj.adapter.MyJobCancelled_Adapter;
import com.a2zkaj.Pojo.MyJobCancelledPojo;
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
public class MyJob_Cancelled_Fragment extends FragmentHockeyApp {

    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private boolean isCancelledJobAvailable = false;
    public static String canceljobs="";
    private ConnectionDetector cd;
    private MyJobCancelled_Adapter adapter;
    private MyJobCancelledPojo pojo;
    private Dialog dialogs;

    private StringRequest postrequest;
    private LoadingDialog dialog;
    private String provider_id = "";

    private SessionManager session;
    private FrameLayout loadmore;
    private Handler mHandler;

    private boolean loadingMore = false;
    private String asyntask_name = "normal";
    private String Str_currentpage = "", Str_perpage = "";

    private SwipeRefreshLayout swipeRefreshLayout = null;

    private RelativeLayout layout_cancelled_nojobs, Rl_myjob_cancelled_main_layout, Rl_myjob_cancelled_no_internet_layout, Rl_myjob_cancelled_empty_editprofile_layout;

    private ArrayList<MyJobCancelledPojo> cancelledlist;

    private String Str_Pagination = "", Str_PageDateCount = "", Str_Nextpage = "";
    BroadcastReceiver cancelleddReciver;

    private ServiceRequest mRequest;

    private ListView listView;
    private TextView Tv_noList, empty_txtview;
    String Str_type = "", Str_sortby = "", Str_orderby = "", Strfrom = "", Strto = "";
    private SocketHandler socketHandler;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootview = inflater.inflate(R.layout.myjob_cancelled, container, false);
        init(rootview);


        IntentFilter filter = new IntentFilter();
        filter.addAction("com.app.MyJob_Cancelled_Fragment");
        cancelleddReciver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                System.out.println("ongoing---------");
                Str_type = (String) intent.getExtras().get("Type");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");
                Strfrom = (String) intent.getExtras().get("from");
                Strto = (String) intent.getExtras().get("to");

                postJobRequestSorting(ServiceConstant.myjobs_sortingurl, Str_type);

                System.out.println("sortancel-------" + ServiceConstant.myjobs_sortingurl);

            }
        };
        getActivity().registerReceiver(cancelleddReciver, filter);


        Rl_myjob_cancelled_empty_editprofile_layout.setOnClickListener(new View.OnClickListener() {
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
                if (isInternetPresent){

                    Intent intent = new Intent(getActivity(), MyJobs_OnGoingDetailPage.class);
                    intent.putExtra("JobId", cancelledlist.get(position).getOrder_id());
                    startActivity(intent);
                    getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

                }else{
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

                                    Rl_myjob_cancelled_main_layout.setVisibility(View.VISIBLE);
                                    Rl_myjob_cancelled_no_internet_layout.setVisibility(View.GONE);
                                    layout_cancelled_nojobs.setVisibility(View.GONE);

                                    myjobCancelled_LoadMore_PostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);
                                    System.out.println("--------------newleads_loadmore-------------------" + ServiceConstant.MYJOBON_LIST_URL);
                                } else {

                                    Rl_myjob_cancelled_main_layout.setVisibility(View.GONE);
                                    Rl_myjob_cancelled_no_internet_layout.setVisibility(View.VISIBLE);
                                    layout_cancelled_nojobs.setVisibility(View.GONE);

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
                    Rl_myjob_cancelled_main_layout.setVisibility(View.VISIBLE);
                    Rl_myjob_cancelled_no_internet_layout.setVisibility(View.GONE);
                    layout_cancelled_nojobs.setVisibility(View.GONE);

                    asyntask_name = "swipe";
                    myjobCancelledPostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);
                } else {
                    swipeRefreshLayout.setRefreshing(false);
                    Rl_myjob_cancelled_main_layout.setVisibility(View.GONE);
                    Rl_myjob_cancelled_no_internet_layout.setVisibility(View.VISIBLE);
                    layout_cancelled_nojobs.setVisibility(View.GONE);
                }
            }
        });

        return rootview;

    }


    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        cancelledlist = new ArrayList<MyJobCancelledPojo>();
        mHandler = new Handler();
        socketHandler = SocketHandler.getInstance(getActivity());

        canceljobs="1";
        listView = (ListView) rootview.findViewById(R.id.myjobs_cancelled_listView);
        layout_cancelled_nojobs = (RelativeLayout) rootview.findViewById(R.id.no_jobs_cancelled_layout);
        loadmore = (FrameLayout) rootview.findViewById(R.id.myjob_cancelled_fragment_loadmoreprogress);
        Rl_myjob_cancelled_main_layout = (RelativeLayout) rootview.findViewById(R.id.myjob_cancelled_main_layout);
        Rl_myjob_cancelled_no_internet_layout = (RelativeLayout) rootview.findViewById(R.id.myjobs_cancelled_noInternet_layout);
        Rl_myjob_cancelled_empty_editprofile_layout = (RelativeLayout) rootview.findViewById(R.id.layout_go_profile_myjob_cancelled);

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

        isInternetPresent = cd.isConnectingToInternet();

        if (isInternetPresent) {
            Rl_myjob_cancelled_main_layout.setVisibility(View.VISIBLE);
            Rl_myjob_cancelled_no_internet_layout.setVisibility(View.GONE);
            layout_cancelled_nojobs.setVisibility(View.GONE);
            myjobCancelledPostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);

            System.out.println("cancelledurl-----------" + ServiceConstant.MYJOBON_LIST_URL);

        } else {
            Rl_myjob_cancelled_main_layout.setVisibility(View.GONE);
            Rl_myjob_cancelled_no_internet_layout.setVisibility(View.VISIBLE);
            layout_cancelled_nojobs.setVisibility(View.GONE);
        }

        swipeRefreshLayout = (SwipeRefreshLayout) rootview.findViewById(R.id.myjob_cancelled_swipe_refresh_layout);
        swipeRefreshLayout.setColorSchemeResources(android.R.color.holo_blue_bright,
                android.R.color.holo_green_light,
                android.R.color.holo_orange_light,
                android.R.color.holo_red_light);

        swipeRefreshLayout.setEnabled(true);

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


    //-----------------------Code for my rides post request-----------------

    private void myjobCancelledPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", "5");
        jsonParams.put("page", "1");
        jsonParams.put("perPage", "100");

        System.out.println("provider_id------" + provider_id);
        System.out.println("type------" + "5");
        System.out.println("page------" + "1");
        System.out.println("perPage------" + "2");


        loadingDialog();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                System.out.println("--------------reponse-------------------" + response);
                Log.e("cancellled", response);
                String Str_status = "", Str_response = "", Str_totaljobs = "", Str_Response = "";

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

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {

                                cancelledlist.clear();

                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyJobCancelledPojo pojo = new MyJobCancelledPojo();
                                    pojo.setJobcancelled_address(object2.getString("location"));
                                    pojo.setJobcancelled_categorys(object2.getString("category_name"));
                                    pojo.setJobcancelled_date(object2.getString("booking_time"));
                                    pojo.setJobcancelled_user_name(object2.getString("user_name"));
                                    pojo.setJobcancelled_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setJobcancelled_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    cancelledlist.add(pojo);
                                    isCancelledJobAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isCancelledJobAvailable = false;
                            }

                        } else {
                            isCancelledJobAvailable = false;
                        }
                    } else {
                        Str_response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        if (isCancelledJobAvailable) {
                            adapter = new MyJobCancelled_Adapter(getActivity(), cancelledlist);
                            listView.setAdapter(adapter);

                            if (show_progress_status) {
                                layout_cancelled_nojobs.setVisibility(View.GONE);
                            } else {
                                layout_cancelled_nojobs.setVisibility(View.VISIBLE);
                                listView.setEmptyView(layout_cancelled_nojobs);
                            }
                        } else {
                            layout_cancelled_nojobs.setVisibility(View.VISIBLE);
                            listView.setEmptyView(layout_cancelled_nojobs);
                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
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


    private void myjobCancelled_LoadMore_PostRequest(Context mContext, String url) {

        loadmore.setVisibility(View.VISIBLE);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", "cancelled");
        jsonParams.put("page", Str_Pagination);
        jsonParams.put("perPage", Str_PageDateCount);

        System.out.println("--------------loadmore page-------------------" + Str_Nextpage);

        System.out.println("--------------loadmore perpage--------------------" + Str_PageDateCount);


        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                System.out.println("--------------loadmorereponse-------------------" + response);
                Log.e("ongoing", response);
                String Str_status = "", Str_totaljobs = "", Str_response = "";

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

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {


                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyJobCancelledPojo pojo = new MyJobCancelledPojo();
                                    pojo.setJobcancelled_address(object2.getString("location"));
                                    pojo.setJobcancelled_categorys(object2.getString("category_name"));
                                    pojo.setJobcancelled_date(object2.getString("booking_time"));
                                    pojo.setJobcancelled_user_name(object2.getString("user_name"));
                                    pojo.setJobcancelled_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setJobcancelled_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    cancelledlist.add(pojo);
                                    isCancelledJobAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isCancelledJobAvailable = false;
                            }

                        } else {
                            isCancelledJobAvailable = false;
                        }
                    } else {
                        Str_response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {

                        loadingMore = false;
                        loadmore.setVisibility(View.GONE);

                        if (show_progress_status) {
                            adapter.notifyDataSetChanged();
                        }
                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
                    }
                    if (swipeRefreshLayout.isRefreshing()) {
                        swipeRefreshLayout.setRefreshing(false);
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


    //-------------My Jobs Post Request---------------
    private void postJobRequestSorting(String url, String sType) {

        loadingDialog();

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", sType);
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
        System.out.println("---------My Jobs type------------" + sType);
        System.out.println("---------My Jobs Page page------------" + "1");
        System.out.println("---------My Jobs url------------" + url);

        mRequest = new ServiceRequest(getActivity());
        mRequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------- sortingcancel response------------" + response);

                String Str_status = "", Str_response = "", Str_totaljobs = "", Str_Response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        cancelledlist.clear();
                        JSONObject object = jobject.getJSONObject("response");

                        Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");

                        Str_totaljobs = object.getString("total_jobs");

                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {

                                cancelledlist.clear();

                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyJobCancelledPojo pojo = new MyJobCancelledPojo();
                                    pojo.setJobcancelled_address(object2.getString("location"));
                                    pojo.setJobcancelled_categorys(object2.getString("category_name"));
                                    pojo.setJobcancelled_date(object2.getString("booking_time"));
                                    pojo.setJobcancelled_user_name(object2.getString("user_name"));
                                    pojo.setJobcancelled_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setJobcancelled_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    cancelledlist.add(pojo);
                                    isCancelledJobAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isCancelledJobAvailable = false;
                            }

                        } else {
                            isCancelledJobAvailable = false;
                        }
                    } else {
                        Str_response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        if (isCancelledJobAvailable) {
                            adapter = new MyJobCancelled_Adapter(getActivity(), cancelledlist);
                            listView.setAdapter(adapter);
                            adapter.notifyDataSetChanged();
                            if (show_progress_status) {
                                layout_cancelled_nojobs.setVisibility(View.GONE);
                            } else {
                                layout_cancelled_nojobs.setVisibility(View.VISIBLE);
                                listView.setEmptyView(layout_cancelled_nojobs);
                            }
                        } else {
                            layout_cancelled_nojobs.setVisibility(View.VISIBLE);
                            listView.setEmptyView(layout_cancelled_nojobs);
                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
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
       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


    @Override
    public void onDestroy() {
        getActivity().unregisterReceiver(cancelleddReciver);
        super.onDestroy();
    }


}
