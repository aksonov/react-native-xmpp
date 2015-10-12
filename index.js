'use strict';
var React = require('react-native');
var {NativeAppEventEmitter} = React;

var map = {
    'message' : 'RNXMPPMessage',
    'iq': 'RNXMPPIQ',
    'presence': 'RNXMPPPresence',
    'connect': 'RNXMPPConnect',
    'disconnect': 'RNXMPPDisconnect',
    'error': 'RNXMPPError',
    'loginError': 'RNXMPPLoginError',
    'login': 'RNXMPPLogin'
}

class XMPP {
    constructor(){
        this.isConnected = false;
        this.isLogged = false;
        NativeAppEventEmitter.addListener(map.connect, this.onConnected.bind(this));
        NativeAppEventEmitter.addListener(map.disconnect, this.onDisconnected.bind(this));
        NativeAppEventEmitter.addListener(map.error, this.onError.bind(this));
        NativeAppEventEmitter.addListener(map.loginError, this.onLoginError.bind(this));
        NativeAppEventEmitter.addListener(map.login, this.onLogin.bind(this));
    }

    onConnected(){
        console.log("Connected");
        this.isConnected = true;
    }

    onLogin(){
        console.log("Logged");
        this.isLogged = true;
    }

    onDisconnected(error){
        console.log("Disconnected, error"+error);
        this.isConnected = false;
        this.isLogged = false;
    }

    onError(text){
        console.log("Error: "+text);
    }

    onLoginError(text){
        this.isLogged = false;
        console.log("LoginError: "+text);
    }

    on(type, callback){
        if (map[type]){
            NativeAppEventEmitter.addListener(
                map[type],callback);
        } else {
            console.error("No registered type: "+type);
        }

    }

    connect(username, password){
        React.NativeModules.RNXMPP.connect(username, password);
    }

    message(text, user){
        console.log("Message:"+text+" being sent to user: "+user);
        React.NativeModules.RNXMPP.message(text, user);
    }

    disconnect(){
        if (this.isConnected){
            React.NativeModules.RNXMPP.disconnect();
        }
    }
}

module.exports = new XMPP();
