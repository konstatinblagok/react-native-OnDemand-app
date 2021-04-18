package com.a2zkaj.Fragment;


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

import com.android.volley.Request;
import com.android.volley.toolbox.StringRequest;
import com.a2zkaj.adapter.MyjobConverted_Adapter;
import com.a2zkaj.Pojo.MyjobConverted_Pojo;
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
public class MyJob_Converted_Fragment extends FragmentHockeyApp {

    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private ConnectionDetector cd;
    private MyjobConverted_Adapter adapter;
    private MyjobConverted_Pojo pojo;

    private StringRequest postrequest;
    private String provider_id = "";
    public static String completedjobs="";
    BroadcastReceiver convertedReciver;

    private SessionManager session;
    private SwipeRefreshLayout swipeRefreshLayout = null;
    private FrameLayout loadmore;

    private String asyntask_name = "normal";
    private String Str_currentpage = "", Str_perpage = "";
    private boolean loadingMore = false;
    private boolean isConvertedJobAvailable = false;

    private LoadingDialog dialog;
    private Handler mHandler;

    private ArrayList<MyjobConverted_Pojo> convertedlist;

    private ListView listView;
    private RelativeLayout layout_nojobs_converted, Rl_myjob_converted_main_layout, Rl_myjob_converted_nointernet_layout, Rl_myjob_converted_empty_editprofile_layout;

    private String Str_Pagination = "", Str_PageDateCount = "", Str_Nextpage = "";
    String Str_type = "", Str_sortby = "", Str_orderby = "", Str_from = "", Str_to = "";

    private ServiceRequest mRequest;
    private SocketHandler socketHandler;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment

        View rootview = inflater.inflate(R.layout.myjob_converted, container, false);
        init(rootview);

        IntentFilter filter = new IntentFilter();
        filter.addAction("com.app.MyJob_Completed_Fragment");
        convertedReciver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                System.out.println("ongoing---------");
                Str_type = (String) intent.getExtras().get("Type");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");
                Str_from = (String) intent.getExtras().get("from");
                Str_to = (String) intent.getExtras().get("to");

                postJobRequestSorting(ServiceConstant.myjobs_sortingurl, Str_type);

