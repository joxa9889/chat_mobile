import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_project/lips/home_people.dart';
import 'package:chat_project/pages/contacts.dart';
import 'package:chat_project/pages/log_in.dart';
import 'package:chat_project/pages/profile_settings.dart';
import 'package:chat_project/pages/stories.dart';
import 'package:flutter/material.dart';
import 'package:chat_project/datas/data.dart';
import 'package:chat_project/pages/chatting.dart';
import 'package:web_socket_channel/io.dart';

class ChattingContacts extends StatefulWidget {
  const ChattingContacts({super.key});

  @override
  State<ChattingContacts> createState() => _ChattingContactsState();
}

class _ChattingContactsState extends State<ChattingContacts> {
  int? active;
  String strUrl = Rooms().getStrUrl();
  Map<String, dynamic> myData = {};
  BuildContext? _modalContext;
  final _formKey = GlobalKey<FormState>();
  String? errorUsername;
  late IOWebSocketChannel status;
  var streamer;
  List<dynamic> statuses = [];
  String simplePath = Rooms().justPath();
  List<dynamic> chattingRooms = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  getData() async {
    var dt = await Auth().getMyData();
    var dataToRooms = await Rooms().getMethod();
    setState(() {
      myData = dt;
      chattingRooms = dataToRooms;
    });
    print(chattingRooms);
  }


  getToken() async {
    var tkn = await Auth.getRA();
    print(tkn);
    status.sink.add(jsonEncode({'token': tkn}));
  }

