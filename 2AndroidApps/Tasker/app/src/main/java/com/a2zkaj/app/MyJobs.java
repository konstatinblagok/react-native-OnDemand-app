package com.a2zkaj.app;

import android.app.Activity;
import android.app.Dialog;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.Color;
import android.net.ParseException;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.prolificinteractive.materialcalendarview.MaterialCalendarView;
import com.a2zkaj.Fragment.MyJob_Cancelled_Fragment;
import com.a2zkaj.Fragment.MyJob_Converted_Fragment;
import com.a2zkaj.Fragment.MyJob_OnGoing_Fragment;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;
import com.roomorama.caldroid.CaldroidFragment;
import com.roomorama.caldroid.CaldroidListener;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Dialog.PkLoadingDialog;
import core.Volley.ServiceRequest;
import core.socket.ChatMessageService;
import core.socket.SocketHandler;

/**
 * Created by user88 on 12/11/2015.
 */
public class MyJobs extends ActionBarActivityHockeyApp {

    private TabLayout tabLayout;
    private ViewPager viewPager;
    private RelativeLayout layout_myjob_back;

    private Dialog sort_dialog;
    private boolean isReasonAvailable = false;
    private ImageView Img_filter;
    private Context context;

    private RelativeLayout sorting_cancel, sorting_apply, sortingDate, sortingname, Ascending_orderby, Descending_Orderby;
    private ImageView sorting_checkename, sorting_checkeddate, sorting_checkedthree, sorting_ascendingimg, sorting_descinngimg;
    private String Sselected_sorting = "";
    private String Sselected_ordrby = "";

    private RelativeLayout today_booking, recent_booking, upcoming_booking;
    private ImageView today_booking_image, recent_booking_image, upcoming_booking_image;

    private String Filter_booking_type = "0";
    private String Filter_type = "no";
    private String Filter_completed = "0";
    private String Filter_cancelled = "0";

    private ServiceRequest mRequest;
    private SessionManager session;

    private RelativeLayout Rl_layoyt_datefrom, Rl_layout_to;
    private TextView Tv_fromdaate, Tv_todate;

    private Dialog moreAddressDialog;
    private View moreAddressView;
    private String SelectDate = "";
    private MaterialCalendarView mcalendar;

    private String seleceteddate = "1";


    private CaldroidFragment dialogCaldroidFragment;
    final SimpleDateFormat formatter = new SimpleDateFormat("yyyy/MM/dd");


    private Context mContext;

    private PkLoadingDialog mLoadingDialog;

    private String provider_id = "";

    private String Stype = "2";
    private LoadingDialog dialog;
    private RelativeLayout Rl_layout_filter;
    private SocketHandler socketHandler;
    private String page_selected = "1";
    private String status_page = "";
    public static Activity Myjobs_Activity;

