package com.a2zkaj.Pojo;

/**
 * Created by CAS61 on 12/30/2016.
 */
public class MessageChatPojo {

    private String MessageTaskId = "";
    private String MessageBookingId = "";
    private String MessageUserNameId = "";
    private String MessageUserId = "";
    private String MessageUserImageId = "";
    private String Category;
    private String tasker_status="";
    private String date="";

    public String getMessageTaskId() {
        return MessageTaskId;
    }

    public void setMessageTaskId(String messageTaskId) {
        MessageTaskId = messageTaskId;
    }

    public String getMessageBookingId() {
        return MessageBookingId;
    }

    public void setMessageBookingId(String messageBookingId) {
        MessageBookingId = messageBookingId;
    }

    public String getMessageUserNameId() {
        return MessageUserNameId;
    }

    public void setMessageUserNameId(String messageUserNameId) {
        MessageUserNameId = messageUserNameId;
    }

    public String getMessageUserId() {
        return MessageUserId;
    }

    public void setMessageUserId(String messageUserId) {
        MessageUserId = messageUserId;
    }

    public String getMessageUserImageId() {
        return MessageUserImageId;
    }

    public void setMessageUserImageId(String messageUserImageId) {
        MessageUserImageId = messageUserImageId;
    }
    public String getCategory() {
        return Category;
    }

    public void setCategory(String category) {
        Category = category;
    }

    public String getstatus() {
        return tasker_status;
    }

    public void setstatus(String taskerstatus) {
        tasker_status = taskerstatus;
    }

    public String getdate() {
        return date;
    }

    public void setdate(String Date) {
        date = Date;
    }

}
