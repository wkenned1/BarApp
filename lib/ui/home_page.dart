import 'package:bar_app/ui/map_test.dart';
import 'package:bar_app/ui/search_page.dart';
import 'package:flutter/material.dart';

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
    _page1 = const SearchPage();
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
