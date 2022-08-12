import 'package:bar_app/resources/util/location_util.dart';
import 'package:bar_app/ui/map_test.dart';
import 'package:bar_app/ui/search_page.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart';

/*class HomePage extends StatelessWidget {
  late Widget _currentPage;
  HomePage({Key? key}) : super(key: key);

  @override
  void initState() {
    super.initState();
    _currentPage = _page1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BottomNavigationBar Demo'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Calls',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Camera',
          ),
        ],
        onTap: (value) {
          if (value != null) {
            print("NavBar value: ${value}");
          }
          switch (value) {
            case 0:
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => SearchPage()));
              break;
            case 1:
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MapSample()));
              break;
          }
        },
      ),
    );
  }
}*/

class GetLocationWidget extends StatefulWidget {
  const GetLocationWidget({Key? key}) : super(key: key);

  @override
  _GetLocationState createState() => _GetLocationState();
}

class _GetLocationState extends State<GetLocationWidget> {
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  LocationData? _userLocation;

  Future<void> _getUserLocation() async {
    print("FINDING LOCATION");
    Location location = Location();

    // Check if location service is enable
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Check if permission is granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    final _locationData = await location.getLocation();
    LocationUtil util = LocationUtil();
    util.setUserLocation(_locationData);
    print(
        "RESULT: ${util.getUserLocation()?.latitude}, ${util.getUserLocation()?.longitude}");
    setState(() {
      _userLocation = _locationData;
    });
  }

  @override
  Widget build(BuildContext context) {
    _getUserLocation();
    return Scaffold(
        /*body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 25),
            // Display latitude & longtitude
            _userLocation != null
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      children: [
                        Text('Your latitude: ${_userLocation?.latitude}'),
                        const SizedBox(width: 10),
                        Text('Your longtitude: ${_userLocation?.longitude}')
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),*/
        );
  }
}

class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

const String page1 = "Search";
const String page2 = "Map";

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> _pages;
  late Widget _page1;
  late Widget _page2;
  late int _currentIndex;
  late Widget _currentPage;

  @override
  void initState() {
    super.initState();
    _page1 = SearchPage();
    _page2 = MapSample();
    _pages = [_page1, _page2];
    _currentIndex = 0;
    _currentPage = _page2;
  }

  void _changeTab(int index) {
    setState(() {
      _currentIndex = index;
      _currentPage = _pages[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Linez"),
      ),
      body: /*_currentPage*/ IndexedStack(
        children: <Widget>[
          SearchPage(),
          MapSample(),
        ],
        index: _currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            _changeTab(index);
          },
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              label: page1,
              icon: Icon(Icons.search),
            ),
            BottomNavigationBarItem(
              label: page2,
              icon: Icon(Icons.map_outlined),
            ),
          ]),
      drawer: Drawer(
        child: Container(
          margin: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: <Widget>[
              _navigationItemListTitle(page1, 0),
              _navigationItemListTitle(page2, 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigationItemListTitle(String title, int index) {
    return ListTile(
      title: Text(
        '$title Page',
        style: TextStyle(color: Colors.blue[400], fontSize: 22.0),
      ),
      onTap: () {
        Navigator.pop(context);
        _changeTab(index);
      },
    );
  }
}