    boolean select_filter = false;

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {

            if (intent.getAction().equalsIgnoreCase("com.avail.finish")) {
                finish();
            }

        }
    }

    private RefreshReceiver finishReceiver;

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.myjobs);
        Myjobs_Activity = MyJobs.this;
        context = MyJobs.this;
        if (MyJobs_OnGoingDetailPage.job_page_activity != null) {
            MyJobs_OnGoingDetailPage.job_page_activity.finish();
        }
        Intent i = getIntent();
        status_page = i.getExtras().getString("status");
        System.out.println("Status_page : " + status_page);
        socketHandler = SocketHandler.getInstance(this);
        viewPager = (ViewPager) findViewById(R.id.viewpager);
        layout_myjob_back = (RelativeLayout) findViewById(R.id.layout_back_myjob);
        setupViewPager(viewPager);
        Rl_layout_filter = (RelativeLayout) findViewById(R.id.filter_layout);
        session = new SessionManager(MyJobs.this);

        tabLayout = (TabLayout) findViewById(R.id.tabs);
        tabLayout.setupWithViewPager(viewPager);


        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.avail.finish");
        registerReceiver(finishReceiver, intentFilter);

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);


        layout_myjob_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });


        Rl_layout_filter.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                chooseSortingImage(savedInstanceState);

            }
        });


        viewPager.setOnPageChangeListener(new ViewPager.OnPageChangeListener() {
            public void onPageScrollStateChanged(int state) {
            }

            public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            }

            public void onPageSelected(int position) {
                // Check if this is the page you want.

                System.out.println("----------view pager position---------------" + position);

                if (position == 0) {
                    Stype = "2";
                    page_selected = "1";
                } else if (position == 1) {
                    Stype = "4";
                    page_selected = "2";
                } else if (position == 2) {
                    Stype = "5";
                    page_selected = "3";
                }
            }
        });
    }

    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());
        adapter.addFragment(new MyJob_OnGoing_Fragment(), getResources().getString(R.string.my_jobs_Open));
        adapter.addFragment(new MyJob_Converted_Fragment(), getResources().getString(R.string.my_jobs_Completed));
        adapter.addFragment(new MyJob_Cancelled_Fragment(), getResources().getString(R.string.my_jobs_Cancelled));
        viewPager.setAdapter(adapter);
        if (status_page.equalsIgnoreCase("cancelled")) {
            viewPager.setCurrentItem(3);
        }

    }

    class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFragment(Fragment fragment, String title) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mFragmentTitleList.get(position);
        }
    }

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(MyJobs.this);
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


    private void chooseSortingImage(final Bundle savedInstanceState) {
        sort_dialog = new Dialog(MyJobs.this);
        sort_dialog.getWindow();
        sort_dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        sort_dialog.setContentView(R.layout.sorting_layout);
        sort_dialog.setCanceledOnTouchOutside(true);
        sort_dialog.getWindow().getAttributes().windowAnimations = R.style.Animations_photo_Picker;
        sort_dialog.show();
        sort_dialog.getWindow().setGravity(Gravity.CENTER);
        final TextView name_text = (TextView) sort_dialog.findViewById(R.id.name_text);
        final TextView date_text = (TextView) sort_dialog.findViewById(R.id.date_text);
        TextView today_booking_text = (TextView) sort_dialog.findViewById(R.id.today_booking_text);
        TextView upcoming_booking_text = (TextView) sort_dialog.findViewById(R.id.upcoming_booking_text);
        TextView recent_booking_text = (TextView) sort_dialog.findViewById(R.id.recent_booking_text);
        sorting_cancel = (RelativeLayout) sort_dialog.findViewById(R.id.cancel_sorting_clearlayout);
        sorting_apply = (RelativeLayout) sort_dialog.findViewById(R.id.sorting_apply_layout);
        sortingDate = (RelativeLayout) sort_dialog.findViewById(R.id.subcategories_sorting_date_layout);
        Ascending_orderby = (RelativeLayout) sort_dialog.findViewById(R.id.subcategories_sorting_ascending_layout);
        Descending_Orderby = (RelativeLayout) sort_dialog.findViewById(R.id.subcategories_sorting_descending_layout);
        sortingname = (RelativeLayout) sort_dialog.findViewById(R.id.subcategories_sortingname_layout);
        today_booking = (RelativeLayout) sort_dialog.findViewById(R.id.today_booking);
        recent_booking = (RelativeLayout) sort_dialog.findViewById(R.id.recent_booking);
        upcoming_booking = (RelativeLayout) sort_dialog.findViewById(R.id.upcoming_booking);

        Tv_fromdaate = (TextView) sort_dialog.findViewById(R.id.from_date_select_textView_myjobs);
        Tv_todate = (TextView) sort_dialog.findViewById(R.id.todate_select_textViewmyjobs);
        Rl_layoyt_datefrom = (RelativeLayout) sort_dialog.findViewById(R.id.myjooobsfrom_page_date_select_layout);
        Rl_layout_to = (RelativeLayout) sort_dialog.findViewById(R.id.myjobstodate_select_layout);


        sorting_checkeddate = (ImageView) sort_dialog.findViewById(R.id.sorting_checkedate);
        // sorting_checkedthree=(ImageView)sort_dialog.findViewById(R.id.checkedthree);
        sorting_checkename = (ImageView) sort_dialog.findViewById(R.id.subcategories_sorting_checkename);
        sorting_ascendingimg = (ImageView) sort_dialog.findViewById(R.id.subcategories_ascendingsorting_ascending);
        sorting_descinngimg = (ImageView) sort_dialog.findViewById(R.id.checkeddescending);
        today_booking_image = (ImageView) sort_dialog.findViewById(R.id.today_booking_image);
        recent_booking_image = (ImageView) sort_dialog.findViewById(R.id.recent_booking_image);
        upcoming_booking_image = (ImageView) sort_dialog.findViewById(R.id.upcoming_booking_image);

        Filter_type = "No";

        if (page_selected.equalsIgnoreCase("2") || page_selected.equalsIgnoreCase("3")) {
            today_booking.setEnabled(false);
            recent_booking.setEnabled(false);
            upcoming_booking.setEnabled(false);
            today_booking_text.setTextColor(Color.parseColor("#DCDCDC"));
            recent_booking_text.setTextColor(Color.parseColor("#DCDCDC"));
            upcoming_booking_text.setTextColor(Color.parseColor("#DCDCDC"));

        }

        sorting_cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sort_dialog.dismiss();
            }
        });


        Rl_layoyt_datefrom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

