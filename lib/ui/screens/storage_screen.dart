import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:viewerapp/business_logic/providers/collections provider.dart';
import 'package:viewerapp/models/postslist_model.dart';
import 'package:viewerapp/ui/child%20widgets/singlepost_cardview_widget.dart';
import 'package:viewerapp/ui/child%20widgets/singlepost_listview_widget.dart';
import 'package:viewerapp/utils/utils.dart';

import '../../utils/strings.dart';
import 'auth_screen.dart';

class StorageBoxScreen extends StatefulWidget {
  final height;
  final width;
  late String memberId= "";

  StorageBoxScreen(this.height, this.width);

  @override
  _StorageBoxScreenState createState() => _StorageBoxScreenState();
}

class _StorageBoxScreenState extends State<StorageBoxScreen> with SingleTickerProviderStateMixin {
  bool _searchMode = false;
  Button mode = Button.BOOKMARK;
  CollectionsProvider _collectionsProvider = CollectionsProvider();
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _collectionsProvider = Provider.of<CollectionsProvider>(context, listen: true);
    if ((_collectionsProvider.statusCode1 == 0 || _collectionsProvider.statusCode1 == -2)) {
     // widget.memberId = preferences!.getString("id")!;
      _collectionsProvider.fetchSavedPostsList("10470", "10", "1", "views").then((value) {});
    }
    if ((_collectionsProvider.statusCode2 == 0 || _collectionsProvider.statusCode2 == -2)) {
      //widget.memberId = preferences!.getString("id")!;
      _collectionsProvider.fetchOpenedPostsList("10470", "10", "1", "views").then((value) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    print("ewqrihgiwhpwirhgpwrtpwirhrpo");
    int count = 2;
    widget.memberId = "10470";


    if (_searchMode) count = count + 1;
    if (mode == Button.BOOKMARK && _collectionsProvider.savedPosts.isNotEmpty)
      count = count + _collectionsProvider.savedPosts.length;
    else if (mode == Button.OPEN_CHERI && _collectionsProvider.savedPosts.isNotEmpty) count = count + _collectionsProvider.openedPosts.length;

    if (widget.memberId == null) {
      return Container(
          margin: EdgeInsets.only(top: widget.width * 0.5),
          child: Column(
            children: [
              Text(
                "먼저 로그인 하십시오!",
                style: TextStyle(fontSize: 18),
              ),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Theme.of(context).selectedRowColor,
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, AuthScreen.route);
                },
                child: Text("로그인"),
              )
            ],
          ));
    } else {
      if (_collectionsProvider.statusCode1 == 200 && _collectionsProvider.statusCode2 == 200)
        return ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: count,
            itemBuilder: (BuildContext context, index) {
              if (index == 0) {
                return _buildCustomTabBar();
              } else if (index == 1) {
                return _buildSortWidget(widget.memberId, _collectionsProvider);
              } else if (index == 2 && _searchMode) {
                return _buildSearchWidget();
              } else {
                if (_searchMode)
                  index = index - 3;
                else
                  index = index - 2;
                return _buildPostWidget(widget.height, widget.width, index, _collectionsProvider);
              }
            });
      else if (_collectionsProvider.statusCode1 == -1 || _collectionsProvider.statusCode2 == -1)
        return Center(
          child: Column(
            children: [
              Text("TimeOut happened:("),
              MaterialButton(
                onPressed: () {
                  _collectionsProvider.fetchSavedPostsList(widget.memberId, "10", "1", "views").then((value) {});
                  _collectionsProvider.fetchOpenedPostsList(widget.memberId, "10", "1", "views").then((value) {});
                },
                child: Text("try again"),
              )
            ],
          ),
        );
      else if (_collectionsProvider.statusCode1 == -2 || _collectionsProvider.statusCode2 == -2) {
        return Center(
          child: Container(
            margin: EdgeInsets.only(top: widget.width * 0.5),
            child: Column(
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 30,
                ),
                Text(
                  "Please check your internet connectivity!",
                  style: TextStyle(fontSize: 15),
                ),
                MaterialButton(
                  color: Theme.of(context).selectedRowColor,
                  textColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onPressed: () {},
                  child: Text("Reload Page"),
                )
              ],
            ),
          ),
        );
      } else if (_collectionsProvider.statusCode1 == -3 || _collectionsProvider.statusCode2 == -3) {
        return Center(
          child: Container(
            margin: EdgeInsets.only(top: widget.width * 0.5),
            child: Column(
              children: [
                Text("Unexpected error happened"),
                MaterialButton(
                  onPressed: () {},
                  child: Text("Try again"),
                )
              ],
            ),
          ),
        );
      } else{
        print(_collectionsProvider.statusCode1);
        print(_collectionsProvider.statusCode2);
        return Center(
          child: Container(
              margin: EdgeInsets.only(top: widget.width * 0.5),
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).selectedRowColor,
              )),
        );
    }}
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                mode = Button.BOOKMARK;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.white),
                  bottom: mode == Button.BOOKMARK ? BorderSide(width: 4, color: Theme.of(context).selectedRowColor) : BorderSide(color: Colors.grey),
                ),
              ),
              alignment: Alignment.center,
              height: 60,
              width: widget.width / 2,
              child: Text(
                "북마크",
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                mode = Button.OPEN_CHERI;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                  bottom: mode == Button.OPEN_CHERI ? BorderSide(width: 4, color: Theme.of(context).selectedRowColor) : BorderSide(color: Colors.grey),
                ),
              ),
              alignment: Alignment.center,
              height: 60,
              width: widget.width / 2,
              child: Text("여러본 체리", style: TextStyle(fontSize: 15)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSortWidget(String memberId, CollectionsProvider postListsProvidert) {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          InkWell(
              onTap: () {
                setState(() {
                  _searchMode = !_searchMode;
                });
              },
              child: Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 25,
                  height: 25,
                  child: SvgPicture.asset(
                    "assets/icons/search.svg",
                    color: _searchMode ? Theme.of(context).selectedRowColor : Colors.black,
                  ))),
          Container(
            margin: EdgeInsets.only(left: 5.0),
            child: PopupMenuButton(
                child: Container(width: 30, height: 30, child: SvgPicture.asset("assets/icons/list.svg")),
                elevation: 10,
                enabled: true,
                onSelected: (value) async {
                  if (value == "first1") {
                    await preferences!.setString("mode2", "card");
                  } else if (value == "first2") {
                    await preferences!.setString("mode2", "list");
                  }
                  setState(() {});
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(menu1[korean]![0]),
                        value: "first1",
                      ),
                      PopupMenuItem(
                        child: Text(menu1[korean]![1]),
                        value: "first2",
                      )
                    ]),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.0, right: 10),
            child: PopupMenuButton(
                elevation: 10,
                child: Container(width: 30, height: 30, child: SvgPicture.asset("assets/icons/options.svg")),
                enabled: true,
                onSelected: (value) async {
                  if (value == "second1") {
                    await postListsProvidert.fetchSavedPostsList(memberId, "8", "1", "regdate r");
                  } else if (value == "second2") {
                    await postListsProvidert.fetchSavedPostsList(memberId, "8", "1", "regdate");
                  } else if (value == "second3") {
                    await postListsProvidert.fetchSavedPostsList(memberId, "8", "1", "views");
                  }
                  setState(() {});
                },
                itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text(menu2[korean]![0]),
                        value: "second1",
                      ),
                      PopupMenuItem(
                        child: Text(menu2[korean]![1]),
                        value: "second2",
                      ),
                      PopupMenuItem(
                        child: Text(menu2[korean]![2]),
                        value: "second3",
                      ),
                    ]),
          ),
        ],
      ),
    );
  }

  Widget _buildPostWidget(double height, double width, index, CollectionsProvider collectionsProvider) {
    List<Post> posts = [];
    if (mode == Button.BOOKMARK)
      posts.addAll(collectionsProvider.savedPosts);
    else
      posts.addAll(collectionsProvider.openedPosts);

    String sortMode = preferences!.getString("mode2") ?? "card";
    if (sortMode == "card")
      return CardViewWidget(height, width, posts[index]);
    else
      return ListViewWidget(height, width, posts[index]);
  }

  Widget _buildSearchWidget() {
    return Container(
      margin: EdgeInsets.only(left: 10, top: 10),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: Container(
              height: widget.height * 0.05,
              child: TextField(
                controller: _controller,
                onSubmitted: (searchWord) {
                  print("$searchWord submitted");
                },
                autofocus: true,
                textAlign: TextAlign.start,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 10.0),
                  hintText: search_hint[korean],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _searchMode = false;
                });
              },
            ),
          )
        ],
      ),
    );
  }
}

enum Button { BOOKMARK, OPEN_CHERI }
