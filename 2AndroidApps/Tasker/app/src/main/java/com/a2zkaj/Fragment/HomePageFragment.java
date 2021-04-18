package com.a2zkaj.Fragment;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.andexert.library.RippleView;
import com.android.volley.Request;
import com.nightonke.jellytogglebutton.JellyToggleButton;
import com.nightonke.jellytogglebutton.State;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.NavigationDrawer;
import com.a2zkaj.app.NewLeadsPage;
import com.a2zkaj.app.R;
import com.a2zkaj.app.StatisticsPage;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;

import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by CAS61 on 1/21/2017.
 */
public class HomePageFragment extends FragmentHockeyApp implements View.OnClickListener, JellyToggleButton.OnStateChangeListener, RippleView.OnRippleCompleteListener {

    private static View myView;
    private SessionManager mySession;
    private RelativeLayout myDrawerLAY;
    private String myProviderIdStr;
    private SocketHandler mySocketHandler;
    private String myAppInfoMailStr = "";
    private ImageView myDrawerIMG;
    private LoadingDialog myDialog;
    private RippleView myLeadsRPL, myJobsRPL, myStatiticsRPL, mySupportRPL;
    private String Appinfoemail = "";
    public static JellyToggleButton myStatusTGB;
    private TextView myAvailabilityTXT;
    private String tasker_availability_status="";
    public static boolean admin_avail_status=false;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             final Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        myView = inflater.inflate(R.layout.screen_home_page, container, false);
        classAndWidgetInitialize(myView);
        return myView;
    }

    private void classAndWidgetInitialize(View rootview) {

        mySocketHandler = SocketHandler.getInstance(getActivity());
        mySession = new SessionManager(getActivity());
        HashMap<String, String> user = mySession.getUserDetails();
        myProviderIdStr = user.get(SessionManager.KEY_PROVIDERID);
        HashMap<String, String> tasker_availaibilty_status = mySession.getUserDetails();
        tasker_availability_status = tasker_availaibilty_status.get(SessionManager.KEY_STATUS);
        HashMap<String, String> infomail = mySession.getUserDetails();
        Appinfoemail = infomail.get(SessionManager.KEY_Appinfo_email);
        myAppInfoMailStr = infomail.get(SessionManager.KEY_Appinfo_email);
        myDrawerIMG = (ImageView) rootview.findViewById(R.id.home_navigation_icon);
        myDrawerLAY = (RelativeLayout) rootview.findViewById(R.id.home_navigation_layout_icon);
        myLeadsRPL = (RippleView) rootview.findViewById(R.id.screen_home_page_RPL_leads);
        myJobsRPL = (RippleView) rootview.findViewById(R.id.screen_home_page_RPL_jobs);
        myStatiticsRPL = (RippleView) rootview.findViewById(R.id.screen_home_page_RPL_statistics);
        mySupportRPL = (RippleView) rootview.findViewById(R.id.screen_home_page_RPL_support);
        myStatusTGB = (JellyToggleButton) rootview.findViewById(R.id.screen_home_page_TGB_status);
        myAvailabilityTXT = (TextView) rootview.findViewById(R.id.screen_home_page_TXT_status);
        if(mySession.isLoggedIn()){
            if(tasker_availability_status.equalsIgnoreCase("")){
                postSetOnlineStatus(ServiceConstant.AVAILABILITY_URL, getContext(), 1);
            }
            else if(tasker_availability_status.equalsIgnoreCase("1")){
                myStatusTGB.setChecked(true);
            }
            else{
                myStatusTGB.setChecked(false);
            }
        }

        clickListener();
    }

    private void clickListener() {
        myDrawerLAY.setOnClickListener(this);
        myLeadsRPL.setOnRippleCompleteListener(this);
        myJobsRPL.setOnRippleCompleteListener(this);
        myStatiticsRPL.setOnRippleCompleteListener(this);
        mySupportRPL.setOnRippleCompleteListener(this);
        myStatusTGB.setOnStateChangeListener(this);
    }

    @Override
    public void onClick(View v) {

        switch (v.getId()) {
            case R.id.home_navigation_layout_icon:
                NavigationDrawer.openDrawer();
                break;
        }
    }

    @Override
    public void onComplete(RippleView aRippleView) {
        switch (aRippleView.getId()) {
            case R.id.screen_home_page_RPL_leads:
                Intent aNewLeadsIntent = new Intent(getActivity(), NewLeadsPage.class);
                startActivity(aNewLeadsIntent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                break;
            case R.id.screen_home_page_RPL_jobs:
                Intent aJobsIntent = new Intent(getActivity(), com.a2zkaj.app.MyJobs.class);
                aJobsIntent.putExtra("status","open");
                startActivity(aJobsIntent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                break;
            case R.id.screen_home_page_RPL_statistics:
                Intent aStatisticsIntent = new Intent(getActivity(), StatisticsPage.class);
                startActivity(aStatisticsIntent);
                getActivity().overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                break;
            case R.id.screen_home_page_RPL_support:
                shareToGMail("quickrabbit@gmail.com", "", "");
                break;

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


    @Override
    public void onStateChange(float process, State state, JellyToggleButton jtb) {


            if (state.equals(State.LEFT)) {
                 myAvailabilityTXT.setText(getResources().getString(R.string.unavailabe_title));

                    postSetOnlineStatus(ServiceConstant.AVAILABILITY_URL, getContext(), 0);


            } else if (state.equals(State.RIGHT)) {
                myAvailabilityTXT.setText(getResources().getString(R.string.availabe_title));

                    postSetOnlineStatus(ServiceConstant.AVAILABILITY_URL, getContext(), 1);
            }
    }

    private void postSetOnlineStatus(String url, Context context, int state) {
        // loadDialog();


        myDialog = new LoadingDialog(getContext());
        myDialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        myDialog.show();
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("tasker", myProviderIdStr);
        jsonParams.put("availability", "" + state);
        ServiceRequest mservicerequest = new ServiceRequest(context);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                myDialog.dismiss();
                String status = "", responseString = "";
                System.out.println("Online Status-----------------------" + response);
                try {
                    JSONObject jobject = new JSONObject(response);
                    status = jobject.getString("status");
                    if (status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");
                        status = object.getString("tasker_status");
                        if(status.equalsIgnoreCase("0")){
                            String message=object.getString("message");
                            Alert(getResources().getString(R.string.availability_title),getResources().getString(R.string.availability_message_off));
                        }else{
                            String message=object.getString("message");
                            Alert(getResources().getString(R.string.availability_title),getResources().getString(R.string.availability_message_on));
                        }

                    } else {


                    }
                    mySession.Taskerstatus(status);

                } catch (Exception e) {
                    e.printStackTrace();
                    myDialog.dismiss();
                }
            }

            @Override
            public void onErrorListener() {
                myDialog.dismiss();
            }
        });
    }

    private void Alert(String title, String alert) {
        final PkDialog mDialog = new PkDialog(getActivity());
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(alert);
        mDialog.setPositiveButton(
                getResources().getString(R.string.action_ok), new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        mDialog.dismiss();
                    }
                }
        );

        mDialog.show();
    }


    @Override
    public void onPause() {
        super.onPause();
        if (myDialog != null) {
            myDialog.dismiss();
        }
    }
}
