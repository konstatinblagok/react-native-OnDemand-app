package com.a2zkaj.app;

import android.Manifest;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.graphics.drawable.Drawable;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.NetworkResponse;
import com.android.volley.NoConnectionError;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.TimeoutError;
import com.android.volley.VolleyError;
import com.github.paolorotolo.expandableheightlistview.ExpandableHeightListView;
import com.a2zkaj.Pojo.Reviwes_Pojo;
import com.a2zkaj.SubClassBroadCast.SubClassActivity;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.Reviwes_Adapter;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.AppController;
import core.Volley.ServiceRequest;
import core.Volley.VolleyMultipartRequest;
import core.Widgets.CircularImageView;
import core.service.ServiceConstant;
import core.socket.ChatMessageService;
import core.socket.SocketHandler;

/**
 * Created by user88 on 1/4/2016.
 */
public class ReviwesPage extends SubClassActivity {

    RelativeLayout layout_skip;

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private boolean show_progress_status = false;

    private String provider_id = "", JobId = "";
    private SessionManager session;

    Reviwes_Adapter adapter;
    private ArrayList<Reviwes_Pojo> reviweslist;
    LoadingDialog dialog;
    String id, title, count;
    Dialog dialog1;

    private EditText Et_comment;
    private RelativeLayout Rl_ratings_main_layout, Rl_ratings_emptyratings_layout, Rl_ratings_nointernet_layout, Rl_rating_now_layout;
    private ExpandableHeightListView listview;
    private Button BT_submit_rating;
    private SocketHandler socketHandler;
    private  TextView username;
    private CircularImageView Img_upload_ratingimg;
    private byte[] byteArray;
    Bitmap bitMapThumbnail;
    private String mSelectedFilePath = "";

    final int PERMISSION_REQUEST_CODE = 111;

    private Dialog photo_dialog;
    //variable to add photo
    private static final int CAMERA_PICTURE = 1;
    private static final int GALLERY_PICTURE = 2;
    // private HttpEntity resEntity;
    private File captured_image;
    String imagePath;
    byte[] Image_byteArray;
    private Uri mImageCaptureUri;

