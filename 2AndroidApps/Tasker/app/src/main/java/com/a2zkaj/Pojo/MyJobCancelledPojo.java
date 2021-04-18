package com.a2zkaj.Pojo;

/**
 * Created by user88 on 12/12/2015.
 */
public class MyJobCancelledPojo {

    private String order_id;
    private String jobcancelled_user_name;
    private String jobcancelled_user_image;
    private String jobcancelled_address;
    private String jobcancelled_date;
    private String Address="";

    public String getAddress() {
        return Address;
    }

    public void setAddress(String Address) {
        this.Address = Address;
    }
    public String getOrder_id() {
        return order_id;
    }

    public void setOrder_id(String order_id) {
        this.order_id = order_id;
    }

    public String getJobcancelled_user_name() {
        return jobcancelled_user_name;
    }

    public void setJobcancelled_user_name(String jobcancelled_user_name) {
        this.jobcancelled_user_name = jobcancelled_user_name;
    }

    public String getJobcancelled_user_image() {
        return jobcancelled_user_image;
    }

    public void setJobcancelled_user_image(String jobcancelled_user_image) {
        this.jobcancelled_user_image = jobcancelled_user_image;
    }

    public String getJobcancelled_address() {
        return jobcancelled_address;
    }

    public void setJobcancelled_address(String jobcancelled_address) {
        this.jobcancelled_address = jobcancelled_address;
    }

    public String getJobcancelled_date() {
        return jobcancelled_date;
    }

    public void setJobcancelled_date(String jobcancelled_date) {
        this.jobcancelled_date = jobcancelled_date;
    }

    public String getJobcancelled_time() {
        return jobcancelled_time;
    }

    public void setJobcancelled_time(String jobcancelled_time) {
        this.jobcancelled_time = jobcancelled_time;
    }

    public String getJobcancelled_status() {
        return jobcancelled_status;
    }

    public void setJobcancelled_status(String jobcancelled_status) {
        this.jobcancelled_status = jobcancelled_status;
    }

    public String getJobcancelled_categorys() {
        return jobcancelled_categorys;
    }

    public void setJobcancelled_categorys(String jobcancelled_categorys) {
        this.jobcancelled_categorys = jobcancelled_categorys;
    }

    private String jobcancelled_time;
    private String jobcancelled_status;
    private String jobcancelled_categorys;

}
