# react-native-xmpp
XMPP library for React Native

Simple interface for native XMPP communication (only iOS supported at this moment) using iOS XMPPFramework

## Demo
XmppDemo uses Flux approach (check its XmppStore) to communicate with sample XMPP server, where 4 accounts were registered.
![demo-3](https://cloud.githubusercontent.com/assets/1321329/10537760/406affa6-73f4-11e5-986f-81a78adf129e.gif)


## Example

```
var XMPP = require('react-native-xmpp');

// optional callbacks
XMPP.on('message', (message)=>console.log("MESSAGE:"+JSON.stringify(message)));
XMPP.on('iq', (message)=>console.log("IQ:"+JSON.stringify(message)));
XMPP.on('presence', (message)=>console.log("PRESENCE:"+JSON.stringify(message)));
XMPP.on('error', (message)=>console.log("ERROR:"+message));
XMPP.on('loginError', (message)=>console.log("LOGIN ERROR:"+message));
XMPP.on('login', (message)=>console.log("LOGGED!"));
XMPP.on('connect', (message)=>console.log("CONNECTED!"));
XMPP.on('disconnect', (message)=>console.log("DISCONNECTED!"));

// trust hosts(Ignore self-signed ssl issues)
// Warning: Do not use this in production( Security will be compromised. ).
XMPP.trustHosts(['chat.google.com']);

// connect
XMPP.connect(MYJID, MYPASSWORD);

// send message
XMPP.message('Hello world!', TOJID);

// disconnect
XMPP.disconnect();

```


## Getting started
1. `npm install react-native-xmpp --save`
2. `rnpm link react-native-xmpp`
3. In the XCode project navigator, select your project, select the `Build Phases` tab and in the `Link Binary With Libraries` section add **libRNXMPP.a**, ***libresolv** and **libxml2**
