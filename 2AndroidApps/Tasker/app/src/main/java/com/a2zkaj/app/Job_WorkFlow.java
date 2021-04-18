package com.a2zkaj.app;

import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.adapter.JobWorkFlow_Adapter;
import com.a2zkaj.Pojo.WorkFlow_Pojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 1/8/2016.
 */
public class Job_WorkFlow extends ActionBarActivityHockeyApp {

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;

    private Dialog dialog;
    private boolean show_progress_status = false;

    private JobWorkFlow_Adapter adapter;
    ArrayList<WorkFlow_Pojo> workflow_list;

    private String provider_id = "", Str_jobId = "";
    private RelativeLayout Rl_workflow_main_layout, Rl_workflow_nointernet_layout, Rl_workflow_empty_layout, Rl_workflow_layout_back, Rl_workflow_date_time_layout;
    private ListView listview;

    private SocketHandler socketHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.job_workflow);
        initilize();

        Rl_workflow_layout_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

    }

    private void initilize() {
        session = new SessionManager(Job_WorkFlow.this);
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        cd = new ConnectionDetector(Job_WorkFlow.this);
        socketHandler = SocketHandler.getInstance(this);

        workflow_list = new ArrayList<WorkFlow_Pojo>();

        Intent i = getIntent();
        Str_jobId = i.getStringExtra("JobId");

        listview = (ListView) findViewById(R.id.job_workflow_listView);
        Rl_workflow_main_layout = (RelativeLayout) findViewById(R.id.job_workflow_main_layout);
        Rl_workflow_nointernet_layout = (RelativeLayout) findViewById(R.id.job_workflow_no_internetlayout);
        Rl_workflow_layout_back = (RelativeLayout) findViewById(R.id.layout_back_workflow);
        Rl_workflow_empty_layout = (RelativeLayout) findViewById(R.id.workflow_empty_timeline_layout);

        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            Rl_workflow_main_layout.setVisibility(View.VISIBLE);
            Rl_workflow_nointernet_layout.setVisibility(View.GONE);
            workflowPostRequest(Job_WorkFlow.this, ServiceConstant.JOB_WORKFLOW_URL);

            System.out.println("workflowurl-----------" + ServiceConstant.JOB_WORKFLOW_URL);

        } else {
            Rl_workflow_nointernet_layout.setVisibility(View.VISIBLE);
            Rl_workflow_main_layout.setVisibility(View.GONE);
        }
    }


    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(Job_WorkFlow.this);
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

    //-----------------------Getting workflow post request-------------------
    private void workflowPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", Str_jobId);

        System.out.println("job_id------------" + Str_jobId);

        System.out.println("provider_id------------" + provider_id);

        dialog = new Dialog(Job_WorkFlow.this);
        dialog.getWindow();
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.custom_loading);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();

        final TextView dialog_title = (TextView) dialog.findViewById(R.id.custom_loading_textview);
        dialog_title.setText(getResources().getString(R.string.action_loading));

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("workflow", response);

                String Str_Status = "", Str_Response = "", Str_jobStatus = "";

                try {
                    JSONObject jobject = new JSONObject(response);

                    Str_Status = jobject.getString("status");

                    if (Str_Status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");
                        Str_jobStatus = object.getString("job_status");
                        JSONArray jarry = object.getJSONArray("timeline");

                        if (jarry.length() > 0) {
                            for (int i = 0; i < jarry.length(); i++) {
                                JSONObject object2 = jarry.getJSONObject(i);
                                WorkFlow_Pojo pojo = new WorkFlow_Pojo();

                                pojo.setJob_title(object2.getString("title"));
                                pojo.setJob_date(object2.getString("date"));
                                pojo.setJob_time(object2.getString("time"));
                                pojo.setJobs_check(object2.getString("check"));
                                workflow_list.add(pojo);
                            }
                            show_progress_status = true;
                        } else {
                            show_progress_status = false;
                        }

                    } else {
                        Str_Response = jobject.getString("response");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
                dialog.dismiss();
                if (Str_Status.equalsIgnoreCase("1")) {

                    adapter = new JobWorkFlow_Adapter(Job_WorkFlow.this, workflow_list);
                    listview.setAdapter(adapter);

                    if (show_progress_status) {
                        Rl_workflow_empty_layout.setVisibility(View.GONE);
                    } else {
                        Rl_workflow_empty_layout.setVisibility(View.VISIBLE);
                        listview.setEmptyView(Rl_workflow_empty_layout);
                    }
                } else {
                    Alert(getResources().getString(R.string.server_lable_header), Str_Response);
                }
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }


    @Override
    public void onResume() {
        super.onResume();
    }

}
