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
import com.a2zkaj.adapter.NewLeadsFragment_Adapter;
import com.a2zkaj.Pojo.NewLeadsPojo;
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
 * Created by user88 on 12/15/2015.
 */
public class NewLeads_Fragment extends FragmentHockeyApp {

    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private ConnectionDetector cd;

    private NewLeadsFragment_Adapter adapter;
    private NewLeadsPojo pojo;

    private StringRequest postrequest;
    private LoadingDialog dialog;
    private String provider_id = "", provider_name = "";
    private SessionManager session;
    private SwipeRefreshLayout swipeRefreshLayout = null;
    private FrameLayout loadmore;

    private String asyntask_name = "normal";
    private boolean loadingMore = false;
    private boolean isNewLeadsAvailable = false;
    BroadcastReceiver newleadsReciver;

    String Str_type = "", Str_sortby = "", Str_orderby = "", Strfrom = "", Strto = "";

    String filter_type = "";

    private Handler mHandler;
    private ServiceRequest mRequest;

    private ArrayList<NewLeadsPojo> newleadslist;
    private ListView listView;
    private RelativeLayout layout_nojobs;

    private String Str_Pagination = "", Str_PageDateCount = "", Str_Nextpage = "";

    private RelativeLayout Rl_newleads_main_layout, Rl_newleads_empty_editprofile_layout, RL_newleads_empty_layout, Rl_new_leads_nointernet_layout;
    private String lat = "", longi = "", Address = "";

    private SocketHandler socketHandler;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootview = inflater.inflate(R.layout.newleads_fragement, container, false);

        init(rootview);

