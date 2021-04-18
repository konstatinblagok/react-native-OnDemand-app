package core.Volley;

import android.content.Context;
import android.widget.Toast;

import com.android.volley.AuthFailureError;
import com.android.volley.NetworkError;
import com.android.volley.NoConnectionError;
import com.android.volley.ParseError;
import com.android.volley.ServerError;
import com.android.volley.TimeoutError;
import com.android.volley.VolleyError;

/**
 * Created by user88 on 11/30/2015.
 */
public class VolleyErrorResponse {


    public static void VolleyError(Context context,VolleyError error)
    {
        if(error instanceof TimeoutError ||error instanceof NoConnectionError)
        {
            Toast.makeText(context, "Unable to fetch data from server", Toast.LENGTH_LONG).show();
        }
        else if(error instanceof AuthFailureError)
        {
            Toast.makeText(context, "AuthFailureError", Toast.LENGTH_LONG).show();
        }
        else if(error instanceof ServerError)
        {
            Toast.makeText(context, "ServerError", Toast.LENGTH_LONG).show();
        }
        else if(error instanceof NetworkError)
        {
            Toast.makeText(context, "NetworkError", Toast.LENGTH_LONG).show();
        }
        else if(error instanceof ParseError)
        {
            Toast.makeText(context, "ParseError", Toast.LENGTH_LONG).show();
        }
    }

}
