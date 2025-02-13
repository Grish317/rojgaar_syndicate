import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchPage extends StatefulWidget {
  final Function(String) onSearch;  // Callback to return the search query

  VoiceSearchPage({Key? key, required this.onSearch}) : super(key: key);

  @override
  _VoiceSearchPageState createState() => _VoiceSearchPageState();
}

class _VoiceSearchPageState extends State<VoiceSearchPage> {
  stt.SpeechToText _speechToText = stt.SpeechToText();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
  }

  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      _speechToText.listen(onResult: (result) {
        setState(() {
          _searchQuery = result.recognizedWords;
          widget.onSearch(_searchQuery);  // Pass the search query back to HomePage
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Voice Search')),
      body: Column(
        children: [
          IconButton(
            icon: Icon(Icons.mic),
            onPressed: _startListening,
          ),
          Text('Search Query: $_searchQuery'),
        ],
      ),
    );
  }
}
