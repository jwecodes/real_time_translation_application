import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connectToBackend() {
    socket = IO.io(
      'http://192.168.1.3:5000', // ⬅️ Replace with your actual IP if testing on mobile
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('✅ Socket connected');
      socket.emit('start_translation');
    });

    socket.on('started', (data) {
      print('👂 Listening: ${data['status']}');
    });

    socket.on('translation', (data) {
      print("🌍 ${data['lang']} ➤ ${data['translation']}");
      // You can update a UI here, emit a stream, etc.
    });

    socket.onDisconnect((_) => print(' Socket disconnected'));
  }

  void disconnect() {
    socket.disconnect();
  }
}


/*import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connectToBackend() {
    socket = IO.io(
      'http://127.0.0.1:5000',
      IO.OptionBuilder()
          .setTransports(['websocket']) // for Flutter/web support
          .disableAutoConnect()         // disable auto-connect
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      print('Socket connected ✅');
      socket.emit('start_translation');
    });

    socket.on('started', (data) {
      print('Server says: ${data['status']}');
    });

    socket.on('translation', (data) {
      print("Language: ${data['lang']}, Translation: ${data['translation']}");
      // You can update the UI here using any state management (setState, Provider, Riverpod, etc.)
    });

    socket.onDisconnect((_) => print('Disconnected ❌'));
  }

  void disconnect() {
    socket.disconnect();
  }
}
*/