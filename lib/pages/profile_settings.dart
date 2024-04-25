import 'dart:convert';
import 'package:chat_project/pages/home_page.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_project/datas/data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSettings extends StatefulWidget {
  final status;
  const ProfileSettings({
    super.key,
    required this.status
  });

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  Map<String, dynamic> myData = {};
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  Row _actions = Row();
  Row _lastNameActions = Row();
  Row _bioActions = Row();
  bool _firstNameIsRead = true;
  bool _lastNameIsRead = true;
  bool _bioIsRead = true;
  bool updated = false;

  getData() async {
    var dt = await Auth().getMyData();
    setState(() {
      myData = dt;
      print(myData['profile_img']);
      _firstNameController.text = myData['first_name'];
      _lastNameController.text = myData['last_name'];
      _usernameController.text = '@' + myData['username'];
      _bioController.text = myData['bio'];
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
        leading: updated ? TextButton(onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst); 
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ChattingContacts()));
        }, child: const Icon(Icons.arrow_back_ios)) : const BackButton(
          color: Colors.white,
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white
          ),
        ),
      ),
      body: Container(
        color: const Color.fromRGBO(20, 20, 22, 1),
        child: GestureDetector(
          onVerticalDragDown: (details) {
          },
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                  color: const Color.fromRGBO(28, 29, 31, 1),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18, top: 3, bottom: 15),
                    child: Row(
                      children: [
                        if (myData['profile_img'] != null && myData != {}) CircleAvatar(
                          radius: 31,
                          backgroundImage: CachedNetworkImageProvider('${myData['profile_img']}'),
                        ) else CircleAvatar(
                          radius: 31,
                          backgroundColor: const Color.fromARGB(255, 37, 36, 36),
                          child: Text(
                            myData != {} && myData.isNotEmpty ? myData['first_name'][0] : "", 
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            )
                          ),
                        ),
                                        
                        const SizedBox(
                          width: 13,
                        ),
                                        
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              myData != {} ?
                              '${myData['first_name']} ${myData['last_name']}'
                              : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600
                              ),
                            ),
                            const Text(
                              'online',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    ),
                  ),
                  
                  Positioned(
                    right: 20,
                    bottom: -30,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ) 
                  )
                ],
              ),

              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Account',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 17,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                
                      SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                onTap: () {
                                  setState(() {
                                    _actions = Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _firstNameController.text = myData['first_name'];
                                            setState(() {
                                              _firstNameIsRead = true;
                                              _actions = const Row();
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            height: 35,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                            ),
                                            child: const Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.white,
                                            ),
                                          )
                                        ),

                                        const SizedBox(
                                          width: 2,
                                        ),

                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              myData['first_name'] = _firstNameController.text;
                                          
                                            });
                                            String update = jsonEncode({
                                              'update': true,
                                              'field': 'first_name',
                                              'value': _firstNameController.text
                                            });

                                            widget.status.sink.add(update);
                                            setState(() {
                                              updated = true;
                                              _firstNameIsRead = true;
                                              _actions = Row();
                                            });
                                          },
                                          child: Container(
                                            height: 35,
                                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
                                            decoration: const BoxDecoration(
                                              color:Color.fromARGB(255, 27, 104, 167),
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))
                                            ),
                                            child: const Text(
                                              'Save',
                                              style: TextStyle(
                                                color: Colors.white 
                                              ),
                                            ),
                                          )
                                        )
                                      ],
                                    );
                                    _firstNameIsRead = false;
                                  });
                                },
                                decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: const Color.fromRGBO(28, 29, 31, 1))),
                                  border: InputBorder.none
                                ),
                                readOnly: _firstNameIsRead,
                                controller: _firstNameController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18
                                ),
                              ),
                            ),
                            _actions
                          ],
                        ),
                      ),
                
                      const Text(
                        'Tap to change first name',
                        style: TextStyle(
                          color: Colors.grey
                        ),
                      ),
                      
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),
                
                      const SizedBox(
                        height: 5,
                      ),
                
                      SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                onTap: () {
                                  setState(() {
                                    _lastNameActions = Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _lastNameController.text = myData['last_name'];
                                            setState(() {
                                              _lastNameIsRead = true;
                                              _lastNameActions = const Row();
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            height: 35,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                            ),
                                            child: const Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.white,
                                            ),
                                          )
                                        ),

                                        const SizedBox(
                                          width: 2,
                                        ),

                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              myData['last_name'] = _lastNameController.text;
                                            });
                                            String update = jsonEncode({
                                              'update': true,
                                              'field': 'last_name',
                                              'value': _lastNameController.text
                                            });

                                            widget.status.sink.add(update);
                                            setState(() {
                                              updated = true;
                                              _lastNameActions = Row();
                                              _lastNameIsRead = true;
                                            });
                                          },
                                          child: Container(
                                            height: 35,
                                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
                                            decoration: const BoxDecoration(
                                              color:Color.fromARGB(255, 27, 104, 167),
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))
                                            ),
                                            child: const Text(
                                              'Save',
                                              style: TextStyle(
                                                color: Colors.white 
                                              ),
                                            ),
                                          )
                                        )
                                      ],
                                    );
                                    _lastNameIsRead = false;
                                  });
                                },
                                decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 37, 36, 36))),
                                  border: InputBorder.none
                                ),
                                readOnly: _lastNameIsRead,
                                controller: _lastNameController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18
                                ),
                              ),
                            ),
                            _lastNameActions
                          ],
                        ),
                      ),
                
                      const Text(
                        'Tap to change last name',
                        style: TextStyle(
                          color: Colors.grey
                        ),
                      ),
                      
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),

                      TextField(
                        decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 37, 36, 36))),
                          border: InputBorder.none
                        ),
                        readOnly: true,
                        controller: _usernameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18
                        ),
                      ),

                      const Text(
                        'Username',
                        style: TextStyle(
                          color: Colors.grey
                        ),
                      ),
                      
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 1,
                        width: double.infinity,
                        color: Colors.grey,
                      ),

                      SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: TextField(
                                onTap: () {
                                  setState(() {
                                    _bioActions = Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _bioController.text = myData['last_name'];
                                            setState(() {
                                              _bioIsRead = true;
                                              _bioActions = const Row();
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 5),
                                            height: 35,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                            ),
                                            child: const Icon(
                                              Icons.cancel_outlined,
                                              color: Colors.white,
                                            ),
                                          )
                                        ),

                                        const SizedBox(
                                          width: 2,
                                        ),

                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              myData['bio'] = _bioController.text;
                                            });
                                            String update = jsonEncode({
                                              'update': true,
                                              'field': 'bio',
                                              'value': _bioController.text
                                            });

                                            widget.status.sink.add(update);
                                            setState(() {
                                              updated = true;
                                              _bioActions = Row();
                                              _bioIsRead = true;
                                            });
                                          },
                                          child: Container(
                                            height: 35,
                                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 5),
                                            decoration: const BoxDecoration(
                                              color:Color.fromARGB(255, 27, 104, 167),
                                              borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))
                                            ),
                                            child: const Text(
                                              'Save',
                                              style: TextStyle(
                                                color: Colors.white 
                                              ),
                                            ),
                                          )
                                        )
                                      ],
                                    );
                                    _bioIsRead = false;
                                  });
                                },
                                decoration: const InputDecoration(
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 37, 36, 36))),
                                  border: InputBorder.none
                                ),
                                readOnly: _bioIsRead,
                                controller: _bioController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18
                                ),
                              ),
                            ),
                            _bioActions
                          ],
                        ),
                      ),
                      const Text(
                        'Username',
                        style: TextStyle(
                          color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}