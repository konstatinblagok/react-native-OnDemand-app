package com.a2zkaj.app;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.github.nkzawa.engineio.client.Socket;
import com.a2zkaj.Fragment.HomePageFragment;
import com.a2zkaj.Utils.AndroidServiceStartOnBoot;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.Utils.SocketCheckService;
import com.a2zkaj.adapter.NavigationMenuAdapter;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.ChatMessageService;
import core.socket.SocketHandler;

/**
 * Created by user88 on 12/11/2015.
 */
public class NavigationDrawer extends ActionBarActivityHockeyApp {
    ActionBarDrawerToggle actionBarDrawerToggle;
    static DrawerLayout drawerLayout;
    private static RelativeLayout mDrawer;
    private Context context;
    private ListView mDrawerList;
    private SessionManager session;
    private String provider_id = "", provider_name = "";
    private String Page_Open_Status = "";
    private Socket mSocket;
    private static NavigationMenuAdapter mMenuAdapter;
    private String[] title;
    private int[] icon;
    LoadingDialog mLoadingDialog;
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SocketHandler socketHandler;
    public static Activity navigation_Drawer;

    private class Receiver extends BroadcastReceiver {

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equalsIgnoreCase("com.availability.change")) {
                String status = intent.getExtras().getString("status");
                HomePageFragment.admin_avail_status = true;
                if (status.equalsIgnoreCase("0")) {
                    HomePageFragment.myStatusTGB.setChecked(false);
                } else {
                    HomePageFragment.myStatusTGB.setChecked(true);
                }

            }
        }
    }

    private Receiver refreshReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.navigation_drawer);
        socketHandler = SocketHandler.getInstance(this);
        context = getApplicationContext();
        session = new SessionManager(NavigationDrawer.this);
        navigation_Drawer = NavigationDrawer.this;

        drawerLayout = (DrawerLayout) findViewById(R.id.navigation_drawer);
        mDrawer = (RelativeLayout) findViewById(R.id.drawer);
        mDrawerList = (ListView) findViewById(R.id.drawer_listview);


        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        provider_name = user.get(SessionManager.KEY_PROVIDERNAME);
        Page_Open_Status = user.get(SessionManager.NAVIGATION_OPEN);

        refreshReceiver = new Receiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.availability.change");
        registerReceiver(refreshReceiver, intentFilter);

        if (savedInstanceState == null) {
            FragmentTransaction tx = getSupportFragmentManager().beginTransaction();
            tx.replace(R.id.content_frame, new HomePageFragment());
            tx.commit();
        }

        if (!ChatMessageService.isStarted()) {
            Intent intent = new Intent(NavigationDrawer.this, ChatMessageService.class);
            startService(intent);
        }

        actionBarDrawerToggle = new ActionBarDrawerToggle(this, drawerLayout, R.string.app_name, R.string.app_name);
        drawerLayout.setDrawerListener(actionBarDrawerToggle);
        actionBarDrawerToggle.syncState();


        title = new String[]{getResources().getString(R.string.drawer_list_profile_label), getResources().getString(R.string.drawer_list_home_label),
                getResources().getString(R.string.drawer_list_myjobs_label),
                getResources().getString(R.string.drawer_list_chat_label),
                getResources().getString(R.string.navigation_label_notification),
                getResources().getString(R.string.navigation_label_transactions),
                getResources().getString(R.string.drawer_list_banking_label),
                getResources().getString(R.string.navigation_label_review),
//                getResources().getString(R.string.action_settings_Caps),
                getResources().getString(R.string.drawer_list_changepassword_label),
                getResources().getString(R.string.aboutus),
                getResources().getString(R.string.drawer_list_signout_label),
        };

        icon = new int[]{R.drawable.nouserimg, R.drawable.home_icon,
                R.drawable.jobsicon, R.drawable.icon_menu_chat, R.drawable.icon_menu_notification,
                R.drawable.icon_menu_transaction, R.drawable.bankicon, R.drawable.icon_menu_review,
//                R.drawable.settings,
                R.drawable.changepassword, R.drawable.aboutus_icon,
                R.drawable.logouticon};

        mMenuAdapter = new NavigationMenuAdapter(context, title, icon);
        mDrawerList.setAdapter(mMenuAdapter);
        mMenuAdapter.notifyDataSetChanged();


        mDrawerList.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {

                cd = new ConnectionDetector(NavigationDrawer.this);
                isInternetPresent = cd.isConnectingToInternet();
                FragmentTransaction tx = getSupportFragmentManager().beginTransaction();

                switch (position) {

                    case 0:
                        Intent intent = new Intent(NavigationDrawer.this, ProfilePage.class);
                        startActivity(intent);
                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                        break;

                    case 1:
                        //  tx.replace(R.id.content_frame, new HomePage());
                        tx.replace(R.id.content_frame, new HomePageFragment());
                        tx.commit();
                        break;

                    case 2:
                        Intent intent_myjobs = new Intent(NavigationDrawer.this, MyJobs.class);
                        intent_myjobs.putExtra("status", "open");
                        startActivity(intent_myjobs);
                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                        break;

                    case 3:
                        Intent aMessageIntent = new Intent(NavigationDrawer.this, GetMessageChatActivity.class);
                        startActivity(aMessageIntent);
                        overridePendingTransition(R.anim.enter, R.anim.exit);
                        break;
                    case 4:
                        Intent aNotificationIntent = new Intent(NavigationDrawer.this, NotificationMenuActivity.class);
                        startActivity(aNotificationIntent);
                        overridePendingTransition(R.anim.enter, R.anim.exit);
                        break;

                    case 5:
                        Intent aTransactionIntent = new Intent(NavigationDrawer.this, TransactionMenuActivity.class);
                        startActivity(aTransactionIntent);
                        overridePendingTransition(R.anim.enter, R.anim.exit);
                        break;

                    case 6:
                        Intent intent_bank = new Intent(NavigationDrawer.this, BankDetails.class);
                        startActivity(intent_bank);
                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                        break;
                    case 7:
                        Intent aReviewIntent = new Intent(NavigationDrawer.this, ReviewMenuActivity.class);
                        startActivity(aReviewIntent);
                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                        break;
//                    case 8:
//                        Intent intent_sesttings = new Intent(NavigationDrawer.this, SettingsPage.class);
//                        startActivity(intent_sesttings);
//                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
//                        break;

                    case 8:
                        Intent intent_changepwd = new Intent(NavigationDrawer.this, ChangePassword.class);
                        startActivity(intent_changepwd);
                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                        break;

                    case 9:
                        Intent intent_about = new Intent(NavigationDrawer.this, AboutUs.class);
                        startActivity(intent_about);
                        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                        break;
                    case 10:
                        logout();

                }
                mDrawerList.setItemChecked(position, true);
                drawerLayout.closeDrawer(mDrawer);
            }
        });
    }


    private void logout() {

        cd = new ConnectionDetector(NavigationDrawer.this);
        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            final PkDialog mDialog = new PkDialog(NavigationDrawer.this);
            mDialog.setDialogTitle(getResources().getString(R.string.profile_lable_logout_title));
            mDialog.setDialogMessage(getResources().getString(R.string.profile_lable_logout_message));
            mDialog.setPositiveButton(getResources().getString(R.string.profile_lable_logout_yes), new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    postRequest_Logout(ServiceConstant.logout_url);
                    mDialog.dismiss();
                }
            });
            mDialog.setNegativeButton(getResources().getString(R.string.profile_lable_logout_no), new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    mDialog.dismiss();
                }
            });
            mDialog.show();

        } else {
            Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
        }

    }


    //--------------Alert Method------------------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(NavigationDrawer.this);
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


    public static void navigationNotifyChange() {

        mMenuAdapter.notifyDataSetChanged();
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        return super.onOptionsItemSelected(item);
    }


    public static void disableSwipeDrawer() {
        drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
    }

    public static void enableSwipeDrawer() {
        drawerLayout.setDrawerLockMode(DrawerLayout.LOCK_MODE_UNLOCKED);
    }


    public static void openDrawer() {
        drawerLayout.openDrawer(mDrawer);
    }


    @Override
    protected void onResume() {
        super.onResume();
        try {
            Intent i = new Intent(context, AndroidServiceStartOnBoot.class);
            startService(i);

            if (!ChatMessageService.isStarted()) {
                Intent intent = new Intent(NavigationDrawer.this, ChatMessageService.class);
                startService(intent);
            }
            Intent service = new Intent(NavigationDrawer.this, SocketCheckService.class);
            startService(service);

        } catch (Exception e) {
            e.printStackTrace();
        }

        session.pageopen("open");
    }

    @Override
    protected void onStop() {
        super.onStop();
        session.pageopen("close");
    }

    @Override
    protected void onPause() {
        super.onPause();
        // session.pageopen("close");

    }

    private void showDialog(String data) {
        mLoadingDialog = new LoadingDialog(NavigationDrawer.this);
        mLoadingDialog.setLoadingTitle(data);
        mLoadingDialog.show();
    }

    //-----------------------Logout Request-----------------
    private void postRequest_Logout(String Url) {
        showDialog(getResources().getString(R.string.action_logging_out));
        System.out.println("---------------LogOut Url-----------------" + Url);
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("device_type", "android");
        ServiceRequest mservicerequest = new ServiceRequest(context);
        mservicerequest.makeServiceRequest(Url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("---------------LogOut Response-----------------" + response);
                String sStatus = "", sResponse = "";
                try {

                    JSONObject object = new JSONObject(response);
                    sStatus = object.getString("status");
                    sResponse = object.getString("response");
                } catch (JSONException e) {
                    e.printStackTrace();
                }

                mLoadingDialog.dismiss();
                if (sStatus.equalsIgnoreCase("1")) {
                    postSetOnlineStatus(ServiceConstant.AVAILABILITY_URL, NavigationDrawer.this, 0);
                } else {

                }
            }

            @Override
            public void onErrorListener() {
                mLoadingDialog.dismiss();
            }
        });
    }


    //----------------------------------------Availability Off------------------------------------
    private void postSetOnlineStatus(String url, Context context, int state) {

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("tasker", provider_id);
        jsonParams.put("availability", "" + state);
        ServiceRequest mservicerequest = new ServiceRequest(context);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                String status = "", responseString = "";
                System.out.println("Online Status-----------------------" + response);
                try {
                    JSONObject jobject = new JSONObject(response);
                    status = jobject.getString("status");
                    if (status.equalsIgnoreCase("1")) {

                        JSONObject object = jobject.getJSONObject("response");
                        status = object.getString("tasker_status");
                        if (status.equalsIgnoreCase("0")) {
                            session.logoutUser();
//                            session.setLocaleLanguage(session.getLocaleLanguage());
                            finish();
                            SocketHandler.getInstance(NavigationDrawer.this).getSocketManager().disconnect();
                            Intent i = new Intent(NavigationDrawer.this, ChatMessageService.class);
                            stopService(i);
                        } else {
                            String message = object.getString("message");
                            Alert(getResources().getString(R.string.availability_title), getResources().getString(R.string.availability_message_on));
                        }

                    } else {

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


    public void CloseActivity() {
        finish();

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_BACK && event.getRepeatCount() == 0) {
            onBackPressed();
            Intent back_pressed_intent = new Intent();
            back_pressed_intent.setAction("com.app.device.back.button.pressed");
            sendBroadcast(back_pressed_intent);
            finish();
            return true;
        }
        return false;
    }
}
