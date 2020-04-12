import 'dart:convert';

import 'package:covidtrack/utils/constants.dart';
import 'package:covidtrack/utils/country_data_model.dart';
import 'package:covidtrack/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CountryPage extends StatefulWidget {
  String countryName;
  CountryPage({this.countryName});
  @override
  _CountryPageState createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  CountryData countryData;
  String countryName;
  String countryCode;
  @override
  void initState() {
    countryName = widget.countryName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: getCountry(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        AppHeader(
                          url:
                              'http://www.geognos.com/api/en/countries/flag/${countryCode.toUpperCase()}.png',
                          onTap: () async {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          '${snapshot.data.countryName} Outbreak',
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

  Future<CountryData> getCountry() async {
    http.Response response = await http.get(
        'https://api.covid19api.com/live/country/$countryName/status/confirmed');
    if (response.statusCode == 200) {
      countryData = CountryData(
        totalRecovered: 0,
        totalActive: 0,
        totalConfirmed: 0,
        totalDeath: 0,
        countryName: '',
      );
      var data = response.body;
      var countryDetails = jsonDecode(data);
      for (var country in countryDetails) {
        if (country == countryDetails[countryDetails.length - 1])
          setState(() {
            countryCode = country['CountryCode'];
            countryData.countryName = country['Country'];
            countryData.totalConfirmed = country['Confirmed'];
            countryData.totalDeath = country['Deaths'];
            countryData.totalRecovered = country['Recovered'];
            countryData.totalActive = country['Active'];
          });
      }
    }
    return countryData;
  }
}
