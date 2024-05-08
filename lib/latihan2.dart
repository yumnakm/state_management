import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

void main() {
  runApp(MyApp());
}

class UniversityCubit extends Cubit<List<University>> {
  UniversityCubit() : super([]);

  Future<void> fetchData(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<University> universities = data
          .map((universityJson) => University.fromJson(universityJson))
          .toList();
      emit(universities);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University List',
      home: Scaffold(
        appBar: AppBar(
          title: Text('ASEAN Universities'),
        ),
        body: MultiBlocProvider(
          providers: [
            BlocProvider<UniversityCubit>(
              create: (_) => UniversityCubit(),
            ),
          ],
          child: UniversityPage(),
        ),
      ),
    );
  }
}

class UniversityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityCubit = context.read<UniversityCubit>();

    return Column(
      children: [
        SizedBox(height: 10),
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
              universityCubit.fetchData(newValue);
            }
          },
        ),
        SizedBox(height: 10),
        Expanded(
          child: BlocBuilder<UniversityCubit, List<University>>(
            builder: (context, universities) {
              if (universities.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                  itemCount: universities.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          universities[index].name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(universities[index].website),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
