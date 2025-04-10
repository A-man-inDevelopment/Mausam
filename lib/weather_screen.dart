import 'dart:convert';
import 'dart:ui';
import'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';
import 'hourly_forecast_item.dart';
import 'package:flutter/material.dart';
import 'additional_info_item.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String,dynamic>> weather;
  IconData getIconForSky(String value) {
    if (value == 'Clear') {
      return Icons.sunny;
    } else if (value == 'Rain') {
      return FontAwesomeIcons.cloudShowersHeavy;
    } else {
      return Icons.cloud;
    }
  }

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Delhi';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      final data = jsonDecode(res.body);
      if (data['cod'] != '200') {
        throw 'An unexpected error occured';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState(){
    super.initState();
    weather=getCurrentWeather();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Mausam',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(onPressed: () {
            setState((){
              weather=getCurrentWeather();
            });
          }, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: const CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          final data = snapshot.data!;
          final currentData = data['list'][0];
          final currentTemp = currentData['main']['temp'];
          final currentSky = currentData['weather'][0]['main'];
          final currentPressure = currentData['main']['pressure'];
          final currentHumidity = currentData['main']['humidity'];
          final currentSpeed = currentData['wind']['speed'];
          final currentT=DateTime.parse(data['list'][0]['dt_txt']);
          final String currentTime=DateFormat.j().format(currentT);
          final IconData iconData=getIconForSky(currentSky);
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //main card
                SizedBox(
                  width: double.infinity,
                  // width:MediaQuery.of(context).size.width * 0.85,
                  // height:MediaQuery.of(context).size.height * 0.20,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              SizedBox(height: 15),
                              Icon(iconData, size: 50),
                              SizedBox(height: 10),
                              Text(
                                '$currentSky',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                              SizedBox(height:10),
                              Text(
                                currentTime,
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                //weather forecast cards
                const SizedBox(height: 25),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    //TextDirection.rtl
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height:150,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final String hourlySky=data['list'][index+1]['weather'][0]['main'];
                      final IconData hourlyIcon= getIconForSky(hourlySky);
                      final time=DateTime.parse(data['list'][index+1]['dt_txt']);
                      final String hourlyTemp=data['list'][index+1]['main']['temp'].toString();
                      return HourlyForecastItem(
                        time: DateFormat.j().format(time),
                        icon: hourlyIcon,
                        temp: hourlyTemp,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                //extra details
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    //TextDirection.rtl
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfoItem(
                      icon: Icons.water_drop,
                      label: 'Humididty',
                      value: '$currentHumidity',
                    ),
                    AdditionalInfoItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '$currentSpeed',
                    ),
                    AdditionalInfoItem(
                      icon: FontAwesomeIcons.gaugeHigh,
                      label: 'Pressure',
                      value: '$currentPressure',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
