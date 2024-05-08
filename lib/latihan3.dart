import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

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

abstract class UniversityEvent {}

class FetchUniversitiesEvent extends UniversityEvent {
  final String country;
  FetchUniversitiesEvent(this.country);
}

class UniversityState {}

class UniversityLoadedState extends UniversityState {
  late List<University> universities;
  UniversityLoadedState(this.universities);
}

class UniversityErrorState extends UniversityState {}

class UniversityBloc extends Bloc<UniversityEvent, UniversityState> {
  UniversityBloc() : super(UniversityState());

  @override
  Stream<UniversityState> mapEventToState(UniversityEvent event) async* {
    if (event is FetchUniversitiesEvent) {
      yield* _mapFetchUniversitiesEventToState(event.country);
    }
  }

  Stream<UniversityState> _mapFetchUniversitiesEventToState(
      String country) async* {
    try {
      final universities = await fetchUniversities(country);
      yield UniversityLoadedState(universities);
    } catch (e) {
      yield UniversityErrorState();
    }
  }

  Future<List<University>> fetchUniversities(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<University> universities = data
          .map((universityJson) => University.fromJson(universityJson))
          .toList();
      return universities;
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
      home: BlocProvider(
        create: (_) => UniversityBloc(),
        child: UniversityListScreen(),
      ),
    );
  }
}

class UniversityListScreen extends StatefulWidget {
  @override
  _UniversityListScreenState createState() => _UniversityListScreenState();
}

class _UniversityListScreenState extends State<UniversityListScreen> {
  late String selectedCountry;
  late UniversityBloc universityBloc;

  @override
  void initState() {
    super.initState();
    selectedCountry = "Indonesia";
    universityBloc = BlocProvider.of<UniversityBloc>(context);
    universityBloc.add(FetchUniversitiesEvent(selectedCountry));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ASEAN Universities'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedCountry,
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
                setState(() {
                  selectedCountry = newValue;
                });
                universityBloc.add(FetchUniversitiesEvent(selectedCountry));
              }
            },
          ),
          Expanded(
            child: BlocBuilder<UniversityBloc, UniversityState>(
              builder: (context, state) {
                if (state is UniversityLoadedState) {
                  return ListView.builder(
                    itemCount: state.universities.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Text(
                            state.universities[index].name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(state.universities[index].website),
                        ),
                      );
                    },
                  );
                } else if (state is UniversityErrorState) {
                  return Center(
                    child: Text('Failed to load universities'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