    private int REQUEST_TAKE_PHOTO = 1;
    private int galleryRequestCode = 2;
    private Uri camera_FileUri;
    private static final String TAG = "";
    // directory name to store captured images and videos
    private static final String IMAGE_DIRECTORY_NAME = "QuickrabbitPartner";
    private String user_image="",Usersname="";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.reviwes);

        initilize();
        layout_skip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Intent broadcastIntent_receivecash = new Intent();
                broadcastIntent_receivecash.setAction("com.finish.ReceiveCashPage");
                sendBroadcast(broadcastIntent_receivecash);

                Intent broadcastIntent_otppage = new Intent();
                broadcastIntent_otppage.setAction("com.finish.OtpPage");
                sendBroadcast(broadcastIntent_otppage);

                Intent broadcastIntent_paymentfaresummery = new Intent();
                broadcastIntent_paymentfaresummery.setAction("com.finish.PaymentFareSummeryPage");
                sendBroadcast(broadcastIntent_paymentfaresummery);

                Intent broadcastIntent_newleadslpage = new Intent();
                broadcastIntent_newleadslpage.setAction("com.finish.NewLeadsPage");
                sendBroadcast(broadcastIntent_newleadslpage);

                Intent broadcastIntent_statisticsPage = new Intent();
                broadcastIntent_statisticsPage.setAction("com.finish.StatisticsPage");
                sendBroadcast(broadcastIntent_statisticsPage);

                Intent broadcastIntent_loadingPage = new Intent();
                broadcastIntent_loadingPage.setAction("com.finish.LoadingPage");
                sendBroadcast(broadcastIntent_loadingPage);


            }
        });

        BT_submit_rating.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                boolean isRatingEmpty = false;

                System.out.println("btnclick------------------");

                if (reviweslist != null) {
                    for (int i = 0; i < reviweslist.size(); i++) {
                        if (reviweslist.get(i).getRatings_count().length() == 0 || reviweslist.get(i).getRatings_count().equalsIgnoreCase("0.0")) {
                            isRatingEmpty = true;
                        }

                        System.out.println("btnclick2------------------");
                    }

                    if (!isRatingEmpty) {

                        if (!isRatingEmpty) {
                            if (isInternetPresent) {

                                System.out.println("------------job_id-------------" + JobId);
                                System.out.println("------------comments-------------" + Et_comment.getText().toString());
                                System.out.println("------------ratingsFor-------------" + "user");

                                if (Et_comment.getText().toString().length() > 0) {
                                    HashMap<String, String> jsonParams = new HashMap<String, String>();
                                    jsonParams.put("comments", Et_comment.getText().toString());
                                    jsonParams.put("ratingsFor", "tasker");
                                    jsonParams.put("job_id", JobId);
                                    for (int i = 0; i < reviweslist.size(); i++) {
                                        id = reviweslist.get(i).getOptions_id();
                                        title = reviweslist.get(i).getOptions_title();
                                        count = reviweslist.get(i).getRatings_count();


                                        jsonParams.put("ratings[" + i + "][option_id]", reviweslist.get(i).getOptions_id());
                                        jsonParams.put("ratings[" + i + "][option_title]", reviweslist.get(i).getOptions_title());
                                        jsonParams.put("ratings[" + i + "][rating]", reviweslist.get(i).getRatings_count());
                                    }
                                    System.out.println("------------jsonParams-------------" + jsonParams);


                                    if (byteArray != null) {
                                        uploadUserImage(ServiceConstant.REVIWES_SUBMIT_URL, jsonParams);
                                    } else {

                                        submitRatingsPostRequest(ServiceConstant.REVIWES_SUBMIT_URL, jsonParams);
                                    }


                                } else {
                                    Alert(getResources().getString(R.string.my_rides_rating_header_sorry_textview), getResources().getString(R.string.my_rides_rating_header_comment_textview));
                                }
                            } else {
                                Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                            }
                        } else {
                            Alert(getResources().getString(R.string.my_rides_rating_header_sorry_textview), getResources().getString(R.string.my_rides_rating_header_enter_all));
                        }

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), getResources().getString(R.string.lbel_notification_selectrating));
                    }

                }


            }


        });


    }


    private void initilize() {
        cd = new ConnectionDetector(ReviwesPage.this);
        session = new SessionManager(ReviwesPage.this);
        socketHandler = SocketHandler.getInstance(this);

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

        reviweslist = new ArrayList<Reviwes_Pojo>();

        Intent i = getIntent();
        JobId = i.getStringExtra("jobId");

        System.out.println("jobidget-----------" + JobId);

        listview = (ExpandableHeightListView) findViewById(R.id.listView_rating);
        layout_skip = (RelativeLayout) findViewById(R.id.layout_reviwes_skip);
        // Rl_ratings_main_layout = (RelativeLayout) findViewById(R.id.rating_main_layout);
        //   Rl_ratings_emptyratings_layout = (RelativeLayout) findViewById(R.id.layout_ratings_reviwes_empty);
        //  Rl_ratings_nointernet_layout = (RelativeLayout) findViewById(R.id.layout_ratings__noInternet);
        // Rl_rating_now_layout = (RelativeLayout) findViewById(R.id.layout_reviwesubmit_btn);
        BT_submit_rating = (Button) findViewById(R.id.btn_submit_reviwes);
        Et_comment = (EditText) findViewById(R.id.my_rides_rating_comment_edittext);
        Img_upload_ratingimg = (CircularImageView) findViewById(R.id.rating_uploadimg);
        username= (TextView) findViewById(R.id.username);

        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            ratingsPostRequest(ReviwesPage.this, ServiceConstant.REVIWES_GET_URL);
            System.out.println("reviwes-get url-----------" + ServiceConstant.REVIWES_GET_URL);

        } else {
            Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
        }

    }


    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(ReviwesPage.this);
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


    //-------------------------Get ratings options-------------------
    private void ratingsPostRequest(Context mContext, String url) {

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("holder_type", "provider");
        jsonParams.put("user", provider_id);
        jsonParams.put("job_id", JobId);

        // System.out.println("---------------provider----------------"+provider);
        System.out.println("---------------provider_id-----------------" + provider_id);
        dialog = new LoadingDialog(ReviwesPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                System.out.println("Review Response---------------" + response);
                Log.e("ratings", response);
                String Str_status = "", Str_total = "", Str_Rating = "";

                try {

                    JSONObject jobject = new JSONObject(response);
                    Log.e("reviews_url",jobject.toString(1));
                    Str_status = jobject.getString("status");
                    Str_total = jobject.getString("total");

                    if (Str_status.equalsIgnoreCase("1")) {

                        JSONArray jarry = jobject.getJSONArray("review_options");

                        if (jarry.length() > 0) {
                            for (int i = 0; i < jarry.length(); i++) {
                                JSONObject object = jarry.getJSONObject(i);
                                Reviwes_Pojo pojo = new Reviwes_Pojo();

                                pojo.setOptions_title(object.getString("option_name"));
                                pojo.setOptions_id(object.getString("option_id"));
                                pojo.setRatings_count("");
                                user_image=object.getString("image");
                                Usersname=object.getString("username");
                                System.out.println("-------username------------"+Usersname);
                                reviweslist.add(pojo);
                            }
                        }
                        show_progress_status = true;
                        Picasso.with(getApplicationContext()).load(String.valueOf(user_image)).placeholder(R.drawable.nouserimg).into(Img_upload_ratingimg);

                    } else {
                        show_progress_status = false;
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

                dialog.dismiss();

                if (Str_status.equalsIgnoreCase("1")) {
                    username.setText(Usersname);
                    adapter = new Reviwes_Adapter(ReviwesPage.this, reviweslist);
                    listview.setAdapter(adapter);
                    listview.setExpanded(true);
                    dialog.dismiss();

                } else {
                    final PkDialog mdialog = new PkDialog(ReviwesPage.this);
                    mdialog.setDialogTitle(getResources().getString(R.string.server_lable_header));
                    mdialog.setDialogMessage(getResources().getString(R.string.alert_servererror));
                    mdialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            mdialog.dismiss();
                        }
                    });
                }
              /*  if (show_progress_status) {
                    Rl_ratings_emptyratings_layout.setVisibility(View.GONE);
                } else {
                    Rl_ratings_emptyratings_layout.setVisibility(View.VISIBLE);
                    listview.setEmptyView(Rl_ratings_emptyratings_layout);
                }*/
            }

            @Override
            public void onErrorListener() {

                dialog.dismiss();

            }
        });


    }

    //----------------------------------submit ratings-----------------------
    private void submitRatingsPostRequest(String url, final Map<String, String> jsonParams) {

        dialog = new LoadingDialog(ReviwesPage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.dialog_rating));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(ReviwesPage.this);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, (HashMap<String, String>) jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                System.out.println("------------Submit Rating Response----------------" + response);

                Log.e("submitratins", response);
                String status = "", Str_response = "";
                String sStatus = "", SUser_image = "", Smsg = "";
                try {
                    JSONObject object = new JSONObject(response);
                    status = object.getString("status");
                    Str_response = object.getString("response");

                    System.out.println("status------" + status);


                    if (status.equalsIgnoreCase("1")) {
                        JSONObject responseObject = object.getJSONObject("response");
                        SUser_image = responseObject.getString("image");
                        Smsg = responseObject.getString("msg");
                        session.setUserImageUpdate(SUser_image);
                        Img_upload_ratingimg.setImageBitmap(bitMapThumbnail);
                        session.setUserImageUpdate(SUser_image);
                        final PkDialog mdialog = new PkDialog(ReviwesPage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Smsg);
                        mdialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();

                                        Intent broadcastIntent_receivecash = new Intent();
                                        broadcastIntent_receivecash.setAction("com.finish.ReceiveCashPage");
                                        sendBroadcast(broadcastIntent_receivecash);

                                        Intent broadcastIntent_otppage = new Intent();
                                        broadcastIntent_otppage.setAction("com.finish.OtpPage");
                                        sendBroadcast(broadcastIntent_otppage);

                                        Intent broadcastIntent_paymentfaresummery = new Intent();
                                        broadcastIntent_paymentfaresummery.setAction("com.finish.PaymentFareSummeryPage");
                                        sendBroadcast(broadcastIntent_paymentfaresummery);

                                        Intent broadcastIntent_newleadslpage = new Intent();
                                        broadcastIntent_newleadslpage.setAction("com.finish.NewLeadsPage");
                                        sendBroadcast(broadcastIntent_newleadslpage);

                                        finish();
                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
                    }
                    dialog.dismiss();


                } catch (Exception e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                }

            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }

    private void uploadUserImage(String url, final HashMap<String, String> jsonParams) {

        System.out.println("------------job_id-------------" + JobId);
        System.out.println("------------comments-------------" + Et_comment.getText().toString());
        System.out.println("------------ratingsFor-------------" + "user");
        System.out.println("id---------" + id);
        System.out.println("title---------" + title);
        System.out.println("count---------" + count);


        dialog1 = new Dialog(ReviwesPage.this);
        dialog1.getWindow();
        dialog1.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog1.setContentView(R.layout.custom_loading);
        dialog1.setCanceledOnTouchOutside(false);
        dialog1.show();

        TextView dialog_title = (TextView) dialog1.findViewById(R.id.custom_loading_textview);
        dialog_title.setText(getResources().getString(R.string.action_loading));

        VolleyMultipartRequest multipartRequest = new VolleyMultipartRequest(Request.Method.POST, url, new Response.Listener<NetworkResponse>() {
            @Override
            public void onResponse(NetworkResponse response) {

                System.out.println("------------- image response-----------------" + response.data);

                String resultResponse = new String(response.data);
                System.out.println("-------------  response-----------------" + resultResponse);
                String sStatus = "", Str_response = "", SUser_image = "", Smsg = "";

                try {
                    JSONObject jsonObject = new JSONObject(resultResponse);
                    sStatus = jsonObject.getString("status");
                    Str_response = jsonObject.getString("response");

                    if (sStatus.equalsIgnoreCase("1")) {
                        JSONObject responseObject = jsonObject.getJSONObject("response");
                        SUser_image = responseObject.getString("image");
                        Smsg = responseObject.getString("msg");

                        Img_upload_ratingimg.setImageBitmap(bitMapThumbnail);
                        session.setUserImageUpdate(SUser_image);

                        final PkDialog mdialog = new PkDialog(ReviwesPage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Smsg);
                        mdialog.setPositiveButton(getResources().getString(R.string.action_ok), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();

                                        Intent broadcastIntent_receivecash = new Intent();
                                        broadcastIntent_receivecash.setAction("com.finish.ReceiveCashPage");
                                        sendBroadcast(broadcastIntent_receivecash);

                                        Intent broadcastIntent_otppage = new Intent();
                                        broadcastIntent_otppage.setAction("com.finish.OtpPage");
                                        sendBroadcast(broadcastIntent_otppage);

                                        Intent broadcastIntent_paymentfaresummery = new Intent();
                                        broadcastIntent_paymentfaresummery.setAction("com.finish.PaymentFareSummeryPage");
                                        sendBroadcast(broadcastIntent_paymentfaresummery);

                                        Intent broadcastIntent_newleadslpage = new Intent();
                                        broadcastIntent_newleadslpage.setAction("com.finish.NewLeadsPage");
                                        sendBroadcast(broadcastIntent_newleadslpage);

                                        finish();
                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.server_lable_header), Str_response);
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
                dialog.dismiss();
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {

                dialog.dismiss();

                NetworkResponse networkResponse = error.networkResponse;
                String errorMessage = "Unknown error";
                if (networkResponse == null) {
                    if (error.getClass().equals(TimeoutError.class)) {
                        errorMessage = "Request timeout";
                    } else if (error.getClass().equals(NoConnectionError.class)) {
                        errorMessage = "Failed to connect server";
                    }
                } else {
                    String result = new String(networkResponse.data);
                    try {
                        JSONObject response = new JSONObject(result);
                        String status = response.getString("status");
                        String message = response.getString("message");

                        Log.e("Error Status", status);
                        Log.e("Error Message", message);

                        if (networkResponse.statusCode == 404) {
                            errorMessage = "Resource not found";
                        } else if (networkResponse.statusCode == 401) {
                            errorMessage = message + " Please login again";
                        } else if (networkResponse.statusCode == 400) {
                            errorMessage = message + " Check your inputs";
                        } else if (networkResponse.statusCode == 500) {
                            errorMessage = message + " Something is getting wrong";
                        }
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                }
                Log.i("Error", errorMessage);
                error.printStackTrace();
            }
        }) {
            @Override
            protected Map<String, String> getParams() {
                return jsonParams;
            }

            @Override
            protected Map<String, DataPart> getByteData() {
                Map<String, DataPart> params = new HashMap<>();
                params.put("file", new DataPart("maidac.jpg", byteArray));

                System.out.println("photo--------edit------" + byteArray);

                return params;
            }
        };

        //to avoid repeat request Multiple Time
        DefaultRetryPolicy retryPolicy = new DefaultRetryPolicy(0, -1, DefaultRetryPolicy.DEFAULT_BACKOFF_MULT);
        multipartRequest.setRetryPolicy(retryPolicy);
        multipartRequest.setRetryPolicy(new DefaultRetryPolicy(60000,
                DefaultRetryPolicy.DEFAULT_MAX_RETRIES,
                DefaultRetryPolicy.DEFAULT_BACKOFF_MULT));
        multipartRequest.setShouldCache(false);
        AppController.getInstance().addToRequestQueue(multipartRequest);
    }

    @Override
    public void onResume() {
        super.onResume();
        if (!ChatMessageService.isStarted()) {
            Intent intent = new Intent(ReviwesPage.this, ChatMessageService.class);
            startService(intent);
        }
    }

    private boolean checkAccessFineLocationPermission() {
        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkAccessCoarseLocationPermission() {
        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkWriteExternalStoragePermission() {
        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private void requestPermission() {
        ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.CAMERA, Manifest.permission.CAMERA, Manifest.permission.WRITE_EXTERNAL_STORAGE}, PERMISSION_REQUEST_CODE);
    }

    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case PERMISSION_REQUEST_CODE:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    chooseimage();
                } else {
                    finish();
                }
                break;
        }
    }

    // --------------------Method for choose image to edit profileimage--------------------
    private void chooseimage() {
        photo_dialog = new Dialog(ReviwesPage.this);
        photo_dialog.getWindow();
        photo_dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        photo_dialog.setContentView(R.layout.image_upload_dialog);
        photo_dialog.setCanceledOnTouchOutside(true);
        photo_dialog.getWindow().getAttributes().windowAnimations = R.style.Animations_photo_Picker;
        photo_dialog.show();
        photo_dialog.getWindow().setGravity(Gravity.CENTER);

        RelativeLayout camera = (RelativeLayout) photo_dialog
                .findViewById(R.id.profilelayout_takephotofromcamera);
        RelativeLayout gallery = (RelativeLayout) photo_dialog
                .findViewById(R.id.profilelayout_takephotofromgallery);

        camera.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                takePicture();
                photo_dialog.dismiss();
            }
        });

        gallery.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                openGallery();
                photo_dialog.dismiss();
            }
        });
    }


    private void takePicture() {
        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        camera_FileUri = getOutputMediaFileUri(1);
        intent.putExtra(MediaStore.EXTRA_OUTPUT, camera_FileUri);
        // start the image capture Intent
        startActivityForResult(intent, REQUEST_TAKE_PHOTO);
    }

    private void openGallery() {
        Intent intent = new Intent(Intent.ACTION_PICK, MediaStore.Images.Media.EXTERNAL_CONTENT_URI);
        startActivityForResult(intent, galleryRequestCode);
    }

    /**
     * Creating file uri to store image/video
     */
    public Uri getOutputMediaFileUri(int type) {
        return Uri.fromFile(getOutputMediaFile(type));
    }


    /**
     * returning image / video
     */
    private static File getOutputMediaFile(int type) {

        // External sdcard location
        File mediaStorageDir = new File(
                Environment
                        .getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES), IMAGE_DIRECTORY_NAME);

        // Create the storage directory if it does not exist
        if (!mediaStorageDir.exists()) {
            if (!mediaStorageDir.mkdirs()) {
                Log.d(TAG, "Oops! Failed create "
                        + IMAGE_DIRECTORY_NAME + " directory");
                return null;
            }
        }

        // Create a media file name
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss",
                Locale.getDefault()).format(new Date());
        File mediaFile;
        if (type == 1) {
            mediaFile = new File(mediaStorageDir.getPath() + File.separator
                    + "IMG_" + timeStamp + ".jpg");
        } else {
            return null;
        }

        return mediaFile;
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);

        // save file url in bundle as it will be null on screen orientation
        // changes
        outState.putParcelable("file_uri", camera_FileUri);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);

        // get the file url
        camera_FileUri = savedInstanceState.getParcelable("file_uri");
    }


    private static int exifToDegrees(int exifOrientation) {
        if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_90) {
            return 90;
        } else if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_180) {
            return 180;
        } else if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_270) {
            return 270;
        }
        return 0;
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (resultCode == RESULT_OK) {
            if (requestCode == REQUEST_TAKE_PHOTO) {
                try {
                    BitmapFactory.Options options = new BitmapFactory.Options();
                    options.inSampleSize = 8;

                    final Bitmap bitmap = BitmapFactory.decodeFile(camera_FileUri.getPath(), options);
                    Bitmap thumbnail = bitmap;
                    final String picturePath = camera_FileUri.getPath();
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();

                    File curFile = new File(picturePath);
                    try {
                        ExifInterface exif = new ExifInterface(curFile.getPath());
                        int rotation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
                        int rotationInDegrees = exifToDegrees(rotation);

                        Matrix matrix = new Matrix();
                        if (rotation != 0f) {
                            matrix.preRotate(rotationInDegrees);
                        }
                        thumbnail = Bitmap.createBitmap(thumbnail, 0, 0, thumbnail.getWidth(), thumbnail.getHeight(), matrix, true);
                    } catch (IOException ex) {
                        Log.e("TAG", "Failed to get Exif data", ex);
                    }
                    thumbnail.compress(Bitmap.CompressFormat.JPEG, 70, byteArrayOutputStream);
                    byteArray = byteArrayOutputStream.toByteArray();

                    //------------Code to update----------
                    bitMapThumbnail = thumbnail;
                    Img_upload_ratingimg.setImageBitmap(thumbnail);

                    /*if (isInternetPresent) {
                        uploadUserImage (Iconstant.profile_edit_photo_url);
                        System.out.println("edit-----"+Iconstant.profile_edit_photo_url);
                    } else {
                        alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                    }*/

                } catch (Exception e) {
                    e.printStackTrace();
                }

            } else if (requestCode == galleryRequestCode) {

                Uri selectedImage = data.getData();
                if (selectedImage.toString().startsWith("content://com.sec.android.gallery3d.provider")) {
                    String[] filePath = {MediaStore.Images.Media.DATA};
                    Cursor c = getContentResolver().query(selectedImage, filePath, null, null, null);
                    c.moveToFirst();
                    int columnIndex = c.getColumnIndex(filePath[0]);
                    final String picturePath = c.getString(columnIndex);
                    c.close();

                    Picasso.with(ReviwesPage.this).load(picturePath).resize(100, 100).into(new Target() {
                        @Override
                        public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom from) {
                            Bitmap thumbnail = bitmap;
                            mSelectedFilePath = picturePath;
                            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                            thumbnail.compress(Bitmap.CompressFormat.JPEG, 70, byteArrayOutputStream);
                            byteArray = byteArrayOutputStream.toByteArray();

                            //------------Code to update----------
                            bitMapThumbnail = thumbnail;
                            Img_upload_ratingimg.setImageBitmap(thumbnail);

/*
                            cd = new ConnectionDetector(RatingPage.this);
                            isInternetPresent = cd.isConnectingToInternet();
                            if (isInternetPresent) {
                                uploadUserImage (Iconstant.profile_edit_photo_url);
                                System.out.println("edit-----"+Iconstant.profile_edit_photo_url);
                            } else {
                                alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                            }*/
                        }

                        @Override
                        public void onBitmapFailed(Drawable errorDrawable) {
                        }

                        @Override
                        public void onPrepareLoad(Drawable placeHolderDrawable) {
                        }
                    });
                } else {
                    String[] filePath = {MediaStore.Images.Media.DATA};
                    Cursor c = getContentResolver().query(selectedImage, filePath, null, null, null);
                    c.moveToFirst();

                    int columnIndex = c.getColumnIndex(filePath[0]);
                    final String picturePath = c.getString(columnIndex);
                    Bitmap bitmap = BitmapFactory.decodeFile(picturePath);
                    Bitmap thumbnail = bitmap; //getResizedBitmap(bitmap, 600);
                    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                    File curFile = new File(picturePath);

                    try {
                        ExifInterface exif = new ExifInterface(curFile.getPath());
                        int rotation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
                        int rotationInDegrees = exifToDegrees(rotation);

                        Matrix matrix = new Matrix();
                        if (rotation != 0f) {
                            matrix.preRotate(rotationInDegrees);
                        }
                        thumbnail = Bitmap.createBitmap(thumbnail, 0, 0, thumbnail.getWidth(), thumbnail.getHeight(), matrix, true);
                    } catch (IOException ex) {
                        Log.e("TAG", "Failed to get Exif data", ex);
                    }
                    thumbnail.compress(Bitmap.CompressFormat.JPEG, 70, byteArrayOutputStream);
                    byteArray = byteArrayOutputStream.toByteArray();
                    c.close();

                    bitMapThumbnail = thumbnail;
                    Img_upload_ratingimg.setImageBitmap(thumbnail);
/*
                    cd = new ConnectionDetector(ReviwesPage.this);
                    isInternetPresent = cd.isConnectingToInternet();
                    if (isInternetPresent) {
                        //------------Code to update----------
                        bitMapThumbnail = thumbnail;
                        Img_profilepic.setImageBitmap(thumbnail);

                        uploadUserImage (Iconstant.profile_edit_photo_url);
                        System.out.println("edit-----"+Iconstant.profile_edit_photo_url);

                    } else {
                        alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                    }*/
                }
            }
        }
    }


    //-----------------Move Back on  phone pressed  back button------------------
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if ((keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0)) {
            // nothing
            return true;
        }
        return false;
    }


}
