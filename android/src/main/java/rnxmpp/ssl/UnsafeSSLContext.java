package rnxmpp.ssl;

import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;

import javax.net.ssl.SSLContext;

/**
 * Created by Kristian Frølund on 7/20/16.
 * Copyright (c) 2016. Teletronics. All rights reserved
 */

public enum UnsafeSSLContext {
    INSTANCE();

    private SSLContext context;

    private UnsafeSSLContext(){
        context = null;
        try {
            context = SSLContext.getInstance("SSL");
            context.init(null, NullTrustManager.INSTANCE.get(), null);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
        } catch (KeyManagementException e) {
            e.printStackTrace();
        }
    }

    public SSLContext getContext() {
        return context;
    }
}