//                DisplayMetrics metrics = getResources().getDisplayMetrics();
//                int screenWidth = (int) (metrics.widthPixels * 0.80);//fill only 80% of the screen
//                moreAddressView = View.inflate(MyJobs.this, R.layout.metirial_custom_calender_layout_new, null);
//                moreAddressDialog = new Dialog(MyJobs.this);
//                moreAddressDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
//                moreAddressDialog.setContentView(moreAddressView);
//                moreAddressDialog.setCanceledOnTouchOutside(true);
//                moreAddressDialog.getWindow().setLayout(screenWidth, LinearLayout.LayoutParams.WRAP_CONTENT);
//                moreAddressDialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
//                moreAddressDialog.show();
//
//                mcalendar = (MaterialCalendarView) moreAddressView.findViewById(R.id.appointment_page_calendarview);
//
//                mcalendar.setWeekDayFormatter(new WeekDayFormatter() {
//                    @Override
//                    public CharSequence format(int dayOfWeek) {
//
//                        session = new SessionManager(MyJobs.this);
//                        Locale locale = new Locale(session.getLocaleLanguage());
//                        DateFormat dateFormat = new SimpleDateFormat("EEE", locale);
//
//                        Calendar cal = Calendar.getInstance();
//                        cal.set(Calendar.DAY_OF_WEEK, dayOfWeek);
//
//                        Date d = cal.getTime();
//                        return dateFormat.format(d);
//
//
//                    }
//                });
//                mcalendar.setTitleFormatter(new TitleFormatter() {
//                    @Override
//                    public CharSequence format(CalendarDay day) {
//
//                        session = new SessionManager(MyJobs.this);
//                        Locale locale = new Locale(session.getLocaleLanguage());
//                        DateFormat dateFormat = new SimpleDateFormat("LLLL yyyy", locale);
//
//                        return dateFormat.format(day.getDate());
//                    }
//                });
//
//                mcalendar.setOnDateChangedListener(new OnDateSelectedListener() {
//                    @Override
//                    public void onDateSelected(@NonNull MaterialCalendarView widget, @NonNull CalendarDay date, boolean selected) {
//
//
//                        SelectDate = String.valueOf(formatter.format(date.getDate()));
//                        String[] splite = SelectDate.split("/");
//                        String day = splite[2];
//                        String month = splite[1];
//                        String year = splite[0];
//
//                        System.out.println("Date : " + SelectDate);
//                        System.out.println("Date :=========> " + day + "/" + month + "/" + year);
//                        Tv_fromdaate.setText(day + "/" + month + "/" + year);
//                        moreAddressDialog.dismiss();
//                    }
//                });
//                mcalendar.setDateSelected(new Date(), true);
//                mcalendar.state().edit()
//                        .setMinimumDate(new Date())
//                        .setFirstDayOfWeek(Calendar.SUNDAY)
//                        .commit();

                seleceteddate = "1";
                datePicker(savedInstanceState);
            }
        });


        Rl_layout_to.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

