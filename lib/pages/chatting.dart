import 'dart:convert';
import 'dart:io';
import 'package:chat_project/pages/home_page.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_project/datas/data.dart';
import 'package:web_socket_channel/io.dart';
import 'package:text_scroll/text_scroll.dart';
import 'package:cached_network_image/cached_network_image.dart';


class ChattingPage extends StatefulWidget {
  final String fullName;
  final String avatarImg;
  final String roomName;
  final int roomId;
  final int myId;
  final bool needUpdate;

  const ChattingPage({
    super.key,
    required this.fullName,
    required this.avatarImg,
    required this.roomId,
    required this.roomName,
    required this.myId,
    required this.needUpdate
  });


  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage> {

  // Variables used for front 

  String strUrl = Rooms().getStrUrl();

  String simplePath = Rooms().justPath();

  IconData _voice = Icons.mic;

  final TextEditingController _textEditingController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final _focusNode = FocusNode();

  List<Map<String, dynamic>> messages = [];

  int? replyMessageId;

  late IOWebSocketChannel chat;

  File ? _selectedImg;

  BuildContext? _modalContext;

  bool reply = false;

  Container _replyActivation = Container();

  List<GlobalKey> keys = [];

  bool showEmoji = false;

  bool isRecordingInit = false;

  bool isRecording = false;

  FlutterSoundRecorder? soundRecorder; 


  void replyModeOn(replyingMsg) {
    setState(() {
      reply = true;
      replyMessageId = replyingMsg;
      _replyActivation = Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                height: 55,
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply_rounded,
                      color: Colors.white,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    messages[replyingMsg]['is_image'] ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        child: CachedNetworkImage(
                          imageUrl: messages[replyingMsg]['url']
                        ),
                      ),
                    ) : Container(),

                    messages[replyingMsg]['is_image'] ? const SizedBox(
                      width: 10,
                    ) : const SizedBox(
                      width: 0,
                    ),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reply to ${messages[replyingMsg]['full_name']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              overflow: TextOverflow.ellipsis
                            ),
                          ),
                          
                          Text(
                            !messages[replyingMsg]['is_image'] ? '${messages[replyingMsg]['message']}' : 'Photo',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 200, 197, 197),
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _replyActivation = Container();
                          reply = false;
                          replyMessageId = null;
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        color: Color.fromARGB(255, 200, 197, 197),
                      ),
                    )
                  ],
                ),
              );
    });
  }


  Transform _transformRotate = Transform.rotate(
    angle: 170.4,
    child: const Icon(
      Icons.attach_file,
      color: Colors.white,
    ),
  );


  // Works First
  @override
  void initState() {
    super.initState();

    chat = IOWebSocketChannel.connect('ws://$simplePath/ws/chat/${widget.roomName}/');

    soundRecorder = FlutterSoundRecorder();

    openAudio();

    // Loads All Messages from DB
    _loadMessages();


    // Listend does message changed or not
    chat.stream.listen((message) {
      setState(() {
        var mess = jsonDecode(message);
        if (mess['is_image']) {
          mess['url'] = strUrl.substring(0, strUrl.length-1) + mess['url'];
        }
        messages.insert(0, mess);

        // Crolls till the end
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }); 
    });
  }



  // It closes connection when i quit from this page
  @override void dispose() {
    chat.sink.close();
    super.dispose();
    soundRecorder!.closeRecorder();
    isRecordingInit = false;
  }


  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await soundRecorder!.openRecorder();
    isRecordingInit = true;
  }


  // It sends message
  void sendMessage() {
    var dataToSend = {
      "message": _textEditingController.text,
      "room_id": widget.roomId,
      "user": widget.myId,
      "url": null,
      "is_image": false,
      'reply_to': null,
    };
    String data = json.encode(dataToSend);
    chat.sink.add(data);
    _textEditingController.clear();

    Future.delayed(const Duration(milliseconds: 100), () {  //
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  void _replyMessage(messageToReply) {
    var dataToSend = {
      "message": _textEditingController.text,
      "room_id": widget.roomId,
      "user": widget.myId,
      "url": null,
      "is_image": false,
      "reply_to": messages[messageToReply]['id'],
    };

    String data = json.encode(dataToSend);
    chat.sink.add(data);
    _textEditingController.clear();

    _replyActivation = Container();
    reply = false;

    Future.delayed(const Duration(milliseconds: 100), () {  //
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });
  }

  // This is log which shows to choose img :) and etc... 
  _showLogForAttachment() {
    showModalBottomSheet(
      elevation: 2,
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      context: context,
      builder: (builder) {
        _modalContext = context;
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height/2.2,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  
                )
              ),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _pickImageFromGallery();
                    },
                    icon: const Icon(
                      Icons.photo_size_select_actual_rounded,
                      color: Colors.white,
                      size: 50,
                    )
                  )
                ],
              ),
              const SizedBox(height: 10,),

              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _pickImageFromCamera();
                    },
                    icon: const Icon(
                      Icons.camera_enhance,
                      color: Colors.white,
                      size: 50,
                    )
                  )
                ],
              ),
            ],
          ),
        );
      }
    );
  }



  _loadMessages() async {
    final List<dynamic> dynamicMessages = await Message().getMessages(widget.roomId);
    
    final List<Map<String, dynamic>> messagesList = dynamicMessages.cast<Map<String, dynamic>>();

    setState(() {
      messages = messagesList.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(28, 29, 34, 1),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: Color.fromRGBO(38, 39, 44, 1))),
        backgroundColor: const Color.fromRGBO(28, 29, 31, 1),
        leadingWidth: 35,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: BackButton(
            color: Colors.white,
            onPressed: () {
              if (widget.needUpdate) {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (builder) => const ChattingContacts()));
              }
              Navigator.pop(context);
            },
          ),
        ),
        centerTitle: false,
        
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                // Handle onTap
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: widget.avatarImg != '' ? CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                  foregroundImage: CachedNetworkImageProvider(
                    widget.avatarImg,
                  ),
                ) : CircleAvatar(
                  backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                  child: Text(
                    widget.fullName[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 1),
                  TextScroll(
                    widget.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    velocity: const Velocity(pixelsPerSecond: Offset(35, 0)),
                  ),
                  const Text(
                    'last seen 12:11',
                    style: TextStyle(
                      color: Color.fromARGB(255, 200, 197, 197),
                      fontSize: 13,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),

        
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10), 
                  child: const Icon(Icons.search_rounded, color: Colors.white,),               
                ),
                const Icon(Icons.more_vert_outlined, color: Colors.white)
              ],
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  color: const Color.fromRGBO(20, 20, 22, 1),
                  child: ListView.custom(
                    reverse: true,
                    controller: _scrollController,
                    childrenDelegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        final message = messages[index];
                        messages.firstWhere((element) => element['id'] == message['reply_to'], orElse: () => {});
                        if (message['user'] == widget.myId) {
                          if (message['is_image']) {
                            return SwipeTo(
                              iconOnLeftSwipe: Icons.reply,
                              iconColor: Colors.white,
                              onLeftSwipe: (details) {
                                replyModeOn(index);
                              },
                              onRightSwipe: (details) {
                                replyModeOn(index);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                                alignment: Alignment.topRight,
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: CachedNetworkImage(
                                  imageUrl: '${message['url']}',
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width / 2.5,
                                  placeholder: (context, url) => LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SizedBox(
                                        width: MediaQuery.of(context).size.width / 2.5,
                                        height: constraints.maxWidth,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return messages[index]['reply_to'] != null ?
                              SwipeTo(
                              iconOnLeftSwipe: Icons.reply,
                              iconColor: Colors.white,
                              onLeftSwipe: (details) {
                                replyModeOn(index);
                              },
                              onRightSwipe: (details) {
                                replyModeOn(index);
                              },
                              child: 
                                GestureDetector(
                                  onTap: () {
                                    scrollToMessage(index);
                                  },
                                  child: Container(
                                    margin: const  EdgeInsets.only(top: 2.5, bottom: 2.5),
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 0, maxWidth: MediaQuery.of(context).size.width/1.65),
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(3)),
                                        color: Color.fromRGBO(189, 210, 182, 1),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: const BoxDecoration(
                                              color:  Color.fromRGBO(169, 203, 157, 1),
                                              border: Border(left: BorderSide(width: 5, color: Colors.white)),
                                              borderRadius: BorderRadius.all(Radius.circular(7))
                                            ),
                                            padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${messages.firstWhere((element) => element['id'] == message['reply_to'])['full_name']}',
                                                  style: const TextStyle(
                                                    overflow: TextOverflow.ellipsis,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                
                                                Text(
                                                  '${messages.firstWhere((element) => element['id'] == message['reply_to'])['message']}',
                                                  style: const TextStyle(
                                                    overflow: TextOverflow.ellipsis
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  
                                          Container(
                                            padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10, top: 7),
                                            child: Text(
                                              style: const TextStyle(
                                                color: Color.fromARGB(255, 30, 34, 0)
                                              ),
                                              '${message['message']}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              )
                            : SwipeTo(
                              iconOnLeftSwipe: Icons.reply,
                              iconColor: Colors.white,
                              onLeftSwipe: (details) {
                                replyModeOn(index);
                              },
                              onRightSwipe: (details) {
                                replyModeOn(index);
                              },
                              child: Container(
                                  margin: const  EdgeInsets.only(top: 2.5, bottom: 2.5),
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 0, maxWidth: MediaQuery.of(context).size.width/1.65),
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(3)),
                                      color: Color.fromRGBO(189, 210, 182, 1),
                                    ),
                                    child: Text(
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 30, 34, 0)
                                      ),
                                      '${message['message']}',
                                    ),
                                  ),
                                )
                              );
                          }
                        } else {
                          if (message['is_image']) {
                            return SwipeTo(
                              iconOnRightSwipe: Icons.reply,
                              iconColor: Colors.white,
                              onLeftSwipe: (details) {
                                replyModeOn(index);
                              },
                              onRightSwipe: (details) {
                                replyModeOn(index);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                                alignment: Alignment.topLeft,
                                width: MediaQuery.of(context).size.width / 2.5,
                                child: CachedNetworkImage(
                                  imageUrl: '${message['url']}',
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width / 2.5,
                                  placeholder: (context, url) => LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SizedBox(
                                        width: MediaQuery.of(context).size.width / 2.5,
                                        height: constraints.maxWidth-100,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return messages[index]['reply_to'] != null ? SwipeTo(
                              iconOnRightSwipe: Icons.reply,
                              iconColor: Colors.white,
                              onLeftSwipe: (details) {
                                replyModeOn(index);
                              },
                              onRightSwipe: (details) {
                                replyModeOn(index);
                              },
                              swipeSensitivity: 15,
                              child: GestureDetector(
                                onTap: () {
                                  scrollToMessage(index);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 0, maxWidth: MediaQuery.of(context).size.width/1.70),
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(38, 39, 45, 1),
                                      borderRadius: BorderRadius.all(Radius.circular(3))
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          decoration: const BoxDecoration(
                                            color:  Color.fromRGBO(57, 58, 57, 1),
                                            border: Border(left: BorderSide(width: 5, color: Color.fromRGBO(163, 200, 156, 1))),
                                            borderRadius: BorderRadius.all(Radius.circular(7))
                                          ),
                                          padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${messages.firstWhere((element) => element['id'] == message['reply_to'])['full_name']}',
                                                style: const TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                  color: Color.fromRGBO(163, 200, 156, 1),
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                              
                                              Text(
                                                '${messages.firstWhere((element) => element['id'] == message['reply_to'])['message']}',
                                                style: const TextStyle(
                                                  overflow: TextOverflow.ellipsis,
                                                  color: Colors.white
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(right: 10, left: 10, bottom: 10, top: 7),
                                          child: Text(
                                            style: const TextStyle(
                                              color: Colors.white
                                            ),
                                            '${message['message']}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ) 
                            : 
                            SwipeTo(
                              iconOnRightSwipe: Icons.reply,
                              iconColor: Colors.white,
                              onLeftSwipe: (details) {
                                replyModeOn(index);
                              },
                              onRightSwipe: (details) {
                                replyModeOn(index);
                              },
                              swipeSensitivity: 10,
                              child: Container(
                                margin: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                                alignment: Alignment.topLeft,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 0, maxWidth: MediaQuery.of(context).size.width/1.70),
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(38, 39, 45, 1),
                                    borderRadius: BorderRadius.all(Radius.circular(3))
                                  ),
                                  child: Text(
                                    style: const TextStyle(
                                      color: Colors.white
                                    ),
                                    '${message['message']}',
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      },
                      childCount: messages.length,
                    ),
                  ),
                ),
              ),

              _replyActivation,

              Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color.fromRGBO(56, 57, 59, 1))),
                    ),
                    padding: const EdgeInsets.only(right: 10, left: 10, top: 8, bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (showEmoji){
                                showEmoji = false;
                                _focusNode.requestFocus();
                              } else {
                                showEmoji = true;
                                _focusNode.requestFocus();
                              }
                            });
                          },
                          icon: const Icon(
                            Icons.emoji_emotions_outlined,
                            color: Colors.white,
                          ),
                        ),
                  
                        Expanded(
                          child: TextField(
                            onTap: () {
                              if (showEmoji) {
                                setState(() {
                                  showEmoji = false;
                                });
                              }
                            },
                            focusNode: _focusNode,
                            autofocus: true,
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  _transformRotate = Transform.rotate(angle: 0);
                                  _voice = Icons.send;
                                });
                              } else {
                                setState(() {
                                  _transformRotate = Transform.rotate(
                                    angle: 170.4,
                                    child: const Icon(
                                      Icons.attach_file,
                                      color: Colors.white,
                                    ),
                                  );
                                _voice = Icons.mic;
                                });
                              }
                            },
                            controller: _textEditingController,
                            cursorColor: Colors.white,
                            style: const TextStyle(
                              color: Colors.white
                            ),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color.fromRGBO(38, 39, 45, 1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              hintStyle: TextStyle(
                                color: Colors.white
                              ),
                              hintText: 'Message',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10)
                            ),
                          ),
                        ),
                  
                        const SizedBox(width: 10),
                  
                        GestureDetector(
                          onTap: () {
                            _showLogForAttachment();
                          },
                          child: _transformRotate,
                        ),
                  
                  
                        const SizedBox(width: 5),
                  
                        GestureDetector(
                          onTap: () async {
                            if (_textEditingController.text != '') {
                              setState(() {
                                if (reply) {
                                  _replyMessage(replyMessageId);
                                } else {
                                  sendMessage();
                                }
                              });
                            } else {
                              var dir = await getTemporaryDirectory();
                              var path = '${dir.path}/flutter_sound.aac';
                              if (isRecording) {
                                await soundRecorder!.stopRecorder();
                                sendAudioMessage(path);
                              } else {
                                await soundRecorder!.startRecorder(
                                  toFile: path 
                                );
                              }
                              setState(() {
                                isRecording = !isRecording;
                              });
                            }
                  
                            _transformRotate = Transform.rotate(
                              angle: 170.4,
                              child: const Icon(
                                Icons.attach_file,
                                color: Colors.white,
                              ),
                            );
                            _voice = Icons.mic;
                          },
                          
                          child: Icon(
                            _voice,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  showEmoji ?
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 3.5,
                      // child: EmojiPicker(
                      //   onEmojiSelected: (category, emoji) {
                      //     _textEditingController.text += emoji.emoji;
                      //   },
                      // ),
                    ) : const SizedBox(),
                ],
              ),
            ],
          ),
        ),
    );
  }


  void sendAudioMessage (path) {

    // Read audio file as bytes
    List<int> bytes = File(path).readAsBytesSync();
    // Send audio data over WebSocket
    var dt = {
      "audio": bytes,
      "name": path.toString().split('/').last,
    };
    var x = json.encode(dt);
    chat.sink.add(x);

  }


  void scrollToMessage(int index) {
    _scrollController.animateTo(
      index * 100.0, // Adjust as neededx
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future _pickImageFromGallery() async {
    var returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (returnedImage != null) {
          _selectedImg = File(returnedImage.path);
          List<int> imageBytes = _selectedImg!.readAsBytesSync();
          String base64Image = base64Encode(imageBytes);
          var dataToSend = {
            "message": _textEditingController.text,
            "room_id": widget.roomId,
            "user": widget.myId,
            
            "url": {
              'url': base64Image,
              'name': returnedImage.path.split('/').last,
            },
            "is_image": true,
            'reply_to': null,
          };
          
          String data = json.encode(dataToSend);
          chat.sink.add(data);
          _textEditingController.clear();
          Navigator.pop(_modalContext!);
          _modalContext = null;
        }
    });
  }


  Future _pickImageFromCamera() async {
    var returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      if (returnedImage != null) {
          _selectedImg = File(returnedImage.path);
          List<int> imageBytes = _selectedImg!.readAsBytesSync();
          String base64Image = base64Encode(imageBytes);
          var dataToSend = {
            "message": _textEditingController.text,
            "room_id": widget.roomId,
            "user": widget.myId,
            
            "url": {
              'url': base64Image,
              'name': returnedImage.path.split('/').last,
            },
            "is_image": true,
            'reply_to': null,
          };
          
          String data = json.encode(dataToSend);
          chat.sink.add(data);
          _textEditingController.clear();
          Navigator.pop(_modalContext!);
          _modalContext = null;
        }
    });
  }
}

