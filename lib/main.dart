// ignore_for_file: unnecessary_this, avoid_print, prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'dart:async';


class UserTemplate extends StatefulWidget {
  @override
  _UserTemplateState createState() => _UserTemplateState();
}

class _UserTemplateState extends State<UserTemplate> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  String? selectedGender;
  bool _viewedEventRaised = false;

  @override
  void initState() {
    super.initState();
    cleverTapInboxHandler();
  }

  void cleverTapInboxHandler() {
    // ignore: no_leading_underscores_for_local_identifiers
    //inbox
    CleverTapPlugin _clevertapPlugin = CleverTapPlugin();
    _clevertapPlugin.setCleverTapInboxDidInitializeHandler(inboxDidInitialize);
    _clevertapPlugin
        .setCleverTapInboxMessagesDidUpdateHandler(inboxMessagesDidUpdate);
    _clevertapPlugin.setCleverTapInboxNotificationMessageClickedHandler(
        inboxNotificationMessageClicked);
    _clevertapPlugin.setCleverTapInboxNotificationButtonClickedHandler(
        inboxNotificationButtonClicked);

    //native
    _clevertapPlugin
        .setCleverTapDisplayUnitsLoadedHandler(onDisplayUnitsLoaded);
  }

  void onDisplayUnitsLoaded(List<dynamic>? displayUnits) {
    // Handle the loaded display units
    if (displayUnits != null && displayUnits.isNotEmpty) {
      print("Display Units = " + displayUnits.toString());
      // Process the display units here
      getAdUnits(); // Call getAdUnits to fetch display units and navigate to the next screen
    }
  }

  void getAdUnits() async {
    List? displayUnits = await CleverTapPlugin.getAllDisplayUnits();
    print("Display Units Payload = " + displayUnits.toString());

    if (displayUnits != null && displayUnits.isNotEmpty) {
      var response = displayUnits[0]; // Assuming there's only one response
      var unitId = response['wzrk_id']; // Extracting unitId directly from response
      print("WZRK_ID : " + unitId );

      var content = response['content'];

      if (content != null && content.isNotEmpty) {
        List<String> images = [];

        for (var item in content) {
          var media = item['media'];
          if (media != null) {
            var url = media['url'];
            if (url != null) {
              images.add(url);
            }
          }
        }

        if (images.isNotEmpty && unitId != null) {
          _nativeDisplay(images, unitId); // Pass unitId to _nativeDisplay method
        }
      }
    }
  }



  void inboxNotificationButtonClicked(Map<String, dynamic>? map) {
    this.setState(() {
      print("inboxNotificationButtonClicked called = ${map.toString()}");
    });
  }

  void inboxDidInitialize() {
    // ignore: unnecessary_this
    this.setState(() {
      // ignore: avoid_print
      print("inboxDidInitialize called");
      var styleConfig = {
        'noMessageTextColor': '#ff6600',
        'noMessageText': 'No message(s) to show.',
        'navBarTitle': 'App Inbox'
      };
      CleverTapPlugin.showInbox(styleConfig);
    });
  }

  void inboxMessagesDidUpdate() {
    this.setState(() async {
      print("inboxMessagesDidUpdate called");
    });
  }

  void inboxNotificationMessageClicked(
      Map<String, dynamic>? data, int contentPageIndex, int buttonIndex) {
    this.setState(() {
      print(
          "inboxNotificationMessageClicked called = InboxItemClicked at page-index $contentPageIndex with button-index $buttonIndex");

      var inboxMessageClicked = data?["msg"];
      if (inboxMessageClicked == null) {
        return;
      }

      //The contentPageIndex corresponds to the page index of the content, which ranges from 0 to the total number of pages for carousel templates. For non-carousel templates, the value is always 0, as they only have one page of content.
      var messageContentObject =
          inboxMessageClicked["content"][contentPageIndex];

      //The buttonIndex corresponds to the CTA button clicked (0, 1, or 2). A value of -1 indicates the app inbox body/message clicked.
      if (buttonIndex != -1) {
        //button is clicked
        var buttonObject = messageContentObject["action"]["links"][buttonIndex];
        var buttonType = buttonObject?["type"];
        print("type of button clicked: $buttonType");
      } else {
        //Item's body is clicked
        print(
            "type/template of App Inbox item: ${inboxMessageClicked["type"]}");
      }
    });
  }

  void _handleName(String name) {
    // Handle name input
  }

  void _handleEmail(String email) {
    // Handle email input
  }

  void _handlePhone(String phone) {
    // Handle phone input
  }

  void _handleUsername(String username) {
    // Handle username input
  }

  void _nativeDisplay(List<String> images, String unitId) {
  // Check if the viewed event has already been raised
  if (!_viewedEventRaised) {
    // Raise the viewed event
    CleverTapPlugin.pushDisplayUnitViewedEvent(unitId);
    _viewedEventRaised = true; // Set the flag to true to indicate that the event has been raised
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DisplayImagesPage(images: images),
    ),
  );
}


  void _handleGender(String? gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  void _profilePush() {
    var dob = '2012-04-22';
    var profile = {
      'dob': CleverTapPlugin.getCleverTapDate(DateTime.parse(dob)),
      'Customer': 'Platinum'
    };
    CleverTapPlugin.profileSet(profile);
  }

  void _addedToCart() {
    var eventData = {
      'Product Name': 'Casio Chronograph Watch',
      'Category': 'Mens Accessories',
      'Price': 59.99
    };
    CleverTapPlugin.recordEvent("Added To Cart", eventData);
  }

  void _charged() {
    // Handle extra button 3 tap
    var item1 = {
      // Key:    Value
      'Product category': 'books',
      'Book name': 'The Millionaire next door',
      'Quantity': 1
    };
    var item2 = {
      // Key:    Value
      'Product category': 'books',
      'Book name': 'Achieving inner zen',
      'Quantity': 1
    };
    var items = [item1, item2];
    var chargeDetails = {
      // Key:    Value
      'Amount': 300,
      'Payment Mode': 'Credit Card'
    };
    CleverTapPlugin.recordChargedEvent(chargeDetails, items);
  }

  void _appInbox() {
    CleverTapPlugin.initializeInbox();
    // Handle extra button 4 tap
  }

  void _handleSignin() {
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String username = usernameController.text;
    String gender = selectedGender ?? ""; // Ensure a value is selected
    // Now you have the data, perform your signup action
    var profile = {
      'Name': name,
      'Identity': username,
      'Email': email,
      'Phone': phone,
      'Gender': gender
    };
    CleverTapPlugin.onUserLogin(profile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('User Template'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              onChanged: _handleName,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              onChanged: _handleEmail,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              onChanged: _handlePhone,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: usernameController,
              onChanged: _handleUsername,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            DropdownButtonFormField<String>(
              value: selectedGender,
              onChanged: _handleGender,
              items: ['M', 'F']
                  .map((gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _handleSignin,
              child: Text('Signin'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Signup'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _profilePush,
              child: Text('Profile Push'),
            ),
            ElevatedButton(
              onPressed: _addedToCart,
              child: Text('Added To Cart'),
            ),
            ElevatedButton(
              onPressed: _charged,
              child: Text('Charged'),
            ),
            ElevatedButton(
              onPressed: _appInbox,
              child: Text('App Inbox'),
            ),
            ElevatedButton(
              onPressed: (){
                CleverTapPlugin.recordEvent("Native Display", {});
                getAdUnits();
              },
              child: Text('Native Display'),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayImagesPage extends StatelessWidget {
  final List<String> images;

  DisplayImagesPage({required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Images from CleverTap'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Carousel(images: images),
          ),
        ],
      ),
    );
  }
}

class Carousel extends StatefulWidget {
  final List<String> images;

  Carousel({required this.images});

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late PageController _pageController;
  int _currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < widget.images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    _pageController.addListener(() {
      if (_pageController.page == widget.images.length - 1) {
        // If the last page is reached, jump back to the first page
        _currentPage = 0;
        // Manually scroll to the first page
        Future.delayed(Duration(milliseconds: 600), () {
          _pageController.animateToPage(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              widget.images[index],
              fit: BoxFit.fitWidth,
            ),
          ),
        );
      },
    );
  }
}


class LoginPage extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  void _handleLogin(BuildContext context) {
    String email = emailController.text;
    String username = phoneController.text;

    var profile = {'Identity': username, 'Email': email};
    CleverTapPlugin.onUserLogin(profile);

    // Now you have the data, perform your login action

    // After login, navigate back to the previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleLogin(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: UserTemplate(),
    debugShowCheckedModeBanner: false,
  ));
  CleverTapPlugin.setDebugLevel(3);
  CleverTapPlugin.createNotificationChannel(
      "manishTest", "Flutter Test", "Flutter Test", 3, true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
