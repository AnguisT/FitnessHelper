import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:oauth/oauth.dart';
import 'package:http/http.dart' as http;
import 'package:oauth/src/core.dart';

class HttpClient {

  Random rng = new Random();
  int timestamp = 0;

  Future getFoodId(String foodId) {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['food_id'] = foodId;
    param['format'] = 'json';
    param['method'] = 'food.get';
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch * 1000;
    if (time > timestamp) {
      timestamp = time;
    } else {
      timestamp = timestamp + 100;
    }
    print(foodId + ': ' + timestamp.toString());
    var params = generateParameters(request, tokens, nonce, timestamp);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    // var response = await http.get(url);
    // var data = JSON.decode(response.body);
    // if (data['error'] != null) {
    //   print(data);
    // }
    // return data['food'];
    return http.get(url)
    .then((res) {
      var response = JSON.decode(res.body);
      if (response['error'] != null) {
        print(response['error']['message']);
      }
      return response['food'];
    })
    .catchError((onError) => print(onError));
  }

  Future search(String nameFood) async {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['format'] = 'json';
    param['method'] = 'foods.search';
    param['search_expression'] = nameFood;
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch;
    int timestampe = time * 1000;
    var params = generateParameters(request, tokens, nonce, timestampe);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    var response = await http.get(url);
    var data = JSON.decode(response.body);
    if (data['error'] != null) {
      print(data);
    }
    return data;
  }

  Future newUser(String login) async {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['format'] = 'json';
    param['method'] = 'profile.create';
    param['user_id'] = login;
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch;
    int timestampe = time * 1000;
    var params = generateParameters(request, tokens, nonce, timestampe);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    var response = await http.get(url);
    var data = JSON.decode(response.body);
    if (data['error'] != null) {
      print(data);
    }
    return data['profile'];
  }

  Future getUser(String login) async {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['format'] = 'json';
    param['method'] = 'profile.get_auth';
    param['user_id'] = login;
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch;
    int timestampe = time * 1000;
    var params = generateParameters(request, tokens, nonce, timestampe);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    var response = await http.get(url);
    var data = JSON.decode(response.body);
    if (data['error'] != null) {
      print(data);
    }
    return data['profile'];
  }

  Future newWeightHeight(String token, String shared, String height, String weight) async {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['current_height_cm'] = height;
    param['current_weight_kg'] = weight;
    param['format'] = 'json';
    param['goal_weight_kg'] = weight;
    param['method'] = 'weight.update';
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      userId: token,
      userKey: shared,
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch;
    int timestampe = time * 1000;
    var params = generateParameters(request, tokens, nonce, timestampe);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_token'] = params['oauth_token'];
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    var response = await http.get(url);
    var data = JSON.decode(response.body);
    if (data['error'] != null) {
      print(data);
    }
    return data;
  }

  Future updtaeWeight(String token, String shared, String weight) async {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['current_weight_kg'] = weight;
    param['format'] = 'json';
    param['method'] = 'weight.update';
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      userId: token,
      userKey: shared,
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch;
    int timestampe = time * 1000;
    var params = generateParameters(request, tokens, nonce, timestampe);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_token'] = params['oauth_token'];
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    var response = await http.get(url);
    var data = JSON.decode(response.body);
    if (data['error'] != null) {
      print(data);
    }
    return data;
  }

  Future getProfile(String token, String shared) async {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['format'] = 'json';
    param['method'] = 'profile.get';
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      userId: token,
      userKey: shared,
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch;
    int timestampe = time * 1000;
    var params = generateParameters(request, tokens, nonce, timestampe);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_token'] = params['oauth_token'];
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    var response = await http.get(url);
    var data = JSON.decode(response.body);
    if (data['error'] != null) {
      print(data);
    }
    return data['profile'];
  }