//                DisplayMetrics metrics = getResources().getDisplayMetrics();
//                int screenWidth = (int) (metrics.widthPixels * 0.80);//fill only 80% of the screen
//                moreAddressView = View.inflate(MyJobs.this, R.layout.metirial_custom_calender_layout_new, null);
//                moreAddressDialog = new Dialog(MyJobs.this);
//                moreAddressDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
//                moreAddressDialog.setContentView(moreAddressView);
//                moreAddressDialog.setCanceledOnTouchOutside(true);
//                moreAddressDialog.getWindow().setLayout(screenWidth, LinearLayout.LayoutParams.WRAP_CONTENT);
//                moreAddressDialog.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
//                moreAddressDialog.show();
//
//                mcalendar = (MaterialCalendarView) moreAddressView.findViewById(R.id.appointment_page_calendarview);
//
//                mcalendar.setWeekDayFormatter(new WeekDayFormatter() {
//                    @Override
//                    public CharSequence format(int dayOfWeek) {
//
//                        session = new SessionManager(MyJobs.this);
//                        Locale locale = new Locale(session.getLocaleLanguage());
//                        DateFormat dateFormat = new SimpleDateFormat("EEE", locale);
//
//                        Calendar cal = Calendar.getInstance();
//                        cal.set(Calendar.DAY_OF_WEEK, dayOfWeek);
//
//                        Date d = cal.getTime();
//                        return dateFormat.format(d);
//                    }
//                });
//                mcalendar.setTitleFormatter(new TitleFormatter() {
//                    @Override
//                    public CharSequence format(CalendarDay day) {
//
//                        session = new SessionManager(MyJobs.this);
//                        Locale locale = new Locale(session.getLocaleLanguage());
//                        DateFormat dateFormat = new SimpleDateFormat("LLLL yyyy", locale);
//
//                        return dateFormat.format(day.getDate());
//                    }
//                });
//
//                mcalendar.setOnDateChangedListener(new OnDateSelectedListener() {
//                    @Override
//                    public void onDateSelected(@NonNull MaterialCalendarView widget, @NonNull CalendarDay date, boolean selected) {
//
//
//                        SelectDate = String.valueOf(formatter.format(date.getDate()));
//                        String[] splite = SelectDate.split("/");
//                        String day = splite[2];
//                        String month = splite[1];
//                        String year = splite[0];
//
//                        System.out.println("Date : " + SelectDate);
//                        System.out.println("Date :=========> " + day + "/" + month + "/" + year);
//                        Tv_todate.setText(day + "/" + month + "/" + year);
//                        moreAddressDialog.dismiss();
//                    }
//                });
//                mcalendar.setDateSelected(new Date(), true);
//                mcalendar.state().edit()
//                        .setMinimumDate(new Date())
//                        .setFirstDayOfWeek(Calendar.SUNDAY)
//                        .commit();

                seleceteddate = "2";
                datePicker(savedInstanceState);
            }
        });


        sortingname.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sorting_checkename.setVisibility(View.VISIBLE);
                sorting_checkeddate.setVisibility(View.GONE);

                Sselected_sorting = "name";
            }
        });


        sortingDate.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                sorting_checkename.setVisibility(View.GONE);
                sorting_checkeddate.setVisibility(View.VISIBLE);

                Sselected_sorting = "date";
            }
        });


        Ascending_orderby.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                sorting_descinngimg.setVisibility(View.GONE);
                sorting_ascendingimg.setVisibility(View.VISIBLE);

                Sselected_ordrby = "-1";
            }
        });


        Descending_Orderby.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                sorting_descinngimg.setVisibility(View.VISIBLE);
                sorting_ascendingimg.setVisibility(View.GONE);

                Sselected_ordrby = "1";
            }
        });
        today_booking.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                today_booking_image.setVisibility(View.VISIBLE);
                recent_booking_image.setVisibility(View.GONE);
                upcoming_booking_image.setVisibility(View.GONE);
                Filter_booking_type = "1";
                Filter_type = "today";
                sortingname.setEnabled(false);
                sortingDate.setEnabled(false);
                Rl_layoyt_datefrom.setEnabled(false);
                Rl_layout_to.setEnabled(false);
                sorting_checkename.setVisibility(View.GONE);
                sorting_checkeddate.setVisibility(View.GONE);
                name_text.setTextColor(Color.parseColor("#DCDCDC"));
                date_text.setTextColor(Color.parseColor("#DCDCDC"));
                Tv_fromdaate.setTextColor(Color.parseColor("#DCDCDC"));
                Tv_todate.setTextColor(Color.parseColor("#DCDCDC"));
                select_filter = true;
            }
        });
        recent_booking.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                recent_booking_image.setVisibility(View.VISIBLE);
                today_booking_image.setVisibility(View.GONE);
                upcoming_booking_image.setVisibility(View.GONE);
                Filter_booking_type = "1";
                Filter_type = "recent";
                sortingname.setEnabled(false);
                sortingDate.setEnabled(false);
                Rl_layoyt_datefrom.setEnabled(false);
                Rl_layout_to.setEnabled(false);
                sorting_checkename.setVisibility(View.GONE);
                sorting_checkeddate.setVisibility(View.GONE);
                name_text.setTextColor(Color.parseColor("#DCDCDC"));
                date_text.setTextColor(Color.parseColor("#DCDCDC"));
                Tv_fromdaate.setTextColor(Color.parseColor("#DCDCDC"));
                Tv_todate.setTextColor(Color.parseColor("#DCDCDC"));
                select_filter = true;
            }
        });
        upcoming_booking.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                upcoming_booking_image.setVisibility(View.VISIBLE);
                today_booking_image.setVisibility(View.GONE);
                recent_booking_image.setVisibility(View.GONE);
                Filter_booking_type = "1";
                Filter_type = "upcoming";
                sortingname.setEnabled(false);
                sortingDate.setEnabled(false);
                Rl_layoyt_datefrom.setEnabled(false);
                Rl_layout_to.setEnabled(false);
                sorting_checkename.setVisibility(View.GONE);
                sorting_checkeddate.setVisibility(View.GONE);
                name_text.setTextColor(Color.parseColor("#DCDCDC"));
                date_text.setTextColor(Color.parseColor("#DCDCDC"));
                Tv_fromdaate.setTextColor(Color.parseColor("#DCDCDC"));
                Tv_todate.setTextColor(Color.parseColor("#DCDCDC"));
                select_filter = true;
            }
        });


        sorting_apply.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!select_filter) {
                    if (Tv_fromdaate.getText().toString().equalsIgnoreCase("From") || Tv_todate.getText().toString().equalsIgnoreCase("To")) {
                        Alert(getResources().getString(R.string.label_pushnotification_canceled), getResources().getString(R.string.myjobs_enter_the_from_and_to_date));
                    } else {
                        sortedMethode();
                    }
                } else {
                    sortedMethode();
                    select_filter = false;
                }
            }
        });
    }

    private void sortedMethode() {
        sort_dialog.dismiss();
        //postJobRequestSorting(ServiceConstant.myjobs_sortingurl,"2");
        System.out.println("Stype---------------" + Stype);
        if (Stype == "2") {

            Intent myjobtype_intent = new Intent();
            myjobtype_intent.setAction("com.app.MyJob_OnGoing_Fragment");
            myjobtype_intent.putExtra("Type", Stype);
            myjobtype_intent.putExtra("SortBy", Sselected_sorting);
            myjobtype_intent.putExtra("OrderBy", Sselected_ordrby);
            myjobtype_intent.putExtra("from", Tv_fromdaate.getText().toString());
            myjobtype_intent.putExtra("to", Tv_todate.getText().toString());
            myjobtype_intent.putExtra("filter_type", Filter_type);
            context.sendBroadcast(myjobtype_intent);
            // postJobRequestSorting(ServiceConstant.myjobs_sortingurl,Stype);

        } else if (Stype == "4") {

            System.out.println("Stype1---------------" + "Ongoing");
            Intent myjobtypecomplete_intent = new Intent();
            myjobtypecomplete_intent.setAction("com.app.MyJob_Completed_Fragment");
            myjobtypecomplete_intent.putExtra("Type", Stype);
            myjobtypecomplete_intent.putExtra("SortBy", Sselected_sorting);
            myjobtypecomplete_intent.putExtra("OrderBy", Sselected_ordrby);
            myjobtypecomplete_intent.putExtra("from", Tv_fromdaate.getText().toString());
            myjobtypecomplete_intent.putExtra("to", Tv_todate.getText().toString());
            context.sendBroadcast(myjobtypecomplete_intent);

        } else if (Stype == "5") {
            System.out.println("Stype3---------------" + "cancel");
            Intent myjobtypecancelled_intent = new Intent();
            myjobtypecancelled_intent.setAction("com.app.MyJob_Cancelled_Fragment");
            myjobtypecancelled_intent.putExtra("Type", Stype);
            myjobtypecancelled_intent.putExtra("SortBy", Sselected_sorting);
            myjobtypecancelled_intent.putExtra("OrderBy", Sselected_ordrby);
            myjobtypecancelled_intent.putExtra("from", Tv_fromdaate.getText().toString());
            myjobtypecancelled_intent.putExtra("to", Tv_todate.getText().toString());
            context.sendBroadcast(myjobtypecancelled_intent);

        }
    }

    private void loadingDialog() {

        dialog = new LoadingDialog(MyJobs.this);
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

    }

    private void dismissDialog() {
        dialog.dismiss();
    }

    //-------------My Jobs Post Request---------------
    private void postJobRequestSorting(String url, String sType) {

        loadingDialog();

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        jsonParams.put("type", sType);
        jsonParams.put("page", "0");
        jsonParams.put("perPage", "20");
        jsonParams.put("orderby", Sselected_sorting);
        jsonParams.put("sortby", Sselected_ordrby);
        jsonParams.put("from", Tv_fromdaate.getText().toString());
        jsonParams.put("to", Tv_todate.getText().toString());


        System.out.println("---------orderby------------" + Sselected_ordrby);
        System.out.println("---------sortby------------" + Sselected_sorting);

        System.out.println("---------My Jobs user_id------------" + provider_id);
        System.out.println("---------My Jobs type------------" + sType);
        System.out.println("---------My Jobs Page page------------" + "1");
        System.out.println("---------My Jobs url------------" + url);

        mRequest = new ServiceRequest(MyJobs.this);
        mRequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {

                System.out.println("--------- sortingname response------------" + response);

               /* String Str_status = "";
                try {
                    JSONObject object = new JSONObject(response);
                    Str_status = object.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject response_Object = object.getJSONObject("response");
                        if (response_Object.length() > 0) {

                            checkPagePos = response_Object.getInt("current_page");

                            Object check_jobs_object = response_Object.get("jobs");
                            if (check_jobs_object instanceof JSONArray) {

                                JSONArray jobs_Array = response_Object.getJSONArray("jobs");
                                if (jobs_Array.length() > 0) {
                                    jobsList.clear();
                                    for (int i = 0; i < jobs_Array.length(); i++) {
                                        JSONObject jobs_Object = jobs_Array.getJSONObject(i);
                                        MyJobsListPojo pojo = new MyJobsListPojo();

                                        pojo.setJob_id(jobs_Object.getString("job_id"));
                                        pojo.setJob_time(jobs_Object.getString("job_time"));
                                        pojo.setService_type(jobs_Object.getString("service_type"));
                                        pojo.setService_icon(jobs_Object.getString("service_icon"));
                                        pojo.setBooking_date(jobs_Object.getString("booking_date"));
                                        pojo.setJob_date(jobs_Object.getString("job_date"));
                                        pojo.setJob_status(jobs_Object.getString("job_status"));
                                        pojo.setContact_number(jobs_Object.getString("contact_number"));
                                        pojo.setDoCall(jobs_Object.getString("doCall"));
                                        pojo.setIsSupport(jobs_Object.getString("isSupport"));
                                        pojo.setDoMsg(jobs_Object.getString("doMsg"));
                                        pojo.setDoCancel(jobs_Object.getString("doCancel"));

                                        System.out.println("contact_number-------------"+jobs_Object.getString("contact_number"));

                                        jobsList.add(pojo);
                                    }
                                    isJobAvailable = true;
                                } else {
                                    isJobAvailable = false;
                                    jobsList.clear();
                                }
                            } else {
                                isJobAvailable = false;
                                jobsList.clear();
                            }
                        }
                    } else {
                        jobsList.clear();
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                    stopLoading();
                    System.out.println("-------JSONException-----------------" + e);
                }

                if (Str_status.equalsIgnoreCase("1") && isJobAvailable) {
                    adapter = new MyJobsListAdapter(MyJobs.this, jobsList);
                    listView.setAdapter(adapter);
                    Tv_empty.setVisibility(View.GONE);
                } else if (Str_status.equalsIgnoreCase("1") && !isJobAvailable) {
                    adapter = new MyJobsListAdapter(MyJobs.this, jobsList);
                    listView.setAdapter(adapter);
                    Tv_empty.setVisibility(View.VISIBLE);
                } else if (Str_status.equalsIgnoreCase("0")) {
                    adapter = new MyJobsListAdapter(MyJobs.this, jobsList);
                    listView.setAdapter(adapter);
                    Tv_empty.setVisibility(View.VISIBLE);
                }*/

                dismissDialog();
            }

            @Override
            public void onErrorListener() {
                dismissDialog();
            }
        });
    }


    //--------------Date Select Method-----------
    private void datePicker(Bundle savedState) {

        dialogCaldroidFragment = new CaldroidFragment();
        dialogCaldroidFragment.setCaldroidListener(caldroidListener);

        // If activity is recovered from rotation
        final String dialogTag = "CALDROID_DIALOG_FRAGMENT";
        if (savedState != null) {
            dialogCaldroidFragment.restoreDialogStatesFromKey(getSupportFragmentManager(), savedState,
                    "DIALOG_CALDROID_SAVED_STATE", dialogTag);
            Bundle args = dialogCaldroidFragment.getArguments();
            if (args == null) {
                args = new Bundle();
                dialogCaldroidFragment.setArguments(args);
            }
        } else {
            // Setup arguments
            Bundle bundle = new Bundle();
            // Setup dialogTitle
            dialogCaldroidFragment.setArguments(bundle);
        }

        Calendar cal = Calendar.getInstance();
        Date currentDate = null;
        Date maximumDate = null;
        try {
            SimpleDateFormat df = new SimpleDateFormat("yyyy/MM/dd");
            String formattedDate = df.format(cal.getTime());
            currentDate = df.parse(formattedDate);

            // Max date is next 7 days
            cal = Calendar.getInstance();
            cal.add(Calendar.DATE, 7);
            maximumDate = cal.getTime();

        } catch (ParseException e1) {
            e1.printStackTrace();
        } catch (java.text.ParseException e) {
            e.printStackTrace();
        }


        dialogCaldroidFragment.setMinDate(currentDate);
        dialogCaldroidFragment.setMaxDate(maximumDate);
        dialogCaldroidFragment.show(getSupportFragmentManager(), dialogTag);
        dialogCaldroidFragment.refreshView();
    }


    // Setup CaldroidListener
    final CaldroidListener caldroidListener = new CaldroidListener() {
        @Override
        public void onSelectDate(Date date, View view) {
            dialogCaldroidFragment.dismiss();
            // Tvto_date.setText(getResources().getString(R.string.appointment_label_select_time));

            if (seleceteddate.equalsIgnoreCase("1")) {
                Tv_fromdaate.setText(formatter.format(date));
            } else {
                Tv_todate.setText(formatter.format(date));
            }
        }

        @Override
        public void onChangeMonth(int month, int year) {
            String text = "month: " + month + " year: " + year;
        }

        @Override
        public void onLongClickDate(Date date, View view) {
        }

        @Override
        public void onCaldroidViewCreated() {
        }
    };


    @Override
    public void onResume() {
        super.onResume();
        if (!ChatMessageService.isStarted()) {
            Intent intent = new Intent(MyJobs.this, ChatMessageService.class);
            startService(intent);
        }
    }

}
