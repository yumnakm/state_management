import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider<UniversityModel>(
      create: (context) => UniversityModel(),
      child: const MyApp(),
    ),
  );
}

class University {
  late String name;
  late String website;

  University({required this.name, required this.website});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

class UniversityModel extends ChangeNotifier {
  Future<List<University>>? futureUniversities;

  String url = "http://universities.hipolabs.com/search?country=Indonesia";

  Future<void> fetchData(String country) async {
    url = "http://universities.hipolabs.com/search?country=$country";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<University> universities = data
          .map((universityJson) => University.fromJson(universityJson))
          .toList();
      futureUniversities = Future.value(universities);
      notifyListeners();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final universityModel = Provider.of<UniversityModel>(context);

    return MaterialApp(
      title: 'University List',
      home: Scaffold(
        appBar: AppBar(
          title: Text('ASEAN Universities'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                hint: Text('Select Country'),
                items: <String>[
                  'Indonesia',
                  'Malaysia',
                  'Singapore',
                  'Thailand',
                  'Philippines',
                  'Vietnam',
                  'Brunei',
                  'Cambodia',
                  'Laos',
                  'Myanmar',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    universityModel.fetchData(newValue);
                  }
                },
              ),
              SizedBox(height: 10),
              Expanded(
                child: FutureBuilder<List<University>>(
                  future:
                      universityModel.futureUniversities ?? Future.value([]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(
                                snapshot.data![index].name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(snapshot.data![index].website),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
