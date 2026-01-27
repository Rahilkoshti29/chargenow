import 'package:flutter/material.dart';
class MyVanPage extends StatefulWidget {
  const MyVanPage({super.key});

  @override
  State<MyVanPage> createState() => _MyVanPageState();
}

class _MyVanPageState extends State<MyVanPage> {
  bool isLoading = true;
  List vans = [];

  @override
  void initState() {
    super.initState();
    fetchVans();
  }

  Future<void> fetchVans() async {
    // TODO: Call API
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      vans = ["Van 1", "Van 2"];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFF7),
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "My Van",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: Center(child: Text("My Van content")),
    );
  }
}
