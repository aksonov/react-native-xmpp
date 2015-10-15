'use strict';

var React = require('react-native');
var {AppRegistry} = React;
var {Router, Route, Schema, Action, Animations} = require('react-native-router-flux');
var Conversation = require('./components/Conversation');
var Login = require('./components/Login');
var NavBar = require('./components/NavBar');
var XmppStore = require('./stores/XmppStore');

// Define all routes of the app
var XmppDemo = React.createClass({
  render: function() {
      return (
          <Router>
              <Schema name="default" navBar={NavBar} sceneConfig={Animations.FlatFloatFromRight}/>
              <Action name="auth" />
              <Action name="message" />
              <Route name="login" component={Login} title="Login" store={XmppStore}/>
              <Route name="conversation" component={Conversation} store={XmppStore}/>
          </Router>
      );
  }
});

AppRegistry.registerComponent('XmppDemo', () => XmppDemo);
