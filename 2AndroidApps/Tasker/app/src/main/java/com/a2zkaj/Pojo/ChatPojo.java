package com.a2zkaj.Pojo;

/**
 * Casperon Technology on 1/29/2016.
 */
public class ChatPojo {
    private String message, time, type;
    private String url;
    private String date;
    private String messageid;
    private String warnings="";
    private String seenstatus="";

    public String getSeenstatus() {
        return seenstatus;
    }

    public void setSeenstatus(String seenstatus) {
        this.seenstatus = seenstatus;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getURL() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public void setmesaageid(String messageid) {
        this.messageid = messageid;


    }

    public String getMessageid() {
        return messageid;
    }
    public String getwarnings() {
        return warnings;
    }

    public void setwarnings(String warnings) {
        this.warnings = warnings;
    }
}
