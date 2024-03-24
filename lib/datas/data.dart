import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


String startUrl = '192.168.1.3:8000';


class Auth {

  makeAuth(username, password) async {
    var url = Uri.http(startUrl, '/auth/token/login/');
    var data = {
      "username": username,
      "password": password,
    };
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    String body = json.encode(data);
    var response = await http.post(url, body: body, headers: headers);
    final token = jsonDecode(response.body);
    print(token);
    if (!token.containsKey('non_field_errors')) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token['auth_token']);
    }
    return token;
  }

  static Future<String?> getRA() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> removeToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.http(startUrl, '/auth/token/logout/');
    final removeToken = prefs.getString('token');

    Map<String, String> header = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $removeToken'
    };

    await http.post(url, headers: header);

    prefs.remove('token');
    return true;
  }

  getMyData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    var url = Uri.http(startUrl, '/api/me/');
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token'
    });
    return jsonDecode(utf8.decode(response.bodyBytes))['me'];
  }

}


class Rooms {
  List<dynamic> dataList = [];

  Future<Map<String, dynamic>> getSmbdsId(hisUsername) async {
    var url = Uri.http(startUrl, '/api/get_user/$hisUsername/');
    var token = await Auth.getRA();
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token'
    });
    var resp = jsonDecode(utf8.decode(response.bodyBytes));
    return resp;
  }

  Future<Map<String, dynamic>> getRoomByName(roomName) async {
    var url = Uri.http(startUrl, '/api/get_room_by_name/$roomName/');
    var token = await Auth.getRA();
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token'
    });
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  Future<List<Map<String, dynamic>>> createContact(firstName, lastName, hisUsername) async {
    var url = Uri.http(startUrl, '/api/contacts/');
    var token = await Auth.getRA();
    var myInfo = await Auth().getMyData();
    var hisUserId = await getSmbdsId(hisUsername);

    if (!hisUserId.containsKey('id')) {
      return [{'dt': hisUserId}];
    }

    var data = {
      'first_name': firstName,
      'last_name': lastName,
      'me': myInfo['id'],
      'show_him': hisUserId['id'],
    };

    var body = json.encode(data);

    var response = await http.post(url, body: body, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token'
    });

    var resp = jsonDecode(utf8.decode(response.bodyBytes));
    Map<String, dynamic> room;
    var createdRoom = await createRoom([myInfo['username'], hisUserId['username']], [myInfo['id'], hisUserId['id']]);
    if (createdRoom.containsKey('room_exist')) {
      room = await getRoomByName('${createdRoom['room_exist'][1]}');
    } else {
      room = await getRoomByName(createdRoom['room_name']);
    }
    return [resp, room];
  }

  Future<List<dynamic>> getMethod() async {
    var url = Uri.http(startUrl, '/api/my_rooms/');
    var token = await Auth.getRA();
    var response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token'
    });
    dataList = jsonDecode(utf8.decode(response.bodyBytes));
    return dataList;
  }

  String getStrUrl() {
    return 'http://$startUrl/';
  }

  String justPath() {
    return startUrl;
  }

  createRoom(List usernames, List usersId) async {
    var url = Uri.http(startUrl, '/api/rooms/create/');
    var token = await Auth.getRA();
    var data = {
      "room_name": '${usernames[0]}_${usernames[1]}',
      "users": usersId
    };

    String body = json.encode(data);

    var response = await http.post(url, body: body, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token'
    });

    var returnedData = json.decode(utf8.decode(response.bodyBytes));

    return returnedData;
  }

}


class Message {
  Future<List<dynamic>> getMessages(roomId) async {
    var url = Uri.http(startUrl, '/api/rooms_messages/$roomId/');
    var response = await http.get(url);
    var dataList = jsonDecode(utf8.decode(response.bodyBytes));
    return dataList['messages'];
  }
}


class Register {
  registerSMB (username, firstName, lastName, password) async {
    var url = Uri.http(startUrl, '/api/users/'); 

    var data = {
      "first_name": firstName,
      "last_name": lastName,
      "username": username,
      "password": password,
      "profile_img": null,
      "last_login": null
    };

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    String body = json.encode(data);
    var response = await http.post(url, body: body, headers: headers);
    var resp = jsonDecode(utf8.decode(response.bodyBytes));
    await Auth().makeAuth(username, password);
    return resp;
  }
}


class Contacts {

  Future<List<dynamic>> getMyContacts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var url = Uri.http(startUrl, '/api/get_my_contacts/');
    final token = prefs.getString('token');
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token'
    };
    var response = await http.get(url, headers: headers);

    var rsp = jsonDecode(utf8.decode(response.bodyBytes));

    return rsp;
  }

}