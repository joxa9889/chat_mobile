import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_project/datas/data.dart';
import 'package:chat_project/pages/chatting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';

class ContactsPage extends StatefulWidget {
  final strUrl;
  final IOWebSocketChannel status;
  final Stream streamer;

  const ContactsPage({
    super.key,
    required this.strUrl,
    required this.status,
    required this.streamer
  });

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {

  BuildContext? _modalContext;
  final _formKey = GlobalKey<FormState>();
  String? errorUsername;
  Map<String, dynamic> myData = {};
  List<dynamic> contacts = [];
  List<dynamic> contact_statuses = [];
  String? showTime;


  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();




  _showLog () {
    showModalBottomSheet(
      elevation: 2,
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      context: context,
      builder: (builder) {
        _modalContext = context;
        return SizedBox(
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
        );
      }
    );
  }

  getData() async {
    var dt = await Auth().getMyData();
    var gottenContacts = await Contacts().getMyContacts();
    setState(() {
      myData = dt;
      contacts = gottenContacts;
    });
  }

  getStatuses() {
    widget.status.sink.add(jsonEncode({
      'contacts': true,
    }));
  }

  dtToChange(index, data) {
    setState(() {
      contact_statuses[index] = data;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    getStatuses();
    widget.streamer.listen((event) {
      Map<String, dynamic> data = jsonDecode(event);
      if (data.containsKey('update')) {
        data.remove('update');
        int index = contact_statuses.indexWhere((user) => user['username'] == data['username']);
        print(index);
        dtToChange(index, data);
        print(contact_statuses);
      } else {
        setState(() {
          contact_statuses = jsonDecode(event)['contacts'];          
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 44, 43, 43),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: BackButton(
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ],
            ), 
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showLog();
        },
        shape: const CircleBorder(),
        backgroundColor: const Color.fromARGB(255, 43, 42, 42),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: Container(
        color: const Color.fromRGBO(20, 20, 22, 1),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  if (contact_statuses[index]['last_active'] != null) {
                    DateTime today = DateTime.now();
                    DateTime dateTime = DateFormat('MM/dd/yyyy, HH:mm:ss').parse(contact_statuses[index]['last_active']);
                    showTime = DateFormat('MM/dd/yyyy, HH:mm').format(dateTime);
                    if (DateFormat('MM/dd/yyyy').format(dateTime) == DateFormat('MM/dd/yyyy').format(today)) {
                      showTime = DateFormat('HH:mm').format(dateTime);
                    }
                  } 
                  return Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(
                        color: Color.fromARGB(255, 73, 72, 72)
                      ))
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                    child: Row(
                      children: [

                        if (contacts[index]['profile_img'] != null) CircleAvatar(
                          radius: 23,
                          backgroundImage: CachedNetworkImageProvider('${widget.strUrl}${contacts[index]['profile_img']}'),
                        ) else CircleAvatar(
                          radius: 23,
                          backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                          child: Text(
                            '${contacts[index]['first_name'][0]}',
                            style: const TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ),
                      
                        
                        const SizedBox(width: 10,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${contacts[index]['first_name']} ${contacts[index]['last_name']}', 
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17
                              ),
                            ),
                            Text('${contact_statuses[index]['last_active'] == null ? 'online' : showTime}',
                              style: TextStyle(
                                color: contact_statuses[index]['last_active'] == null ? Colors.blue : Colors.grey,
                                fontSize: 14
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }
              ),
            )
          ],
        ),
      ),
    );
  }
}