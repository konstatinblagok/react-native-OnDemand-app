package com.a2zkaj.app;

import android.Manifest;
import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.location.Location;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListAdapter;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;
import android.widget.Toast;

import com.android.volley.Request;
import com.android.volley.toolbox.StringRequest;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResult;
import com.google.android.gms.location.LocationSettingsStatusCodes;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.a2zkaj.Pojo.Addmaterialpojo;
import com.a2zkaj.Pojo.Materialcostsubmitpojo;
import com.a2zkaj.SubClassBroadCast.SubClassActivity;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.GMapV2GetRouteDirection;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.Utils.onItemRemoveClickListener;
import com.a2zkaj.adapter.MaterialAddNewAdapter;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Map.CallBack;
import core.Map.GPSTracker;
import core.Map.GeocoderHelper;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.ChatMessageService;
import core.socket.SocketHandler;
import core.socket.SocketManager;
import me.drakeet.materialdialog.MaterialDialog;

/**
 * Created by user88 on 12/12/2015.
 */
public class MyJobs_OnGoingDetailPage extends SubClassActivity implements com.google.android.gms.location.LocationListener,
        GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener, SeekBar.OnSeekBarChangeListener, onItemRemoveClickListener {

    private TextView Tv_ongoingDetail_jobdate, Tv_ongoing_detail_jobtime, Tv_ongoing_jobtype, Tv_ongoing_detail_jobinstruction, Tv_ongoing_location, Tv_ongoing_cancel;

    private RelativeLayout layout_detail_back, Rl_cancel;
    private ImageView Img_Chat, Img_Call, Img_Message, Img_Email;
    private String Str_usermobile = "";
    private String destination_lat;
    private String destination_long, cancel_reson = "";
    String sendlat = "";
    String sendlng = "";
    private RelativeLayout layout_viewon_map;
    public static Button detail_btn1, detail_btn2;
    private Handler mHandler;

    public static String str_jobId = "";
    private double strlat, strlon;

    String address = "";
    String jsonformat = "";
    final int PERMISSION_REQUEST_CODE = 111;

    final int PERMISSION_REQUEST_CODES = 222;
    final int PERMISSION_REQUEST_LOCATION = 333;
    private final static int REQUEST_LOCATION = 199;
    private PendingResult<LocationSettingsResult> result;
    SessionManager session;
    ConnectionDetector cd;
    private Boolean isInternetPresent = false;

    private GoogleMap googleMap;
    GPSTracker gps;
    private Marker currentMarker;

    public static LoadingDialog dialog;
    public static String Str_Userid = "";

    public static MaterialDialog completejob_dialog;

    private StringRequest postrequest;
    public static String provider_id = "";
    private String Str_job_group = "";

    private double MyCurrent_lat = 0.0, MyCurrent_long = 0.0;

    private GoogleApiClient mGoogleApiClient;
    private LocationRequest mLocationRequest;
    public static Location myLocation;
    public static String mTaskID;
    private EditText Et_jobfare;
    private EditText Et_job_cost;
    private TextView Tv_OrderId;
    private String Str_Orderid = "";
    private ImageView track_location;
    private RelativeLayout Rl_detailpage_main_layout, Rl_detailpage_nointrnet_layout, Rl_job_workflow_layout;
    private SocketHandler socketHandler;
    GMapV2GetRouteDirection v2GetRouteDirection;
    static SocketManager smanager;
    private View moreAddressView;
    //  public static MaterialAddAdapter aAdapter;
    public static MaterialAddNewAdapter aAdapter;
    public static Dialog moreAddressDialog;
    ArrayList<String> listItems;
    public static ListView list;
    private ArrayList<Addmaterialpojo> item_add = new ArrayList<Addmaterialpojo>();
    public static boolean item_add_bollean = false;

    public static RelativeLayout aCancelLAY;
    public static RelativeLayout aOKLAY;
    public static CheckBox addmaterial;
    private String Str_user_email = "";
    private RelativeLayout disable_layout;
    public static Activity job_page_activity;
    private String share_text = "";
    private RelativeLayout show_more_layout;
    private RelativeLayout cancel_layout;
    private RelativeLayout show_moretext_layout;
    private TextView show_more;
    private String Job_Instruction = "";

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.package.finish.jobdetailpage")) {
                if (MyJobs.Myjobs_Activity != null) {
                    MyJobs.Myjobs_Activity.finish();
                    Intent i = new Intent(MyJobs_OnGoingDetailPage.this, MyJobs.class);
                    i.putExtra("status", "cancelled");
                    startActivity(i);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                } else {
                    Intent i = new Intent(MyJobs_OnGoingDetailPage.this, MyJobs.class);
                    i.putExtra("status", "cancelled");
                    startActivity(i);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                }

            }

            if (intent.getAction().equalsIgnoreCase("com.avail.finish")) {
                finish();
            }

        }
    }

    private RefreshReceiver finishReceiver;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.myjobs_ongoing_detail);
        job_page_activity = MyJobs_OnGoingDetailPage.this;
        initialize();
        try {
            setLocationRequest();
            buildGoogleApiClient();
        } catch (Exception e) {
            e.printStackTrace();
        }
        initilizeMap();
        googleMap.getUiSettings().setAllGesturesEnabled(false);

        layout_detail_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


        Rl_job_workflow_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, Job_WorkFlow.class);
                intent.putExtra("JobId", str_jobId);
                //intent.putExtra("UserId",Str_Userid);
                startActivity(intent);
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

        Img_Chat.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ChatMessageService.user_id = "";
                ChatMessageService.task_id = "";
                Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, ChatPage.class);
                intent.putExtra("chatpage", true);
                intent.putExtra("JOBID", str_jobId);
                intent.putExtra("TaskerId", Str_Userid);
                intent.putExtra("TaskId", mTaskID);
                System.out.println("Str_Userid-----------" + Str_Userid);
                startActivity(intent);
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


        Img_Call.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (Str_usermobile != null) {
                    if (Build.VERSION.SDK_INT >= 23) {
                        // Marshmallow+
                        if (!checkCallPhonePermission() || !checkReadStatePermission()) {
                            requestPermission();
                        } else {
                            Intent callIntent = new Intent(Intent.ACTION_CALL);
                            callIntent.setData(Uri.parse("tel:" + Str_usermobile));
                            startActivity(callIntent);
                        }
                    } else {
                        Intent callIntent = new Intent(Intent.ACTION_CALL);
                        callIntent.setData(Uri.parse("tel:" + Str_usermobile));
                        startActivity(callIntent);
                    }

                } else {
                    Alert(MyJobs_OnGoingDetailPage.this.getResources().getString(R.string.server_lable_header), MyJobs_OnGoingDetailPage.this.getResources().getString(R.string.arrived_alert_content1));
                }


            }
        });


        Img_Message.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                try {

                    share_text = getResources().getString(R.string.ongoing_detail_shar_text);
                    sms_sendMsg(share_text);

                } catch (Exception e) {
                    Toast.makeText(getApplicationContext(), "Your call has failed...", Toast.LENGTH_LONG).show();
                    e.printStackTrace();
                }
            }
        });


        Img_Email.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent i = new Intent(Intent.ACTION_SEND);
                i.setType("message/rfc822");
                i.putExtra(Intent.EXTRA_EMAIL, new String[]{Str_user_email});
                i.putExtra(Intent.EXTRA_SUBJECT, getResources().getString(R.string.ongoing_detail_subject));
                i.putExtra(Intent.EXTRA_TEXT, getResources().getString(R.string.ongoing_detail_text) + " ");
                try {
                    startActivity(Intent.createChooser(i, "Send mail..."));
                } catch (android.content.ActivityNotFoundException ex) {
                    // Toast.makeText(SettingsPage.this, "There are no email clients installed.", Toast.LENGTH_SHORT).show();
                }
            }
        });


        detail_btn2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                cd = new ConnectionDetector(MyJobs_OnGoingDetailPage.this);
                isInternetPresent = cd.isConnectingToInternet();

                if (detail_btn2.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_accept)) || detail_btn2.getText().equals("Accept")) {
                    if (isInternetPresent) {
                        buttonsClickActions(MyJobs_OnGoingDetailPage.this, ServiceConstant.ACCEPT_JOB_URL, "accept");
                        System.out.println("--------------accept-------------------" + ServiceConstant.ACCEPT_JOB_URL);
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                } else if (detail_btn2.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_start_Off)) || detail_btn2.getText().equals("Start Off")) {
                    if (isInternetPresent) {
                        buttonsClickActions(MyJobs_OnGoingDetailPage.this, ServiceConstant.STARTOFFJOB_JOB_URL, "startoff");
                        System.out.println("--------------startoff url-------------------" + ServiceConstant.STARTOFFJOB_JOB_URL);


                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                } else if (detail_btn2.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_arrived)) || detail_btn2.getText().equals("Arrived")) {

                    if (isInternetPresent) {
                        buttonsClickActions(MyJobs_OnGoingDetailPage.this, ServiceConstant.ARRIVED_JOB_URL, "arrived");
                        System.out.println("--------------arrived url-------------------" + ServiceConstant.ARRIVED_JOB_URL);
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                } else if (detail_btn2.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_start_job)) || detail_btn2.getText().equals("Start job")) {

                    if (isInternetPresent) {
                        buttonsClickActions(MyJobs_OnGoingDetailPage.this, ServiceConstant.STARTJOB_URL, "startjob");
                        System.out.println("--------------startjob url-------------------" + ServiceConstant.STARTJOB_URL);
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                }

            }
        });


        detail_btn1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (detail_btn1.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_reject)) || detail_btn1.getText().equals("Reject")) {
                    // onBackPressed();

                    Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, Cancel_Job_Reason.class);
                    intent.putExtra("JobId", str_jobId);
                    startActivity(intent);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

                } else if (detail_btn1.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_complete_job)) || detail_btn1.getText().equals("Complete Job")) {
                    detail_btn2.setVisibility(View.GONE);

                    Materail_Add_ALert();

                } else if (detail_btn1.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_Payment)) || detail_btn1.getText().equals("Payment")) {
                    detail_btn2.setVisibility(View.GONE);
                    Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, PaymentFareSummery.class);
                    intent.putExtra("JobId", str_jobId);
                    startActivity(intent);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

                } else if (detail_btn1.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_cancel)) || detail_btn1.getText().equals("Cancel")) {
                    detail_btn2.setVisibility(View.VISIBLE);
                    Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, Cancel_Job_Reason.class);
                    intent.putExtra("JobId", str_jobId);
                    startActivity(intent);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

                } else if (detail_btn1.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_cancel_reason)) || detail_btn1.getText().equals("Cancel Reason")) {
                    detail_btn2.setVisibility(View.GONE);
                    Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, Cancel_Job_Reason.class);
                    intent.putExtra("JobId", str_jobId);
                    startActivity(intent);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                } else if (detail_btn1.getText().equals(getResources().getString(R.string.myjobs_ongoing_deatils_page_more_info)) || detail_btn1.getText().equals("More Info")) {
                    detail_btn2.setVisibility(View.GONE);
                    Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, MoreInfoPage.class);
                    intent.putExtra("JobId", str_jobId);
                    startActivity(intent);
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                }

            }
        });

        track_location.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                String status = detail_btn2.getText().toString();

                if (status.equalsIgnoreCase(getResources().getString(R.string.ongoing_detail_accept_label)) || status.equalsIgnoreCase(getResources().getString(R.string.ongoing_detail_startoff_label))
                        || status.equalsIgnoreCase(getResources().getString(R.string.ongoing_detail_arrived_label))) {
                    if (cd.isConnectingToInternet()) {
                        CheckPermissions();
                    } else {
                        Alert(getResources().getString(R.string.sorry), getResources().getString(R.string.alert_nointernet));
                    }


                } else {

                    Alert(getResources().getString(R.string.sorry), getResources().getString(R.string.live_tracking_alert));
                }

                show_more_layout.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Toast.makeText(getApplicationContext(), "Clicked", Toast.LENGTH_LONG).show();
                        showalert(cancel_reson);
                    }
                });


            }
        });

        show_moretext_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                instuctionshow(Job_Instruction);

            }
        });


        if (smanager == null) {
            smanager = new SocketManager(this, new SocketManager.SocketCallBack() {

                @Override
                public void onSuccessListener(Object response) {
                    System.out.println("Location Updated Success--------------------->");
                }
            });
            if (!smanager.isConnected) {
                smanager.connect();
            }
        }

    }


    private void instuctionshow(String instruct) {

        DisplayMetrics metrics = getResources().getDisplayMetrics();
        int screenWidth = (int) (metrics.widthPixels * 0.80);//fill only 80% of the screen
        moreAddressView = View.inflate(MyJobs_OnGoingDetailPage.this, R.layout.instruction_dialog, null);
        moreAddressDialog = new Dialog(MyJobs_OnGoingDetailPage.this);
        moreAddressDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        moreAddressDialog.setContentView(moreAddressView);
        moreAddressDialog.setCanceledOnTouchOutside(false);
        moreAddressDialog.getWindow().setLayout(screenWidth, LinearLayout.LayoutParams.WRAP_CONTENT);
        moreAddressDialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

        TextView instruction = (TextView) moreAddressView.findViewById(R.id.instruction_dialog_text);
        instruction.setText(instruct);
        RelativeLayout cancel = (RelativeLayout) moreAddressView.findViewById(R.id.cancel_lay);

        cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                moreAddressDialog.dismiss();
            }
        });
        moreAddressDialog.show();
    }


    private void sms_sendMsg(String share_text) {
        if (Build.VERSION.SDK_INT >= 23) {
            // Marshmallow+
            if (!checkSmsPermission()) {
                requestPermissionSMS();
            } else {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.putExtra("address", Str_usermobile);
                intent.putExtra("sms_body", share_text);
                intent.setData(Uri.parse("smsto:" + Str_usermobile));
                startActivity(intent);
            }
        } else {
            Intent sendIntent = new Intent(Intent.ACTION_VIEW);
            sendIntent.putExtra("sms_body", share_text);
            sendIntent.putExtra("address", Str_usermobile);
            sendIntent.setType("vnd.android-dir/mms-sms");
            startActivity(sendIntent);
        }
    }


    public void Materail_Add_ALert() {
        item_add.clear();
        DisplayMetrics metrics = getResources().getDisplayMetrics();
        int screenWidth = (int) (metrics.widthPixels * 0.80);//fill only 80% of the screen
        moreAddressView = View.inflate(MyJobs_OnGoingDetailPage.this, R.layout.material_add_design, null);
        moreAddressDialog = new Dialog(MyJobs_OnGoingDetailPage.this);
        moreAddressDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        moreAddressDialog.setContentView(moreAddressView);
        moreAddressDialog.setCanceledOnTouchOutside(false);
        moreAddressDialog.getWindow().setLayout(screenWidth, LinearLayout.LayoutParams.WRAP_CONTENT);
        moreAddressDialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        addmaterial = (CheckBox) moreAddressView.findViewById(R.id.check_box);
        list = (ListView) moreAddressView.findViewById(R.id.list);
        final RelativeLayout aAddFieldLAY = (RelativeLayout) moreAddressView.findViewById(R.id.add_fields_layout);
        aCancelLAY = (RelativeLayout) moreAddressView.findViewById(R.id.cancel_layout);
        aOKLAY = (RelativeLayout) moreAddressView.findViewById(R.id.add_one_layout);

        listItems = new ArrayList<>();

        addmaterial.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
            @Override
            public void onCheckedChanged(CompoundButton compoundButton, boolean b) {
                if (b) {
                    Addmaterialpojo pojo = new Addmaterialpojo();
                    pojo.setToolname("name");
                    pojo.setToolcost("cost");
                    item_add.add(pojo);
                    listItems.add("1");
                    aAdapter = new MaterialAddNewAdapter(MyJobs_OnGoingDetailPage.this, listItems, list, addmaterial, item_add);
                    list.setAdapter(aAdapter);
                    // setListViewHeightBasedOnChildren(list);
                    aAdapter.notifyDataSetChanged();
                    aAddFieldLAY.setVisibility(View.GONE);
                } else {
                    aAddFieldLAY.setVisibility(View.GONE);
                    listItems.clear();
                    aAdapter.notifyDataSetChanged();
                    aOKLAY.setVisibility(View.VISIBLE);
                    aCancelLAY.setVisibility(View.VISIBLE);
                }
            }
        });

        aOKLAY.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (addmaterial.isChecked()) {

                    if (item_add.size() >= 0) {
                        if (aAdapter != null) {
                            aAdapter.notifyDataSetChanged();

                            ArrayList<EditText> aToolNameET = aAdapter.getToolname();
                            if (aToolNameET.size() == 0) {
                                return;
                            }
                            ArrayList<EditText> aToolCost = aAdapter.getTool_cost();
                            Addmaterialpojo pojo = new Addmaterialpojo();
                            if (aToolNameET.get(0).getText().toString().length() == 0) {
                                Toast.makeText(getApplicationContext(), getResources().getString(R.string.ongoing_detail_toolname), Toast.LENGTH_SHORT).show();
                            } else if (aToolCost.get(0).getText().toString().length() == 0) {
                                Toast.makeText(getApplicationContext(), getResources().getString(R.string.ongoing_detail_toolcost), Toast.LENGTH_SHORT).show();
                                return;
                            } else {

                                pojo.setToolname(aToolNameET.get(0).getText().toString());
                                pojo.setToolcost(aToolCost.get(0).getText().toString());
                                if (!item_add_bollean) {
                                    item_add.add(pojo);
                                }

                                for (int i = 0; i < item_add.size(); i++) {
                                    Log.e("name", item_add.get(i).getToolname());
                                    Log.e("cost", item_add.get(i).getToolcost());
                                }
                                // createArrayFormat();
                                if (isInternetPresent) {
                                    if (isInternetPresent) {
                                        jobCompletewithmaterial(MyJobs_OnGoingDetailPage.this, ServiceConstant.JOBCOMPLETE_URL, "jobcomplete");
                                        System.out.println("--------------completejob url-------------------" + ServiceConstant.JOBCOMPLETE_URL);
                                    } else {
                                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                                    }
                                }
                            }

                        }
                    }

                }
                if (!addmaterial.isChecked()) {
                    if (isInternetPresent) {
                        jobCompletewithoutmaterial(MyJobs_OnGoingDetailPage.this, ServiceConstant.JOBCOMPLETE_URL, "jobcomplete");
                        System.out.println("--------------completejob url-------------------" + ServiceConstant.JOBCOMPLETE_URL);
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                }
                moreAddressDialog.dismiss();
            }
        });
        aAddFieldLAY.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                item_add_bollean = false;
                ArrayList<EditText> aToolNameET = aAdapter.getToolname();
                ArrayList<EditText> aToolCost = aAdapter.getTool_cost();
                Addmaterialpojo pojo = new Addmaterialpojo();
                if (aToolNameET.get(0).getText().toString().length() == 0) {
                    Toast.makeText(getApplicationContext(), getResources().getString(R.string.ongoing_detail_toolname), Toast.LENGTH_SHORT).show();
                } else if (aToolCost.get(0).getText().toString().length() == 0) {
                    Toast.makeText(getApplicationContext(), getResources().getString(R.string.ongoing_detail_toolcost), Toast.LENGTH_SHORT).show();

                } else {
                    pojo.setToolname(aToolNameET.get(0).getText().toString());
                    pojo.setToolcost(aToolCost.get(0).getText().toString());
                    item_add.add(pojo);

                    if (listItems.size() > 0) {
                        listItems.add("1");
                        setListViewHeightBasedOnChildren(list);
                        aAdapter.notifyDataSetChanged();
                    }
                }


            }
        });
        aCancelLAY.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                moreAddressDialog.dismiss();
            }
        });
        moreAddressDialog.show();
    }

    public void showalert(String message) {
        AlertDialog.Builder builder = new AlertDialog.Builder(MyJobs_OnGoingDetailPage.this);
        builder.setTitle(getString(R.string.dialog_title));
        builder.setMessage(message);

        String positiveText = getString(android.R.string.ok);
        builder.setPositiveButton(positiveText,
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                    }
                });

        String negativeText = getString(android.R.string.cancel);


        AlertDialog dialog = builder.create();
        // display dialog
        dialog.show();
    }


    private boolean checkSmsPermission() {
        int result = ContextCompat.checkSelfPermission(MyJobs_OnGoingDetailPage.this, Manifest.permission.SEND_SMS);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }


    private void requestPermissionSMS() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.SEND_SMS}, PERMISSION_REQUEST_CODES);
    }


    private void createArrayFormat() {
        JSONArray jArray = new JSONArray();
        try {
            for (int i = 0; i < item_add.size(); i++) {
                Log.e("name", item_add.get(i).getToolname());
                Log.e("cost", item_add.get(i).getToolcost());
                JSONObject jGroup = new JSONObject();
                jGroup.put("name", item_add.get(i).getToolname());
                jGroup.put("price", item_add.get(i).getToolcost());
                jArray.put(jGroup);
                //   jResult.put("miscellaneous", jArray);
            }
            // Log.e("00000 jResult", "" + jResult);
            jsonformat = jArray.toString();
            Log.e("11111 jArray", "" + jArray);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onRemoveListener(int aPosition) {
//        listItems.remove(aPosition - 1);
//        aAdapter.notifyDataSetChanged();
        item_add.remove(item_add.size() - 1);

    }

    public static void UpdateListview() {
        setListViewHeightBasedOnChildren(list);
        aAdapter.notifyDataSetChanged();

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

    private void initialize() {
        session = new SessionManager(MyJobs_OnGoingDetailPage.this);
        cd = new ConnectionDetector(MyJobs_OnGoingDetailPage.this);
        gps = new GPSTracker(MyJobs_OnGoingDetailPage.this);
        mHandler = new Handler();
        socketHandler = SocketHandler.getInstance(this);

//        setLanguage(session.getLocaleLanguage());

        // get user data from session
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

        System.out.println("sessionproviderId=-------------------" + provider_id);

        Intent i = getIntent();
        str_jobId = i.getStringExtra("JobId");

        Tv_ongoingDetail_jobdate = (TextView) findViewById(R.id.ongoing_details_date);
        Tv_ongoing_detail_jobtime = (TextView) findViewById(R.id.ongoing_details_time);
        Tv_ongoing_jobtype = (TextView) findViewById(R.id.ongoing_detail_jobtype);
        track_location = (ImageView) findViewById(R.id.track_location);
        Tv_ongoing_detail_jobinstruction = (TextView) findViewById(R.id.ongoing_details_instruction);
        Tv_ongoing_location = (TextView) findViewById(R.id.ongoing_location_detail);
        Tv_ongoing_cancel = (TextView) findViewById(R.id.ongoing_details_cancel);
        layout_detail_back = (RelativeLayout) findViewById(R.id.layout_back_ongoingback);
        Rl_detailpage_main_layout = (RelativeLayout) findViewById(R.id.detail_main_layout);
        Rl_detailpage_nointrnet_layout = (RelativeLayout) findViewById(R.id.detail_page_noInternet_layout);
        Rl_job_workflow_layout = (RelativeLayout) findViewById(R.id.myjobs_ongoing_detail_workflow_relativelayout);
        Tv_OrderId = (TextView) findViewById(R.id.details_orderid);
        Tv_OrderId.setText(str_jobId);
        Img_Chat = (ImageView) findViewById(R.id.detail_chat_img);
        Img_Call = (ImageView) findViewById(R.id.detail_phone_img);
        Img_Message = (ImageView) findViewById(R.id.detail_message_img);
        Img_Email = (ImageView) findViewById(R.id.detail_email_img);
        disable_layout = (RelativeLayout) findViewById(R.id.detail_cahts_relativeLayout);
        detail_btn1 = (Button) findViewById(R.id.job_detail_btn1);
        detail_btn2 = (Button) findViewById(R.id.job_detail_btn2);
        show_more_layout = (RelativeLayout) findViewById(R.id.more_reason);
        cancel_layout = (RelativeLayout) findViewById(R.id.cancel_layout);
        show_moretext_layout = (RelativeLayout) findViewById(R.id.show_moretext_layout);
        show_more = (TextView) findViewById(R.id.show_more);
        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            Rl_detailpage_main_layout.setVisibility(View.VISIBLE);
            Rl_detailpage_nointrnet_layout.setVisibility(View.GONE);

            myjobOngoingDetail(MyJobs_OnGoingDetailPage.this, ServiceConstant.MYJOB_DETAIL_INFORMATION_URL);
            System.out.println("--------------detail-------------------" + ServiceConstant.MYJOB_DETAIL_INFORMATION_URL);
        } else {
            Rl_detailpage_main_layout.setVisibility(View.GONE);
            Rl_detailpage_nointrnet_layout.setVisibility(View.VISIBLE);
        }

        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.package.finish.jobdetailpage");
        intentFilter.addAction("com.avail.finish");
        registerReceiver(finishReceiver, intentFilter);

    }


    private void setLocationRequest() {
        mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(10000);
        mLocationRequest.setFastestInterval(5000);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
    }


    protected synchronized void buildGoogleApiClient() {
        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
    }

    protected void startLocationUpdates() {
        if (mGoogleApiClient != null && mGoogleApiClient.isConnected()) {
            int result = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION);
            if (result == PackageManager.PERMISSION_GRANTED) {
                LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, mLocationRequest, this);

            }
        }

    }


    public void onPause() {
        super.onPause();
        try {
            //unregisterReceiver(finishReceiver);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    private void initilizeMap() {
        if (googleMap == null) {
            googleMap = ((MapFragment) MyJobs_OnGoingDetailPage.this.getFragmentManager().findFragmentById(R.id.myjob_ongoing_detail_map)).getMap();
            // check if map is created successfully or not
            if (googleMap == null) {
                Toast.makeText(MyJobs_OnGoingDetailPage.this, getResources().getString(R.string.ongoing_detail_map_doesnotcreate_label), Toast.LENGTH_SHORT).show();
            }
        }
        // Changing map type
        googleMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        // Showing / hiding your current location
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return;
        }
        googleMap.setMyLocationEnabled(false);
        // Enable / Disable zooming controls
        googleMap.getUiSettings().setZoomControlsEnabled(false);
        // Enable / Disable my location button
        googleMap.getUiSettings().setMyLocationButtonEnabled(false);
        // Enable / Disable Compass icon
        googleMap.getUiSettings().setCompassEnabled(false);
        // Enable / Disable Rotate gesture
        googleMap.getUiSettings().setRotateGesturesEnabled(true);
        // Enable / Disable zooming functionality
        googleMap.getUiSettings().setZoomGesturesEnabled(true);

        if (gps.canGetLocation()) {
            double Dlatitude = gps.getLatitude();
            double Dlongitude = gps.getLongitude();
            MyCurrent_lat = Dlatitude;
            MyCurrent_long = Dlongitude;
            CameraPosition cameraPosition = new CameraPosition.Builder().target(new LatLng(Dlatitude, Dlongitude)).zoom(17).build();
            googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
            // create marker double Dlatitude = gps.getLatitude();

            MarkerOptions marker = new MarkerOptions().position(new LatLng(Dlatitude, Dlongitude));
            // marker.icon(BitmapDescriptorFactory.fromResource(R.drawable.maps));
            //  currentMarker = googleMap.addMarker(marker);
            System.out.println("currntlat----------" + MyCurrent_lat);
            System.out.println("currntlon----------" + MyCurrent_long);

        } else {
            //show gps alert
           /* alert_layout.setVisibility(View.VISIBLE);
            alert_textview.setText(getResources().getString(R.string.alert_gpsEnable));*/
        }
        setLocationRequest();
    }

    //-------------------Show Summery fare  Method--------------------
    private void jobFareDetails() {

        completejob_dialog = new MaterialDialog(MyJobs_OnGoingDetailPage.this);
        View view = LayoutInflater.from(MyJobs_OnGoingDetailPage.this).inflate(R.layout.job_complete_popup, null);
        Et_jobfare = (EditText) view.findViewById(R.id.complete_job_fareEt);
        //  Et_job_cost = (EditText)view.findViewById(R.id.complete_job_fare_costEt);
        Button Bt_Submit = (Button) view.findViewById(R.id.jobcomplete_popup_submit);
        Button Bt_Cancel = (Button) view.findViewById(R.id.jobcomplete_popup_cancel);

        completejob_dialog.setView(view).show();

        Bt_Submit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
              /*  if (isInternetPresent){
                    jobComplete(MyJobs_OnGoingDetailPage.this, ServiceConstant.JOBCOMPLETE_URL, "jobcomplete");
                    System.out.println("--------------completejob url-------------------" + ServiceConstant.JOBCOMPLETE_URL);
                }else{
                    Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                }*/
            }
        });

        Bt_Cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                completejob_dialog.dismiss();
            }
        });

    }


    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(MyJobs_OnGoingDetailPage.this);
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

    private void detailButtons(String name1, int color1, String name2, int color2) {
        detail_btn1.setText(name1);
        detail_btn1.setBackgroundColor(color1);
        detail_btn2.setText(name2);
        detail_btn2.setBackgroundColor(color2);
    }

    //------------------------Job Complete------------------
    private void JobReject(Context mContext, String url, String key) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", str_jobId);

        System.out.println("provider_id-----------" + provider_id);
        System.out.println("job_id-----------" + str_jobId);

        dialog = new LoadingDialog(MyJobs_OnGoingDetailPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("jobreject-----------" + response);
                Log.e("jobreject", response);

                String Str_status = "", Str_response = "", Str_message = "", Str_btn_group = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_message = object.getString("message");
                        Str_btn_group = object.getString("btn_group");

                    } else {
                        Str_response = jobject.getString("response");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                dialog.dismiss();

                if (Str_status.equalsIgnoreCase("1")) {

                    final PkDialog mdialog = new PkDialog(MyJobs_OnGoingDetailPage.this);
                    mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                    mdialog.setDialogMessage(Str_message);
                    mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    mdialog.dismiss();

                                    if (completejob_dialog != null) {
                                        completejob_dialog.dismiss();
                                    }

                                    finish();

                                }
                            }
                    );
                    mdialog.show();
                } else {
                    Alert(getResources().getString(R.string.alert_label_title), Str_response);
                }

            }

            @Override
            public void onErrorListener() {

                dialog.dismiss();

            }
        });

    }


    //------------------------Job Complete------------------
    private void jobCompletewithmaterial(Context mContext, String url, String key) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", str_jobId);
        jsonParams.put("summary", "");
        for (int i = 0; i < item_add.size(); i++) {
            jsonParams.put("miscellaneous[" + i + "][name]", item_add.get(i).getToolname());
            jsonParams.put("miscellaneous[" + i + "][price]", item_add.get(i).getToolcost());
        }
        //  jsonParams.put("cost",Et_job_cost.getText().toString());

        System.out.println("provider_id-----------" + provider_id);
        System.out.println("job_id-----------" + str_jobId);

        dialog = new LoadingDialog(MyJobs_OnGoingDetailPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("jobcomplete-----------" + response);
                Log.e("jobcomplete", response);

                String Str_status = "", Str_response = "", Str_message = "", Str_btn_group = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_message = object.getString("message");
                        Str_btn_group = object.getString("btn_group");

                    } else {
                        Str_response = jobject.getString("response");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                dialog.dismiss();

                if (Str_status.equalsIgnoreCase("1")) {

                    if (Str_btn_group.equalsIgnoreCase("6")) {
                        detail_btn2.setVisibility(View.GONE);
                        detail_btn1.setVisibility(View.VISIBLE);
                        detail_btn1.setText(getResources().getString(R.string.ongoing_detail_payment_label));
                    }

                    final PkDialog mdialog = new PkDialog(MyJobs_OnGoingDetailPage.this);
                    mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                    mdialog.setDialogMessage(Str_message);
                    mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    mdialog.dismiss();

                                    if (completejob_dialog != null) {
                                        completejob_dialog.dismiss();
                                    }


                                }
                            }
                    );
                    mdialog.show();
                } else {
                    Alert(getResources().getString(R.string.alert_label_title), Str_response);
                }

            }

            @Override
            public void onErrorListener() {

                dialog.dismiss();

            }
        });

    }


    //------------------------Job Complete------------------
    private void jobCompletewithoutmaterial(Context mContext, String url, String key) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", str_jobId);
        jsonParams.put("summary", "");
        //jsonParams.put("miscellaneous", jsonformat);
        //  jsonParams.put("cost",Et_job_cost.getText().toString());

        System.out.println("provider_id-----------" + provider_id);
        System.out.println("job_id-----------" + str_jobId);

        dialog = new LoadingDialog(MyJobs_OnGoingDetailPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("jobcomplete-----------" + response);
                Log.e("jobcomplete", response);

                String Str_status = "", Str_response = "", Str_message = "", Str_btn_group = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_message = object.getString("message");
                        Str_btn_group = object.getString("btn_group");

                    } else {
                        Str_response = jobject.getString("response");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                dialog.dismiss();

                if (Str_status.equalsIgnoreCase("1")) {

                    if (Str_btn_group.equalsIgnoreCase("6")) {
                        detail_btn2.setVisibility(View.GONE);
                        detail_btn1.setVisibility(View.VISIBLE);
                        detail_btn1.setText(getResources().getString(R.string.ongoing_detail_payment_label));
                    }

                    final PkDialog mdialog = new PkDialog(MyJobs_OnGoingDetailPage.this);
                    mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                    mdialog.setDialogMessage(Str_message);
                    mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    mdialog.dismiss();

                                    if (completejob_dialog != null) {
                                        completejob_dialog.dismiss();
                                    }


                                }
                            }
                    );
                    mdialog.show();
                } else {
                    Alert(getResources().getString(R.string.alert_label_title), Str_response);
                }

            }

            @Override
            public void onErrorListener() {

                dialog.dismiss();

            }
        });

    }


    //-----------------------------------------------------------Connect to Chat---------------------------------------------------


    //-------------------------code for myjobs ongoing detail----------------
    private void myjobOngoingDetail(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", str_jobId);


        System.out.println("provider_id------" + provider_id);

        System.out.println("job_id------" + str_jobId);

        dialog = new LoadingDialog(MyJobs_OnGoingDetailPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------------reponsedetail-------------------" + response);
                Log.e("detail", response);
                String Str_status = "", Str_jobId = "", Str_Response = "", Str_currencycode = "", Str_jobdate = "", Str_jobtime = "", Str_jobtype = "",
                        Str_jobinstruction = "", Str_jobstatus = "", Str_jobusername = "", Str_userimg = "", Str_job_userrating = "", Str_job_location = "", Str_location_lattitude = "", Str_location_longitude = "";

                try {

                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");

                        JSONObject object2 = object.getJSONObject("job");
                        // mTaskID = object2.getString("job_id");
                        Str_Userid = object2.getString("user_id");
                        Str_currencycode = object2.getString("currency");
                        Str_jobdate = object2.getString("job_date");
                        Str_jobtime = object2.getString("job_time");
                        Str_jobtype = object2.getString("job_type");
                        Str_jobinstruction = object2.getString("instruction");
                        Job_Instruction = object2.getString("instruction");
                        Str_jobstatus = object2.getString("job_status");
                        Str_jobusername = object2.getString("user_name");
                        Str_userimg = object2.getString("user_image");
                        Str_job_userrating = object2.getString("user_ratings");
                        Str_user_email = object2.getString("user_email");

                        Str_usermobile = object2.getString("user_mobile");
                        Str_job_location = object2.getString("job_location");
                        Str_job_group = object2.getString("btn_group");
                        destination_lat = object2.getString("location_lat");
                        destination_long = object2.getString("location_lon");
                        if (object2.has("cancelreason")) {
                            cancel_reson = object2.getString("cancelreason");
                            System.out.println("cancel----reson===========" + cancel_reson);
                        }
                        System.out.println("details----userid===========" + Str_Userid);

                        strlat = Double.parseDouble(destination_lat);
                        strlon = Double.parseDouble(destination_long);

                        String address = new GeocoderHelper().fetchCityName(MyJobs_OnGoingDetailPage.this, strlat, strlon, callBack);

                        //address = getCompleteAddressString(strlat, strlon);
                        mTaskID = object2.getString("task_id");

                    } else {
                        Str_Response = jobject.getString("response");
                    }

                    if (Str_status.equalsIgnoreCase("1")) {
                        Tv_ongoingDetail_jobdate.setText(Str_jobdate);
                        Tv_ongoing_detail_jobtime.setText(Str_jobtime);
                        Tv_ongoing_detail_jobinstruction.setText(Str_jobinstruction);
                        String length = String.valueOf(Tv_ongoing_detail_jobinstruction.getText().toString().length());
                        if (Str_jobinstruction.length() > 30) {
                            show_moretext_layout.setVisibility(View.VISIBLE);
                        } else {
                            show_moretext_layout.setVisibility(View.GONE);
                        }
                        Tv_ongoing_jobtype.setText(Str_jobtype);
                        // Tv_ongoing_location.setText(address);

                        if (!cancel_reson.equalsIgnoreCase("")) {
                            Tv_ongoing_cancel.setText(cancel_reson);
                            if (Tv_ongoing_cancel.getText().toString().length() == 35) {
                                // show_more_layout.setVisibility(View.VISIBLE);
                                show_more_layout.setEnabled(true);
                            } else {
                                show_more_layout.setVisibility(View.GONE);
                                show_more_layout.setEnabled(false);
                            }
                        } else {

                        }


                        //-------------------code for set marker-------------------------
                        googleMap.addMarker(new MarkerOptions()
                                .position(new LatLng((strlat), (strlon)))
                                .icon(BitmapDescriptorFactory.fromResource(R.drawable.maps)));
                        // Move the camera to last position with a zoom level
                        CameraPosition cameraPosition = new CameraPosition.Builder().target(new LatLng((strlat), (strlon))).zoom(12).build();
                        googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));

                        System.out.println("--------------btngroup-------------------" + Str_job_group);

                        if (Str_job_group.equalsIgnoreCase("1")) {
                            cancel_layout.setVisibility(View.GONE);
                            disable_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.GONE);
                            detailButtons(getResources().getString(R.string.ongoing_detail_rejectlabel), Color.parseColor("#cc1c1c"), getResources().getString(R.string.ongoing_detail_accept_label), Color.parseColor("#74d600"));

                        } else if (Str_job_group.equalsIgnoreCase("2")) {
                            cancel_layout.setVisibility(View.GONE);
                            disable_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            detailButtons(getResources().getString(R.string.ongoing_detail_cancelbtn_label), Color.parseColor("#cc0000"), getResources().getString(R.string.ongoing_detail_startoff_label), Color.parseColor("#6c3a02"));

                        } else if (Str_job_group.equalsIgnoreCase("3")) {
                            cancel_layout.setVisibility(View.GONE);
                            disable_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            detailButtons(getResources().getString(R.string.ongoing_detail_cancelbtn_label), Color.parseColor("#cc0000"), getResources().getString(R.string.ongoing_detail_arrived_label), Color.parseColor("#460137"));

                        } else if (Str_job_group.equalsIgnoreCase("4")) {
                            cancel_layout.setVisibility(View.GONE);
                            disable_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            detailButtons(getResources().getString(R.string.ongoing_detail_cancelbtn_label), Color.parseColor("#cc0000"), getResources().getString(R.string.ongoing_detail_startjob_label), Color.parseColor("#097054"));

                        } else if (Str_job_group.equalsIgnoreCase("5")) {
                            cancel_layout.setVisibility(View.GONE);
                            disable_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            detail_btn2.setVisibility(View.GONE);
                            detail_btn1.setVisibility(View.VISIBLE);
                            detail_btn1.setText(getResources().getString(R.string.ongoing_detail_jobcompleted_label));
                            detail_btn1.setBackgroundColor(getResources().getColor(R.color.layout_completejob_btn_color));

                        } else if (Str_job_group.equalsIgnoreCase("6")) {
                            cancel_layout.setVisibility(View.GONE);
                            disable_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            detail_btn2.setVisibility(View.GONE);
                            detail_btn1.setVisibility(View.VISIBLE);
                            detail_btn1.setText(getResources().getString(R.string.ongoing_detail_payment_label));
                            detail_btn1.setBackgroundColor(getResources().getColor(R.color.layout_payment_btn_color));

                        } else if (Str_job_group.equalsIgnoreCase("7")) {
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            detail_btn2.setVisibility(View.GONE);
                            detail_btn1.setVisibility(View.VISIBLE);
                            detail_btn1.setText(getResources().getString(R.string.ongoing_detail_canceled_job_label));
                            detail_btn1.setBackgroundColor(getResources().getColor(R.color.app_cancel_btn_color));
                            cancel_layout.setVisibility(View.VISIBLE);
                            disable_layout.setVisibility(View.GONE);
                            disable_layout.setBackgroundColor(Color.parseColor("#A9A9A9"));
                            disable_layout.setEnabled(false);
                            Img_Chat.setEnabled(false);
                            Img_Call.setEnabled(false);
                            Img_Email.setEnabled(false);
                            Img_Message.setEnabled(false);
                            track_location.setEnabled(false);
                        } else {
                            cancel_layout.setVisibility(View.GONE);
                            disable_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            Rl_job_workflow_layout.setVisibility(View.VISIBLE);
                            detail_btn1.setText(getResources().getString(R.string.ongoing_detail_more_label));
                            detail_btn2.setVisibility(View.GONE);
                            detail_btn1.setVisibility(View.VISIBLE);
                            detail_btn1.setBackgroundColor(getResources().getColor(R.color.layout_moreinfo_btn_color));
                        }

                    } else {
                        final PkDialog mdialog = new PkDialog(MyJobs_OnGoingDetailPage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.server_lable_header));
                        mdialog.setDialogMessage(Str_Response);
                        mdialog.setCancelOnTouchOutside(false);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                    }
                                }
                        );
                        mdialog.show();
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


    CallBack callBack = new CallBack() {
        @Override
        public void onComplete(String LocationName) {
            System.out.println("-------------------addreess----------------0" + LocationName);

            if (LocationName != null) {

                Tv_ongoing_location.setText(LocationName);
                address = LocationName;

            } else {
            }
        }

        @Override
        public void onError(String errorMsg) {

        }
    };

    //-----------------------code for detail ButtonAction Post request---------------------
    private void buttonsClickActions(Context mContext, String url, String key) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", str_jobId);

        if (key.equalsIgnoreCase("accept")) {
            jsonParams.put("provider_lat", String.valueOf(MyCurrent_lat));
            jsonParams.put("provider_lon", String.valueOf(MyCurrent_long));
        }
        if (key.equalsIgnoreCase("startoff")) {
            jsonParams.put("provider_lat", String.valueOf(MyCurrent_lat));
            jsonParams.put("provider_lon", String.valueOf(MyCurrent_long));
        }

        System.out.println("curentlat-----------" + MyCurrent_lat);
        System.out.println("curentlong-----------" + MyCurrent_long);
        System.out.println("provider_id-----------" + provider_id);
        System.out.println("job_id-----------" + str_jobId);

        dialog = new LoadingDialog(MyJobs_OnGoingDetailPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                Log.e("clickresponse------", response);

                String Str_status = "", username = "", user_email = "", user_phoneno = "", user_img = "", user_reviwe = "", jobId = "", user_location = "", jobtime = "", job_lat = "", job_long = "",
                        Str_message = "", Str_btngroup = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_message = object.getString("message");
                        Str_btngroup = object.getString("btn_group");
                        Toast.makeText(getApplicationContext(), Str_message, Toast.LENGTH_SHORT).show();
                    } else {
                        Str_message = jobject.getString("response");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (Str_status.equalsIgnoreCase("1")) {

                    Rl_job_workflow_layout.setVisibility(View.VISIBLE);

                    if (Str_btngroup.equalsIgnoreCase("1")) {
                        detailButtons(getResources().getString(R.string.ongoing_detail_rejectlabel), Color.parseColor("#cc1c1c"), getResources().getString(R.string.ongoing_detail_accept_label), Color.parseColor("#74d600"));

                    } else if (Str_btngroup.equalsIgnoreCase("2")) {
                        detailButtons(getResources().getString(R.string.ongoing_detail_cancelbtn_label), Color.parseColor("#cc0000"), getResources().getString(R.string.ongoing_detail_startoff_label), Color.parseColor("#6c3a02"));

                    } else if (Str_btngroup.equalsIgnoreCase("3")) {
                        detailButtons(getResources().getString(R.string.ongoing_detail_cancelbtn_label), Color.parseColor("#cc0000"), getResources().getString(R.string.ongoing_detail_arrived_label), Color.parseColor("#460137"));

                    } else if (Str_btngroup.equalsIgnoreCase("4")) {
                        detailButtons(getResources().getString(R.string.ongoing_detail_cancelbtn_label), Color.parseColor("#cc0000"), getResources().getString(R.string.ongoing_detail_startjob_label), Color.parseColor("#097054"));

                    } else if (Str_btngroup.equalsIgnoreCase("5")) {
                        detail_btn2.setVisibility(View.GONE);
                        detail_btn1.setText(getResources().getString(R.string.ongoing_detail_jobcompleted_label));
                        detail_btn1.setBackgroundColor(getResources().getColor(R.color.layout_completejob_btn_color));

                    } else if (Str_btngroup.equalsIgnoreCase("6")) {
                        detail_btn2.setVisibility(View.GONE);
                        detail_btn1.setText(getResources().getString(R.string.ongoing_detail_payment_label));
                        detail_btn1.setBackgroundColor(getResources().getColor(R.color.layout_payment_btn_color));

                    } else if (Str_btngroup.equalsIgnoreCase("7")) {
                        detail_btn2.setVisibility(View.GONE);
                        detail_btn1.setText(getResources().getString(R.string.ongoing_detail_cancel_label));
                        detail_btn1.setBackgroundColor(getResources().getColor(R.color.app_cancel_btn_color));
                    } else {
                        detail_btn2.setVisibility(View.GONE);
                        detail_btn1.setText(getResources().getString(R.string.ongoing_detail_more_label));
                        detail_btn1.setBackgroundColor(getResources().getColor(R.color.layout_moreinfo_btn_color));
                    }

                } else {
                    Alert(getResources().getString(R.string.server_lable_header), Str_message);
                }
                dialog.dismiss();
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();

            }
        });
    }


    private boolean checkCallPhonePermission() {
        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.CALL_PHONE);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkReadStatePermission() {
        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkAccessFineLocationPermission() {
        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkAccessCoarseLocationPermission() {
        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private void CheckPermissions() {
        if (!checkAccessFineLocationPermission() || !checkAccessCoarseLocationPermission()) {
            requestPermissionLocation();
        } else {
            enableGpsService();
        }
    }

    private void enableGpsService() {
        mLocationRequest = LocationRequest.create();
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        mLocationRequest.setInterval(30 * 1000);
        mLocationRequest.setFastestInterval(5 * 1000);
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder()
                .addLocationRequest(mLocationRequest);
        builder.setAlwaysShow(true);
        result = LocationServices.SettingsApi.checkLocationSettings(mGoogleApiClient, builder.build());
        result.setResultCallback(new ResultCallback<LocationSettingsResult>() {
            @Override
            public void onResult(LocationSettingsResult result) {
                final com.google.android.gms.common.api.Status status = result.getStatus();
                //final LocationSettingsStates state = result.getLocationSettingsStates();
                switch (status.getStatusCode()) {
                    case LocationSettingsStatusCodes.SUCCESS:
                        Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, Track_your_ride.class);
                        intent.putExtra("LAT", destination_lat);
                        intent.putExtra("LONG", destination_long);
                        intent.putExtra("Userid", Str_Userid);
                        intent.putExtra("tasker", provider_id);
                        intent.putExtra("task", mTaskID);
                        intent.putExtra("address", address);
                        startActivity(intent);
                        break;
                    case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                        // Location settings are not satisfied. But could be fixed by showing the user
                        // a dialog.
                        try {
                            // Show the dialog by calling startResolutionForResult(),
                            // and check the result in onActivityResult().
                            status.startResolutionForResult(MyJobs_OnGoingDetailPage.this, REQUEST_LOCATION);
                        } catch (IntentSender.SendIntentException e) {
                            // Ignore the error.
                        }
                        break;
                    case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                        // Location settings are not satisfied. However, we have no way to fix the
                        // settings so we won't show the dialog.
                        //...
                        break;
                }
            }
        });
    }

    private void requestPermission() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CALL_PHONE, Manifest.permission.READ_PHONE_STATE}, PERMISSION_REQUEST_CODE);
    }


    private void requestPermissions() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CALL_PHONE, Manifest.permission.READ_PHONE_STATE}, PERMISSION_REQUEST_CODES);
    }

    private void requestPermissionLocation() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION}, PERMISSION_REQUEST_LOCATION);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case PERMISSION_REQUEST_CODE:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Intent callIntent = new Intent(Intent.ACTION_CALL);
                    callIntent.setData(Uri.parse("tel:" + Str_usermobile));
                    startActivity(callIntent);
                }
                break;


            case PERMISSION_REQUEST_CODES:

                if (Build.VERSION.SDK_INT >= 23) {

                    Intent intent = new Intent(Intent.ACTION_VIEW);
                    intent.putExtra("address", Str_usermobile);
                    intent.putExtra("sms_body", share_text);
                    intent.setData(Uri.parse("smsto:" + Str_usermobile));
                    startActivity(intent);


                } else {
                    Intent sendIntent = new Intent(Intent.ACTION_VIEW);
                    sendIntent.putExtra("sms_body", share_text);
                    sendIntent.putExtra("address", Str_usermobile);
                    sendIntent.setType("vnd.android-dir/mms-sms");
                    startActivity(sendIntent);
                }
                break;
            case PERMISSION_REQUEST_LOCATION:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, Track_your_ride.class);
                    intent.putExtra("LAT", destination_lat);
                    intent.putExtra("LONG", destination_long);
                    intent.putExtra("Userid", Str_Userid);
                    intent.putExtra("tasker", provider_id);
                    intent.putExtra("task", mTaskID);
                    intent.putExtra("address", address);
                    startActivity(intent);
                } else {

                }
                break;
        }
    }


    public static void AlertShow(String title, String message, Context context) {
        final PkDialog mDialog = new PkDialog(context);
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(context.getResources().getString(R.string.action_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        mDialog.show();
    }


    @Override
    public void onResume() {
        super.onResume();
        if (!ChatMessageService.isStarted()) {
            Intent intent = new Intent(MyJobs_OnGoingDetailPage.this, ChatMessageService.class);
            startService(intent);
        }
    }

    @Override
    public void onStart() {
        super.onStart();
        if (mGoogleApiClient != null)
            mGoogleApiClient.connect();
    }

    protected void onStop() {
        if (mGoogleApiClient != null) {
            mGoogleApiClient.disconnect();
        }
        super.onStop();
        //  mHandler.removeCallbacks(mHandlerTask);
    }


    @Override
    public void onDestroy() {
        super.onDestroy();

        try {
            unregisterReceiver(finishReceiver);
        } catch (Exception e) {
            e.printStackTrace();
        }
        // mHandler.removeCallbacks(mHandlerTask);

    }

    @Override
    public void onConnected(Bundle bundle) {
        if (gps != null && gps.canGetLocation() && gps.isgpsenabled()) {
        }

        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION);
        if (result == PackageManager.PERMISSION_GRANTED) {
            myLocation = LocationServices.FusedLocationApi.getLastLocation(
                    mGoogleApiClient);

            LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, mLocationRequest, this);

        }

    }

    @Override
    public void onConnectionSuspended(int i) {
        Toast.makeText(getApplicationContext(), "Connection lost", Toast.LENGTH_LONG).show();
    }

    MarkerOptions mm = new MarkerOptions();
    Marker drivermarker;
    JSONObject job = new JSONObject();

    @Override
    public void onLocationChanged(Location location) {

    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {

    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int i, boolean b) {

    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    //---------------------------------------------Material Fees Submit Request--------------------------------------------------------

    public static void SubmitMaterialFees(ArrayList<Materialcostsubmitpojo> arrayList, final Context context) {

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("job_id", str_jobId);
        jsonParams.put("summary", "");
        for (int i = 0; i < arrayList.size(); i++) {
            jsonParams.put("miscellaneous[" + i + "][name]", arrayList.get(i).getToolname());
            jsonParams.put("miscellaneous[" + i + "][price]", arrayList.get(i).getToolcost());

            System.out.println("miscellaneous[" + i + "][name]" + arrayList.get(i).getToolname());
            System.out.println("miscellaneous[" + i + "][price]" + arrayList.get(i).getToolcost());
        }

        System.out.println("provider_id-----------" + provider_id);
        System.out.println("job_id-----------" + str_jobId);

        dialog = new LoadingDialog(context);
        dialog.setLoadingTitle(context.getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(context);
        mservicerequest.makeServiceRequest(ServiceConstant.JOBCOMPLETE_URL, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("jobcomplete-----------" + response);
                Log.e("jobcomplete", response);

                String Str_status = "", Str_response = "", Str_message = "", Str_btn_group = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_message = object.getString("message");
                        Str_btn_group = object.getString("btn_group");

                    } else {
                        Str_response = jobject.getString("response");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                dialog.dismiss();

                if (Str_status.equalsIgnoreCase("1")) {

                    if (Str_btn_group.equalsIgnoreCase("6")) {
                        detail_btn2.setVisibility(View.GONE);
                        detail_btn1.setVisibility(View.VISIBLE);
                        detail_btn1.setText(context.getResources().getString(R.string.ongoing_detail_payment_label));
                    }

                    final PkDialog mdialog = new PkDialog(context);
                    mdialog.setDialogTitle(context.getResources().getString(R.string.action_loading_sucess));
                    mdialog.setDialogMessage(Str_message);
                    mdialog.setPositiveButton(context.getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                @Override
                                public void onClick(View v) {
                                    mdialog.dismiss();

                                    if (completejob_dialog != null) {
                                        completejob_dialog.dismiss();
                                    }


                                }
                            }
                    );
                    mdialog.show();
                } else {
                    AlertShow(context.getResources().getString(R.string.alert_label_title), Str_response, context);
                }

            }

            @Override
            public void onErrorListener() {

                dialog.dismiss();

            }
        });
    }

    public void setLanguage(String languagecode) {
        session.setLocaleLanguage(languagecode);
        Resources res = getApplicationContext().getResources();
        DisplayMetrics dm = res.getDisplayMetrics();
        android.content.res.Configuration conf = res.getConfiguration();
        conf.locale = new Locale(languagecode);
        res.updateConfiguration(conf, dm);
    }

}