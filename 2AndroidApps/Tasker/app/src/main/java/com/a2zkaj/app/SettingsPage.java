package com.a2zkaj.app;

import android.content.Intent;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v7.app.AppCompatActivity;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.RelativeLayout;

import com.afollestad.materialdialogs.DialogAction;
import com.android.volley.Request;
import com.jaredrummler.materialspinner.MaterialSpinner;
import com.a2zkaj.Utils.SessionManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Locale;

import core.Volley.ServiceRequest;

public class SettingsPage extends AppCompatActivity {

    MaterialSpinner spinner;
    private String Item1 = "";
    private String Item2 = "";
    SessionManager session;
    RelativeLayout back;
    String selected_lang;
    private String[] myLanguageSPNArrayItems;
    String User_id = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings_page);

        session = new SessionManager(SettingsPage.this);

        HashMap<String, String> user = session.getUserDetails();
        User_id = user.get(SessionManager.KEY_PROVIDERID);

        selected_lang = session.getLocaleLanguage();

        myLanguageSPNArrayItems = new String[]{
                getResources().getString(R.string.english_text),
                getResources().getString(R.string.other_text)};

        initialize();

        headerinitialize();

        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


        spinner.setOnItemSelectedListener(new MaterialSpinner.OnItemSelectedListener<String>() {

            @Override
            public void onItemSelected(MaterialSpinner view, int position, long id, String item) {
                showAlertDialog(item);
            }
        });

    }

    private void showAlertDialog(final String item) {
        try {
            new com.afollestad.materialdialogs.MaterialDialog.Builder(this)
                    .title(R.string.title)
                    .content(R.string.content)
                    .positiveText(R.string.btn_TXT_positive)
                    .titleColor(getResources().getColor(R.color.black_color))
                    .contentColor(getResources().getColor(R.color.black_color))
                    .negativeText(R.string.btn_TXT_negative)
                    .positiveColor(getResources().getColor(R.color.appmain_color))
                    .negativeColor(getResources().getColor(R.color.pink_background_color))
                    .onPositive(new com.afollestad.materialdialogs.MaterialDialog.SingleButtonCallback() {
                        @Override
                        public void onClick(@NonNull com.afollestad.materialdialogs.MaterialDialog dialog, @NonNull DialogAction which) {
                            try {
                                if (item.equalsIgnoreCase(getResources().getString(R.string.other_text))) {
                                    setLanguage("en1");
//                                    postRequestLanguage(ServiceConstant.Update_Language_Url, "en1");
                                } else if (item.equalsIgnoreCase(getResources().getString(R.string.english_text))) {
                                    setLanguage("en");
//                                    postRequestLanguage(ServiceConstant.Update_Language_Url, "en");
                                }
                                dialog.dismiss();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    })
                    .onNegative(new com.afollestad.materialdialogs.MaterialDialog.SingleButtonCallback() {
                        @Override
                        public void onClick(@NonNull com.afollestad.materialdialogs.MaterialDialog dialog, @NonNull DialogAction which) {
                            dialog.dismiss();
                        }
                    })
                    .show();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void headerinitialize() {
        back = (RelativeLayout) findViewById(R.id.layout_settings_back);
    }

    public void initialize() {
        session = new SessionManager(SettingsPage.this);
        spinner = (MaterialSpinner) findViewById(R.id.spinner);
        spinner.setItems(myLanguageSPNArrayItems);
        if (selected_lang.equalsIgnoreCase("en")) {
            spinner.setSelectedIndex(0);
        } else {
            spinner.setSelectedIndex(1);
        }
       /* HashMap<String, String> user = session.getUserDetails();
        Item1=user.get(SessionManager.KEY_LANGUAGE1);
        Item2=user.get(SessionManager.KEY_LANGUAGE2);
        if(Item1.equalsIgnoreCase("")||Item2.equalsIgnoreCase("")){
            spinner.setItems("English", "Portuguese");
        }else{
            spinner.setItems(Item1, Item2);
        }*/

    }


    private void postRequestLanguage(final String url, final String language) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("userid", User_id);
        jsonParams.put("langcode", language);

        ServiceRequest mservicerequest = new ServiceRequest(SettingsPage.this);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                String Str_status = "";

                try {
                    JSONObject object = new JSONObject(response);

                } catch (JSONException e) {
                    e.printStackTrace();
                }

            }

            @Override
            public void onErrorListener() {

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
        NavigationDrawer.navigation_Drawer.finish();
        Intent i = new Intent(getApplicationContext(), NavigationDrawer.class);
        startActivity(i);
        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
        finish();
    }

}
