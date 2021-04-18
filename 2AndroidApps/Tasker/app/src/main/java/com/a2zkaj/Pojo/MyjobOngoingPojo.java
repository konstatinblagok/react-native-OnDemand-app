package com.a2zkaj.Pojo;

/**
 * Created by user88 on 12/11/2015.
 */
public class MyjobOngoingPojo {

    private String order_id;
    private String ongoing_user_name;
    private String ongoing_user_image;
    private String ongoing_address;
    private String ongoing_date;
    private String ongoingtime;
    private String Address="";

    public String getAddress() {
        return Address;
    }

    public void setAddress(String Address) {
        this.Address = Address;
    }

    public String getJob_status() {
        return job_status;
    }

    public void setJob_status(String job_status) {
        this.job_status = job_status;
    }

    private String job_status;

    public String getOngoing_category() {
        return ongoing_category;
    }

    public void setOngoing_category(String ongoing_category) {
        this.ongoing_category = ongoing_category;
    }

    private String ongoing_category;

    public String getOrder_id() {
        return order_id;
    }

    public void setOrder_id(String order_id) {
        this.order_id = order_id;
    }

    public String getOngoing_user_name() {
        return ongoing_user_name;
    }

    public void setOngoing_user_name(String ongoing_user_name) {
        this.ongoing_user_name = ongoing_user_name;
    }

    public String getOngoing_user_image() {
        return ongoing_user_image;
    }

    public void setOngoing_user_image(String ongoing_user_image) {
        this.ongoing_user_image = ongoing_user_image;
    }

    public String getOngoing_address() {
        return ongoing_address;
    }

    public void setOngoing_address(String ongoing_address) {
        this.ongoing_address = ongoing_address;
    }

    public String getOngoing_date() {
        return ongoing_date;
    }

    public void setOngoing_date(String ongoing_date) {
        this.ongoing_date = ongoing_date;
    }

    public String getOngoingtime() {
        return ongoingtime;
    }

    public void setOngoingtime(String ongoingtime) {
        this.ongoingtime = ongoingtime;
    }
}
