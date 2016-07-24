package rnxmpp.ssl;

import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;

import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

/**
 * Created by Kristian Frølund on 7/20/16.
 * Copyright (c) 2016. Teletronics. All rights reserved
 */

public enum NullTrustManager {

    INSTANCE();

    private TrustManager[] trustAllCerts;

    NullTrustManager() {
        trustAllCerts = new TrustManager[]{new X509TrustManager() {
            public X509Certificate[] getAcceptedIssuers() {
                return new X509Certificate[0];
            }

            @Override
            public void checkClientTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {}

            @Override
            public void checkServerTrusted(X509Certificate[] arg0, String arg1) throws CertificateException {}
        }};
    };

    public TrustManager[] get() {
        return trustAllCerts;
    }
}
