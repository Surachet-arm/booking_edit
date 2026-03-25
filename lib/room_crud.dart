import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'add_room_page.dart';
import 'edit_room_page.dart';
import 'booking_list.dart';
import 'home_page.dart';



//////////////////////////////////////////////////////////////
// ✅ CONFIG
//////////////////////////////////////////////////////////////

const String baseUrl =
    "http://127.0.0.1/booking_66701721-main/php_api/";

//////////////////////////////////////////////////////////////
// ✅ APP ROOT
//////////////////////////////////////////////////////////////



//////////////////////////////////////////////////////////////
// ✅ room LIST PAGE
//////////////////////////////////////////////////////////////

class RoomPage extends StatefulWidget {
  final String name;
  const RoomPage({super.key,required this.name});

  @override
  State<RoomPage> createState() => _roomListState();
}

class _roomListState extends State<RoomPage> {
  List rooms = [];
  List filteredrooms = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchrooms();
  }

  ////////////////////////////////////////////////////////////
  // ✅ FETCH DATA
  ////////////////////////////////////////////////////////////

  Future<void> fetchrooms() async {
    try {
      final response =
          await http.get(Uri.parse("${baseUrl}show_data.php"));

      if (response.statusCode == 200) {
        setState(() {
          rooms = json.decode(response.body);
          filteredrooms = rooms;
        });
      }
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ SEARCH
  ////////////////////////////////////////////////////////////

  void filterrooms(String query) {
    setState(() {
      filteredrooms = rooms.where((room) {
        final name = room['room_name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  ////////////////////////////////////////////////////////////
  // ✅ DELETE
  ////////////////////////////////////////////////////////////

  Future<void> deleteroom(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}delete_room.php?id=$id"),
      );

      final data = json.decode(response.body);

      if (data["success"] == true) {
        fetchrooms();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("ลบห้องเรียบร้อย")),
        );
      }
    } catch (e) {
      debugPrint("Delete Error: $e");
    }
  }

  ////////////////////////////////////////////////////////////
  // ✅ CONFIRM DELETE
  ////////////////////////////////////////////////////////////

  void confirmDelete(dynamic room) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("ยืนยันการลบ"),
        content: Text("ต้องการลบ ${room['room_name']} ?"),
        actions: [
          TextButton(
            child: const Text("ยกเลิก"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("ลบ"),
            onPressed: () {
              Navigator.pop(context);
              deleteroom(int.parse(room['id'].toString()));
            },
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  // ✅ OPEN EDIT PAGE
  ////////////////////////////////////////////////////////////

  void openEdit(dynamic room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditroomPage(room: room),
      ),
    ).then((value) => fetchrooms());
  }

  ////////////////////////////////////////////////////////////
  // ✅ UI
  ////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('room List'),
      
      actions: [
      Text(" ${widget.name}:"),
            const SizedBox(width:20), 




      IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
                (route) => false,
              );

            },
          ),

      

      IconButton(
        icon: const Icon(Icons.list_alt),
        tooltip: "ดูการจองทั้งหมด",
        onPressed: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const BookingList(),
            ),
          );

        },
      )

    ],
      
    
      
      ),
     
        
      body: Column(
        children: [
          //////////////////////////////////////////////////////
          // 🔍 SEARCH
          //////////////////////////////////////////////////////

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Search room',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterrooms,
            ),
          ),

          //////////////////////////////////////////////////////
          // 📦 LIST
          //////////////////////////////////////////////////////

          Expanded(
            child: filteredrooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                   padding: const EdgeInsets.only(bottom: 80), // ✅ สำคัญมาก
                    itemCount: filteredrooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredrooms[index];

                      String imageUrl =
                          "${baseUrl}images/${room['image']}";

                      return Card(
                        child: ListTile(

                          //////////////////////////////////////////////////
                          // 🖼 IMAGE
                          //////////////////////////////////////////////////

                          leading: SizedBox(
                            width: 70,
                            height: 70,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          ),

                          //////////////////////////////////////////////////
                          // 🏷 NAME
                          //////////////////////////////////////////////////

                          title: Text(room['room_name'] ?? ''),

                          //////////////////////////////////////////////////
                          // 📝 DESC
                          //////////////////////////////////////////////////

                          subtitle:
                              Text(room['location'] ?? ''),

                          //////////////////////////////////////////////////
                          // 💰 PRICE
                          //////////////////////////////////////////////////

                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                openEdit(room);
                              } else if (value == 'delete') {
                                confirmDelete(room);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('แก้ไข'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('ลบ'),
                              ),
                            ],
                          ),

                          //////////////////////////////////////////////////
                          // 👉 DETAIL
                          //////////////////////////////////////////////////

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    roomDetail(room: room),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      ////////////////////////////////////////////////////////
      // ➕ ADD BUTTON
      ////////////////////////////////////////////////////////

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddRoomPage(),
            ),
          ).then((value) => fetchrooms());
        },
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// ✅ room DETAIL PAGE
//////////////////////////////////////////////////////////////

class roomDetail extends StatelessWidget {
  final dynamic room;

  const roomDetail({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    String imageUrl =
        "${baseUrl}images/${room['image']}";

    return Scaffold(
      appBar: AppBar(
        title: Text(room['room_name'] ?? 'Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //////////////////////////////////////////////////////
            // 🖼 IMAGE
            //////////////////////////////////////////////////////

            Center(
              child: Image.network(
                imageUrl,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported, size: 100),
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////////
            // 🏷 NAME
            //////////////////////////////////////////////////////

            Text(
              room['room_name'] ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 📝 DESC
            //////////////////////////////////////////////////////

            Text(room['location'] ?? ''),

            const SizedBox(height: 10),

            //////////////////////////////////////////////////////
            // 💰 PRICE
            //////////////////////////////////////////////////////
            Text(
              'พิกัด: ${room['location']}',
              style: const TextStyle(fontSize: 10),
            ),

            Text(
              'รองรับจำนวน: ${room['capacity']}คน',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}