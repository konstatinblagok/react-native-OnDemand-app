package core.Xmpp;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v7.app.ActionBarActivity;
import android.view.Window;

import com.a2zkaj.app.R;

import core.service.ServiceConstant;

/**
 * Created by user88 on 1/11/2016.
 */
public class BaseActivity extends ActionBarActivity implements ServiceConstant {

    private Dialog dialog;


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    public void showDialog(String message) {
        dialog = new Dialog(this);
        dialog.getWindow();
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        dialog.setContentView(R.layout.custom_loading);
        dialog.setCanceledOnTouchOutside(false);
        dialog.show();
    }

    public void dismissDialog() {
        try {
            if (dialog != null)
                dialog.dismiss();
        } catch (IllegalArgumentException ex) {
            ex.printStackTrace();
        }

    }

}
