'use strict';
var React = require('react-native');
var {View, Text, ScrollView, TextInput, ListView, Dimensions} = React;
var height = Dimensions.get('window').height;
var styles = require('./styles');
var Button = require('react-native-button');
var {Actions} = require('react-native-router-flux');
var InvertibleScrollView = require('react-native-invertible-scroll-view');
var KEYBOARD_HEIGHT = 120;

class Conversation extends React.Component {
    constructor(props) {
        super(props);
        this.state = this._loadState(props);
    }
    _loadState(props){
        var ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
        var currentHeight = this.state? this.state.height : height;
        return {
            dataSource: ds.cloneWithRows(props.conversations[props.remote]||{}),
            height:currentHeight, ...props
        };
    }
    componentWillReceiveProps({error, loginError, ...props}){
        if (error){
            alert("XMPP Error:"+error);
        }
        if (loginError){
            Actions.pop();
        }
        this.setState(this._loadState(props));
        // scroll to show new message
        if (this.refs.messages && this.refs.messages.refs.listviewscroll){
            this.refs.messages.refs.listviewscroll.scrollTo(0);
        }
    }

    // scroll to text input element when keyboard is shown
    inputFocused (refName) {
        this.setState({height:height-KEYBOARD_HEIGHT*2});
        setTimeout(() => {
            var scrollResponder = this.refs.scrollView.getScrollResponder();
            scrollResponder.scrollResponderScrollNativeHandleToKeyboard(
                React.findNodeHandle(this.refs[refName]),
                66, //additionalOffset
                true
            );
        }, 50);
    }

    onBlur(){
        // keyboard is hidden, so we need to redraw scrollview and scroll to bottom
        if (this.refs.messages && this.refs.messages.refs.listviewscroll) {
            this.refs.messages.refs.listviewscroll.scrollTo(0);
        }
        this.setState({height});
        if (this.refs.scrollView) {
            this.refs.scrollView.scrollTo(0, 0);
        }
    }

    render(){
        return (
            <ScrollView ref='scrollView' style={styles.container} alwaysBounceVertical={false}>
                <View style={{height:this.state.height-KEYBOARD_HEIGHT}}>
                    {this.state.dataSource && <ListView
                        ref="messages"
                        renderScrollComponent={props => <InvertibleScrollView {...props} inverted />}
                        dataSource={this.state.dataSource}
                        renderRow={(row) =>
                            <Text style={[styles.messageItem, {textAlign:row.own ? 'right':'left' }]}>{row.text}</Text>}
                        /> }
                </View>
                <View style={styles.messageBar}>
                    <View style={{flex:1}}>
                        <TextInput ref='message'
                                   onBlur={this.onBlur.bind(this) }
                                   value={this.state.message}
                                   onChangeText={(message)=>this.setState({message})}
                                   onFocus={this.inputFocused.bind(this, 'message')}
                                   style={styles.message} placeholder="Enter message..."/>
                    </View>
                    <View style={styles.sendButton}>
                        <Button onPress={()=>Actions.message(this.state)} disabled={!this.state.message || !this.state.message.trim()}>Send</Button>
                    </View>
                </View>
            </ScrollView>
        )
    }
}

module.exports = Conversation;