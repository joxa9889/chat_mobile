import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChattingContactsPeople extends StatefulWidget {
  final Function onTap;
  final int? active;
  final Function onLongPress;
  final Color color;
  final Map<String, dynamic> data;
  final strUrl;
  final statuses;
  final int index;
  
  const ChattingContactsPeople({
    super.key,
    required this.onTap,
    required this.active,
    required this.onLongPress,
    required this.color,
    required this.data,
    required this.strUrl,
    required this.statuses,
    required this.index,
  });

  @override
  State<ChattingContactsPeople> createState() => _ChattingContactsPeopleState();
}

class _ChattingContactsPeopleState extends State<ChattingContactsPeople> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
        
      onLongPress: () {
        widget.onLongPress();
      },
                      
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: 80,
        color: widget.color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 13),
                  child: Stack(
                    children: [
                      if (widget.data['users'][0]['profile_img'] != '') CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                        // ignore: prefer_interpolation_to_compose_strings
                        backgroundImage: CachedNetworkImageProvider('${widget.strUrl}media/' + widget.data['users'][0]['profile_img']),
                      ) else CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color.fromARGB(255, 41, 40, 40),
                        child: Text(
                          '${widget.data['users'][0]['first_name'][0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                          ),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            color: widget.statuses[widget.index]['last_active'] == null ? Colors.green : Colors.grey,
                          ),
                        )
                      ),
                    ],
                  ),
                ),
                                    
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.data['users'][0]['first_name'] + ' ' + widget.data['users'][0]['last_name'] }', 
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      
                    ),
            
                    Text(
                      '${widget.data['last_message'] ?? ''}',
                      style: const TextStyle(
                        color: Color.fromRGBO(161, 161, 162, 1),
                        fontSize: 15
                      ),
                    )
                  ],
                ),
              ],
            ),
                                    
            const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                Text(
                  '11:12',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15
                  ),
                ),
                Text('')
              ],
            )
          ],
        ),
      ),
    );
  }
}