  Future getWidthMonth(String token, String shared, int date) async {
    Map<String, dynamic> param = new Map<String, dynamic>();
    param['date'] = date.toString();
    param['format'] = 'json';
    param['method'] = 'weights.get_month';
    Uri uri = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    http.Request request = new http.Request('GET', uri);
    Tokens tokens = new Tokens(
      consumerId: 'ca6a37b74cfd4c19be1df5adbc7e3b73',
      consumerKey: '61e16a01c67d4acfb75fcb84d4ae1c2c',
      userId: token,
      userKey: shared,
      type: 'HMAC-SHA1'
    );
    int length = rng.nextInt(5) + 1;
    String nonce = randomGenerator(length);
    int time = new DateTime.now().microsecondsSinceEpoch;
    int timestampe = time * 1000;
    var params = generateParameters(request, tokens, nonce, timestampe);
    param['oauth_consumer_key'] = params['oauth_consumer_key'];
    param['oauth_signature_method'] = tokens.type;
    param['oauth_token'] = params['oauth_token'];
    param['oauth_version'] = params['oauth_version'];
    param['oauth_nonce'] = params['oauth_nonce'];
    param['oauth_timestamp'] = params['oauth_timestamp'];
    param['oauth_signature'] = params['oauth_signature'];
    Uri uri1 = new Uri(
      scheme: 'http',
      host: 'platform.fatsecret.com',
      path: 'rest/server.api',
      queryParameters: param
    );
    String url = uri1.toString();
    var response = await http.get(url);
    var data = JSON.decode(response.body);
    if (data['error'] != null) {
      print(data);
    }
    return data;
  }

  Future getAllUser() async {
    var url = 'https://serverforflutter.herokuapp.com/user';
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getUserByLogin(String login) async {
    var url = 'https://serverforflutter.herokuapp.com/user/' + login;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future newUserServer(user) async {
    var params = user.login + '/' + user.password + '/' + user.caloriesnorm.toString() + '/' + user.resetcalories.toString() + '/' + user.idtypeexercise.toString();
    var url = 'https://serverforflutter.herokuapp.com/newuser/' + params;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }
  
  Future getAllTypeExercise() async {
    var url = 'https://serverforflutter.herokuapp.com/typeexercise';
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getExerciseByName(String name) async {
    var url = 'https://serverforflutter.herokuapp.com/exercise/' + name;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getAllExercise() async {
    var url = 'https://serverforflutter.herokuapp.com/exercise';
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getAllCustomExercise(iduser) async {
    var url = 'https://serverforflutter.herokuapp.com/customexercise/' + iduser.toString();
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getAllTimeDay() async {
    var url = 'https://serverforflutter.herokuapp.com/timeday';
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getStatisticsByCustomDate(datefrom, dateto) async {
    var url = 'https://serverforflutter.herokuapp.com/statistics/' + datefrom + '/' + dateto;
    print(url);
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getStatisticsByDate(date) async {
    var url = 'https://serverforflutter.herokuapp.com/statistics/' + date;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future getCaloriesByIdStatistics(idstatistics) async {
    var url = 'https://serverforflutter.herokuapp.com/calories/' + idstatistics.toString();
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future newTimeDay(timeday) async {
    var url = 'https://serverforflutter.herokuapp.com/timeday/' + timeday;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future newCustomExercise(customexercise) async {
    var url = 'https://serverforflutter.herokuapp.com/customexercise/' + customexercise.customExerciseName + '/' + customexercise.customMinutes + '/' + customexercise.customCalories + '/' + customexercise.iduser + '/' + customexercise.timedayid;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future updateIdTypeExercise(idtypeexercise, userid) async {
    var url = 'https://serverforflutter.herokuapp.com/usertypeexercise/' + idtypeexercise.toString() + '/' + userid;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future updateCaloriesNorm(caloriesnorm, userid) async {
    var url = 'https://serverforflutter.herokuapp.com/usercaloriesnorm/' + caloriesnorm.toString() + '/' + userid;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future updateResetCalories(resetcalories, userid) async {
    var url = 'https://serverforflutter.herokuapp.com/userresetcalories/' + resetcalories.toString() + '/' + userid;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future newStatistics(statistics) async {
    var url = 'https://serverforflutter.herokuapp.com/newstatistics/' + statistics.datetime + '/' + statistics.iduser.toString();
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future newCalories(calories) async {
    var url = 'https://serverforflutter.herokuapp.com/newcalories/' + calories.caloriescount.toString() + '/' + calories.idstatistics.toString();
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  Future deleteCustomExercise(customexerciseid) async {
    var url = 'https://serverforflutter.herokuapp.com/removecustomexercise/' + customexerciseid;
    var response = await http.get(url);
    return JSON.decode(response.body);
  }

  String randomGenerator(int length) {
    String symbols = 'abcdefghijklmnopqrstuvwxyz1234567890';
    String randString = '';
    for(int i=0;i<length;i++) {
      randString += symbols[rng.nextInt(symbols.length)];
    }
    return randString;
  }

}