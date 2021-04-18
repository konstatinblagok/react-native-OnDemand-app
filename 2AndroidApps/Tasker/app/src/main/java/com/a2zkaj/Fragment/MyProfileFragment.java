package com.a2zkaj.Fragment;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.text.Html;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.RatingBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.Pojo.Availabilitypojo;
import com.a2zkaj.Pojo.ProviderCategory;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.Availabilityadapter;
import com.a2zkaj.adapter.ProviderCategoryAdapter;
import com.a2zkaj.app.EditProfilePage;
import com.a2zkaj.app.R;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;
import com.squareup.picasso.Picasso;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.Widgets.CircularImageView;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 1/6/2016.
 */
public class MyProfileFragment extends FragmentHockeyApp {

    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private ConnectionDetector cd;
    private SessionManager session;

    private static CircularImageView profile_img;
    private TextView Tv_profile_name, Tv_profile_email, Tv_profile_desigaination, Tv_profile_mobile_no, Tv_profile_bio, Tv_profile_address, Tv_profile_category;
    private RatingBar profile_rating;
    private RelativeLayout Rl_layout_edit_profile, Rl_layout_main, Rl_layout_profile_nointernet, Rl_layout_profile_bio, Rl_layout_profile_address, Rl_layout_category;
    private static Context context;
    private String provider_id = "";
    private static String profile_pic = "";
    ListView list;
    private LoadingDialog dialog;
    Availabilityadapter availadapter;
    private String Str_provider_image = "";
    private ArrayList<Availabilitypojo> availlist;
    private SocketHandler socketHandler;
    private RelativeLayout myExperienceLAY, myRadiusLAY, myWorkLocationLAY;
    private TextView myExperienceTXT, myWorkLocationTXT, myRadiusTXT;

    private String radius_mi_km = "";

    private TextView rating;

