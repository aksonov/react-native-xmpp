package rnxmpp.service;

import org.jivesoftware.smack.packet.Message;
import org.jivesoftware.smack.MessageListener;

import java.util.logging.Level;
import java.util.logging.Logger;

public class XmppGroupMessageListenerImpl implements XmppGroupMessageListener, MessageListener {

    XmppServiceListener xmppServiceListener;
    Logger logger;

    public XmppGroupMessageListenerImpl(XmppServiceListener xmppServiceListener, Logger logger) {
        this.xmppServiceListener = xmppServiceListener;
        this.logger = logger;
    }

    public void processMessage(Message message) {
        this.xmppServiceListener.onMessage(message);
        logger.log(Level.INFO, "Received a new group message", message.toString());
    }

}