        IntentFilter filter = new IntentFilter();
        filter.addAction("com.app.NewLeads_Fragment");
        newleadsReciver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {

                System.out.println("newleads---------");
                Str_sortby = (String) intent.getExtras().get("SortBy");
                Str_orderby = (String) intent.getExtras().get("OrderBy");
                Strfrom = (String) intent.getExtras().get("from");
                Strto = (String) intent.getExtras().get("to");
                filter_type = (String) intent.getExtras().get("filter_type");

                if (filter_type.equalsIgnoreCase("today") || filter_type.equalsIgnoreCase("recent") || filter_type.equalsIgnoreCase("upcoming")) {

                    postJobRequestSorting(ServiceConstant.Filter_booking_url);
                } else {

                    postJobRequestSorting(ServiceConstant.myjobs_sortingurl);
                }

                System.out.println("sortopen-------" + ServiceConstant.myjobs_sortingurl);

            }
        };
        getActivity().registerReceiver(newleadsReciver, filter);


        Rl_newleads_empty_editprofile_layout.setOnClickListener(new View.OnClickListener() {
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
                    intent.putExtra("JobId", newleadslist.get(position).getNewleads_order_id());
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
                                    Rl_newleads_main_layout.setVisibility(View.VISIBLE);
                                    Rl_new_leads_nointernet_layout.setVisibility(View.GONE);
                                    layout_nojobs.setVisibility(View.GONE);

                                    myNewLeads_LoadMore_PostRequest(getActivity(), ServiceConstant.NEWLEADS_URL);
                                    System.out.println("--------------newleads_loadmore-------------------" + ServiceConstant.NEWLEADS_URL);
                                } else {
                                    Rl_newleads_main_layout.setVisibility(View.GONE);
                                    Rl_new_leads_nointernet_layout.setVisibility(View.VISIBLE);
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
                    Rl_newleads_main_layout.setVisibility(View.VISIBLE);
                    Rl_new_leads_nointernet_layout.setVisibility(View.GONE);
                    layout_nojobs.setVisibility(View.GONE);

                    swipeRefreshLayout.setRefreshing(false);
                    asyntask_name = "swipe";

                    myNewLeadsPostRequest(getActivity(), ServiceConstant.NEWLEADS_URL);


                } else {
                    swipeRefreshLayout.setRefreshing(false);

                    Rl_newleads_main_layout.setVisibility(View.GONE);
                    Rl_new_leads_nointernet_layout.setVisibility(View.VISIBLE);
                    layout_nojobs.setVisibility(View.GONE);
                }
            }
        });

        return rootview;

    }

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(getActivity());
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


    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        newleadslist = new ArrayList<NewLeadsPojo>();
        mHandler = new Handler();
        socketHandler = SocketHandler.getInstance(getActivity());

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        provider_name = user.get(SessionManager.KEY_PROVIDERNAME);

        listView = (ListView) rootview.findViewById(R.id.newleads_listView);
        layout_nojobs = (RelativeLayout) rootview.findViewById(R.id.no_newleads_layout);
        loadmore = (FrameLayout) rootview.findViewById(R.id.newlead_fragment_loadmoreprogress);
        Rl_newleads_main_layout = (RelativeLayout) rootview.findViewById(R.id.new_leads_main_layout);
        Rl_new_leads_nointernet_layout = (RelativeLayout) rootview.findViewById(R.id.new_leads_noInternet_layout);
        Rl_newleads_empty_editprofile_layout = (RelativeLayout) rootview.findViewById(R.id.layout_go_profile);


        isInternetPresent = cd.isConnectingToInternet();

        if (isInternetPresent) {
            Rl_newleads_main_layout.setVisibility(View.VISIBLE);
            Rl_new_leads_nointernet_layout.setVisibility(View.GONE);
            layout_nojobs.setVisibility(View.GONE);
            myNewLeadsPostRequest(getActivity(), ServiceConstant.NEWLEADS_URL);

            System.out.println("newleadsurl-------------------" + ServiceConstant.NEWLEADS_URL);

        } else {
            Rl_newleads_main_layout.setVisibility(View.GONE);
            Rl_new_leads_nointernet_layout.setVisibility(View.VISIBLE);
            layout_nojobs.setVisibility(View.GONE);

        }

        swipeRefreshLayout = (SwipeRefreshLayout) rootview.findViewById(R.id.newleads_swipe_refresh_layout);
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


    private void myNewLeadsPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("page", "1");
        jsonParams.put("perPage", "100");

        System.out.println("provider_id-----------" + provider_id);
        System.out.println("page-----------" + "1");
        System.out.println("perPage-----------" + "2");

        loadingDialog();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------------reponsenewleads-------------------" + response);

                Log.e("new", response);

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
                                newleadslist.clear();
                                for (int i = 0; i < jarray.length(); i++) {
                                    JSONObject object2 = jarray.getJSONObject(i);
                                    NewLeadsPojo pojo = new NewLeadsPojo();

                                    pojo.setNewleads_user_name(object2.getString("user_name"));
                                    pojo.setNewleads_category(object2.getString("category_name"));
                                    pojo.setNewleads_jabtimeand_date(object2.getString("booking_time"));
                                    pojo.setNewleads_location(object2.getString("location"));
                                    pojo.setNewleads_order_id(object2.getString("job_id"));
                                    pojo.setNewleads_jobtime(object2.getString("job_time"));
                                    pojo.setNewleads_jobstatus(object2.getString("job_status"));
                                    pojo.setNewleads_user_image(object2.getString("user_image"));
                                    pojo.setLatitude(object2.getString("location_lat"));
                                    pojo.setLongitude(object2.getString("location_lng"));
                                    String Address = getCompleteAddressString(Double.parseDouble(object2.getString("location_lat")),
                                            Double.parseDouble(object2.getString("location_lng")));
                                    pojo.setAddress(Address);

                                    newleadslist.add(pojo);
                                    isNewLeadsAvailable = true;
                                }
                                show_progress_status = true;

                            } else {
                                isNewLeadsAvailable = false;
                                show_progress_status = false;
                            }

                        } else {
                            isNewLeadsAvailable = false;
                        }

                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {

                        if (isNewLeadsAvailable) {
                            adapter = new NewLeadsFragment_Adapter(getActivity(), newleadslist);
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
                ;
            }
        });

    }

    //-------------Method to get Complete Address------------
    private String getCompleteAddressString(double LATITUDE, double LONGITUDE) {
        String strAdd = "";
        String loc_addr="";
        Geocoder geocoder = new Geocoder(getActivity(), Locale.getDefault());
        try {
            List<android.location.Address> addresses = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addresses != null) {
                Address returnedAddress = addresses.get(0);
                StringBuilder strReturnedAddress = new StringBuilder("");

                loc_addr=returnedAddress.getAddressLine(0);
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

    private void myNewLeads_LoadMore_PostRequest(Context mContext, String url) {

        loadmore.setVisibility(View.VISIBLE);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("page", Str_Pagination);
        jsonParams.put("perPage", Str_PageDateCount);

        System.out.println("loadmoreprovider_id--------------" + provider_id);
        System.out.println("loadmorepage--------------" + Str_Pagination);
        System.out.println("loadmorepperPage--------------" + Str_PageDateCount);


        System.out.println("--------------loadmore page-------------------" + Str_Nextpage);
        System.out.println("--------------loadmore perpage--------------------" + Str_PageDateCount);

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("newleadsloadmore", response);
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

                            JSONArray jarray = object.getJSONArray("jobs");

                            if (jarray.length() > 0) {

                                for (int i = 0; i < jarray.length(); i++) {
                                    JSONObject object2 = jarray.getJSONObject(i);
                                    NewLeadsPojo pojo = new NewLeadsPojo();

                                    pojo.setNewleads_user_name(object2.getString("user_name"));
                                    pojo.setNewleads_category(object2.getString("category_name"));
                                    pojo.setNewleads_jabtimeand_date(object2.getString("booking_time"));
                                    pojo.setNewleads_location(object2.getString("location"));
                                    pojo.setNewleads_order_id(object2.getString("job_id"));
                                    pojo.setNewleads_jobtime(object2.getString("job_time"));
                                    pojo.setNewleads_jobstatus(object2.getString("job_status"));
                                    pojo.setNewleads_user_image(object2.getString("user_image"));

                                    newleadslist.add(pojo);
                                    isNewLeadsAvailable = true;
                                }
                                show_progress_status = true;

                            } else {
                                show_progress_status = false;
                                isNewLeadsAvailable = false;
                            }

                        } else {

                            isNewLeadsAvailable = false;
                        }
                    } else {
                        Str_response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        loadmore.setVisibility(View.GONE);

                        if (show_progress_status) {
                            adapter.notifyDataSetChanged();
                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);

                        loadmore.setVisibility(View.GONE);
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

        if (filter_type.equalsIgnoreCase("today") || filter_type.equalsIgnoreCase("recent") || filter_type.equalsIgnoreCase("upcoming")) {
            jsonParams.put("provider_id", provider_id);
            jsonParams.put("type", filter_type);
            jsonParams.put("page", "1");
            jsonParams.put("perPage", "20");
            jsonParams.put("orderby", Str_orderby);
            jsonParams.put("sortby", Str_sortby);

        } else {

            jsonParams.put("provider_id", provider_id);
            jsonParams.put("type", "1");
            jsonParams.put("page", "0");
            jsonParams.put("perPage", "50");
            jsonParams.put("orderby", Str_orderby);
            jsonParams.put("sortby", Str_sortby);
            jsonParams.put("from", Strfrom);
            jsonParams.put("to", Strto);
        }


        System.out.println("---------from------------" + Strfrom);
        System.out.println("---------to------------" + Strto);
        System.out.println("---------orderby------------" + Str_orderby);
        System.out.println("---------sortby------------" + Str_sortby);

        System.out.println("---------My Jobs user_id------------" + provider_id);
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
                        // Str_Pagination = object.getString("next_page");
                        Str_PageDateCount = object.getString("perPage");
                        Str_totaljobs = object.getString("total_jobs");


                        Object check_list_object = object.get("jobs");
                        if (check_list_object instanceof JSONArray) {
                            JSONArray jarray = object.getJSONArray("jobs");

                            if (jarray.length() > 0) {
                                newleadslist.clear();
                                for (int i = 0; i < jarray.length(); i++) {
                                    JSONObject object2 = jarray.getJSONObject(i);
                                    NewLeadsPojo pojo = new NewLeadsPojo();

                                    pojo.setNewleads_user_name(object2.getString("user_name"));
                                    pojo.setNewleads_category(object2.getString("category_name"));
                                    pojo.setNewleads_jabtimeand_date(object2.getString("booking_time"));
                                    pojo.setNewleads_location(object2.getString("location"));
                                    pojo.setNewleads_order_id(object2.getString("job_id"));
                                    pojo.setNewleads_jobtime(object2.getString("job_time"));
                                    pojo.setNewleads_jobstatus(object2.getString("job_status"));
                                    pojo.setNewleads_user_image(object2.getString("user_image"));

                                    newleadslist.add(pojo);
                                    isNewLeadsAvailable = true;
                                }
                                show_progress_status = true;

                            } else {
                                isNewLeadsAvailable = false;
                                show_progress_status = false;
                            }

                        } else {
                            isNewLeadsAvailable = false;
                        }

                    } else {
                        newleadslist.clear();
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {

                        if (isNewLeadsAvailable) {
                            adapter = new NewLeadsFragment_Adapter(getActivity(), newleadslist);
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
                        newleadslist.clear();
                        listView.setEmptyView(layout_nojobs);

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
        getActivity().unregisterReceiver(newleadsReciver);
        super.onDestroy();
    }

}
