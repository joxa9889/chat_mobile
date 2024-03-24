import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_project/datas/data.dart';
import 'package:flutter/material.dart';

class ProfileSettings extends StatefulWidget {
  const ProfileSettings({super.key});

  @override
  State<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends State<ProfileSettings> {

  Map<String, dynamic> myData = {};
  final TextEditingController _firstNameController = TextEditingController();

  getData() async {
    var dt = await Auth().getMyData();
    setState(() {
      myData = dt;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
    _firstNameController.text = 'Javohir';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
        leading: const BackButton(
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

              Container(
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

                    TextField(
                      decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                        border: InputBorder.none
                      ),
                      readOnly: true,
                      controller: _firstNameController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}