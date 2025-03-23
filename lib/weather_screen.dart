import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/additional_info_item.dart';
import 'package:weather/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather/secrates.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;

  
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
    String cityName = 'delhi';
    final res = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$weatherAPIKey'),
    );

    final data = jsonDecode(res.body);

    if(data['cod']!='200'){
      throw 'An unexpected error occured ! hehehe sry for your pareshani ';
    }
    return data;
    //data['list'][0]['main']['temp'];
    
    
    } catch (e){
      throw e.toString();
    }

  }
  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            // Show pop-up dialog
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('About Weather App'),
                  content: Text(
                      'This app provides real-time weather updates Currently for Delhi\nCreated by-Aman The coder\nContact info - amansingh484748@gmail.com'),
                      
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the pop-up
                      },
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.info),
        ),
        actions: [
          IconButton(
          onPressed: () {
            setState(() {
              weather = getCurrentWeather();
            });
          },
          icon: const Icon(Icons.refresh),
        ),
        
        ],
      ),

      body:FutureBuilder(
        future: weather ,
        builder:(context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }

          final data = snapshot.data!;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentcelsius = (currentTemp -273.15).toStringAsFixed(1);
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentWindspeed = currentWeatherData['wind']['speed']; 
          final currentHumidity = currentWeatherData['main']['humidity'];

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //maincard
              SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter (
                      filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                      child: Padding(
                        padding:  EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('$currentcelsius ° C',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                            const SizedBox(height: 16,),
                            Icon(
                              currentSky == 'Clouds' || currentSky == 'Rain'? Icons.cloud:Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(height: 16,),
                            Text(currentSky,style: TextStyle(
                              fontSize: 20,
                            ),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
              const Text('Weather Forecast',style: 
              TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
        
              const SizedBox(height: 8,),
        
              // SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       for(int i = 0; i<5;i++)
              //         HourlyForecastItem(
              //           time: data['list'][i+1]['dt'].toString(),
              //           temprature: (data['list'][i+1]['main']['temp']-273.15).toStringAsFixed(1),
              //           icon:data['list'][i+1]['weather'][0]['main']=='Clouds' || data['list'][i+1]['weather'][0]['main']=='Rain'? Icons.cloud:Icons.sunny,
              //         ),
                      
                      
                      
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final hourlyForecast = data['list'][index+1];
                    final time = DateTime.parse(hourlyForecast['dt_txt']);
                    return HourlyForecastItem(
                      time: DateFormat.j().format(time), 
                      temprature: (hourlyForecast['main']['temp']-273.15).toStringAsFixed(1), 
                      icon:hourlyForecast['weather'][0]['main']=='Clouds' || hourlyForecast['weather'][0]['main']=='Rain'? Icons.cloud:Icons.sunny,
                      );
                  },
                ),
              ),


              const SizedBox(height: 20,),
          
          
              const SizedBox(height: 20,),
              const Text('Additional information',style: 
              TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                AdditionalInfoItem(
                  icon: Icons.water_drop,
                  lable: 'Humidity',
                  value: currentHumidity.toString(),
                ),
                AdditionalInfoItem(
                  icon: Icons.air,
                  lable:'Wind Speed',
                  value: currentWindspeed.toString(),
                ),
                AdditionalInfoItem(
                  icon: Icons.beach_access,
                  lable: 'Pressure',
                  value: currentPressure.toString(),
                ),
              ],),
            ],
          ),
        );
        },
      ),
    );
  }
}



