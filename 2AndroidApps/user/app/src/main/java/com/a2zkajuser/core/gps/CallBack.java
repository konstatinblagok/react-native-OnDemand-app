package com.a2zkajuser.core.gps;

/**
 * Created by user145 on 9/28/2017.
 */
public interface CallBack {

    void onComplete(String LocationName);

    void onError(String errorMsg);
}
