# react-native-xmpp

An XMPP library for React Native.

A simple interface for native XMPP communication. Both iOS and Android are supported.

## Demo

XmppDemo uses a Flux approach (check its `XmppStore`) to communicate with a sample XMPP server, where 4 accounts were registered.

![demo-3](https://cloud.githubusercontent.com/assets/1321329/10537760/406affa6-73f4-11e5-986f-81a78adf129e.gif)

## Example

```js
var XMPP = require('react-native-xmpp');

// optional callbacks
XMPP.on('message', (message) => console.log('MESSAGE:' + JSON.stringify(message)));
XMPP.on('iq', (message) => console.log('IQ:' + JSON.stringify(message)));
XMPP.on('presence', (message) => console.log('PRESENCE:' + JSON.stringify(message)));
XMPP.on('error', (message) => console.log('ERROR:' + message));
XMPP.on('loginError', (message) => console.log('LOGIN ERROR:' + message));
XMPP.on('login', (message) => console.log('LOGGED!'));
XMPP.on('connect', (message) => console.log('CONNECTED!'));
XMPP.on('disconnect', (message) => console.log('DISCONNECTED!'));

// trustHosts (ignore self-signed SSL issues)
// Warning: Do not use this in production (security will be compromised).
XMPP.trustHosts(['chat.google.com']);

// connect
XMPP.connect(MYJID, MYPASSWORD);

// send message
XMPP.message('Hello world!', TOJID);

// disconnect
XMPP.disconnect();

// remove all event listeners (recommended on componentWillUnmount)
XMPP.removeListeners();

// remove specific event listener (type can be 'message', 'iq', etc.)
XMPP.removeListener(TYPE);
```

## Getting started

1. `npm install react-native-xmpp --save`
2. `rnpm link react-native-xmpp`

### iOS

In the Xcode project navigator, select your project, select the `Build Phases` tab and in the `Link Binary With Libraries` section add, **`libRNXMPP.a`**, **`libresolv`** and **`libxml2`**.

### Android

If rnpm doesn't link the react-native-xmpp correct:

**android/settings.gradle**

```gradle
include ':react-native-xmpp'
project(':react-native-xmpp').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-xmpp/android')
```

**android/app/build.gradle**

```gradle
dependencies {
   ...
   compile project(':react-native-xmpp')
}
```

**MainApplication.java**

On top, where imports are:

```java
import rnxmpp.RNXMPPPackage;
```

Add the `ReactVideoPackage` class to your list of exported packages.

```java
@Override
protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
        new MainReactPackage(),
        new RNXMPPPackage()
    );
}
```