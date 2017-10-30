/*
 * Copyright (c) 2016. Teletronics. All rights reserved
 */

package rnxmpp.utils;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;

import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.StringReader;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

/**
 * Created by Kristian Frølund on 7/20/16.
 * Copyright (c) 2016. Teletronics. All rights reserved
 */
public class Parser {

    public static WritableMap parse(String xml){
        try {
            JSONObject jsonObject = new JSONObject();
            Document iqDocument = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(new InputSource(new StringReader(xml)));
            Element documentElement = iqDocument.getDocumentElement();
            WritableMap node = parse(documentElement);
            return node;
        } catch (SAXException | ParserConfigurationException | IOException | JSONException e) {
            e.printStackTrace();
        }
        return null;
    }

    static WritableMap parse(Node node) throws JSONException {
        WritableMap writableMap = Arguments.createMap();
        NamedNodeMap documentElementAttributes = node.getAttributes();

        if (documentElementAttributes != null){
            for (int i = 0; i < documentElementAttributes.getLength(); i++){
                Node attribute = documentElementAttributes.item(i);
                writableMap.putString(attribute.getNodeName(), attribute.getNodeValue());
            }
        }

        if (node.hasChildNodes()){
            NodeList childNodes = node.getChildNodes();
            for (int i = 0; i < childNodes.getLength(); i++) {
                Node childNode = childNodes.item(i);
                if (writableMap.hasKey(childNode.getNodeName()) && writableMap.getType(childNode.getNodeName()).equals(ReadableType.Map)){
                    WritableArray childArray = Arguments.createArray();
                    childArray.pushMap(Arguments.fromBundle(Arguments.toBundle(writableMap.getMap(childNode.getNodeName()))));
                    childArray.pushMap(parse(childNode));
                    writableMap.putArray(childNode.getNodeName(), childArray);
                } else if (writableMap.hasKey(childNode.getNodeName()) && writableMap.getType(childNode.getNodeName()).equals(ReadableType.Array)){
                    WritableArray writableArray = fromArray(writableMap.getArray(childNode.getNodeName()));
                    writableArray.pushMap(parse(childNode));
                    writableMap.putArray(childNode.getNodeName(), writableArray);
                } else {
                    NodeList checkTextChildNodes = childNode.getChildNodes();
                    if (checkTextChildNodes.getLength() == 1 && checkTextChildNodes.item(0).getNodeName().equals("#text")){
                        writableMap.putString(childNode.getNodeName(), checkTextChildNodes.item(0).getNodeValue());
                    }else{
                        writableMap.putMap(childNode.getNodeName(), parse(childNode));
                    }
                }
            }
        }
        return writableMap;
    }

    static WritableArray fromArray(ReadableArray readableArray){
        WritableArray newArray = Arguments.createArray();
        for (int i = 0; i < readableArray.size(); i++) {
            ReadableType type = readableArray.getType(i);
            if (type.equals(ReadableType.Map)){
                newArray.pushMap(Arguments.fromBundle(Arguments.toBundle(readableArray.getMap(i))));
            }else if(type.equals(ReadableType.Array)){
                newArray.pushArray(fromArray(readableArray.getArray(i)));
            }else if(type.equals(ReadableType.Boolean)){
                newArray.pushBoolean(readableArray.getBoolean(i));
            }else if(type.equals(ReadableType.Number)){
                newArray.pushInt(readableArray.getInt(i));
            }else if(type.equals(ReadableType.String)){
                newArray.pushString(readableArray.getString(i));
            }
        }
        return newArray;
    }
}
