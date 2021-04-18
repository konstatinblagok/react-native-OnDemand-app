package com.a2zkajuser.app;

import android.app.Dialog;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.github.paolorotolo.expandableheightlistview.ExpandableHeightListView;
import com.a2zkajuser.R;
import com.a2zkajuser.adapter.CancelJobAdapter;
import com.a2zkajuser.core.dialog.LoadingDialog;
import com.a2zkajuser.core.dialog.PkDialog;
import com.a2zkajuser.core.volley.ServiceRequest;
import com.a2zkajuser.iconstant.Iconstant;
import com.a2zkajuser.pojo.CancelJobPojo;
import com.a2zkajuser.utils.ConnectionDetector;
import com.a2zkajuser.utils.SessionManager;
import com.a2zkajuser.utils.SubClassActivity;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Casperon Technology on 1/19/2016.
 */
public class CancelJob extends SubClassActivity {
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager sessionManager;
    private String UserID = "";

    private RelativeLayout Rl_back, other_reason_rl;
    private ImageView Im_backIcon;
    private TextView Tv_headerTitle;

    private View moreAddressView;
    private Dialog moreAddressDialog;
    private EditText edit_reason;
    private Button other_submit, other_cancel;
    String Str_reason = "";

    private ServiceRequest mRequest;
    Dialog dialog;
    ArrayList<CancelJobPojo> itemList;
    CancelJobAdapter adapter;
    private ExpandableHeightListView listView;
    private String sJobId_intent = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.cancel_job);
        initialize();
        initializeHeaderBar();

        Rl_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                finish();
            }
        });

        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, final int position, long id) {
                cd = new ConnectionDetector(CancelJob.this);
                isInternetPresent = cd.isConnectingToInternet();

                if (isInternetPresent) {

                    final PkDialog mDialog = new PkDialog(CancelJob.this);
                    mDialog.setDialogTitle(getResources().getString(R.string.myJobs_cancel_job_alert_title));
                    mDialog.setDialogMessage(getResources().getString(R.string.myJobs_cancel_job_alert));
                    mDialog.setPositiveButton(getResources().getString(R.string.myJobs_cancel_job_alert_yes), new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            mDialog.dismiss();
                            cancel_MyRide(Iconstant.MyJobs_Cancel_Url, itemList.get(position).getReason());
                        }
                    });
                    mDialog.setNegativeButton(getResources().getString(R.string.myJobs_cancel_job_alert_no), new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            mDialog.dismiss();
                        }
                    });
                    mDialog.show();


                } else {
                    alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                }
            }
        });

    }

    private void initialize() {
        sessionManager = new SessionManager(CancelJob.this);
        cd = new ConnectionDetector(CancelJob.this);
        isInternetPresent = cd.isConnectingToInternet();

        listView = (ExpandableHeightListView) findViewById(R.id.cancel_job_listView);
        other_reason_rl = (RelativeLayout) findViewById(R.id.other_reason_rl);

        other_reason_rl.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                DisplayMetrics metrics = getResources().getDisplayMetrics();
                int screenWidth = (int) (metrics.widthPixels * 0.80);//fill only 80% of the screen
                moreAddressView = View.inflate(CancelJob.this, R.layout.other_reason_dialog, null);
                moreAddressDialog = new Dialog(CancelJob.this);
                moreAddressDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
                moreAddressDialog.setContentView(moreAddressView);
                moreAddressDialog.setCanceledOnTouchOutside(false);
                moreAddressDialog.getWindow().setLayout(screenWidth, LinearLayout.LayoutParams.WRAP_CONTENT);
                moreAddressDialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

                edit_reason = (EditText) moreAddressView.findViewById(R.id.edit_reason);
                other_submit = (Button) moreAddressView.findViewById(R.id.other_submit);
                other_cancel = (Button) moreAddressView.findViewById(R.id.other_cancel);

                other_submit.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Str_reason = edit_reason.getText().toString();
                        if (Str_reason.equalsIgnoreCase("")) {
                            alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.other_cancel_reason_alert));
                        } else {
                            if (isInternetPresent) {
                                cancel_MyRide(Iconstant.MyJobs_Cancel_Url, Str_reason);
                                System.out.println("cancelled-----------" + Iconstant.MyJobs_Cancel_Url);
                                moreAddressDialog.dismiss();

                            } else {
                                alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                            }
                        }
                    }
                });

                other_cancel.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        moreAddressDialog.dismiss();
                    }
                });

                moreAddressDialog.show();
            }
        });

        // get user data from session
        HashMap<String, String> user = sessionManager.getUserDetails();
        UserID = user.get(SessionManager.KEY_USER_ID);

        Intent intent = getIntent();
        sJobId_intent = intent.getStringExtra("JOB_ID");
        try {
            Bundle bundleObject = getIntent().getExtras();
            itemList = (ArrayList<CancelJobPojo>) bundleObject.getSerializable("Reason");
            adapter = new CancelJobAdapter(CancelJob.this, itemList);
            listView.setAdapter(adapter);
            listView.setExpanded(true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void initializeHeaderBar() {
        RelativeLayout headerBar = (RelativeLayout) findViewById(R.id.headerBar_layout);
        Rl_back = (RelativeLayout) headerBar.findViewById(R.id.headerBar_left_layout);
        Im_backIcon = (ImageView) headerBar.findViewById(R.id.headerBar_imageView);
        Tv_headerTitle = (TextView) headerBar.findViewById(R.id.headerBar_title_textView);

        Tv_headerTitle.setText(getResources().getString(R.string.cancel_job_header_textView));
        Im_backIcon.setImageResource(R.drawable.back_arrow);
    }

    //--------------Alert Method-----------
    private void alert(String title, String alert) {

        final PkDialog mDialog = new PkDialog(CancelJob.this);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(alert);
        mDialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
                finish();
            }
        });
        mDialog.show();
    }

    //-----------------------Cancel MyRide Post Request-----------------
    private void cancel_MyRide(String Url, final String reason) {

        final LoadingDialog mLoadingDialog = new LoadingDialog(CancelJob.this);
        mLoadingDialog.setLoadingTitle(getResources().getString(R.string.cancel_job_action_cancel));
        mLoadingDialog.show();
        System.out.println("-------------Cancel Job Url----------------" + Url);
        System.out.println("-------------Cancel user_id----------------" + UserID);
        System.out.println("-------------Cancel job_id---------------" + sJobId_intent);
        System.out.println("-------------Cancel reason----------------" + reason);
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_id", UserID);
        jsonParams.put("job_id", sJobId_intent);
        jsonParams.put("reason", reason);

        mRequest = new ServiceRequest(CancelJob.this);
        mRequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("-------------CanceJob Response----------------" + response);

                String sStatus = "";

                try {
                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    if (sStatus.equalsIgnoreCase("1")) {
                        JSONObject response_object = object.getJSONObject("response");
                        if (response_object.length() > 0) {
                            String message = response_object.getString("message");

                            Intent broadcastIntent = new Intent();
                            broadcastIntent.setAction("com.package.ACTION_CLASS_MY_JOBS_REFRESH");
                            broadcastIntent.putExtra("status", "cancelled");
                            if (MyJobs.Myjobs_page != null) {
                                MyJobs.Myjobs_page.finish();
                                sendBroadcast(broadcastIntent);
                            } else {
                                sendBroadcast(broadcastIntent);
                            }


                            Intent broadcastIntent_myjobsdetails = new Intent();
                            broadcastIntent_myjobsdetails.setAction("com.package.finish.MyJobDetails");
                            sendBroadcast(broadcastIntent_myjobsdetails);


                            new Handler().postDelayed(new Runnable() {
                                @Override
                                public void run() {
                                    mLoadingDialog.dismiss();
                                    finish();
                                    overridePendingTransition(android.R.anim.fade_in, android.R.anim.fade_out);
                                }
                            }, 2000);


                        }
                    } else {
                        mLoadingDialog.dismiss();
                        String sResponse = object.getString("response");
                        alert(getResources().getString(R.string.action_sorry), sResponse);
                    }

                } catch (JSONException e) {
                    mLoadingDialog.dismiss();
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                mLoadingDialog.dismiss();
            }
        });
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    //-----------------Move Back on pressed phone back button------------------
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {
            onBackPressed();
            finish();
            overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            return true;
        }
        return false;
    }
}

