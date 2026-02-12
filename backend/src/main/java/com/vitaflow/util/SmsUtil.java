package com.vitaflow.backend.util;

import javax.net.ssl.HttpsURLConnection;
import java.net.URL;
import java.net.URLEncoder;

public class SmsUtil {

    private static final String API_KEY = "YOUR_FAST2SMS_API_KEY";

    public static void sendSms(String message, String number) {

        try {
            message = URLEncoder.encode(message, "UTF-8");

            String urlStr =
                    "https://www.fast2sms.com/dev/bulk" +
                            "?authorization=" + API_KEY +
                            "&route=p" +                      // promo (project only)
                            "&message=" + message +
                            "&language=english" +
                            "&numbers=" + number;

            URL url = new URL(urlStr);
            HttpsURLConnection con = (HttpsURLConnection) url.openConnection();

            con.setRequestMethod("GET");
            con.setRequestProperty("User-Agent", "Mozilla/5.0");

            con.getInputStream(); // trigger request

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

