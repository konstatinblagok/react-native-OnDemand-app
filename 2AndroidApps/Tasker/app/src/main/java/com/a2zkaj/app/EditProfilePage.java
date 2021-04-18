package com.a2zkaj.app;

import android.Manifest;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.util.Base64;
import android.util.Log;
import android.util.Patterns;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.Window;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.DefaultRetryPolicy;
import com.android.volley.NetworkResponse;
import com.android.volley.NoConnectionError;
import com.android.volley.Request;
import com.android.volley.Response;
import com.android.volley.TimeoutError;
import com.android.volley.VolleyError;
import com.countrycodepicker.CountryPicker;
import com.countrycodepicker.CountryPickerListener;
import com.google.android.gms.appindexing.AppIndex;
import com.google.android.gms.common.api.GoogleApiClient;
import com.a2zkaj.Fragment.MyProfileFragment;
import com.a2zkaj.Pojo.AvailabilityEditPojo;
import com.a2zkaj.Pojo.Availabilitypojo;
import com.a2zkaj.Pojo.UpdateCategorydatapojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.HideSoftKeyboard;
import com.a2zkaj.Utils.ListInScroll;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.AvailabillityEditAdapter;
import com.a2zkaj.adapter.CategoryListAdapter;
import com.a2zkaj.adapter.PlaceSearchAdapter;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;
import com.squareup.picasso.Picasso;
import com.yalantis.ucrop.UCrop;

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
import core.Map.GPSTracker;
import core.Volley.AppController;
import core.Volley.ServiceRequest;
import core.Volley.VolleyMultipartRequest;
import core.Widgets.CircularImageView;
import core.service.ServiceConstant;
import core.socket.SocketHandler;
import me.drakeet.materialdialog.MaterialDialog;

/**
 * Created by user88 on 1/12/2016.
 */
public class EditProfilePage extends ActionBarActivityHockeyApp implements View.OnClickListener {
    private static LoadingDialog dialog;

    Dialog dialog1;
    private MaterialDialog otp_dialog;
    private EditText Et_Otp;
    private Button Bt_otp_submit,otp_cancel;
    private String Str_OtpCode = "", Update_mobil_Response = "", Update_otp_response = "", Str_Opt_Status = "", Str_Country_Code = "", Str_PhoneNo = "";
    public static String provider_id = "";
    private ServiceRequest myRequest;
    final int PERMISSION_REQUEST_CODE = 111;
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;
    private EditText Et_email, Et_mobileno, Et_country_code, Et_bio, Et_city, Et_state, Et_country, Et_postal_code, Et_address;
    private TextView etitprofile_email_update_Tv, etitprofile_mobileno_update_Tv, etitprofile_bio_update_Tv, etitprofile_address_update_Tv;
    private CircularImageView Img_profileimg;
    private RelativeLayout Rl_layout_back;
    String add = "";
    String add1 = "";
    Bitmap bitMapThumbnail;
    private byte[] byteArray;
    private ServiceRequest mRequest;
    private Dialog photo_dialog;
    //variable to add photo
    private static final int CAMERA_PICTURE = 1;
    private static final int GALLERY_PICTURE = 2;

    private static final int save_added_category = 5;
    // private HttpEntity resEntity;
    private int search_status = 0;
    private int REQUEST_TAKE_PHOTO = 1;
    private int galleryRequestCode = 2;
    private Uri camera_FileUri;
    private static final String TAG = "";
    // directory name to store captured images and videos
    private static final String IMAGE_DIRECTORY_NAME = "PlumbalPartner";

    private String mSelectedFilePath = "";
    private boolean isdataAvailable = false;
    private SocketHandler socketHandler;
    ArrayList<String> itemList_location = new ArrayList<String>();
    ArrayList<String> itemList_placeId = new ArrayList<String>();
    private ListView myLocationLV;
    private PlaceSearchAdapter myLocationLVAdapter;
    private String SselectedLatitude = "";
    private String SselectedLongitude = "";
    private String myWorkLocLatitude = "", myWorkLocLongitude = "";
    private int placeSearch_request_code = 200;
    private int workLocattionRequestCode = 250;
    private RelativeLayout Rl_layput_address;
    private EditText myNameET, myRadiusET;
    private ImageButton myAddIMGBTN;
    private TextView myUpdateNameTXT, myUpdateWorkLocationTXT, myUpdateRadiusTXT, myWorkLocationTXT;

    private GoogleApiClient client;
    private String Slatitude = "", Slongitude = "", Sselected_location = "";
    AvailabillityEditAdapter availadapter;
    private ArrayList<Availabilitypojo> availlist;
    private ListView list;
    private ListView categoryList;
    private CategoryListAdapter categoryListAdapter;
    private ArrayList<UpdateCategorydatapojo> categorydatapojoArrayList;
    RelativeLayout add_category;
    private GPSTracker gpsTracker;
    CountryPicker picker;

