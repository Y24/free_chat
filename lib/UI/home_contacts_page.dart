import 'package:flutter/material.dart';
import 'package:free_chat/configuration/home_contacts_conf.dart';
import 'package:free_chat/entity/contact_entity.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:free_chat/util/ui/people_expansion_panel.dart';
import 'package:provider/provider.dart';

class HomeContactsPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String username;
  HomeContactsPage({this.scaffoldKey, this.username});

  @override
  _HomeContactsPageState createState() => _HomeContactsPageState();
}

class _HomeContactsPageState extends State<HomeContactsPage>
    with SingleTickerProviderStateMixin {
  int x = 0;
  int _currentTabIndex = 0;
  TabController _tabController;
  List list = new List();
  List<List<bool>> expandedFlag = List(HomeContactsConf.strPool.length);
  Future<Null> _onRefresh() async {
    x++;
    await Future.delayed(Duration(seconds: 1), () {
      print('refresh');
      setState(() {
        list = List.generate(20, (i) => '第 $x 次刷新后数据 $i');
      });
    });
  }

  @override
  initState() {
    super.initState();
    for (int i = 0; i < expandedFlag.length; i++) {
      expandedFlag[i] = [
        for (int i = 0;
            i < HomeContactsConf.strPool.values.first.values.first.length;
            i++)
          false
      ];
    }
    _tabController =
        TabController(length: HomeContactsConf.tabIcons.length, vsync: this)
          ..addListener(() {
            setState(() {
              _currentTabIndex = _tabController.index;
            });
          });
  }

  Widget build(BuildContext context) {
    //final themeState = Provider.of<CustomThemeDataState>(context);
    final languageState = Provider.of<LanguageState>(context);
    return RefreshIndicator(
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
        children: [
          Card(
            elevation: 8,
            shape: const RoundedRectangleBorder(),
            child: InkWell(
              onTap: () {},
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                title: Text('New friends'),
                subtitle: Text(
                  '2',
                  style: TextStyle(color: Colors.green),
                ),
                trailing: Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          TabBar(
            labelColor: Colors.blue,
            indicatorWeight: 3,
            controller: _tabController,
            indicatorPadding: EdgeInsets.symmetric(horizontal: -14),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: <Widget>[
              ...HomeContactsConf.tabIcons.map(
                (i) => Tab(
                  icon: Icon(
                    i,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          IndexedStack(
            index: _currentTabIndex,
            children: <Widget>[
              for (int i = 0; i < expandedFlag.length; i++)
                ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                     // print('i: $i,index: $index,Expanded: $isExpanded');
                      expandedFlag[i][index] = !isExpanded;
                    });
                  },
                  children: [
                    for (int j = 0;
                        j <
                            HomeContactsConf
                                .strPool[HomeContactsConf.index[i]]
                                    [languageState.language]
                                .length;
                        j++)
                      PeopleExpansionPanel(
                        context,
                        content: [
                          for (int i = 0; i < 10; i++)
                            ContactEntity(
                              alias: 'alias',
                              overview: 'subTitle',
                            ),
                        ],
                        header: Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            left: 14,
                          ),
                          child: Text(
                            HomeContactsConf.strPool[HomeContactsConf.index[i]]
                                [languageState.language][j],
                            style: TextStyle(
                                color: Colors.lightBlue,
                                fontSize: 20,
                                shadows: [
                                  Shadow(
                                    color: Colors.blue[100],
                                    blurRadius: 3,
                                    offset: Offset(1, 2),
                                  ),
                                ]),
                          ),
                        ),
                        isExpanded: expandedFlag[i][j],
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
      onRefresh: _onRefresh,
      // displacement:30,
      color: Colors.blue,
      backgroundColor: Colors.white,
      // notificationPredicate:,
      semanticsLabel: 'label',
      semanticsValue: 'push_to_refresh',
    );
  }
}
