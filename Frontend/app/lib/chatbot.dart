import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class ChatbotPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;

  const ChatbotPage({
    super.key,
    required this.userId,
    required this.userData,
  });

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _isListening = false;
  final String _apiKey = "AIzaSyCjQCCAA005X7h_1rYPTvRtKlbsfyUCFrs";

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    setState(() {
      _messages.add({
        "bot":
            "Hi! I'm Finora, your personal financial advisor.I'm here to help you make smart financial decisions. How can I assist you today?"
      });
    });
  }

  Future<void> _sendMessage(String message) async {
    setState(() {
      _messages.add({"user": message});
    });

    try {
      final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey");

      final systemPrompt = """
      You are Finora, a female AI financial advisor. Your personality traits:
      - Professional yet friendly and empathetic
      - Clear and simple in explanations
      - Knowledgeable about personal finance, budgeting, and investment strategies
      - Explains financial jargons in a way that commoners can understand
      - Encouraging and supportive
      - Focus on practical, actionable advice

      Most important give concise answers and avoid unnecessary details. It is like real world chatting with a financial advisor. No human will give one page answer while chatting. So you too dont do that. If anything other than finance is asked, tell the user to focus on finance right now in a jovial way.
      
      Here is the user's financial profile:
      ${widget.userData}
      
      Based on this information, provide personalized financial guidance for the following query:
      $message
      
      Always maintain your identity as Finora and respond in a conversational, empathetic tone.
      """;

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": systemPrompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final reply =
            jsonResponse['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _messages.add({"bot": reply});
        });

        // Configure TTS for female voice
        await _tts.setVoice({"name": "en-US-female-1", "locale": "en-US"});
        await _tts.setPitch(1.2); // Slightly higher pitch for female voice
        await _tts.speak(reply);
      } else {
        setState(() {
          _messages.add({
            "bot":
                "I apologize, but I'm having trouble processing your request right now. Could you please try again?"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "bot":
              "I'm sorry, but I'm unable to connect at the moment. Please try again later."
        });
      });
    }

    _controller.clear();
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (result) {
          _controller.text = result.recognizedWords;
        });
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat with Finora",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.purple[100],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final entry = _messages[index];
                final sender = entry.keys.first;
                final msg = entry[sender];
                return Align(
                  alignment: sender == "user"
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sender == "user"
                          ? Colors.purple[100]
                          : Colors.pink[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg ?? "",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _startListening,
                  color: Colors.purple,
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Ask Finora anything about your finances...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: Colors.purple,
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