    private String radius_mi_or_km = "";
    private TextView unit;

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.refresh.editprofilepage")) {
                myprofilePostRequest(EditProfilePage.this, ServiceConstant.PROFILEINFO_URL);

            }
        }
    }

    private RefreshReceiver finishReceiver;

    private static int PICK_IMAGE = 2;
    private static int CAMERA_REQUEST_2 = 1;
    Bitmap finalPic = null;
    String encode;
    private static int CAMERA_PIC_REQUEST = 1337;
    private Uri mImageCaptureUri;
    Uri outputUri = null;

    File captured_image;
    String imagePath;
    String appDirectoryName;
    File imageRoot;
    Uri selectedImage;

    boolean rotate = false;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.edit_profile);
        initilize();

        HideSoftKeyboard.setupUI(
                EditProfilePage.this.getWindow().getDecorView(),
                EditProfilePage.this);

        Rl_layout_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                Intent editpage = new Intent();
                editpage.setAction("com.package.load.editpage");
                sendBroadcast(editpage);
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

        Img_profileimg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Build.VERSION.SDK_INT >= 23) {
                    // Marshmallow+
                    if (!checkAccessFineLocationPermission() || !checkAccessCoarseLocationPermission() || !checkWriteExternalStoragePermission()) {
                        requestPermission();
                    } else {
                        chooseimage();
                    }
                } else {
                    chooseimage();
                }
            }
        });

        appDirectoryName = getString(R.string.app_name);
        imageRoot = new File(Environment.getExternalStoragePublicDirectory(
                Environment.DIRECTORY_PICTURES), appDirectoryName);
        if (!imageRoot.exists()) {
            imageRoot.mkdir();
        } else if (!imageRoot.isDirectory()) {
            imageRoot.delete();
            imageRoot.mkdir();
        }
        String name = dateToString(new Date(), "yyyy-MM-dd-hh-mm-ss");
        captured_image = new File(imageRoot,
                name + ".jpg");

        myAddIMGBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Build.VERSION.SDK_INT >= 23) {
                    // Marshmallow+
                    if (!checkAccessFineLocationPermission() || !checkAccessCoarseLocationPermission() || !checkWriteExternalStoragePermission()) {
                        requestPermission();
                    } else {
                        chooseimage();
                    }
                } else {
                    chooseimage();
                }
            }
        });

        etitprofile_email_update_Tv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                isInternetPresent = cd.isConnectingToInternet();
                if (isInternetPresent) {
                    EditEmailUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_EMAIL_URL);
                    System.out.println("email---------" + ServiceConstant.EDIT_EMAIL_URL);
                } else {
                    Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                }
            }
        });


        etitprofile_bio_update_Tv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Et_bio.getText().toString().length() == 0) {
                    erroredit(Et_bio, getResources().getString(R.string.editbiovalidate_country_label));

                } else {
                    isInternetPresent = cd.isConnectingToInternet();
                    if (isInternetPresent) {
                        EditBioUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_BIO_URL);
                        System.out.println("bio---------" + ServiceConstant.EDIT_BIO_URL);
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                }


            }
        });


        etitprofile_address_update_Tv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (Et_address.getText().toString().length() == 0) {
                    erroredit(Et_address, getResources().getString(R.string.edit_address_validate_country_label));

                }

                else {
                    isInternetPresent = cd.isConnectingToInternet();
                    if (isInternetPresent) {
                        EditAddressUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_ADDRESS_URL);
                        System.out.println("address---------" + ServiceConstant.EDIT_ADDRESS_URL);
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }

                }
            }
        });

        etitprofile_mobileno_update_Tv.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (Et_mobileno.getText().toString().length() == 0) {
                    erroredit(Et_mobileno, getResources().getString(R.string.edit_mobilno_validate_country_label));
                } else if (!isValidPhoneNumber(Et_mobileno.getText().toString())) {
                    erroredit(Et_mobileno, getResources().getString(R.string.profile_label_error_mobile));
                } else if (Et_country_code.getText().toString().length() == 0) {
                    erroredit(Et_country_code, getResources().getString(R.string.edit_country_code_validate_country_label));
                } else {
                    isInternetPresent = cd.isConnectingToInternet();
                    if (isInternetPresent) {
                        EditMObilenoUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_MOBILE_NUMBER_URL);
                        System.out.println("mobileno---------" + ServiceConstant.EDIT_MOBILE_NUMBER_URL);
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                    }
                }
            }
        });
        add_category.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent editIntent = new Intent(EditProfilePage.this, EditCategoryActivity.class);
                editIntent.putExtra("from","add");
                startActivityForResult(editIntent, save_added_category);
            }
        });

        client = new GoogleApiClient.Builder(this).addApi(AppIndex.API).build();
    }
    public String dateToString(Date date, String format) {
        SimpleDateFormat df = new SimpleDateFormat(format);
        return df.format(date);
    }

    private void initilize() {
        gpsTracker=new GPSTracker(EditProfilePage.this);
        picker = CountryPicker.newInstance("Select Country");
        categorydatapojoArrayList=new ArrayList<>();
        session = new SessionManager(EditProfilePage.this);
        availlist = new ArrayList<Availabilitypojo>();
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        cd = new ConnectionDetector(EditProfilePage.this);
        socketHandler = SocketHandler.getInstance(this);
        Et_email = (EditText) findViewById(R.id.editprofile_edit_email_Et);
        Et_bio = (EditText) findViewById(R.id.editprofile_edit_bio_Et);
        Et_mobileno = (EditText) findViewById(R.id.editprofile_edit_mobileno_Et);
        Et_country_code = (EditText) findViewById(R.id.editprofile_edit_countrycode_mobileno_Et);
        Et_city = (EditText) findViewById(R.id.editprofile_edit_city_addresss_Et);
        Et_state = (EditText) findViewById(R.id.editprofile_edit_state_addresss_Et);
        Et_country = (EditText) findViewById(R.id.editprofile_edit_country_addresss_Et);
        Et_postal_code = (EditText) findViewById(R.id.editprofile_edit_postalcode_addresss_Et);
        Et_address = (EditText) findViewById(R.id.editprofile_edit_address_addresss_Et);
        list = (ListView) findViewById(R.id.avail_list);
        myAddIMGBTN = (ImageButton) findViewById(R.id.edit_profile_IMGBTN_add);
        unit = (TextView) findViewById(R.id.unit);

        Rl_layout_back = (RelativeLayout) findViewById(R.id.layout_editprofile_back);
        myLocationLV = (ListView) findViewById(R.id.location_search_listView);
        Rl_layput_address = (RelativeLayout) findViewById(R.id.book_address_layout);
        etitprofile_email_update_Tv = (TextView) findViewById(R.id.email_Update_Tv);
        etitprofile_mobileno_update_Tv = (TextView) findViewById(R.id.mobilno_Update_Tv);
        etitprofile_bio_update_Tv = (TextView) findViewById(R.id.bio_Update_Tv);
        etitprofile_address_update_Tv = (TextView) findViewById(R.id.address_Update_Tv);
        Img_profileimg = (CircularImageView) findViewById(R.id.profileimg);
        add_category=(RelativeLayout)findViewById(R.id.add_category);
        categoryList = (ListView) findViewById(R.id.saved_category_list);
        //--------------------Name-------------//
        myNameET = (EditText) findViewById(R.id.editprofile_edit_name_Et);
        myUpdateNameTXT = (TextView) findViewById(R.id.name_Update_Tv);

        //--------------------Work Location-------------//
        myWorkLocationTXT = (TextView) findViewById(R.id.editprofile_edit_worklocation_TXT);
        myUpdateWorkLocationTXT = (TextView) findViewById(R.id.worklocation_Update_Tv);


        //--------------------Radius-------------//
        myRadiusET = (EditText) findViewById(R.id.editprofile_edit_radius_Et);
        myUpdateRadiusTXT = (TextView) findViewById(R.id.radius_Update_Tv);


        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            getEditProfileinfoPostRequest(EditProfilePage.this, ServiceConstant.EDIT_PROFILE_URL);
            System.out.println("edit---------" + ServiceConstant.EDIT_PROFILE_URL);
        } else {
            Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
        }

        Rl_layput_address.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                search_status = 0;
                Intent intent = new Intent(EditProfilePage.this, LocationSearch.class);
                startActivityForResult(intent, placeSearch_request_code);
                //  EditProfilePage.this.overridePendingTransition(R.anim.slideup, R.anim.slidedown);
            }
        });

        Intent intent = getIntent();
        radius_mi_or_km = intent.getStringExtra("radius_mi_or_km");
        if (radius_mi_or_km.contains("km") || radius_mi_or_km.contains("KM")){
            unit.setText("KM");
        } else {
            unit.setText("mi");
        }

        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.refresh.editprofilepage");
        registerReceiver(finishReceiver, intentFilter);
        clickListener();
    }

    private void clickListener() {
        myUpdateNameTXT.setOnClickListener(this);
        myUpdateWorkLocationTXT.setOnClickListener(this);
        myUpdateRadiusTXT.setOnClickListener(this);
        myWorkLocationTXT.setOnClickListener(this);

        Et_country_code.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!picker.isAdded()) {
                    picker.show(getSupportFragmentManager(), "COUNTRY_PICKER");
                }
            }
        });

        picker.setListener(new CountryPickerListener() {
            @Override
            public void onSelectCountry(String name, String code, String dialCode) {
                picker.dismiss();
                Et_country_code.setText(dialCode);
            }
        });


    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.name_Update_Tv:
                checkNameDataValues();
                break;

            case R.id.worklocation_Update_Tv:
                checkWorkLocationValues();
                break;

            case R.id.radius_Update_Tv:
                checkRadiusValues();
                break;

            case R.id.editprofile_edit_worklocation_TXT:
                Intent intent = new Intent(EditProfilePage.this, WorkLocationEditSearch.class);
                startActivityForResult(intent, workLocattionRequestCode);
                break;
        }
    }

    /**
     * check the Name values
     */
    private void checkNameDataValues() {
        if (myNameET.getText().toString().length() == 0) {
            erroredit(myNameET, getResources().getString(R.string.editbiovalidate_name_label));
        } else {
            isInternetPresent = cd.isConnectingToInternet();
            if (isInternetPresent) {
                EditNameUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_NAME_URL);
                System.out.println("bio---------" + ServiceConstant.EDIT_NAME_URL);
            } else {
                Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
            }
        }
    }

    /**
     * check the work location  values
     */
    private void checkWorkLocationValues() {
        if (myWorkLocationTXT.getText().toString().length() == 0) {
            errorTextView(myWorkLocationTXT, getResources().getString(R.string.editbiovalidate_worklocation_label));
        }
        else if(myWorkLocLatitude.equalsIgnoreCase("")&&myWorkLocLongitude.equalsIgnoreCase("")){
            Alert(getResources().getString(R.string.review_not_available),getResources().getString(R.string.location_change));
        }

        else {
            isInternetPresent = cd.isConnectingToInternet();
            if (isInternetPresent) {
                EditWorkLocationUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_WORKLOCATION_URL);
                System.out.println("bio---------" + ServiceConstant.EDIT_WORKLOCATION_URL);
            } else {
                Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
            }
        }
    }

    private void checkRadiusValues() {

        if (myRadiusET.getText().toString().length() == 0) {
            erroredit(myRadiusET, getResources().getString(R.string.editbiovalidate_radius_label));
        } else {
            isInternetPresent = cd.isConnectingToInternet();
            if (isInternetPresent) {
                EditRadiusUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_RADIUS_URL);
                System.out.println("bio---------" + ServiceConstant.EDIT_RADIUS_URL);
            } else {
                Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
            }
        }
    }

    // --------------------Code to set error for EditText-----------------------
    private void erroredit(EditText editname, String msg) {
        Animation shake = AnimationUtils.loadAnimation(EditProfilePage.this,
                R.anim.shake);
        editname.startAnimation(shake);

        ForegroundColorSpan fgcspan = new ForegroundColorSpan(
                Color.parseColor("#cc0000"));
        SpannableStringBuilder ssbuilder = new SpannableStringBuilder(msg);
        ssbuilder.setSpan(fgcspan, 0, msg.length(), 0);
        editname.setError(ssbuilder);
    }

    // --------------------Code to set error for EditText-----------------------
    private void errorTextView(TextView aTextView, String msg) {
        Animation shake = AnimationUtils.loadAnimation(EditProfilePage.this,
                R.anim.shake);
        aTextView.startAnimation(shake);

        ForegroundColorSpan fgcspan = new ForegroundColorSpan(
                Color.parseColor("#cc0000"));
        SpannableStringBuilder ssbuilder = new SpannableStringBuilder(msg);
        ssbuilder.setSpan(fgcspan, 0, msg.length(), 0);
        aTextView.setError(ssbuilder);
    }

    //--------------Alert Method-----------
    private void Alert(String title, String alert) {
        final PkDialog mDialog = new PkDialog(EditProfilePage.this);
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

    // --------------------Method for choose image to edit profileimage--------------------
    private void chooseimage() {
        photo_dialog = new Dialog(EditProfilePage.this);
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
        intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(captured_image));
        intent.putExtra("android.intent.extras.CAMERA_FACING", 0);
        startActivityForResult(intent, CAMERA_REQUEST_2);
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

    //-----------------------Getting profile info post request-------------------
    private void getEditProfileinfoPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);

        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("editinfo", response);

                String Str_Status = "", Str_response = "", Str_Address = "", Str_email = "", Str_address = "", Str_Mobilno = "", Str_countrycode = "", Str_state = "", Str_city = "", Str_country = "", Str_postal_code = "", Str_mobileno = "", Str_bio = "", Str_image = "";

                String aWorkLocationStr = "", aUserNameStr = "", aRadiusStr = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");
                    if (Str_Status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_email = object.getString("email");
                        if(object.has("mobile_number")){
                            Str_Mobilno = object.getString("mobile_number");
                        }
                        if(object.has("dial_code")){
                            Str_countrycode = object.getString("dial_code");
                        }

                        Str_state = object.getString("state");
                        Str_city = object.getString("city");
                        Str_country = object.getString("country");
                        Str_postal_code = object.getString("postal_code");
                        Str_bio = object.getString("bio");
                        Str_image = object.getString("image");
                        Str_Address = object.getString("address");
                        aWorkLocationStr = object.getString("working_location");
                        aUserNameStr = object.getString("username");
                        aRadiusStr = object.getString("radius");

                        String address[] = Str_Address.split(",");
                        add = address[0];

                        System.out.println("AddressField:" + add);
                        //    add1 = address[1];

                        add1 = address[1];

                    } else {
                        Str_response = jobject.getString("response");
                    }
                    if (Str_Status.equalsIgnoreCase("1")) {
                        Et_email.setText(Str_email);
                        Et_bio.setText(Str_bio);
                        Et_mobileno.setText(Str_Mobilno);
                        Et_address.setText(add);
                        Et_country_code.setText(Str_countrycode);
                        Et_country.setText(Str_country);
                        Et_city.setText(Str_city);
                        Et_state.setText(Str_state);
                        Et_postal_code.setText(Str_postal_code);
                        if (aRadiusStr.contains("km") || aRadiusStr.contains("KM")){
                            if (aRadiusStr.contains("km")){
                                myRadiusET.setText(aRadiusStr.replace("km",""));
                            } else {
                                myRadiusET.setText(aRadiusStr.replace("KM",""));
                            }
                        } else {
                            myRadiusET.setText(aRadiusStr.replace("mi",""));
                        }
                        myWorkLocationTXT.setText(aWorkLocationStr);
                        myNameET.setText(aUserNameStr);
                        Picasso.with(EditProfilePage.this).load(String.valueOf(Str_image)).placeholder(R.drawable.nouserimg).into(Img_profileimg);

                        myprofilePostRequest(EditProfilePage.this, ServiceConstant.PROFILEINFO_URL);

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


    private void myprofilePostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);

        System.out.println("provider_id----------------" + provider_id);

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
                        JSONObject object = jobject.getJSONObject("response");
                        Str_name = object.getString("provider_name");
                        Str_designation = object.getString("designation");
                        Str_rating = object.getString("avg_review");
                        Str_email = object.getString("email");
                        if(object.has("mobile_number")){
                            Str_mobileno = object.getString("mobile_number");
                        }
                        if(object.has("dial_code")){
                            aDialcode = object.getString("dial_code");
                        }

                        Str_bio = object.getString("bio");
                        Str_category = object.getString("category").replace("\\n", "<br/>");
                        aExperienceStr = object.getString("experience");
                        aWorkLocationStr = object.getString("Working_location");
                        aRadiusStr = object.getString("radius");
                        Str_addrress = object.getString("address_str");
                        JSONArray array1 = object.getJSONArray("availability_days");
                        availlist.clear();

                        JSONArray categoryItems = object.getJSONArray("category_Details");
                        categorydatapojoArrayList.clear();
                        for (int i = 0; i < categoryItems.length(); i++) {
                            JSONObject object2 = categoryItems.getJSONObject(i);
                            UpdateCategorydatapojo categorydatapojo = new UpdateCategorydatapojo();
                            categorydatapojo.setChildCategory(object2.getString("categoryname"));
                            categorydatapojo.setChildID(object2.getString("_id"));
                            categorydatapojoArrayList.add(categorydatapojo);
                        }


                        categoryListAdapter = new CategoryListAdapter(EditProfilePage.this, categorydatapojoArrayList);
                        categoryList.setAdapter(categoryListAdapter);

                        ListInScroll.setListViewHeightBasedOnChildren(categoryList);
                        setItemClickListener();
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
                        availadapter = new AvailabillityEditAdapter(EditProfilePage.this, availlist);
                        list.setAdapter(availadapter);

                    } else {
                        Str_response = jobject.getString("response");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }

            }

            @Override
            public void onErrorListener() {


            }
        });
    }


    public static final boolean isValidPhoneNumber(CharSequence target) {
        if (target == null || TextUtils.isEmpty(target) || target.length() <= 9) {
            return false;
        } else {
            return Patterns.PHONE.matcher(target).matches();
        }
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        System.out.println("resultCode " + resultCode + "request Code" + requestCode);
        System.out.println("outside the resultcode");

        if (resultCode == RESULT_OK) {
            System.out.println("" + requestCode);
            System.out.println("inside the resultcode" + resultCode);
            if (requestCode == CAMERA_REQUEST_2) {
                try {

                    rotate = true;
                    imagePath = captured_image.getAbsolutePath();
                    mImageCaptureUri = Uri.fromFile(new File(imagePath));
                    outputUri = mImageCaptureUri;
                    System.out.println("Image Captured Uri = " + mImageCaptureUri);

                    Bitmap bitmap = MediaStore.Images.Media.getBitmap(this.getContentResolver(), mImageCaptureUri);
                    System.out.println("Image Captured Uri bitmap = " + bitmap.toString());
                  /*  if (bitmap.getWidth() <= 500 && bitmap.getHeight() <= 500) {
                        Toast.makeText(this, "image is too small", Toast.LENGTH_SHORT).show();
                    } else {*/

                        UCrop.Options options = new UCrop.Options();
                        options.setStatusBarColor(getResources().getColor(R.color.colorPrimary));
                        options.setToolbarColor(getResources().getColor(R.color.colorPrimary));
                        options.setMaxBitmapSize(800);

                        UCrop.of(mImageCaptureUri, outputUri)
                                .withAspectRatio(1, 1)
                                .withMaxResultSize(8000, 8000)
                                .withOptions(options)
                                .start(EditProfilePage.this);



                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else if (requestCode == PICK_IMAGE) {
                // Aviary_Edit(data);
                rotate = false;
                selectedImage = data.getData();

                try {

                    Bitmap bitmap = MediaStore.Images.Media.getBitmap(this.getContentResolver(), selectedImage);
                    int wid = bitmap.getWidth();
                    int height = bitmap.getHeight();
                    System.out.println("---------image------width and -----");

                  /*  if (bitmap.getWidth() <= 500 && bitmap.getHeight() <= 500) {
                        Toast.makeText(this, "Selected Image too small", Toast.LENGTH_SHORT).show();
                    } else {*/

                        if (!imageRoot.exists()) {
                            imageRoot.mkdir();
                        } else if (!imageRoot.isDirectory()) {
                            imageRoot.delete();
                            imageRoot.mkdir();
                        }


                        final File image = new File(imageRoot, System.currentTimeMillis() + ".jpg");
                        outputUri = Uri.fromFile(image);

                        UCrop.Options options = new UCrop.Options();
                        options.setStatusBarColor(getResources().getColor(R.color.colorPrimary));
                        options.setToolbarColor(getResources().getColor(R.color.colorPrimary));
                        options.setMaxBitmapSize(800);


                        UCrop.of(selectedImage, outputUri)
                                .withAspectRatio(1, 1)
                                .withMaxResultSize(8000, 8000)
                                .withOptions(options)
                                .start(EditProfilePage.this);

                 //  }
                } catch (IOException e) {
                    e.printStackTrace();
                }
            } else if (requestCode == UCrop.REQUEST_CROP) {

                final Uri resultUri = UCrop.getOutput(data);

                Log.d("Crop success", "" + resultUri);
                try {
                    Bitmap bitmap = MediaStore.Images.Media.getBitmap(this.getContentResolver(), resultUri);

                    if (bitmap.getWidth() == 500 && bitmap.getHeight() == 500) {

                        finalPic = bitmap;

                    } else {

                        int width = bitmap.getWidth();
                        int height = bitmap.getHeight();

                        float bitmapRatio = (float) width / (float) height;
                        if (bitmapRatio > 0) {
                            width = 500;
                            height = (int) (width / bitmapRatio);

                        } else {
                            height = 500;
                            width = (int) (height * bitmapRatio);
                        }


                        finalPic = Bitmap.createScaledBitmap(bitmap, width, height, true);
                        encode = encodeToBase64(finalPic, Bitmap.CompressFormat.JPEG, 100);

                    }

                    if (finalPic == null) {
                        Log.d("Bitmap", "null");
                    } else {
                        Log.d("Bitmap", "not null");
//                        ByteArrayOutputStream stream = new ByteArrayOutputStream();
//                        finalPic.compress(Bitmap.CompressFormat.JPEG, 100, stream);
//                        byte[] byteArray = stream.toByteArray();
                        //  Log.d("count", "" + img_capture_count);
                        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();


                        finalPic.compress(Bitmap.CompressFormat.JPEG, 70, byteArrayOutputStream);
                        byteArray = byteArrayOutputStream.toByteArray();



                        cd = new ConnectionDetector(EditProfilePage.this);
                        isInternetPresent = cd.isConnectingToInternet();
                        if (isInternetPresent) {

                            //   ------------Code to update----------
                            bitMapThumbnail = finalPic;
                            Img_profileimg.setImageBitmap(finalPic);


                            uploadUserImage(ServiceConstant.EDIT_PROFILEIMAGE_URL);
                            System.out.println("edit-----" + ServiceConstant.EDIT_PROFILEIMAGE_URL);
                        } else {
                            Alert(getResources().getString(R.string.action_no_internet_title), getResources().getString(R.string.action_no_internet_message));
                        }

                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            else if ((requestCode == placeSearch_request_code && data != null)) {
                if (search_status == 0) {

                    SselectedLatitude = data.getStringExtra("Selected_Latitude");
                    SselectedLongitude = data.getStringExtra("Selected_Longitude");

                    //String SselectedLocation = data.getStringExtra("Selected_Location");

                    String ShouseNo = data.getStringExtra("HouseNo");
                    String Scity = data.getStringExtra("City");
                    String SpostalCode = data.getStringExtra("ZipCode");
                    String Slocation = data.getStringExtra("Location");
                    String aState = data.getStringExtra("State");

                    System.out.println("SselectedLatitude---------" + SselectedLatitude);
                    System.out.println("SselectedLongitude---------" + SselectedLongitude);

                    System.out.println("ShouseNo-----------" + ShouseNo);
                    System.out.println("Scity-----------" + Scity);
                    System.out.println("SpostalCode-----------" + SpostalCode);
                    System.out.println("Slocation-----------" + Slocation);

                    Et_address.setText(ShouseNo);
                    //Et_houseNo.setText(ShouseNo);
                    Et_city.setText(Scity);
                    Et_state.setText("");
                    Et_state.setText(aState);
                    Et_postal_code.setText(SpostalCode);

//                        Et_address.setText(add + add1);
//                        Et_country_code.setText(Str_countrycode);
//                        Et_country.setText(Str_country);
//                        Et_city.setText(Str_city);
//                        Et_state.setText(Str_state);
//                        Et_postal_code.setText(Str_postal_code);
                }
            } else if (requestCode == workLocattionRequestCode && data != null) {

                myWorkLocLatitude = data.getStringExtra("Selected_Latitude");
                myWorkLocLongitude = data.getStringExtra("Selected_Longitude");

                //String SselectedLocation = data.getStringExtra("Selected_Location");

                String ShouseNo = data.getStringExtra("HouseNo");
                String Scity = data.getStringExtra("City");
                String SpostalCode = data.getStringExtra("ZipCode");
                String Slocation = data.getStringExtra("Location");
                String aState = data.getStringExtra("State");

                System.out.println("SselectedLatitude---------" + SselectedLatitude);
                System.out.println("SselectedLongitude---------" + SselectedLongitude);
                Log.e("Address", data.getStringExtra("formattedaddress"));

                myWorkLocationTXT.setText(data.getStringExtra("formattedaddress"));

                System.out.println("ShouseNo-----------" + ShouseNo);
                System.out.println("Scity-----------" + Scity);
                System.out.println("SpostalCode-----------" + SpostalCode);
                System.out.println("Slocation-----------" + Slocation);
            }
        }

    }

    public static String encodeToBase64(Bitmap image, Bitmap.CompressFormat compressFormat, int quality) {
        ByteArrayOutputStream byteArrayOS = new ByteArrayOutputStream();
        image.compress(compressFormat, quality, byteArrayOS);
        return Base64.encodeToString(byteArrayOS.toByteArray(), Base64.DEFAULT);
    }


    private void uploadUserImage(String url) {

        dialog1 = new Dialog(EditProfilePage.this);
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
                String sStatus = "", sResponse = "", SUser_image = "", Smsg = "";


                try {
                    JSONObject jsonObject = new JSONObject(resultResponse);
                    sStatus = jsonObject.getString("status");
                    if (sStatus.equalsIgnoreCase("1")) {
                        JSONObject responseObject = jsonObject.getJSONObject("response");
                        SUser_image = responseObject.getString("image");
                        Smsg = responseObject.getString("msg");

                        Img_profileimg.setImageBitmap(bitMapThumbnail);
                        session.setUserImageUpdate(SUser_image);
/*

                        Picasso.with(EditProfilePage.this).load(sResponse).error(R.drawable.nouserimg)
                                .placeholder(R.drawable.nouserimg).memoryPolicy(MemoryPolicy.NO_CACHE).into(Img_profileimg);
*/

                        MyProfileFragment.profileimgNotifyChange();
                        NavigationDrawer.navigationNotifyChange();

                        Alert(getResources().getString(R.string.action_loadings_sucess), getResources().getString(R.string.edit_profile_success_label));
                    } else {
                        sResponse = jsonObject.getString("response");
                        Alert(getResources().getString(R.string.server_lable_header), sResponse);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                dialog1.dismiss();
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
                Map<String, String> params = new HashMap<>();
                params.put("provider_id", provider_id);
                System.out.println("provider_id---------------" + provider_id);
                return params;
            }

            @Override
            protected Map<String, DataPart> getByteData() {
                Map<String, DataPart> params = new HashMap<>();
                params.put("file", new DataPart("quickrabbitprovider.jpg", byteArray));

                System.out.println("file------" + byteArray);

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




    //-----------------------------editprofile upload----------------------------------
    private void EditMObilenoUploadPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("country_code", Et_country_code.getText().toString());
        jsonParams.put("mobile_number", Et_mobileno.getText().toString());

        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("editmobileno", response);

                String Str_Status = "", Str_Response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    if (Str_Status.equalsIgnoreCase("1")) {
                        Update_mobil_Response = jobject.getString("response");
                        Str_Opt_Status = jobject.getString("otp_status");
                        Str_OtpCode = jobject.getString("otp");
                        Str_Country_Code = jobject.getString("country_code");
                        Str_PhoneNo = jobject.getString("phone_number");

                    } else {
                        Str_Response = jobject.getString("response");
                    }
                    if (Str_Status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_mobil_Response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();

                                        EditmobilOtpPopup();
                                    }
                                }
                        );
                        mdialog.show();

                    } else {

                        Alert(getResources().getString(R.string.server_lable_header), Str_Response);

                    }
                    dialog.dismiss();
                } catch (Exception e) {
                    e.printStackTrace();
                    dialog.dismiss();
                }
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }


    private void EditmobilOtpPopup() {

        otp_dialog = new MaterialDialog(EditProfilePage.this);
        View view = LayoutInflater.from(EditProfilePage.this).inflate(R.layout.editprofile_otplayout, null);
        Et_Otp = (EditText) view.findViewById(R.id.editmobilno_otp_Et);
        Bt_otp_submit = (Button) view.findViewById(R.id.otp_submit);
        otp_cancel= (Button) view.findViewById(R.id.otp_cancel);
        otp_dialog.setView(view).show();

        if (Str_Opt_Status.equalsIgnoreCase("development")) {
            Et_Otp.setText(Str_OtpCode);

        } else {

        }
        otp_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                otp_dialog.dismiss();
            }
        });
        Bt_otp_submit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isInternetPresent) {

                    String check_otp_empty = Et_Otp.getText().toString();


                    if (check_otp_empty.isEmpty()) {
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert__otp_empty));
                    } else if(!check_otp_empty.equalsIgnoreCase(Str_OtpCode)){
                        Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_otp_wrong));
                    } else {
                        EditMObilenoWithOtpUploadPostRequest(EditProfilePage.this, ServiceConstant.EDIT_MOBILE_NUMBER_URL, "otp");
                        System.out.println("--------------otpmobile url-------------------" + ServiceConstant.JOBCOMPLETE_URL);
                    }
                }else {
                    Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                }
            }
        });


    }


    private void EditMObilenoWithOtpUploadPostRequest(Context mContext, String url, String key) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("country_code", Str_Country_Code);
        jsonParams.put("mobile_number", Str_PhoneNo);
        jsonParams.put("otp", Et_Otp.getText().toString());

        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("otp", response);

                String Str_Status = "", Str_Response = "";

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    if (Str_Status.equalsIgnoreCase("1")) {
                        Update_otp_response = jobject.getString("response");
                        Str_Country_Code = jobject.getString("country_code");
                        Str_PhoneNo = jobject.getString("phone_number");

                    } else {
                        Str_Response = jobject.getString("response");
                    }
                    if (Str_Status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_otp_response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        otp_dialog.dismiss();
                                        dialog.dismiss();
                                        mdialog.dismiss();

                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), Str_Response);
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                    dialog.dismiss();
                }
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }

    //-----------------------------edit email-----------------------
    private void EditEmailUploadPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("email", Et_email.getText().toString());

        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {

                Log.e("editemail", response);
                String Str_status = "", Str_response = "", Update_Response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        Update_Response = object.getString("response");

                    } else {
                        Str_response = object.getString("response");

                    }
                    if (Str_status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_Response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();
                                    }
                                }
                        );
                        mdialog.show();
                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), Str_response);
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

    //-----------------------------edit Bio-----------------------
    private void EditBioUploadPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("bio", Et_bio.getText().toString());

        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_updating));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("editbio", response);

                String Str_status = "", Str_response = "", Update_Response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        Update_Response = object.getString("response");

                    } else {
                        Str_response = object.getString("response");

                    }
                    if (Str_status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_Response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();

                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        dialog.dismiss();
                        Alert(getResources().getString(R.string.alert_label_title), Str_response);

                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }

    //-----------------------------Radius updating API-----------------------
    private void EditRadiusUploadPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("radius", myRadiusET.getText().toString());

        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_updating));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("editbio", response);

                String Str_status = "", Str_response = "", Update_Response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        Update_Response = object.getString("response");

                    } else {
                        Str_response = object.getString("response");

                    }
                    if (Str_status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_Response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();


                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), Str_response);
                    }
                    dialog.dismiss();

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }

    //-----------------------------Name updating API-----------------------
    private void EditNameUploadPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("user_name", myNameET.getText().toString());

        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_updating));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("editbio", response);

                String Str_status = "", Str_response = "", Update_Response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        Update_Response = object.getString("response");

                    } else {
                        Str_response = object.getString("response");

                    }
                    if (Str_status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_Response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();

                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), Str_response);
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }
        });
    }


    //-----------------------------edit Bio-----------------------
    private void EditWorkLocationUploadPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("lat", myWorkLocLatitude);
        jsonParams.put("long", myWorkLocLongitude);


        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("editAddresss", response);

                String Str_status = "", Str_response = "", Update_Response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        Update_Response = object.getString("response");

                    } else {
                        Str_response = object.getString("response");

                    }
                    if (Str_status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_Response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();

                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), Str_response);
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


    //-----------------------------edit Bio-----------------------
    private void EditAddressUploadPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("city", Et_city.getText().toString());
        jsonParams.put("state", Et_state.getText().toString());
        jsonParams.put("country", Et_country.getText().toString());
        jsonParams.put("postal_code", Et_postal_code.getText().toString());
        jsonParams.put("address", Et_address.getText().toString());


        dialog = new LoadingDialog(EditProfilePage.this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("editAddresss", response);

                String Str_status = "", Str_response = "", Update_Response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        Update_Response = object.getString("response");

                    } else {
                        Str_response = object.getString("response");

                    }
                    if (Str_status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_Response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();

                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        Alert(getResources().getString(R.string.alert_label_title), Str_response);
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


    @Override
    public void onResume() {
        super.onResume();
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

    private void CloseKeyboard(EditText edittext) {
        InputMethodManager in = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        in.hideSoftInputFromWindow(edittext.getApplicationWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
    }


    public static void EditAvailability(Context context, ArrayList<AvailabilityEditPojo> arrayList) {


        AvailabilityEdit(context, arrayList);
    }


    public static void AvailabilityEdit(final Context context, ArrayList<AvailabilityEditPojo> arrayList) {

        System.out.println("-----Edit_Profile Array Size---------" + arrayList.size());

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        for (int i = 0; i < arrayList.size(); i++) {
            jsonParams.put("working_days[" + i + "][day]", arrayList.get(i).getDays());
            jsonParams.put("working_days[" + i + "][hour][morning]", arrayList.get(i).getMorning());
            jsonParams.put("working_days[" + i + "][hour][afternoon]", arrayList.get(i).getAfternoon());
            jsonParams.put("working_days[" + i + "][hour][evening]", arrayList.get(i).getEvening());

            System.out.println("-----------------------------Availability Edit Call----------------------------");
            System.out.println("working_days[" + i + "][day]" + "," + arrayList.get(i).getDays());
            System.out.println("working_days[" + i + "][hour][morning]" + "," + arrayList.get(i).getMorning());
            System.out.println("working_days[" + i + "][hour][afternoon]" + "," + arrayList.get(i).getAfternoon());
            System.out.println("working_days[" + i + "][hour][evening]" + "," + arrayList.get(i).getEvening());
        }

        dialog = new LoadingDialog(context);
        dialog.setLoadingTitle(context.getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(context);
        mservicerequest.makeServiceRequest(ServiceConstant.Availability_Edit, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                Log.e("editAddresss", response);

                String Str_status = "", Str_response = "", Update_Response = "";

                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        Update_Response = object.getString("message");

                    } else {
                        Str_response = object.getString("message");
                    }
                    if (Str_status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(context);
                        mdialog.setDialogTitle(context.getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(Update_Response);
                        mdialog.setPositiveButton(context.getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();

                                    }
                                }
                        );
                        mdialog.show();

                    } else {

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


    private void setItemClickListener() {
        categoryListAdapter.setCategoryListItemClickListener(new CategoryListAdapter.CategoryListItemClickListener() {
            @Override
            public void onItemClick(View view, int position) {

                if (view.getId() == R.id.categoryItem_dlt_imageView) {

                    callDeleteAlert(categoryListAdapter.getItem(position).getChildID(), position);

                } else if (view.getId() == R.id.categoryItem_edit_imageView) {

                    makeGetCategoryDetailsRequest(EditProfilePage.this, categoryListAdapter.getItem(position).getChildID(), ServiceConstant.GET_CATEGORY_DETAILS);

                }

            }
        });
    }


    private void callDeleteAlert(final String childID, final int position) {
        ConnectionDetector cd = new ConnectionDetector(EditProfilePage.this);
        final boolean isInternetPresent = cd.isConnectingToInternet();
        final PkDialog mDialog = new PkDialog(EditProfilePage.this);
        mDialog.setDialogTitle(getResources().getString(R.string.confirm_delete));
        mDialog.setDialogMessage(getResources().getString(R.string.alert_categoryDlt));

        mDialog.setPositiveButton(getResources().getString(R.string.yes), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (isInternetPresent) {
                    makedeleteCategoryRequest(EditProfilePage.this, childID, position, ServiceConstant.DELETE_CATEGORY_DATA);

                } else {
                    Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
                }
                mDialog.dismiss();
            }
        });

        mDialog.setNegativeButton(getResources().getString(R.string.no), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });

        mDialog.show();
    }

    private void makedeleteCategoryRequest(Context context, String ID, final int Position, String url) {

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("tasker", provider_id);
        jsonParams.put("category", ID);
        dialog = new LoadingDialog(context);
        dialog.setLoadingTitle(context.getResources().getString(R.string.action_loading));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(context);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            String status = "";

            @Override
            public void onCompleteListener(String response) {
                Log.e("deletecategoryinfo", response);
                String status_response="";
                try {
                    JSONObject jobject = new JSONObject(response);
                    status = jobject.getString("status");
                    status_response=jobject.getString("response");
                    if (status.equalsIgnoreCase("1")) {
                        status_response=jobject.getString("response");
                        categorydatapojoArrayList.remove(Position);
                        categoryListAdapter.updateInfo(categorydatapojoArrayList);
                        System.out.println("-----size" + categorydatapojoArrayList.size());
                        ListInScroll.setListViewHeightBasedOnChildren(categoryList);
                        dialog.dismiss();

                    }
                    if (status.equalsIgnoreCase("1")) {
                        final PkDialog mdialog = new PkDialog(EditProfilePage.this);
                        mdialog.setDialogTitle(getResources().getString(R.string.action_loading_sucess));
                        mdialog.setDialogMessage(status_response);
                        mdialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
                                    @Override
                                    public void onClick(View v) {
                                        mdialog.dismiss();
                                        dialog.dismiss();

                                    }
                                }
                        );
                        mdialog.show();

                    } else {
                        dialog.dismiss();
                        Alert(getResources().getString(R.string.alert_label_title), status_response);

                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    dialog.dismiss();
                }

            }

            @Override
            public void onErrorListener() {
                dialog.dismiss();
            }


        });
    }

    private void makeGetCategoryDetailsRequest(Context context, String ID, String url) {

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("tasker", provider_id);
        jsonParams.put("category", ID);
        dialog = new LoadingDialog(context);
        dialog.setLoadingTitle(context.getResources().getString(R.string.action_loading));
        dialog.show();
        ServiceRequest mservicerequest = new ServiceRequest(context);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
                    Integer edit_status;
                    String ser_res;

                    @Override
                    public void onCompleteListener(String response) {
                        Log.e("editcategoryinfo", response);

                        try {
                            JSONObject jobject = new JSONObject(response);
                            edit_status = jobject.getInt("status");
                            ser_res = jobject.getString("response");
                            if (edit_status == 1) {

                                JSONObject object2 = new JSONObject(ser_res);
                                Intent editIntent = new Intent(EditProfilePage.this, EditCategoryActivity.class);
                                editIntent.putExtra("parent_id", object2.getString("parent_id"));
                                editIntent.putExtra("child_id", object2.getString("child_id"));
                                editIntent.putExtra("quick_pitch", object2.getString("quick_pitch"));
                                editIntent.putExtra("hour_rate", object2.getString("hour_rate"));
                                editIntent.putExtra("experience_name", object2.getString("experience_name"));
                                editIntent.putExtra("parent_name", object2.getString("parent_name"));
                                editIntent.putExtra("child_name", object2.getString("child_name"));
                                editIntent.putExtra("min_hourly_rate", object2.getString("min_hourly_rate"));
                                editIntent.putExtra("from", "edit");
                                dialog.dismiss();
                                startActivity(editIntent);
                            }
                        } catch (JSONException e) {
                            e.printStackTrace();
                       }

                    }

                    @Override
                    public void onErrorListener() {

                    }
               }

        );

    }

    public boolean onKeyDown(int keyCode, KeyEvent event) {

        switch (keyCode) {
            case KeyEvent.KEYCODE_BACK:
                Intent editpage = new Intent();
                editpage.setAction("com.package.load.editpage");
                sendBroadcast(editpage);
                finish();
                return true;
        }
        return false;
    }




}