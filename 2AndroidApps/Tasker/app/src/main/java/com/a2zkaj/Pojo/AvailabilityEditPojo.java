package com.a2zkaj.Pojo;

/**
 * Created by user145 on 5/10/2017.
 */
public class AvailabilityEditPojo {

    private String days="";
    private String daysession="";
    private String status="";
    private String Morning="",Afternoon="",Evening="";

    public void setDays(String days){
      this.days=days;
    }

    public String getDays(){
        return days;
    }
    public void setDaysession(String daysession){
        this.daysession=daysession;
    }

    public String getMorning() {
        return Morning;
    }

    public void setMorning(String morning) {
        Morning = morning;
    }

    public String getAfternoon() {
        return Afternoon;
    }

    public void setAfternoon(String afternoon) {
        Afternoon = afternoon;
    }

    public String getEvening() {
        return Evening;
    }

    public void setEvening(String evening) {
        Evening = evening;
    }

    public String getDaysession(){
        return daysession;
    }
    public void setStatus(String status){
        this.status=status;
    }
    public String getStatus(){
        return status;
    }

}
