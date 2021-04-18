package com.a2zkaj.app;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.CompoundButton;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.ToggleButton;

import com.android.volley.Request;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;

import core.Dialog.LoadingDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;


/**
 * Created by user88 on 11/28/2015.
 */
public class HomePage extends FragmentHockeyApp {

    private ImageView drawer_img;
    private static View rootview;
    private RelativeLayout layout_drawer, Rl_chat_layout;
    private ToggleButton online_offline_toggle;
    private ImageView NewLeads_img, Statists_Img, MyJobs_Img, Support_Img;
    private Dialog dialog;
    private String provider_id;
    private LoadingDialog dialog1;
    SessionManager session;
    private SocketHandler socketHandler;
    String Appinfoemail = "";

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             final Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        rootview = inflater.inflate(R.layout.home_page, container, false);
        init(rootview);

        layout_drawer.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                NavigationDrawer.openDrawer();
            }
        });
        Rl_chat_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), ChatList.class);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


        NewLeads_img.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), NewLeadsPage.class);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

            }
        });


        Statists_Img.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), StatisticsPage.class);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


        MyJobs_Img.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getActivity(), MyJobs.class);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

        Support_Img.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                shareToGMail("quickrabbit@gmail.com", "", "");
              /* Intent intent = new Intent(getActivity(),SupportPage.class);
                startActivity(intent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);*/
            }
        });

        return rootview;

    }

    private void init(View rootview) {

        socketHandler = SocketHandler.getInstance(getActivity());
        session = new SessionManager(getActivity());
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        HashMap<String, String> infomail = session.getUserDetails();
        Appinfoemail = infomail.get(SessionManager.KEY_Appinfo_email);
        drawer_img = (ImageView) rootview.findViewById(R.id.home_navigation_icon);
        layout_drawer = (RelativeLayout) rootview.findViewById(R.id.home_navigation_layout_icon);
        NewLeads_img = (ImageView) rootview.findViewById(R.id.home_plumbal_newleads);
        Statists_Img = (ImageView) rootview.findViewById(R.id.home_plumbal_statists);
        MyJobs_Img = (ImageView) rootview.findViewById(R.id.home_plumbal_myorders);
        Support_Img = (ImageView) rootview.findViewById(R.id.home_plumbal_support);
        Rl_chat_layout = (RelativeLayout) rootview.findViewById(R.id.hometab_header_notification_relativelayout);
        online_offline_toggle = (ToggleButton) rootview.findViewById(R.id.online_offline_toggle);
        online_offline_toggle.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
                if (isChecked) {

                    online_offline_toggle.setBackgroundResource(R.drawable.background_online_btn);
                    postSetOnlineStatus(ServiceConstant.AVAILABILITY_URL, getContext(), 0);
                } else {

                    online_offline_toggle.setBackgroundResource(R.drawable.togglebuttonclick);
                    postSetOnlineStatus(ServiceConstant.AVAILABILITY_URL, getContext(), 1);
                }
            }


        });
    }

    private void loadDialog() {
        dialog = new Dialog(getContext());
        dialog.getWindow();
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.custom_loading);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
    }

    private void postSetOnlineStatus(String url, Context context, int state) {
        // loadDialog();


        dialog1 = new LoadingDialog(getContext());
        dialog1.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog1.show();
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("tasker", provider_id);
        jsonParams.put("availability", "" + state);
        ServiceRequest mservicerequest = new ServiceRequest(context);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                dialog1.dismiss();
                String status = "", responseString = "";
                System.out.println("Online Status-----------------------" + response);
                try {
                    JSONObject jobject = new JSONObject(response);
                    status = jobject.getString("status");
                    if (status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");
                        status = object.getString("tasker_status");

                    } else {


                    }
                    session.Taskerstatus(status);

                } catch (Exception e) {
                    e.printStackTrace();
                    dialog1.dismiss();
                }
            }

            @Override
            public void onErrorListener() {
                dialog1.dismiss();
            }
        });
    }

    @Override
    public void onPause() {
        super.onPause();
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

    public void shareToGMail(String email, String subject, String content) {
        Intent emailIntent = new Intent(Intent.ACTION_SEND);
        //  emailIntent.putExtra(Intent.EXTRA_EMAIL, email);
        emailIntent.putExtra(Intent.EXTRA_EMAIL, new String[]{Appinfoemail});
        emailIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        emailIntent.setType("text/plain");
        emailIntent.putExtra(Intent.EXTRA_TEXT, content);
        final PackageManager pm = getActivity().getPackageManager();
        final List<ResolveInfo> matches = pm.queryIntentActivities(emailIntent, 0);
        ResolveInfo best = null;
        for (final ResolveInfo info : matches)
            if (info.activityInfo.packageName.endsWith(".gm") || info.activityInfo.name.toLowerCase().contains("gmail"))
                best = info;
        if (best != null)
            emailIntent.setClassName(best.activityInfo.packageName, best.activityInfo.name);
        getActivity().startActivity(emailIntent);
    }


    public void onResume() {
        super.onResume();
    }


}


