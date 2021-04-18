package com.a2zkaj.app;

import android.content.Context;

import com.a2zkaj.Utils.SessionManager;

import java.util.HashMap;

import core.Volley.ServiceRequest;

/**
 * Casperon Technology on 2/23/2016.
 */
public class ChatAvailabilityCheck {
    private Context context;
    private ServiceRequest mRequest;
    private SessionManager sessionManager;
    private String sMode = "";
    private String sUserID = "";

    public ChatAvailabilityCheck(Context mContext, String mode) {
        this.context = mContext;
        this.sMode = mode;
        sessionManager = new SessionManager(mContext);
        mRequest = new ServiceRequest(mContext);

// get user data from session
        HashMap<String, String> user = sessionManager.getUserDetails();
        sUserID = user.get(SessionManager.KEY_PROVIDERID);
    }

    public void postChatRequest() {

      /*  System.out.println("----------id--------"+sUserID);
        System.out.println("----------mode--------"+sMode);

        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("user_type", "provider");
        jsonParams.put("id", sUserID);
        jsonParams.put("mode", sMode);

        System.out.println("---------Chat Availability url------------" + ServiceConstant.CHAT_CHECK_ONLINE_URL);

        mRequest.makeServiceRequest(ServiceConstant.CHAT_CHECK_ONLINE_URL, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {
            @Override
            public void onCompleteListener(String response) {
                System.out.println("---------Chat Availability response------------" + response);
            }
            @Override
            public void onErrorListener() {
            }
        });*/
    }
}