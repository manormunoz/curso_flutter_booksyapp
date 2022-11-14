import 'package:booksy_app/bookshelf/bookshelf_screen.dart';
import 'package:booksy_app/categories/categories_screen.dart';
import 'package:booksy_app/firebase_options.dart';
import 'package:booksy_app/state.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:booksy_app/home/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BooksyApp());
}

class BooksyApp extends StatelessWidget {
  const BooksyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookshelfBloc(BookshelfState([])),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.red,
        ),
        home: const BottomNavigatorWidget(),
      ),
    );
  }
}

void initNotifications(BuildContext context, mounted) async {
  await initLocalNotifications(context);
  await initPushNotifications();
  await startReadingReminder();
}

Future<void> initPushNotifications() async {
  var fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint(fcmToken);
  FirebaseMessaging.onMessage.listen(_onRemoteMessageReceived);
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessageReceived);
}

Future<void> _onBackgroundMessageReceived(RemoteMessage message) async {
  debugPrint('${message.notification!.title}: ${message.notification!.body}');
}

void _onRemoteMessageReceived(RemoteMessage message) {
  debugPrint('${message.notification!.title}: ${message.notification!.body}');
  _showNotification(message.notification!.title ?? 'Sin titulo',
      message.notification!.body ?? 'Sin body');
}

Future<void> initLocalNotifications(BuildContext context) async {
  FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();
  DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) {});
  AndroidInitializationSettings androidSettings =
      const AndroidInitializationSettings('ic_launcher');
  InitializationSettings initSettings = InitializationSettings(
    iOS: iosSettings,
    android: androidSettings,
  );
  await notifications.initialize(initSettings, onDidReceiveNotificationResponse:
      (NotificationResponse notificationRespons) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("data"),
        content: Text(notificationRespons.payload!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancelar'),
            child: const Text("OK"),
          )
        ],
      ),
    );
  });
}

Future<void> startReadingReminder() async {
  await Future.delayed(const Duration(seconds: 4));
  _showNotification('Local notification', 'Body local notification');
}

void _showNotification(String title, String body) {
  FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'chanel id',
    'chanel name',
    channelDescription: 'chanel description',
    importance: Importance.max,
    priority: Priority.high,
  );
  notifications.show(
    1,
    title,
    body,
    const NotificationDetails(android: androidDetails),
    payload: "20",
  );
}

class BottomNavigatorWidget extends StatefulWidget {
  const BottomNavigatorWidget({super.key});

  @override
  State<BottomNavigatorWidget> createState() => _BottomNavigatorWidgetState();
}

class _BottomNavigatorWidgetState extends State<BottomNavigatorWidget> {
  int _selectedIndex = 0;
  static const List<Widget> _sections = [
    HomeScreen(),
    CategoriesScreen(),
    BookshelfScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    initNotifications(context, mounted);
    return Scaffold(
      appBar: AppBar(title: const Text("Booksy")),
      body: _sections[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_library),
            label: 'Bliblioteca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Mi estante',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
