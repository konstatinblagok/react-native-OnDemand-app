package com.a2zkajuser.pojo;

import java.util.ArrayList;

/**
 * Created by user145 on 2/14/2017.
 */
public class NotificationPojoInfo {

    private String NotificationTaskId = "";
    private String NotificationBookingId = "";
    private String NotificationCategory = "";
    private ArrayList<NotificationMessageInfo> NotificationMessageInfo = null;

    public ArrayList<com.a2zkajuser.pojo.NotificationMessageInfo> getNotificationMessageInfo() {
        return NotificationMessageInfo;
    }

    public void setNotificationMessageInfo(ArrayList<com.a2zkajuser.pojo.NotificationMessageInfo> notificationMessageInfo) {
        NotificationMessageInfo = notificationMessageInfo;
    }

    public String getNotificationTaskId() {
        return NotificationTaskId;
    }

    public void setNotificationTaskId(String notificationTaskId) {
        NotificationTaskId = notificationTaskId;
    }

    public String getNotificationCategory() {
        return NotificationCategory;
    }

    public void setNotificationCategory(String notificationCategory) {
        NotificationCategory = notificationCategory;
    }

    public String getNotificationBookingId() {
        return NotificationBookingId;
    }

    public void setNotificationBookingId(String notificationBookingId) {
        NotificationBookingId = notificationBookingId;
    }
}
