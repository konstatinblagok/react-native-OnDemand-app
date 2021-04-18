package core.Xmpp;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.MyJobs_OnGoingDetailPage;
import com.a2zkaj.app.NavigationDrawer;
import com.a2zkaj.app.NewLeadsPage;
import com.a2zkaj.app.R;
import com.a2zkaj.app.ReceiveCashPage;
import com.a2zkaj.app.ReviwesPage;

import java.text.NumberFormat;
import java.util.Currency;
import java.util.HashMap;
import java.util.Locale;

import core.service.ServiceConstant;

/**
 * Created by user88 on 1/11/2016.
 */
public class Xmpp_PushNotificationPage extends Activity {
    private TextView Message_Tv, Textview_Ok, Textview_alert_header;
    private String message = "", action = "", Str_amount = "", currency_code = "", Str_JobId = "", Amount = "";
    private RelativeLayout Rl_layout_alert_ok;
    private ImageView Img_notification;
    private String Page_Status="";
    NavigationDrawer drawer;
    private String provider_id = "", provider_name = "";
    private SessionManager session;
    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals("com.package.finish_PUSHNOTIFIACTION")) {
                finish();
            }
        }
    }
    private RefreshReceiver refreshReceiver;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.pushnotification);
        initialize();

        System.out.println("pushnotification--------");

        Rl_layout_alert_ok.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                System.out.println("action-----------" + action);

                if (action.equalsIgnoreCase("job_request")) {
                    System.out.println("jobid-------" + Str_JobId);
                    Intent intent = new Intent(Xmpp_PushNotificationPage.this, MyJobs_OnGoingDetailPage.class);
                    intent.putExtra("JobId", Str_JobId);
                    startActivity(intent);
                    finish();
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);


                } else if (action.equalsIgnoreCase("job_cancelled")) {

                    Intent refreshBroadcastIntent = new Intent();
                    refreshBroadcastIntent.setAction("com.package.finish.jobdetailpage");
                    sendBroadcast(refreshBroadcastIntent);
                    finish();

                } else if (action.equalsIgnoreCase("receive_cash")) {
                    System.out.println("recwivecashcxmpp-------");

                    Intent intent = new Intent(Xmpp_PushNotificationPage.this, ReceiveCashPage.class);
                    intent.putExtra("Amount", Amount);
                    intent.putExtra("jobId", Str_JobId);
                    startActivity(intent);
                    finish();
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);

                } else if (action.equalsIgnoreCase("payment_paid")) {
                    Intent broadcastIntentnavigation = new Intent();
                    broadcastIntentnavigation.setAction("com.package.finish_LOADINGPAGE");
                    sendBroadcast(broadcastIntentnavigation);

                    Intent intent = new Intent(Xmpp_PushNotificationPage.this, ReviwesPage.class);
                    intent.putExtra("jobId", Str_JobId);
                    System.out.println("jobId-------" + Str_JobId);
                    startActivity(intent);
                    finish();
                    overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
                } else if (action.equalsIgnoreCase("rejecting_task")) {

                    Intent refreshBroadcastIntent = new Intent();
                    refreshBroadcastIntent.setAction("com.package.finish.jobdetailpage");
                    sendBroadcast(refreshBroadcastIntent);

                    finish();

                }
                else if (action.equalsIgnoreCase("admin_notification")) {

                    finish();

                }
                else if (action.equalsIgnoreCase("Left_job")) {

                    finish();
                }
                else if (action.equalsIgnoreCase("Accept_task")) {
                    Intent pending_task = new Intent(Xmpp_PushNotificationPage.this, NewLeadsPage.class);
                    startActivity(pending_task);
                    finish();
                }
                else if (action.equalsIgnoreCase("Admin Availability Change")) {

                    Intent s=new Intent();
                    s.setAction("com.availability.change");
                    s.putExtra("status",Str_JobId);
                    sendBroadcast(s);
                    if (Page_Status.equalsIgnoreCase("open")) {
                        finish();
                    } else {

                        Intent i = new Intent(getApplicationContext(), NavigationDrawer.class);
                        startActivity(i);
                        finish();

                    }


                } else if (action.equalsIgnoreCase("partially_paid")) {
                    finish();
                }
            }
        });
    }


    private void initialize() {
        session=new SessionManager(this);
        Intent i = getIntent();
        message = i.getStringExtra("Message");
        action = i.getStringExtra("Action");
        Str_JobId = i.getStringExtra("JobId");
        Str_amount = i.getStringExtra("amount");
        currency_code = i.getStringExtra("Currencycode");

        if(Str_JobId.equalsIgnoreCase("0")){
            session.Taskerstatus("0");
        }
        else{
            session.Taskerstatus("1");
        }

        HashMap<String, String> user = session.getUserDetails();

        Page_Status=user.get(SessionManager.NAVIGATION_OPEN);
        // -----code to finish using broadcast receiver-----
        refreshReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.package.finish_PUSHNOTIFIACTION");
        registerReceiver(refreshReceiver, intentFilter);


        Textview_Ok = (TextView) findViewById(R.id.pushnotification_alert_ok_textview);
        Message_Tv = (TextView) findViewById(R.id.pushnotification_alert_messge_textview);
        Textview_alert_header = (TextView) findViewById(R.id.pushnotification_alert_messge_label);
        Rl_layout_alert_ok = (RelativeLayout) findViewById(R.id.pushnotification_alert_ok);
        Img_notification = (ImageView) findViewById(R.id.notification_icon);


        Message_Tv.setText(message);

        if (action.equalsIgnoreCase("job_cancelled")) {
            Textview_alert_header.setText(getResources().getString(R.string.label_pushnotification_canceled));

        } else if (action.equalsIgnoreCase("receive_cash")) {
            Textview_alert_header.setText(getResources().getString(R.string.label_pushnotification_cashreceived));
            Img_notification.setImageResource(R.drawable.oksmily);

        } else if (action.equalsIgnoreCase("payment_paid")) {
            Textview_alert_header.setText(getResources().getString(R.string.label_pushnotification_ride_completed));
            Img_notification.setImageResource(R.drawable.oksmily);

        } else if (action.equalsIgnoreCase("job_request")) {
            Textview_alert_header.setText(getResources().getString(R.string.label_pushnotification_newjob));
        }
        else if (action.equalsIgnoreCase("admin_notification")) {
            Textview_alert_header.setText(getResources().getString(R.string.admin_notification));
        }
        else if(action.equalsIgnoreCase("Admin Availability Change")){
            Textview_alert_header.setText(getResources().getString(R.string.partially_change));
        }
        else if(action.equalsIgnoreCase(ServiceConstant.ACTION_TAG_PARTIALLY_PAID)){
            Textview_alert_header.setText(getResources().getString(R.string.partially_change));
        }
        else if(action.equalsIgnoreCase(ServiceConstant.ACTION_LEFT_JOB)){
            Textview_alert_header.setText(getResources().getString(R.string.admin_notification));
            Message_Tv.setText(message + " : "+Str_JobId);
        }
        else if(action.equalsIgnoreCase(ServiceConstant.ACTION_PENDING_TASK)){
            Textview_alert_header.setText(getResources().getString(R.string.admin_notification));
            Message_Tv.setText(message +" : "+Str_JobId);
        }

        if (currency_code != null) {
            Currency currencycode = Currency.getInstance(getLocale(currency_code));
            Amount = currencycode.getSymbol() + Str_amount;
        }
    }
    //method to convert currency code to currency symbol
    private static Locale getLocale(String strCode) {

        for (Locale locale : NumberFormat.getAvailableLocales()) {
            String code = NumberFormat.getCurrencyInstance(locale).getCurrency().getCurrencyCode();
            if (strCode != null && strCode.equals(code)) {
                return locale;
            }
        }
        return null;
    }
    @Override
    public void onDestroy() {
        // Unregister the logout receiver
        unregisterReceiver(refreshReceiver);
        super.onDestroy();
    }

}
