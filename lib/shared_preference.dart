import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> userId;

  Future<String> ambilDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString('userId') ?? "");
  }

  Future<void> simpanDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', "budiWati");
  }

  Future<void> hapusDataUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  @override
  void initState() {
    super.initState();
    userId = ambilDataUser(); 
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: FutureBuilder<String>(
                future: userId,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
             
                    if (snapshot.data == "") {
                      return (Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("user belum login"),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {                           
                                  simpanDataUser();
                                  userId = ambilDataUser();
                                }); 
                              },
                              child: const Text('Login'),
                            ),
                          ]));
                    } else {
                    
                      return (Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("userid: ${snapshot.data!}"),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  hapusDataUser();
                                  userId = ambilDataUser();
                                }); //refresh
                              },
                              child: const Text('Logout'),
                            ),
                          ]));
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                })),
      ),
    );
  }
}