    private ListView cat_list;
    private ArrayList<String> listItems;
    private ArrayList<ProviderCategory> cat_list_item = new ArrayList<ProviderCategory>();
    private ProviderCategoryAdapter provider_adapter;

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.package.load.editpage")) {
                myprofilePostRequest(getActivity(), ServiceConstant.PROFILEINFO_URL);

            }
        }
    }

    private RefreshReceiver finishReceiver;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootview = inflater.inflate(R.layout.new_tasker_profile, container, false);

        init(rootview);

        Rl_layout_edit_profile.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), EditProfilePage.class);
                intent.putExtra("radius_mi_or_km",radius_mi_km);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

            }
        });

        return rootview;

    }

    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        context = getActivity();
        socketHandler = SocketHandler.getInstance(getActivity());
        availlist = new ArrayList<Availabilitypojo>();
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        profile_pic = user.get(SessionManager.KEY_USERIMAGE);

        System.out.println("profile_pic----------------" + profile_pic);
        list = (ListView) rootview.findViewById(R.id.list);
        profile_img = (CircularImageView) rootview.findViewById(R.id.profile_user_img);
        Tv_profile_name = (TextView) rootview.findViewById(R.id.profile_username_Tv);
        // Tv_profile_desigaination = (TextView)rootview.findViewById(R.id.profile_desigination_Tv);
        Tv_profile_email = (TextView) rootview.findViewById(R.id.profile_email_Tv);
        Tv_profile_mobile_no = (TextView) rootview.findViewById(R.id.profile_mobile_Tv);
        Tv_profile_bio = (TextView) rootview.findViewById(R.id.profile_bio_Tv);
        Tv_profile_address = (TextView) rootview.findViewById(R.id.profile_address_Tv);
        Tv_profile_category = (TextView) rootview.findViewById(R.id.profile_category_Tv);
        profile_rating = (RatingBar) rootview.findViewById(R.id.user_ratting);
        Rl_layout_edit_profile = (RelativeLayout) rootview.findViewById(R.id.layout_edit_profile);
        Rl_layout_profile_nointernet = (RelativeLayout) rootview.findViewById(R.id.layout_profile_noInternet);
        Rl_layout_main = (RelativeLayout) rootview.findViewById(R.id.layout_profile_main);


        Rl_layout_profile_bio = (RelativeLayout) rootview.findViewById(R.id.profile_bio_layout);
        Rl_layout_profile_address = (RelativeLayout) rootview.findViewById(R.id.profile_address_layout);
        Rl_layout_category = (RelativeLayout) rootview.findViewById(R.id.profile_category_layout);
        myExperienceLAY = (RelativeLayout) rootview.findViewById(R.id.experience_layout);
        myWorkLocationLAY = (RelativeLayout) rootview.findViewById(R.id.profile_worklocation_layout);
        myRadiusLAY = (RelativeLayout) rootview.findViewById(R.id.profile_radius_layout);

        myExperienceTXT = (TextView) rootview.findViewById(R.id.profile_experience_Tv);
        myWorkLocationTXT = (TextView) rootview.findViewById(R.id.profile_worklocation_Tv);
        myRadiusTXT = (TextView) rootview.findViewById(R.id.profile_radius_Tv);
        rating = (TextView) rootview.findViewById(R.id.rating);
        cat_list=(ListView)rootview.findViewById(R.id.cat_list);
        listItems = new ArrayList<>();

        Picasso.with(getActivity()).load(String.valueOf(profile_pic)).placeholder(R.drawable.nouserimg).into(profile_img);

        System.out.println("profile_pic1----------------" + profile_pic);

        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {

            Rl_layout_main.setVisibility(View.VISIBLE);
            Rl_layout_profile_nointernet.setVisibility(View.GONE);
            myprofilePostRequest(getActivity(), ServiceConstant.PROFILEINFO_URL);
            System.out.println("myprofileurl---------" + ServiceConstant.PROFILEINFO_URL);

        } else {
            Rl_layout_main.setVisibility(View.GONE);
            Rl_layout_profile_nointernet.setVisibility(View.VISIBLE);

        }
        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.package.load.editpage");
        context.registerReceiver(finishReceiver, intentFilter);

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

    public static void profileimgNotifyChange() {

        Picasso.with(context).load(String.valueOf(profile_pic)).placeholder(R.drawable.nouserimg).into(profile_img);
    }

    private void myprofilePostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);

        System.out.println("provider_id----------------" + provider_id);

        dialog = new LoadingDialog(getActivity());
        dialog.setLoadingTitle(getResources().getString(R.string.action_gettinginfo));
        dialog.show();


        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("profile", response);

                String Str_Status = "", Str_response = "", Str_name = "", Str_designation = "", Str_rating = "", Str_email = "", Str_mobileno = "", Str_bio = "",
                        Str_addrress = "", Str_category = "", aExperienceStr = "", aWorkLocationStr = "", aRadiusStr = "", aDialcode = "";
                String availdays = "";
                String morning = "", afternoon = "", evening = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    if (Str_Status.equalsIgnoreCase("1")) {

                        listItems.clear();
                        cat_list_item.clear();

                        JSONObject object = jobject.getJSONObject("response");
                        Str_name = object.getString("provider_name");
                        Str_designation = object.getString("designation");
                        Str_rating = object.getString("avg_review");
                        Str_email = object.getString("email");

                        if (object.has("mobile_number")) {
                            Str_mobileno = object.getString("mobile_number");
                        }

                        if (object.has("dial_code")) {

                            aDialcode = object.getString("dial_code");
                        }

                        Str_bio = object.getString("bio");
                        Str_category = object.getString("category").replace("\\n", "<br/>");
                        Str_provider_image = object.getString("image");
                        aExperienceStr = object.getString("experience");
                        aWorkLocationStr = object.getString("Working_location");
                        aRadiusStr = object.getString("radius");
                        Str_addrress = object.getString("address_str");
                        JSONArray array1 = object.getJSONArray("availability_days");
                        availlist.clear();
                        for (int i = 0; i < array1.length(); i++) {

                            JSONObject ob = (JSONObject) array1.get(i);
                            Availabilitypojo pojo = new Availabilitypojo();
                            pojo.setDays(ob.getString("day"));

                            availdays = ob.getString("day");
                            JSONObject hourob = ob.getJSONObject("hour");
                            pojo.setMorning(hourob.getString("morning"));
                            pojo.setAfternoon(hourob.getString("afternoon"));
                            pojo.setEvening(hourob.getString("evening"));
                            morning = hourob.getString("morning");
                            afternoon = hourob.getString("afternoon");
                            evening = hourob.getString("evening");
                            availlist.add(pojo);
                        }

                        availadapter = new Availabilityadapter(getActivity(), availlist);
                        list.setAdapter(availadapter);

                        if (object.has("category_Details")) {

                            JSONArray cat_array = object.getJSONArray("category_Details");
                            if (cat_array.length() > 0) {

                                for (int i = 0; i < cat_array.length(); i++) {

                                    JSONObject obs = cat_array.getJSONObject(i);
                                    ProviderCategory pojo = new ProviderCategory();
                                    String cat_name = obs.getString("categoryname");
                                    String hour_amt = obs.getString("hourlyrate");
                                    pojo.setCategory_name(cat_name);
                                    pojo.setHourly_rate(hour_amt);
                                    cat_list_item.add(pojo);
                                }

                            }

                            for (int j = 0; j < cat_list_item.size(); j++) {

                                listItems.add(String.valueOf(j));
                            }

                            provider_adapter = new ProviderCategoryAdapter(getActivity(), listItems, cat_list_item);
                            cat_list.setAdapter(provider_adapter);

                            setListViewHeightBasedOnChildren(cat_list);

                        }

                    } else {
                        Str_response = jobject.getString("response");
                    }
                    if (Str_Status.equalsIgnoreCase("1")) {


                        System.out.println("---------------Category detail text-------------------" + Html.fromHtml(Str_category));


                        Tv_profile_name.setText(Str_name);
                        // Tv_profile_desigaination.setText(Str_designation);
                        //profile_rating.setRating(Float.parseFloat(Str_rating));
                        rating.setText(Str_rating);
                        Tv_profile_mobile_no.setText(aDialcode + " " + Str_mobileno);
                        Tv_profile_category.setText(Html.fromHtml(Str_category + "<br/>"));
                        Tv_profile_email.setText(Str_email);
                        Tv_profile_address.setText(Str_addrress);
                        Picasso.with(getActivity()).load(String.valueOf(Str_provider_image)).placeholder(R.drawable.nouserimg).into(profile_img);
                        session.setUserImageUpdate(Str_provider_image);

                        System.out.println("");

                        if (aRadiusStr.length() > 0) {
                            myRadiusTXT.setText(aRadiusStr);
                            radius_mi_km = aRadiusStr;
                        } else {

                        }

                        if (aWorkLocationStr.length() > 0) {
                            myWorkLocationTXT.setText(aWorkLocationStr);
                        } else {

                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
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

    public static void setListViewHeightBasedOnChildren(ListView listView) {
        ListAdapter listAdapter = listView.getAdapter();
        if (listAdapter == null) {
            // pre-condition
            return;
        }
        int totalHeight = 0;
        for (int i = 0; i < listAdapter.getCount(); i++) {
            View listItem = listAdapter.getView(i, null, listView);
            listItem.measure(0, 0);
            totalHeight += listItem.getMeasuredHeight();
        }

        ViewGroup.LayoutParams params = listView.getLayoutParams();
        params.height = totalHeight + (listView.getDividerHeight() * (listAdapter.getCount() - 1));
        listView.setLayoutParams(params);
        listView.requestLayout();
    }


    @Override
    public void onResume() {
        super.onResume();

    }

}
