import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:viewerapp/business_logic/providers/search provider.dart';
import 'package:viewerapp/models/postslist_model.dart';
import 'package:viewerapp/ui/child%20widgets/singlepost_cardview_widget.dart';
import 'package:viewerapp/ui/child%20widgets/voice%20recorder%20modal%20bottom%20sheet.dart';
import 'package:viewerapp/ui/screens/auth_screen.dart';
import 'package:viewerapp/utils/utils.dart';
import '../../utils/strings.dart';

class SearchScreen extends StatefulWidget {
  final height;
  final width;
  ScrollController _scrollController;

  SearchScreen(this.height, this.width, this._scrollController);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _controller = TextEditingController();
  String _popupValue1 = "";
  String _popupValue2 = "";
  late String? _memberId;
  bool _searchActive = false;
  bool _searching = false;
  bool _loaded = false;
  bool _noSearchResult = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
  //  _memberId = preferences!.getString("id")??null;
   _memberId = "10470";
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    final modalHeight = (widget.height - MediaQueryData.fromWindow(window).padding.top);
    return Container(
        margin: EdgeInsets.only(left: widget.width * 0.025, top: 10),
        child: Consumer<SearchProvider>(
          builder: (context, searchProvider, child) {
            if (!_loaded && _memberId != null) {
              searchProvider.fetchRecentSearches(_memberId!).then((value) {});
              _loaded = true;
            }
            return _buildWidgetsList(searchProvider, modalHeight);
          },
        ));
  }

  Widget _buildWidgetsList(SearchProvider searchProvider, double modalHeight) {
    int count = 2;
    if (searchProvider.searchResults.length > 0 && !_searching) {
      count = searchProvider.searchResults.length + count;
    } else if (searchProvider.searchResults.length == 0 && _noSearchResult) {
      count++;
    } else {
      if (!_searching) {
        if (_controller.text.isEmpty) {
          if (searchProvider.recentSearches.isEmpty)
            count++;
          else
            count = searchProvider.recentSearches.length + count;
        } else {
          if (searchProvider.relatedSearches.isEmpty)
            count++;
          else
            count = searchProvider.relatedSearches.length + count;
        }
      } else {
        count++;
      }
    }
    return _memberId != null
        ? ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: count,
            itemBuilder: (BuildContext context, index) {
              if (index == 0) {
                return _buildSearchWidget(searchProvider,  modalHeight);
              } else if (index == 1) {
                if (searchProvider.searchResults.length > 0) {
                  return _buildSortWidget(_controller.text, searchProvider.searchResults.length);
                } else {
                  if (_controller.text.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      color: Color.fromRGBO(245, 245, 245, 1),
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "최근검색",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    );
                  } else
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      color: Color.fromRGBO(245, 245, 245, 1),
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "관련된 검색어",
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    );
                }
              } else {
                index = index - 2;
                if (_searching) {
                  return Center(
                    child: Container(
                        child: CircularProgressIndicator(
                      backgroundColor: Theme.of(context).selectedRowColor,
                    )),
                  );
                } else if (searchProvider.searchResults.length > 0) {
                  return _buildPostWidget(0.4 * widget.height, widget.width, index, searchProvider);
                } else if (searchProvider.searchResults.isEmpty && _noSearchResult) {
                  return Center(
                    child: Text(
                      "검색 결과가  없습니다",
                      style: TextStyle(fontSize: 15),
                    ),
                  );
                } else if (_controller.text.isEmpty) {
                  if (searchProvider.recentSearches.isEmpty)
                    return Center(
                      child: Text(
                        "최근 검색 결과가 없습니다",
                        style: TextStyle(fontSize: 15),
                      ),
                    );
                  else
                    return _buildRecentSearchResultWidget(searchProvider.recentSearches[index].word!, searchProvider);
                } else {
                  if (searchProvider.relatedSearches.isEmpty)
                    return Center(
                        child: Text(
                      "관련된 검색 결과가 없습니다!",
                      style: TextStyle(fontSize: 15),
                    ));
                  return _buildRelatedSearchesWidget(searchProvider.relatedSearches[index].word!, searchProvider);
                }
              }
            })
        : Center(
      child: Container(
                margin: EdgeInsets.only(top: widget.width*0.5),
                child: Column(
                  children: [
                    Text("먼저 로그인 하십시오!",  style: TextStyle(
                      fontSize: 18
                    ),),
                    MaterialButton(

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Theme.of(context).selectedRowColor, textColor: Colors.white,  onPressed: () {
                      Navigator.pushNamed(context, AuthScreen.route);
                    }, child: Text("로그인"),)
                  ],
                )),
          );
  }

  Widget _buildSearchWidget(SearchProvider homePageProvider,  double modalHeight){
    return Row(
      children: [
        Expanded(
          flex: 9,
          child: Container(
            height: widget.height * 0.05,
            child: TextField(
              onChanged: (searchWord) {



                homePageProvider.cleanList();
                homePageProvider.fetchRelatedSearches(_memberId!, searchWord).then((value) {});
                setState(() {
                  _noSearchResult = false;
                });
              },
              onTap: () {
                _searchActive = true;
              },
              controller: _controller,
              onSubmitted: (searchWord) {

                if(searchWord.isEmpty) {
                  showToast("Please, type something!");
                }
                else  {
                  setState(() {
                    _searching = true;
                  });
                  homePageProvider.searchPostByTitle(10, 1, "views", searchWord, _memberId!).then((value) {
                    setState(() {
                      _searching = false;
                      if (homePageProvider.searchResults.isEmpty)
                        _noSearchResult = true;
                      else
                        _noSearchResult = false;
                    });
                  });
                }

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
        _searchActive
            ? Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 25,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchActive = false;
                    });
                    _controller.text = "";
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              )
            : Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.mic),
                  onPressed: () {
                    showToast("Under development");
                    // setState(() {
                    //   _searchActive = true;
                    // });
                    //
                    // _showModalBottomSheet(homePageProvider, modalHeight);
                  },
                ))
      ],
    );
  }

  Widget _buildPostWidget(double height, double width, index, SearchProvider homePageProvider) {
    List<Post> posts = homePageProvider.searchResults;
    return CardViewWidget(height, width, posts[index]);
  }

  Widget _buildSortWidget(String searchWord, int count) {
    return Row(
      children: [
        Container(margin: EdgeInsets.only(left: 10.0), child: Text('${searchWord} 검색 결과 ${count} 건')),
        Spacer(),
        Container(
          margin: EdgeInsets.only(left: 5.0),
          child: PopupMenuButton(
              child: Icon(Icons.menu),
              elevation: 10,
              enabled: true,
              onSelected: (value) {
                setState(() {
                  _popupValue1 = value.toString();
                });
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("First"),
                      value: "first1",
                    ),
                    PopupMenuItem(
                      child: Text("Second"),
                      value: "second1",
                    )
                  ]),
        ),
        Container(
          margin: EdgeInsets.only(left: 10.0, right: 10),
          child: PopupMenuButton(
              elevation: 10,
              child: Icon(
                Icons.notes_outlined,
              ),
              enabled: true,
              onSelected: (value) {
                setState(() {
                  _popupValue2 = value.toString();
                });
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("First"),
                      value: "first2",
                    ),
                    PopupMenuItem(
                      child: Text("Second"),
                      value: "second2",
                    )
                  ]),
        ),
      ],
    );
  }

  Widget _buildRecentSearchResultWidget(String recentSearchWord, SearchProvider searchProvider) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Icon(Icons.access_time_outlined)),
          Expanded(
            flex: 8,
            child: Container(
                alignment: Alignment.bottomLeft,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      _controller.text = recentSearchWord;
                      _searching = true;
                    });
                    searchProvider.searchPostByTitle(10, 1, "views", recentSearchWord, _memberId!).then((value) {
                      setState(() {
                        _searching = false;
                        if (searchProvider.searchResults.isEmpty)
                          _noSearchResult = true;
                        else
                          _noSearchResult = false;
                      });
                    });
                  },
                  child: Text(
                    recentSearchWord,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                )),
          ),
          Expanded(
              flex: 1,
              child: IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 15,
                  ),
                  onPressed: () {}))
        ],
      ),
    );
  }

  Widget _buildRelatedSearchesWidget(String relatedSearchWord, SearchProvider searchProvider) {
    return InkWell(
      onTap: () {
        setState(() {
          _controller.text = relatedSearchWord;

          _searching = true;
        });
        searchProvider.searchPostByTitle(10, 1, "views", relatedSearchWord, _memberId!).then((value) {
          setState(() {
            _searching = false;
            if (searchProvider.searchResults.isEmpty)
              _noSearchResult = true;
            else
              _noSearchResult = false;
          });
        });
      },
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
          children: [
            Expanded(flex: 1, child: Icon(Icons.search)),
            Expanded(
              flex: 9,
              child: Text(
                relatedSearchWord,
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showModalBottomSheet( SearchProvider provider, double modalHeight) {
    showMaterialModalBottomSheet(
      context: context,
      builder: (context) => VoiceRecorderModalBottomSheet(modalHeight),
    ).then((value) {
      if (value != null) {
        setState(() {
          _searchActive = true;
          _controller.text = value;
          _searching = true;
        });
        provider.searchPostByTitle(10, 1, "views", value, _memberId!).then((value) {
          _searching = false;
          if (provider.searchResults.isEmpty)
            _noSearchResult = true;
          else
            _noSearchResult = false;

        });
      }


    });
  }
}
