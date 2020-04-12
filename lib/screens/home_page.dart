import 'dart:convert';
import 'package:covidtrack/screens/country_select_page.dart';
import 'package:covidtrack/utils/constants.dart';
import 'package:covidtrack/utils/global_data_model.dart';
import 'package:covidtrack/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalData globalData;

  @override
  void initState() {
    globalData = GlobalData(
        totalActive: 0,
        totalConfirmed: 0,
        totalDeath: 0,
        totalRecovered: 0,
        newActive: 0,
        newDeaths: 0,
        newConfirmed: 0,
        newRecovered: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        AppHeader(
                          onTap: () async {
                            print('tap');
                            toCountrySelectPage();
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'World Outbreak',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w300),
                        ),
                        CaseCard(
                          totalCases: snapshot.data.totalConfirmed,
                        ),
                        DataListTile(
                          color: Colors.deepPurple,
                          cases: snapshot.data.totalActive,
                          text: 'Active',
                        ),
                        DataListTile(
                          color: Colors.green,
                          cases: snapshot.data.totalRecovered,
                          text: 'Recovered',
                        ),
                        DataListTile(
                          color: Colors.red,
                          cases: snapshot.data.totalDeath,
                          text: 'Deaths',
                        ),
                        DataListTile(
                          color: Colors.deepPurple,
                          cases: snapshot.data.newActive,
                          text: 'New Active',
                        ),
                        DataListTile(
                          color: Colors.green,
                          cases: snapshot.data.newRecovered,
                          text: 'New Recovered',
                        ),
                        DataListTile(
                          color: Colors.red,
                          cases: snapshot.data.newDeaths,
                          text: 'New Deaths',
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 10),
                          child: Text(
                            'Last Updated Today',
                            style: kLastUpdatedTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (snapshot.connectionState == ConnectionState.none ||
                  snapshot.hasError) {
                return LoaderScreen(
                  text1: 'Some Issue Connecting',
                  text2: 'Please check network',
                  image: kSanitizerImage,
                );
              } else {
                return LoaderScreen(
                  text1: 'Wash your hands with Soap',
                  text2: 'While we sync data for you  .. ',
                  image: kHandWashImage,
                );
              }
            }),
      ),
    );
  }

  void toCountrySelectPage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CountrySelectPage();
    }));
  }

  Future<GlobalData> getData() async {
    http.Response response =
        await http.get('https://api.covid19api.com/summary');
    if (response.statusCode == 200) {
      var data = response.body;
      setState(() {
        globalData.totalRecovered =
            jsonDecode(data)['Global']['TotalRecovered'];
        globalData.totalDeath = jsonDecode(data)['Global']['TotalDeaths'];
        globalData.totalConfirmed =
            jsonDecode(data)['Global']['TotalConfirmed'];
        globalData.newConfirmed = jsonDecode(data)['Global']['NewConfirmed'];
        globalData.newDeaths = jsonDecode(data)['Global']['NewDeaths'];
        globalData.newRecovered = jsonDecode(data)['Global']['NewRecovered'];
        globalData.totalActive = globalData.totalConfirmed -
            (globalData.totalRecovered + globalData.totalDeath);
        globalData.newActive = globalData.newConfirmed -
            (globalData.newRecovered + globalData.newDeaths);
      });
    }
    return globalData;
  }
}
