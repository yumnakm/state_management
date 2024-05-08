import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

abstract class DataEvent {}

class FetchDataEvent extends DataEvent {}

class DataSiapEvent extends DataEvent {
  late ActivityModel activity;
  DataSiapEvent(ActivityModel act) : activity = act;
}

class ActivityBloc extends Bloc<DataEvent, ActivityModel> {
  String url = "https://www.boredapi.com/api/activity";
  ActivityBloc() : super(ActivityModel(aktivitas: "", jenis: "")) {
    on<FetchDataEvent>((event, emit) {
      fetchData(); 
    });
    on<DataSiapEvent>((even, emit) {
      emit(even.activity); 
    });
  }

  void setFromJson(Map<String, dynamic> json) {
    String aktivitas = json['activity'];
    String jenis = json['type'];
    add(DataSiapEvent(ActivityModel(aktivitas: aktivitas, jenis: jenis)));
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setFromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}

class ActivityModel {
  String aktivitas;
  String jenis;
  ActivityModel({required this.aktivitas, required this.jenis}); //constructor
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ActivityBloc(),
        child: const HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlocBuilder<ActivityBloc, ActivityModel>(
            builder: (context, aktivitas) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ActivityBloc>().add(FetchDataEvent());
                        },
                        child: const Text("Saya bosan ..."),
                      ),
                    ),
                    Text(aktivitas.aktivitas),
                    Text("Jenis: ${aktivitas.jenis}")
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}