  dtToChange(index, data) {
    setState(() {
      statuses[index] = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    
    status = IOWebSocketChannel.connect('ws://$simplePath/ws/status/');
    streamer = status.stream.asBroadcastStream();
    getToken();
    streamer.listen((message) {
      print(message);
      Map<String, dynamic> data = jsonDecode(message);
      if (data.containsKey('update')) {
        data.remove('update');
        int index = statuses.indexWhere((user) => user['username'] == data['username']);
        dtToChange(index, data);
        print(statuses);
      } else {
        setState(() {
          statuses = jsonDecode(message)['message'];          
        });
      }
    });
  }


  _showLog () {
    showModalBottomSheet(
      elevation: 2,
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      isScrollControlled: true,
      context: context,
      builder: (builder) {
        _modalContext = context;
        return Padding(
          padding: EdgeInsets.only( bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 35),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'New Contact',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white
                        ),
                      ),
                    
                  
                      const SizedBox(
                        height: 25,
                      ),
                  
                      TextFormField(
                        controller: _usernameController,
                        validator: (value) {
                          if (errorUsername != null) {
                            return errorUsername;
                          }
                          return null;
                        },
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)
                          ),
                          labelText: 'Username (required)',
                          labelStyle: TextStyle(
                            color: Colors.grey
                          ),
                          border: OutlineInputBorder()
                        ),
                      ),
                  
                      const SizedBox(
                        height: 15,
                      ),
                  
                      TextFormField(
                        controller: _firstNameController,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)
                          ),
                          labelText: 'First Name (optional)',
                          labelStyle: TextStyle(
                            color: Colors.grey
                          ),
                          border: OutlineInputBorder()
                        ),
                      ),
                  
                      const SizedBox(
                        height: 15,
                      ),
                  
                      TextFormField(
                        controller: _lastNameController,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        decoration: const InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)
                          ),
                          labelText: 'Last Name (optional)',
                          labelStyle: TextStyle(
                            color: Colors.grey
                          ),
                          border: OutlineInputBorder()
                        ),
                      ),
                  
                      const SizedBox(
                        height: 20,
                      ),
                  
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () async {
                            var data = await Rooms().createContact(_firstNameController.text, _lastNameController.text, _usernameController.text);
                            if (data[0].containsKey('error_show_him')) {
                              setState(() {
                                errorUsername = data[0]['error_show_him'][0];
                                _formKey.currentState!.validate();
                              });
                            } else {
                              Navigator.pop(_modalContext!);
                              _firstNameController.clear();
                              _lastNameController.clear();
                              _usernameController.clear();
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (builder) => ChattingPage(fullName: '${data[0]['first_name']} ${data[0]['last_name']}', avatarImg: data[1]['users'][0]['profile_img'], roomId: data[1]['id'], roomName: data[1]['room_name'], myId: myData['id'], needUpdate: true,)));
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: const MaterialStatePropertyAll(Color.fromARGB(95, 38, 37, 37)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                                side: const BorderSide(color: Color.fromARGB(255, 73, 71, 71))
                              )
                            )
                          ),
                          child: const Text(
                            'Create Contact',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Builder(
            builder: (context) {
              return GestureDetector(
                onTap: () {
                  Scaffold.of(context).openDrawer();
                },
                child: myData.isNotEmpty && myData['profile_img'] != null && myData.containsKey('profile_img') ? CircleAvatar(
                  foregroundImage: CachedNetworkImageProvider(myData['profile_img']),
                  backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                ) : CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                  child: myData.isNotEmpty ? Text(
                    '${myData['first_name'][0]}',
                    style: const TextStyle(color: Colors.white),
                  ) : const Text(''),
                ),
              );
            }
          ),
        ),
        
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10), 
                  child: const Icon(Icons.message_outlined, color: Colors.white,),               
                ),
                const Icon(Icons.more_vert_outlined, color: Colors.white)
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed:() {
          _showLog();
        },
        backgroundColor: const Color.fromARGB(255, 43, 42, 42),
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 25, 26, 30),
        child: SafeArea(
          child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(28, 29, 34, 1),
                    border: Border(bottom: BorderSide(color: Color.fromARGB(255, 79, 79, 79)))
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              myData['profile_img'] != null && myData.isNotEmpty ?
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                                backgroundImage: CachedNetworkImageProvider(
                                  myData['profile_img']
                                ),
                              ) : CircleAvatar(
                                backgroundColor:const Color.fromARGB(255, 41, 40, 40),
                                radius: 30,
                                child: Text(
                                  '${myData.isNotEmpty ? myData['first_name'][0] : ''}',
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white
                                  ),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(
                            height: 12,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(myData.isNotEmpty ? '${myData['first_name']} ${myData['last_name']}' : '', style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    myData.isNotEmpty ? myData['username'] : '', style: const TextStyle(
                                      color: Color.fromARGB(255, 195, 192, 192),
                                      fontWeight: FontWeight.w500
                                    ),
                                  )
                                ], 
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 30,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
          
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    color: const Color.fromRGBO(28, 29, 34, 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (builder) => ContactsPage(
                                strUrl: strUrl.substring(0, strUrl.length-1),
                                status: status,
                                streamer: streamer
                              )));
                            },
                            child: Container(
                              color: const Color.fromRGBO(28, 29, 34, 1),
                              padding: const EdgeInsets.only(top: 20, bottom: 12),
                                child: const SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.contacts,
                                        color: Color.fromARGB(255, 195, 192, 192),
                                        size: 22,
                                      ),
                                  
                                      SizedBox(
                                        width: 13,
                                      ),
                                  
                                      Text(
                                        'Contacts',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (builder) => const ProfileSettings()));
                            },
                            child: Container(
                              color: const Color.fromRGBO(28, 29, 34, 1),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: const SizedBox(
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: Color.fromARGB(255, 195, 192, 192),
                                      size: 22,
                                    ),
                                
                                    SizedBox(
                                      width: 13,
                                    ),
                                
                                    Text(
                                      'Settings',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Container(
                            width: double.infinity,
                            height: 1,
                            color: const Color.fromARGB(255, 14, 13, 13),
                          ),

                          GestureDetector(
                            onTap: () async {
                              bool data = await Auth().removeToken();
                              if (data) {
                                setState(() {
                                  status.sink.close();
                                  Navigator.of(context).popUntil((route) => route.isFirst); 
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LogInPage()));
                                });                               
                              }
                            },

                            child: Container(
                              color: const Color.fromRGBO(28, 29, 34, 1),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                                child: const SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color: Color.fromARGB(255, 195, 192, 192),
                                        size: 22,
                                      ),
                                  
                                      SizedBox(
                                        width: 13,
                                      ),
                                  
                                      Text(
                                        'Log Out',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  )
                )
              ],
            ),
        ),
      ),

      body: Column(
          children: [
            const SizedBox(height: 10),
  
            Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  cursorColor: Colors.white,
                  style: const TextStyle(
                    color: Colors.white
                  ),
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color.fromRGBO(38, 39, 44, 1))),
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(13)), borderSide: BorderSide(color: Color.fromRGBO(38, 39, 44, 1))),
                    filled: true,
                    fillColor: const Color.fromRGBO(38, 39, 44, 1),
                    hintText: 'Search',
                    hintStyle: const TextStyle(color: Colors.white),
                    suffixIcon: const ImageIcon(AssetImage('assets/icons/search-2-line.png')),
                    suffixIconColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15)
                  ),
              ),  
            ),
        
            Container(
              height: 10,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color.fromRGBO(55, 56, 58, 1)))
              ),
            ),
        
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color.fromRGBO(55, 56, 58, 1)))
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              height: 83,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                       Navigator.push(context, MaterialPageRoute(builder: (builder) => const StoriesPage()));
                    },
                    child: const CircleAvatar(
                      radius: 37,           
                      backgroundImage: AssetImage('assets/download.jpeg'),
                    ),
                  );
                } 
              ),
            ),
        
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                child: ListView.builder(
                  itemCount: chattingRooms.length,
                  itemBuilder: (context, index) {
                    return ChattingContactsPeople(
                      onTap: () {setState(() {
                          active = index;
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ChattingPage(
                            fullName: chattingRooms[index]['users'][0]['first_name'] + ' ' + chattingRooms[index]['users'][0]['last_name'],
                            myId: myData['id'],
                            // ignore: prefer_interpolation_to_compose_strings
                            avatarImg: chattingRooms[index]['users'][0]['profile_img'] != '' ? '${Rooms().getStrUrl()}media/' + chattingRooms[index]['users'][0]['profile_img'] : '',
                            roomId: chattingRooms[index]['id'],
                            roomName: chattingRooms[index]['room_name'],
                            needUpdate: false,
                          )));
                      });},
                      active: active,
                      color: active == index ? const Color.fromARGB(19, 16, 18, 1) :const Color.fromARGB(28, 29, 34, 1),
                      data: chattingRooms[index],
                      index: index,
                      strUrl: strUrl,
                      statuses: statuses,
                      onLongPress: () {
                        setState(() {
                          active = index;
                        });
                      },
                    );
                  }
                ),
              )
            )
          ],
        )
    );
  }
}
