import React from 'react';
import {View, Text, ScrollView, TextInput, Keyboard, ListView, Dimensions}  from 'react-native';
import styles from './styles';
const height = Dimensions.get('window').height;
import Button from 'react-native-button';
import {Actions} from 'react-native-router-flux';
import InvertibleScrollView from 'react-native-invertible-scroll-view';
import xmpp from '../stores/XmppStore';
const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});

export default class Conversation extends React.Component {
    static title(props){
        return xmpp.remote;
    }
    constructor(props) {
        super(props);
        this.state = {height:0}
    }
    componentWillMount () {
        Keyboard.addListener('keyboardWillShow', this.keyboardWillShow.bind(this));
        Keyboard.addListener('keyboardWillHide', this.keyboardWillHide.bind(this));
        this.mounted = true;
        xmpp.login({local:xmpp.local, remote:xmpp.remote});
    }
    
    componentWillUnmount(){
        this.mounted = false;
        Keyboard.removeListener('keyboardWillShow');
        Keyboard.removeListener('keyboardWillHide');
    }
    keyboardWillShow (e) {
        if (this.mounted) this.setState({height: e.endCoordinates.height});
    }
    
    keyboardWillHide (e) {
        if (this.mounted) this.setState({height: 0});
    }
    
    render(){
        const dataSource = ds.cloneWithRows(xmpp.conversation.map(x=>x));
        return (
            <View style={styles.container}>
                <View style={{flex:1}}>
                    <ListView enableEmptySections
                        ref="messages"
                        renderScrollComponent={props => <InvertibleScrollView {...props} inverted />}
                        dataSource={dataSource}
                        renderRow={(row) =>
                            <Text style={[styles.messageItem, {textAlign:row.own ? 'right':'left' }]}>{row.text}</Text>}
                        />
                </View>
                <View style={styles.messageBar}>
                    <View style={{flex:1}}>
                        <TextInput ref='message'
                                   value={this.state.message}
                                   onChangeText={(message)=>this.setState({message})}
                                   style={styles.message} placeholder="Enter message..."/>
                    </View>
                    <View style={styles.sendButton}>
                        <Button onPress={()=>{xmpp.sendMessage(this.state.message);this.setState({message:''})}} disabled={!this.state.message || !this.state.message.trim()}>Send</Button>
                    </View>
                </View>
                <View style={{height:this.state.height}}></View>
            </View>
        )
    }
}
