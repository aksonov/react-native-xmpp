'use strict';

var React = require('react-native');
var {View, Modal, ActivityIndicatorIOS, StyleSheet} = React;
var styles = require('./styles');

class ActivityIndicator extends React.Component {
    render(){
        if (this.props.active) {
            return (
                <View style={styles.loadingContainer}>
                    <View style={styles.loading}>
                        <ActivityIndicatorIOS size='large'/>
                    </View>
                </View>
            );
        } else {
            return <View/>;
        }
    }
}

module.exports = ActivityIndicator;