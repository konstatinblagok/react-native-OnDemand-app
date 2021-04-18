package com.a2zkaj.app;

import android.content.Context;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Html;
import android.util.Log;
import android.widget.ListView;
import android.widget.RatingBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.a2zkaj.Pojo.Availabilitypojo;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.adapter.Availabilityadapter;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Volley.ServiceRequest;
import core.Widgets.CircularImageView;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

public class ListActivity extends AppCompatActivity {
//ListView list;
    Availabilityadapter adapter;
    private Boolean isInternetPresent = false;
    private boolean show_progress_status = false;
    private ConnectionDetector cd;
    private SessionManager session;

    private static CircularImageView profile_img;
    private TextView Tv_profile_name,Tv_profile_email,Tv_profile_desigaination,Tv_profile_mobile_no,Tv_profile_bio,Tv_profile_address,Tv_profile_category;
    private RatingBar profile_rating;
    private RelativeLayout Rl_layout_edit_profile,Rl_layout_main,Rl_layout_profile_nointernet,Rl_layout_profile_bio,Rl_layout_profile_address,Rl_layout_category;

    private static Context context;

    private String provider_id = "";
    private static String profile_pic="";
    ListView list;
    private LoadingDialog dialog;
    Availabilityadapter availadapter;
    private String Str_provider_image="";
    private ArrayList<Availabilitypojo> availlist;
    private SocketHandler socketHandler;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        list=(ListView)findViewById(R.id.list);
        cd = new ConnectionDetector(this);
        session = new SessionManager(this);
       // context =  getActivity();
        socketHandler = SocketHandler.getInstance(this);
        availlist=new ArrayList<Availabilitypojo>();
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        myprofilePostRequest(this, ServiceConstant.PROFILEINFO_URL);
    }



    private void myprofilePostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);

        System.out.println("provider_id----------------"+provider_id);

        dialog = new LoadingDialog(this);
        dialog.setLoadingTitle(getResources().getString(R.string.action_gettinginfo));
        dialog.show();


        ServiceRequest mservicerequest = new ServiceRequest(mContext);

        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("profile",response);

                String Str_Status="",Str_response="",Str_name="",Str_designation="",Str_rating="",Str_email="",Str_mobileno="",Str_bio="",
                        Str_addrress="",Str_category="";
                String availdays="";
                String morning="",afternoon="",evening="";

                try{
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    if (Str_Status.equalsIgnoreCase("1")){



                        JSONObject object = jobject.getJSONObject("response");
                        Str_name = object.getString("provider_name");
                        Str_designation = object.getString("designation");
                        Str_rating = object.getString("avg_review");
                        Str_email = object.getString("email");
                        Str_mobileno = object.getString("mobile_number");
                        Str_bio = object.getString("bio");
                        Str_category = object.getString("category").replace("\\n","<br/>");
                        Str_provider_image =  object.getString("image");
                        Str_addrress = object.getString("address_str");
                        JSONArray array1=object.getJSONArray("availability_days");

                        for(int i=0;i<array1.length();i++){

                            JSONObject ob= (JSONObject) array1.get(i);
                            Availabilitypojo pojo=new Availabilitypojo();
                            pojo.setDays(ob.getString("day"));

                            availdays=ob.getString("day");
                            JSONObject hourob=ob.getJSONObject("hour");
                            pojo.setMorning(hourob.getString("morning"));
                            pojo.setAfternoon(hourob.getString("afternoon"));
                            pojo.setEvening(hourob.getString("evening"));
                            morning=hourob.getString("morning");
                            afternoon=hourob.getString("afternoon");
                            evening=hourob.getString("evening");
                            availlist.add(pojo);
                        }

                        availadapter=new Availabilityadapter(getApplicationContext(),availlist);
                        list.setAdapter(availadapter);


                        //JSONObject object_address= object.getJSONObject("address");
                        // Str_addrress = object_address.getString("address");

                    }else{
                        Str_response= jobject.getString("response");
                    }
                    if (Str_Status.equalsIgnoreCase("1")){


                        System.out.println("---------------Category detail text-------------------"+ Html.fromHtml(Str_category));




//                        Tv_profile_name.setText(Str_name);
//                        // Tv_profile_desigaination.setText(Str_designation);
//                        profile_rating.setRating(Float.parseFloat(Str_rating));
//                        Tv_profile_mobile_no.setText(Str_mobileno);
//                        Tv_profile_category.setText(Html.fromHtml(Str_category+"<br/>"));
//                        Tv_profile_email.setText(Str_email);
//                        Tv_profile_address.setText(Str_addrress);
//
//                        session.setUserImageUpdate(Str_provider_image);


                        System.out.println("");

                        if (Str_bio.length()>0){
//                            Rl_layout_profile_bio.setVisibility(View.VISIBLE);
//                            Tv_profile_bio.setText(Str_bio);
                        }else{
                          //  Rl_layout_profile_bio.setVisibility(View.GONE);
                        }

                    }else{
                       // Alert(getResources().getString(R.string.server_lable_header), Str_response);
                    }

                }catch (Exception e){
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
}
