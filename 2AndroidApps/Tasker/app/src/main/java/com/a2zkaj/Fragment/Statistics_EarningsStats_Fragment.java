package com.a2zkaj.Fragment;

import android.content.Context;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.android.volley.Request;
import com.github.mikephil.charting.charts.BarChart;
import com.github.mikephil.charting.data.BarData;
import com.github.mikephil.charting.data.BarDataSet;
import com.github.mikephil.charting.data.BarEntry;
import com.github.mikephil.charting.utils.ColorTemplate;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.R;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;

import org.json.JSONArray;
import org.json.JSONObject;

import java.text.NumberFormat;
import java.util.ArrayList;
import java.util.Currency;
import java.util.HashMap;
import java.util.Locale;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 12/31/2015.
 */
public class Statistics_EarningsStats_Fragment extends FragmentHockeyApp {
    private LoadingDialog dialog;
    private String asyntask_name = "normal";

    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;
    private String provider_id = "";
    BarChart chart;

    private String desc;

    private TextView Tv_ststistics_desc;


    private Boolean ischeckchart = false;
    private boolean show_progress_status = false;
    private ArrayList<String> monthsXaxis;
    private ArrayList<String> amount;
    ArrayList<BarDataSet> dataSets = null;
    ArrayList<BarEntry> priceValueSet1 = new ArrayList<>();

    private String Str_Unit = "", Str_total_earnings = "", Str_maximumearnings = "", Str_interval = "", Str_currency_Code = "";

    Currency currencycode;

    private RelativeLayout Rl_earnings_state_main_layout, Rl_earnings_state_nointernet_layout, Rl_layout_empty_earningsstates;

    private SocketHandler socketHandler;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View rootview = inflater.inflate(R.layout.statistics_earnings_state_barchart, container, false);
        init(rootview);
        return rootview;

    }


    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        socketHandler = SocketHandler.getInstance(getActivity());
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

        chart = (BarChart) rootview.findViewById(R.id.chart);
        //  chart.setPinchZoom(false);
        //  chart.setClickable(false);

        Rl_earnings_state_main_layout = (RelativeLayout) rootview.findViewById(R.id.earnings_state_main_layout);
        Rl_earnings_state_nointernet_layout = (RelativeLayout) rootview.findViewById(R.id.layout_statistics_earningsstate_noInternet);
        Rl_layout_empty_earningsstates = (RelativeLayout) rootview.findViewById(R.id.earnings_state_empty_layout);
        Tv_ststistics_desc = (TextView) rootview.findViewById(R.id.earning_state);

        Tv_ststistics_desc.setText(desc);

        monthsXaxis = new ArrayList<String>();
        amount = new ArrayList<String>();

        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {
            Rl_earnings_state_main_layout.setVisibility(View.VISIBLE);
            Rl_earnings_state_nointernet_layout.setVisibility(View.GONE);
            earnmingsstatesPostRequest(getActivity(), ServiceConstant.STATISTICS_EARNINGS_STATE_URL);
            System.out.println("earningsstate------------" + ServiceConstant.STATISTICS_EARNINGS_STATE_URL);

        } else {
            Rl_earnings_state_main_layout.setVisibility(View.GONE);
            Rl_earnings_state_nointernet_layout.setVisibility(View.VISIBLE);
        }

    }

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(getActivity());
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


    private void earnmingsstatesPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);

        System.out.println("provider_id----------" + provider_id);

        dialog = new LoadingDialog(getActivity());
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("earningsstates", response);

                String Str_Status = "", Str_Response = "";
                ArrayList<BarDataSet> dataSets = null;

                try {
                    JSONObject jobject = new JSONObject(response);
                    Str_Status = jobject.getString("status");

                    if (Str_Status.equals("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        Str_Unit = object.getString("unit");
                        Str_total_earnings = object.getString("total_earnings");
                        Str_maximumearnings = object.getString("max_earnings");
                        Str_interval = object.getString("interval");
                        Str_currency_Code = object.getString("currency_code");
                        currencycode = Currency.getInstance(getLocale(Str_currency_Code));

                        System.out.println("Str_interval--------------" + Str_interval);
                        System.out.println("maximimum--------------" + Str_maximumearnings);

                        JSONArray jarry = object.getJSONArray("earnings");
                        if (jarry.length() > 0) {
                            for (int i = 0; i < jarry.length(); i++) {
                                JSONObject object2 = jarry.getJSONObject(i);

                                monthsXaxis.add(object2.getString("month"));
                                amount.add(object2.getString("amount"));

                                String sAmount = object2.getString("amount");
                                if (sAmount != null && sAmount.length() > 0) {
                                    BarEntry v1e1 = new BarEntry(Float.parseFloat(sAmount), i); // Jan
                                    priceValueSet1.add(v1e1);
                                }
                            }
                            ischeckchart = true;

                            show_progress_status = true;

                        } else {
                            ischeckchart = false;
                            show_progress_status = false;
                        }

                    } else {

                        Str_Response = jobject.getString("response");
                    }

                    if (Str_Status.equals("1") && ischeckchart) {
                       /* if(amount.size()>0 )
                        {
                            for (int i = amount.size()-1; i >= 0; i--) {
                                String sAmount=amount.get(i);
                                if(sAmount!=null && sAmount.length()>0)
                                {
                                    System.out.println("------------sAmount-------------"+sAmount);
                                    System.out.println("------------i-------------"+i);

                                    BarEntry v1e1 = new BarEntry(Float.parseFloat(sAmount), i); // Jan
                                    priceValueSet1.add(v1e1);
                                }
                            }
                        }*/

                        BarDataSet barDataSet1 = new BarDataSet(priceValueSet1, getResources().getString(R.string.statistics_earnings_states_fragment_month_text));
                        barDataSet1.setColors(ColorTemplate.COLORFUL_COLORS);
                        //  barDataSet1.setColor(Color.rgb(0, 155, 0));

                        dataSets = new ArrayList<>();
                        dataSets.add(barDataSet1);

                        BarData data = new BarData(monthsXaxis, dataSets);
                        chart.setData(data);
                        chart.setDescription("");

                        // chart.setDescription("Earnings" + currencycode.getSymbol() + Str_Unit);
                        // chart.setDescriptionTextSize(18);
                        //desc = ("Earnings" + currencycode.getSymbol() +Str_Unit);
                        chart.animateXY(2000, 2000);
                        chart.invalidate();

                        if (show_progress_status) {
                            Rl_layout_empty_earningsstates.setVisibility(View.GONE);
                        } else {
                            Rl_layout_empty_earningsstates.setVisibility(View.VISIBLE);
                            chart.setData(data);
                        }

                    } else {

                        Alert(getResources().getString(R.string.server_lable_header), Str_Response);

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


    //method to convert currency code to currency symbol
    private static Locale getLocale(String strCode) {

        for (Locale locale : NumberFormat.getAvailableLocales()) {
            String code = NumberFormat.getCurrencyInstance(locale).getCurrency().getCurrencyCode();
            if (strCode.equals(code)) {
                return locale;
            }
        }
        return null;
    }


    @Override
    public void onResume() {
        super.onResume();
//starting XMPP service

        /*if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


}