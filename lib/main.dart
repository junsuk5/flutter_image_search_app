import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'photo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageApp(),
    );
  }
}

class ImageApp extends StatefulWidget {
  const ImageApp({Key? key}) : super(key: key);

  @override
  State<ImageApp> createState() => _ImageAppState();
}

class _ImageAppState extends State<ImageApp> {
  List<Photo> photos = [];
  bool isLoading = false;

  void getImages(String query) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'https://pixabay.com/api/?key=10711147-dc41758b93b263957026bdadb&q=$query&image_type=photo&pretty=true');
    var response = await http.get(url);

    Map<String, dynamic> jsonMap = jsonDecode(response.body);
    Iterable hits = jsonMap['hits'];
    List<Photo> data = hits
        .map((e) => Photo(
              url: e['webformatURL'],
              id: e['id'],
              tags: e['tags'],
            ))
        .toList();

    setState(() {
      isLoading = false;
      photos = data;
    });
  }

  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // List<Image> images = [];
    //
    // for (int i = 0; i < photos.length; i++) {
    //   Photo photo = photos[i];
    //   Image image = Image.network(photo.url);
    //   images.add(image);
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('이미지 검색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '검색어',
                suffixIcon: IconButton(
                  onPressed: () {
                    getImages(_textController.text);
                  },
                  icon: const Icon(
                    Icons.search,
                    color: Colors.green,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isLoading == true
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: photos
                          .map(
                            (photo) => ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Image.network(
                                photo.url,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