                System.out.println("sortancompletedl-------" + ServiceConstant.myjobs_sortingurl);

            }
        };
        getActivity().registerReceiver(convertedReciver, filter);


        Rl_myjob_converted_empty_editprofile_layout.setOnClickListener(new View.OnClickListener() {
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
                    intent.putExtra("JobId", convertedlist.get(position).getOrder_id());
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
                                    Rl_myjob_converted_main_layout.setVisibility(View.VISIBLE);
                                    Rl_myjob_converted_nointernet_layout.setVisibility(View.GONE);
                                    layout_nojobs_converted.setVisibility(View.GONE);
                                    myjob_LoadMore_converted_PostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);
                                    System.out.println("--------------newleads_loadmore-------------------" + ServiceConstant.MYJOBON_LIST_URL);
                                } else {
                                    Rl_myjob_converted_main_layout.setVisibility(View.GONE);
                                    Rl_myjob_converted_nointernet_layout.setVisibility(View.VISIBLE);
                                    layout_nojobs_converted.setVisibility(View.GONE);


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
                    Rl_myjob_converted_main_layout.setVisibility(View.VISIBLE);
                    Rl_myjob_converted_nointernet_layout.setVisibility(View.GONE);
                    layout_nojobs_converted.setVisibility(View.GONE);

                    asyntask_name = "swipe";
                    myjob_converted_PostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);
                } else {
                    swipeRefreshLayout.setRefreshing(false);
                    Rl_myjob_converted_main_layout.setVisibility(View.GONE);
                    Rl_myjob_converted_nointernet_layout.setVisibility(View.VISIBLE);
                    layout_nojobs_converted.setVisibility(View.GONE);
                }
            }
        });

        return rootview;

    }


    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        convertedlist = new ArrayList<MyjobConverted_Pojo>();
        mHandler = new Handler();
        socketHandler = SocketHandler.getInstance(getActivity());

        completedjobs="1";
        listView = (ListView) rootview.findViewById(R.id.myjobs_converted_listView);
        layout_nojobs_converted = (RelativeLayout) rootview.findViewById(R.id.no_jobs_converted_layout);
        loadmore = (FrameLayout) rootview.findViewById(R.id.myjob_converted_fragment_loadmoreprogress);
        Rl_myjob_converted_main_layout = (RelativeLayout) rootview.findViewById(R.id.myjob_converted_mainlayout);
        Rl_myjob_converted_nointernet_layout = (RelativeLayout) rootview.findViewById(R.id.layout_myjob_converted_noInternet);
        Rl_myjob_converted_empty_editprofile_layout = (RelativeLayout) rootview.findViewById(R.id.layout_go_profile_myjob_converted);

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            Rl_myjob_converted_main_layout.setVisibility(View.VISIBLE);
            Rl_myjob_converted_nointernet_layout.setVisibility(View.GONE);
            layout_nojobs_converted.setVisibility(View.GONE);

            myjob_converted_PostRequest(getActivity(), ServiceConstant.MYJOBON_LIST_URL);

            System.out.println("convertedurl-----------" + ServiceConstant.MYJOBON_LIST_URL);

        } else {

            Rl_myjob_converted_main_layout.setVisibility(View.GONE);
            Rl_myjob_converted_nointernet_layout.setVisibility(View.VISIBLE);
            layout_nojobs_converted.setVisibility(View.GONE);

        }

        swipeRefreshLayout = (SwipeRefreshLayout) rootview.findViewById(R.id.myjob_converted_swipe_refresh_layout);
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


    //-----------------------Code for myjob converted post request-----------------

    private void myjob_converted_PostRequest(Context mContext, String url) {

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", "4");
        jsonParams.put("page", "1");
        jsonParams.put("perPage", "100");

        loadingDialog();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {


            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------------reponse-------------------" + response);
                Log.e("missed", response);
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

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {
                                convertedlist.clear();

                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyjobConverted_Pojo pojo = new MyjobConverted_Pojo();
                                    pojo.setConverted_address(object2.getString("location"));
                                    pojo.setConverted_category(object2.getString("category_name"));
                                    pojo.setConverted_date(object2.getString("booking_time"));
                                    pojo.setConverted_user_name(object2.getString("user_name"));
                                    pojo.setConverted_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setConvertedjob_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    convertedlist.add(pojo);
                                    isConvertedJobAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isConvertedJobAvailable = false;
                            }
                        } else {

                            isConvertedJobAvailable = false;

                        }
                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {

                        if (isConvertedJobAvailable) {
                            adapter = new MyjobConverted_Adapter(getActivity(), convertedlist);
                            listView.setAdapter(adapter);

                            if (show_progress_status) {
                                layout_nojobs_converted.setVisibility(View.GONE);
                            } else {
                                layout_nojobs_converted.setVisibility(View.VISIBLE);
                                listView.setEmptyView(layout_nojobs_converted);
                            }
                        } else {
                            layout_nojobs_converted.setVisibility(View.VISIBLE);
                            listView.setEmptyView(layout_nojobs_converted);
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


    //-------------------------Myjob converted Load more------------------------------
    private void myjob_LoadMore_converted_PostRequest(Context mContext, String url) {

        loadmore.setVisibility(View.VISIBLE);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", "closed");
        jsonParams.put("page", Str_Pagination);
        jsonParams.put("perPage", Str_PageDateCount);

        System.out.println("--------------loadmore page-------------------" + Str_Nextpage);

        System.out.println("--------------loadmore perpage--------------------" + Str_PageDateCount);

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------------reponse-------------------" + response);
                Log.e("converted", response);
                String Str_status = "", Str_totaljobs = "", Str_Response = "";

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
                                    MyjobConverted_Pojo pojo = new MyjobConverted_Pojo();
                                    pojo.setConverted_address(object2.getString("location"));
                                    pojo.setConverted_category(object2.getString("category_name"));
                                    pojo.setConverted_date(object2.getString("booking_time"));
                                    pojo.setConverted_user_name(object2.getString("user_name"));
                                    pojo.setConverted_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setConvertedjob_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    convertedlist.add(pojo);
                                    isConvertedJobAvailable = true;

                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isConvertedJobAvailable = false;
                            }
                        } else {
                            isConvertedJobAvailable = false;
                        }

                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        loadingMore = false;
                        loadmore.setVisibility(View.GONE);

                        if (show_progress_status) {
                            adapter.notifyDataSetChanged();
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
        jsonParams.put("from", Str_from);
        jsonParams.put("to", Str_to);


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
                String Str_status = "", Str_totaljobs = "", Str_Response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        convertedlist.clear();
                        JSONObject object = jobject.getJSONObject("response");
                        Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");
                        Str_totaljobs = object.getString("total_jobs");

                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {

                            JSONArray jarry = object.getJSONArray("jobs");
                            if (jarry.length() > 0) {
                                convertedlist.clear();

                                for (int i = 0; i < jarry.length(); i++) {
                                    JSONObject object2 = jarry.getJSONObject(i);
                                    MyjobConverted_Pojo pojo = new MyjobConverted_Pojo();
                                    pojo.setConverted_address(object2.getString("location"));
                                    pojo.setConverted_category(object2.getString("category_name"));
                                    pojo.setConverted_date(object2.getString("booking_time"));
                                    pojo.setConverted_user_name(object2.getString("user_name"));
                                    pojo.setConverted_user_image(object2.getString("user_image"));
                                    pojo.setOrder_id(object2.getString("job_id"));
                                    pojo.setConvertedjob_status(object2.getString("job_status"));
                                    String address= getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(address);
                                    convertedlist.add(pojo);
                                    isConvertedJobAvailable = true;
                                }
                                show_progress_status = true;
                            } else {
                                show_progress_status = false;
                                isConvertedJobAvailable = false;
                            }
                        } else {

                            isConvertedJobAvailable = false;

                        }
                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {

                        if (isConvertedJobAvailable) {
                            adapter = new MyjobConverted_Adapter(getActivity(), convertedlist);
                            listView.setAdapter(adapter);
                            adapter.notifyDataSetChanged();

                            if (show_progress_status) {
                                layout_nojobs_converted.setVisibility(View.GONE);
                            } else {
                                layout_nojobs_converted.setVisibility(View.VISIBLE);
                                listView.setEmptyView(layout_nojobs_converted);
                            }
                        } else {
                            layout_nojobs_converted.setVisibility(View.VISIBLE);
                            listView.setEmptyView(layout_nojobs_converted);
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
//starting XMPP service

       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
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
    public void onDestroy() {
        getActivity().unregisterReceiver(convertedReciver);
        super.onDestroy();
    }


}
