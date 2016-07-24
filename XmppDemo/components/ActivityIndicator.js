import React from 'react';
import {View, Modal, ActivityIndicator, StyleSheet} from 'react-native';
import styles from './styles';

export default class MyActivityIndicator extends React.Component {
    render(){
        if (this.props.active) {
            return (
                <View style={styles.loadingContainer}>
                    <View style={styles.loading}>
                        <ActivityIndicator size='large'/>
                    </View>
                </View>
            );
        } else {
            return <View/>;
        }
    }
}
