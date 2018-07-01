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

// join room(s)
XMPP.joinRoom(ROOMJID_1, ROOMNICKNAME)
XMPP.joinRoom(ROOMJID_2, ROOMNICKNAME)

// send message to room(s)
XMPP.sendRoomMessage(ROOMJID_1, 'Hello room 1!');
XMPP.sendRoomMessage(ROOMJID_2, 'Hello room 2!');

// leave room(s)
XMPP.leaveRoom(ROOMJID_1);
XMPP.leaveRoom(ROOMJID_2);

// disconnect
XMPP.disconnect();

// remove all event listeners (recommended on componentWillUnmount)
XMPP.removeListeners();

// remove specific event listener (type can be 'message', 'iq', etc.)
XMPP.removeListener(TYPE);
```

## Getting started

1. `npm install react-native-xmpp --save`

### iOS

Please use CocoaPods 

2. Install latest XMPPFramework:
https://github.com/robbiehanson/XMPPFramework
`pod 'XMPPFramework', :git => 'https://github.com/robbiehanson/XMPPFramework.git', :branch => 'master'`

3. Add this package pod:
`pod 'RNXMPP', :path => '../node_modules/react-native-xmpp'`

If you have problems with latest 4.0 XMPPFramework and/or XCode 9.3, you may use old one with forked KissXML:
`pod 'XMPPFramework', '~> 3.7.0'`
`pod 'KissXML', :git => "https://github.com/aksonov/KissXML.git", :branch => '5.1.4'`


### Android
`react-native link react-native-xmpp`

If it doesn't link the react-native-xmpp correct:

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
