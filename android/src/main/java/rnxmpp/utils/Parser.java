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
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NamedNodeMap;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import java.io.IOException;
import java.io.StringReader;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

/**
 * Created by Kristian Frølund on 7/20/16.
 * Copyright (c) 2016. Teletronics. All rights reserved
 */
public class Parser {

    public static WritableMap parse(String xml){
        try {
            Document iqDocument = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(new InputSource(new StringReader(xml)));
            Element documentElement = iqDocument.getDocumentElement();
            WritableMap node = getWritableMap(parse(documentElement));
            return node;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
	
	static HashMap parse(Node node)
	{
		HashMap<String, Object> writableMap = new HashMap<String, Object>();
		NamedNodeMap documentElementAttributes = node.getAttributes();

        if (documentElementAttributes != null){
            for (int i = 0; i < documentElementAttributes.getLength(); i++){
                Node attribute = documentElementAttributes.item(i);
                writableMap.put(attribute.getNodeName(), attribute.getNodeValue());
            }
        }
		
		if (node.hasChildNodes()){
            NodeList childNodes = node.getChildNodes();
            for (int i = 0; i < childNodes.getLength(); i++){
                Node childNode = childNodes.item(i);
                if (writableMap.containsKey(childNode.getNodeName())){
					Object val = writableMap.get(childNode.getNodeName());
					if (val instanceof HashMap){
						ArrayList<Object> childArray = new ArrayList<Object>();
						childArray.add(val);
						childArray.add(parse(childNode));
						writableMap.put(childNode.getNodeName(), childArray);
					}else if (val instanceof ArrayList){
						((ArrayList)val).add(parse(childNode));
					}
				}else{
					NodeList checkTextChildNodes = childNode.getChildNodes();
                    if (checkTextChildNodes.getLength() == 1 && checkTextChildNodes.item(0).getNodeName().equals("#text")){
                        writableMap.put(childNode.getNodeName(), checkTextChildNodes.item(0).getNodeValue());
                    }else{
                        writableMap.put(childNode.getNodeName(), parse(childNode));
					}
				}
			}
		}
		return writableMap;
	}

	static WritableArray getWritableArray(ArrayList<Object> list){
		WritableArray writableArray = Arguments.createArray();
		for (Object val : list){
			if (val instanceof HashMap){
				writableArray.pushMap(getWritableMap((HashMap)val));
			}else if (val instanceof ArrayList){
				writableArray.pushArray(getWritableArray((ArrayList)val));
			}else{
				writableArray.pushString(String.valueOf(val));
			}
		}
		return writableArray;
	}
	
	static WritableMap getWritableMap(HashMap<String, Object> hashMap){
		WritableMap writableMap = Arguments.createMap();
		for (Map.Entry<String, Object> entry : hashMap.entrySet()){
			Object val = entry.getValue();
			if (val instanceof HashMap){
				writableMap.putMap(entry.getKey(), getWritableMap( (HashMap<String, Object>)val));
			}else if (val instanceof ArrayList){
				writableMap.putArray(entry.getKey(), getWritableArray( (ArrayList<Object>) val));
			}else{
				writableMap.putString(entry.getKey(), String.valueOf(val));
			}
		}
		return writableMap;
	}
}
