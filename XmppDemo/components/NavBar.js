'use strict';

var NavigationBar = require('react-native-navbar');
var React = require('react-native');
var {Actions, PageStore} = require('react-native-router-flux');
var styles = require('./styles');

class NavBar extends React.Component {
    render() {
        // don't display 'Back' button for previous route
        // (because react native redraws both previous and next screens during navigation)
        var onPrev = undefined;
        var prevTitle = undefined;
        if (this.props.navigator
            && this.props.navigator.getCurrentRoutes().length > 1
            && this.props.route.name==PageStore.getState().currentRoute){
            onPrev = ()=>Actions.pop();
        } else {
            prevTitle = " ";
        }
        return <NavigationBar style={styles.navBar}
                              titleColor='white'
                              buttonsColor='white'
                              statusBar='lightContent'
                              onPrev={onPrev}
                              prevTitle={prevTitle}
            {...this.props}
            />
    }
}

module.exports = NavBar;