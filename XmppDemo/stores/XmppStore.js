'use strict';

var {alt, Actions, PageStore} = require('react-native-router-flux');
var XMPP = require('react-native-xmpp');
var DOMAIN = "jabber.hot-chilli.net";
var SCHEMA = "ios";

class XmppStore {
    constructor() {
        // subscribe to custom action (we will process 'auth' and 'message')
        this.bindAction(Actions.custom, this.onCustom.bind(this));

        // subscribe to pop action to disconnect
        this.bindAction(Actions.pop, this.onPop.bind(this));
        XMPP.on('loginError', this.onLoginError.bind(this));
        XMPP.on('error', this.onError.bind(this));
        XMPP.on('disconnect', this.onDisconnect.bind(this));
        XMPP.on('login', this.onLogin.bind(this));
        XMPP.on('message', this.onReceiveMessage.bind(this));

        this.loading = false;
        this.logged = false;
        this.loginError = null;
        this.conversations = {};
        // default values
        this.local = 'rntestuser1';
        this.remote = 'rntestuser2';
    }

    onCustom({name, data}){
        if (name == 'auth'){
            return this.onAuth(data)
        } else if (name == 'message'){
            return this.onSendMessage(data);
        }
        return false;
    }

    _userForName(name){
        return name + '@' + DOMAIN + "/" + SCHEMA;
    }

    onSendMessage({remote, message}){
        if (!remote || !remote.trim()){
            console.error("No remote username is defined");
        }
        if (!message || !message.trim()){
            return false;
        }
        if (!this.conversations[remote]){
            this.conversations[remote] = [];
        }
        // add to list of messages
        this.conversations[remote].unshift({own:true, text:message.trim()});
        // empty sent message
        this.message = null;
        this.error = null;
        // send to XMPP server
        XMPP.message(message.trim(), this._userForName(this.remote))
    }

    onReceiveMessage({from, body}){
        // extract username from XMPP UID
        if (!from || !body){
            return;
        }
        var name = from.match(/^([^@]*)@/)[1];
        if (!this.conversations[name]){
            this.conversations[name] = [];
        }
        this.conversations[name].unshift({own:false, text:body});
        // update state if message is received from current remote user
        if (name == this.remote) {
            this.setState({error: null, conversations: this.conversations, remote: this.remote});
        }
    }

    onLoginError(){
        this.setState({loading:false, loginError:"Cannot authenticate, please use correct local username"});
    }

    onError(message){
        this.setState({error: message});
    }

    onDisconnect(message){
        this.setState({logged: false, loginError:message});
    }

    onLogin(){
        this.setState({loading:false, loginError:null, logged: true});
    }

    onAuth({local, remote}){
        this.local = local;
        this.remote = remote;
        if (!local || !local.trim()){
            this.loginError = "Local username should not be empty";
        } else if (!remote || !remote.trim()){
            this.loginError = "Remote username should not be empty";
        } else if (local==remote){
            this.loginError = "Local username should not be the same as remote username";
        } else {
            this.loginError = null;

            // try to login to test domain with the same password as username
            XMPP.connect(this._userForName(this.local),this.local);
            this.loading = true;
        }

    }

    onPop() {
        // proccess pop to login screen only
        this.waitFor(PageStore.dispatchToken);
        if (PageStore.getState().currentRoute == 'login'){
            XMPP.disconnect();
        }
        return false;
    }

}

module.exports = alt.createStore(XmppStore, 'XmppStore');
