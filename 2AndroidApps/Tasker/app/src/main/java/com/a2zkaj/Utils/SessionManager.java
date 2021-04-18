package com.a2zkaj.Utils;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import com.a2zkaj.app.MainPage;

import java.util.HashMap;

/**
 * Created by user88 on 12/9/2015.
 */
public class SessionManager {


    // Shared Preferences
    SharedPreferences pref;

    // Editor for Shared preferences
    SharedPreferences.Editor editor;

    // Context
    Context _context;

    // Shared pref mode
    int PRIVATE_MODE = 0;

    // Sharedpref file name
    private static final String PREF_NAME = "PlumbalPartner";


    // All Shared Preferences Keys
    private static final String IS_LOGIN = "IsLoggedIn";

    // User name (make variable public to access from outside)

    // Email address (make variable public to access from outside)
    public static final String KEY_EMAIL = "email";

    public static final String KEY_PROVIDERID = "providerid";

    public static final String KEY_GCM_ID = "gcmId";

    public static final String KEY_PROVIDERNAME = "providerrname";

    public static final String KEY_USERIMAGE = "userimage";

    public static final String KEY = "key";

    public static final String KEY_SOCKEYID = "socky_id";

    public static final String KEY_STATUS = "status";

    public static final String KEY_Appinfo_email = "Appinfo_email";

    public static final String KEY_Chat_userid = "chatuserid";
    public static final String KEY_CURRENCY_CODE = "currencyCode";
    public static final String KEY_Task_id = "taskid";
    public static final String NAVIGATION_OPEN="open";

    public static final String KEY_LANG = "lang";

    // Constructor
    @SuppressLint("CommitPrefEdits")
    public SessionManager(Context context) {
        this._context = context;
        pref = _context.getSharedPreferences(PREF_NAME, PRIVATE_MODE);
        editor = pref.edit();
    }

    public void createLoginSession(String email, String providerid, String providername, String userimage) {
        // Storing login value as TRUE
        editor.putBoolean(IS_LOGIN, true);
        editor.putString(KEY_EMAIL, email);
        editor.putString(KEY_PROVIDERID, providerid);
        editor.putString(KEY_PROVIDERNAME, providername);
        editor.putString(KEY_USERIMAGE, userimage);
       // editor.putString(KEY_SOCKEYID, socky_id);
       // editor.putString(KEY, key);
      //  editor.putString(KEY_GCM_ID, gcmId);

        // commit changes
        editor.commit();
    }

    public void createWalletSession(String currencyCode) {
        editor.putString(KEY_CURRENCY_CODE, currencyCode);
        editor.commit();
    }

    public HashMap<String, String> getUserDetails() {
        HashMap<String, String> user = new HashMap<String, String>();
        // user name
        user.put(KEY_EMAIL, pref.getString(KEY_EMAIL, ""));
        user.put(KEY_PROVIDERID, pref.getString(KEY_PROVIDERID, ""));
        user.put(KEY_PROVIDERNAME, pref.getString(KEY_PROVIDERNAME, ""));
        user.put(KEY_USERIMAGE, pref.getString(KEY_USERIMAGE, ""));
        user.put(KEY_SOCKEYID, pref.getString(KEY_SOCKEYID, ""));
        user.put(KEY, pref.getString(KEY, ""));
        user.put(KEY_GCM_ID, pref.getString(KEY_GCM_ID, ""));
        user.put(KEY_STATUS, pref.getString(KEY_STATUS, ""));
        user.put(KEY_Appinfo_email, pref.getString(KEY_Appinfo_email, ""));
        user.put(KEY_Chat_userid, pref.getString(KEY_Chat_userid, ""));
        user.put(KEY_Task_id, pref.getString(KEY_Task_id, ""));
        user.put(NAVIGATION_OPEN, pref.getString(NAVIGATION_OPEN, ""));
        return user;
    }
    /**
     * Clear session details
     * */
    public void logoutUser() {
        // Clearing all data from Shared Preferences
        editor.clear();
        editor.commit();

        // After logout redirect user to Loing Activity
        Intent i = new Intent(_context, MainPage.class);

        // Closing all the Activities
        i.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        // Add new Flag to start new Activity
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);

        // Staring Login Activity
        _context.startActivity(i);

    }
    // Get Login State
    public boolean isLoggedIn() {
        return pref.getBoolean(IS_LOGIN, false);
    }


    //------UserImage update code-----
    public void setUserImageUpdate(String image) {
        editor.putString(KEY_USERIMAGE, image);
        editor.commit();
    }

public void Taskerstatus(String status){
    editor.putString(KEY_STATUS,status);
    editor.commit();


}

    public void Setemailappinfo(String email){
        editor.putString(KEY_Appinfo_email,email);
        editor.commit();


    }

    public void setchatuserid(String id){
        editor.putString(KEY_Chat_userid,id);
        editor.commit();


    }
    public HashMap<String, String> getWalletDetails() {
        HashMap<String, String> wallet = new HashMap<String, String>();
        wallet.put(KEY_CURRENCY_CODE, pref.getString(KEY_CURRENCY_CODE, ""));
        return wallet;
    }

    public void settaskid(String id){
        editor.putString(KEY_Task_id,id);
        editor.commit();

    }

    public void pageopen(String status){
       editor.putString(NAVIGATION_OPEN,status);
        editor.commit();
    }

    public void setLocaleLanguage(String language) {
        editor.putString(KEY_LANG, language);
        editor.commit();
    }

    public String getLocaleLanguage() {
        return pref.getString(KEY_LANG, "en");
    }



}
