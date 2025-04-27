import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  late IO.Socket socket;
  String translatedText = "";

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('http://192.168.1.3:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      print('Connected to backend');
      socket.emit('start_translation');
    });

    socket.on('translation', (data) {
      setState(() {
        translatedText = data['translation'];
      });
    });

    socket.on('started', (data) {
      print(data['status']);
    });

    socket.onDisconnect((_) => print('Disconnected'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Translator')),
      body: Center(child: Text('Translation: $translatedText')),
    );
  }
}
