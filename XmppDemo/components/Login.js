'use strict';
var React = require('react-native');
var {View, Text, TextInput} = React;
var styles = require('./styles');
var Button = require('react-native-button');
var {Actions, PageStore} = require('react-native-router-flux');
var ActivityIndicator = require('./ActivityIndicator');

class Login extends React.Component {
    constructor(props){
        super(props);
        this.state = props || {};
    }
    componentWillReceiveProps({loginError, logged, ... props}){
        // show error (if any)
        this.setState(props);
        if (loginError && PageStore.getState().currentRoute == 'login'){
            alert(loginError);
        }
        if (logged && PageStore.getState().currentRoute == 'login'){
            // go to conversation screen, set nav title to remote username
            setTimeout(()=>
                Actions.conversation({
                    title: this.state.remote,
                    local: this.state.local,
                    remote: this.state.remote
                })
            );

        }
    }
    render(){
        return (
            <View style={styles.container}>
                <Text style={styles.categoryLabel}>Please enter local and remote usernames</Text>
                <Text style={styles.categoryLabel}>(rntestuserN, where N=1,2,3 or 4) </Text>
                <View style={styles.row}>
                    <TextInput style={styles.rowInput}
                               autoCorrect={false}
                               autoCapitalize="none"
                               autoFocus={true}
                               placeholder="Local (@jabber.hot-chilli.net)"
                               value={this.state.local}
                               onChangeText={(local)=>this.setState({local})}
                        />
                </View>
                <View style={styles.lastRow}>
                    <TextInput style={styles.rowInput}
                               autoCorrect={false}
                               autoCapitalize="none"
                               placeholder="Remote (@jabber.hot-chilli.net)"
                               value={this.state.remote}
                               onChangeText={(remote)=>this.setState({remote})}
                        />
                </View>
                <View style={styles.button}><Button onPress={()=>Actions.auth(this.state)}>Login</Button></View>
                <ActivityIndicator active={this.state.loading}/>

            </View>
        )
    }
}

module.exports = Login;