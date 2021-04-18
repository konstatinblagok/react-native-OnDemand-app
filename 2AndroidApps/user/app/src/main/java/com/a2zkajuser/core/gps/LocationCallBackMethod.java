package com.a2zkajuser.core.gps;

/**
 * Created by user145 on 10/10/2017.
 */
public interface LocationCallBackMethod {

    void onComplete(String LocationName, String city,String state,String country,String postalcode,String lat,String log);

    void onError(String errorMsg);
}
