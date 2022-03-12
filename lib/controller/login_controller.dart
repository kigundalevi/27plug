import 'dart:convert';

import 'package:africanplug/config/config.dart';
import 'package:africanplug/main.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/user.dart';
import 'package:africanplug/op/mutations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginController {
  static String? emailValidator(String? input) {
    if (input == '') {
      return 'Email cannot be empty';
    }
    if (!input!.contains('@')) {
      return "Provide a valid email";
    }
    return null;
  }

  static String? passwordValidator(String? input) {
    if (input == '') {
      return 'Password cannot be empty';
    }
    if (input!.length < 6) {
      return 'Password is too short';
    }
    return null;
  }

  Future<String?> authLoginUser(
      String email, String password, Loc location) async {
    var data = {
      'email': email,
      'password': password,
      'location': {
        'ip': location.ip,
        'lat': location.lat,
        'lng': location.lng,
        'name': location.name,
        'live': location.live
      }
    };

    http.Response response = await http.post(
      Uri.parse(LOGIN_URL),
      body: json.encode(data),
      headers: {"Content-Type": "application/json"},
    );
    Map<String, dynamic> res =
        jsonDecode(response.body); // import 'dart:convert';
    print(res['token']);

    String token = res['token'];

    if (token != null) {
      GraphQLConfiguration.setToken(token);
      res['user']['token'] = token;

      String dp_url = txtDefaultDpUrl;
      if (res['user']["dp_url"] != null && res['user']["dp_url"] != "") {
        dp_url = res['user']["dp_url"];
      }

      User loggedin_user = User(
          id: res['user']['id'],
          first_name: res['user']['first_name'],
          last_name: res['user']['last_name'],
          channel_name: res['user']['channel_name'],
          phone_no: res['user']['phoneNo'],
          email: res['user']['email'],
          fb_name: res['user']['fb_name'],
          fb_url: res['user']['fb_url'],
          instagram_name: res['user']['instagram_name'],
          instagram_url: res['user']['instagram_url'],
          dp_url: dp_url,
          user_type: res['user']['user_type']['name'],
          user_type_id: res['user']['user_type']['id'],
          token: token);
      appBox.put('user', res['user']);
      return 'success';
    } else {
      return 'Wrong email or password';
    }

    // GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
    // GraphQLClient _client = graphQLConfig.clientToQuery();
    // Mutations mutation = Mutations();
    // print(email);
    // print(password);
    // QueryResult result = await _client.mutate(MutationOptions(
    //     document: gql(
    //   mutation.loginUser(email, password),
    // )));
    // if (result.hasException) {
    //   print(result);
    //   OperationException? loginexception = result.exception;
    //   List<GraphQLError>? errors = loginexception?.graphqlErrors;
    //   String main_error = errors![0].message;
    //   return main_error;
    // } else {
    //   String token = result.data?['auth']['accessToken'];
    //   GraphQLConfiguration.setToken(token);
    //   print('login token : ' + token);
    //   return 'success';
    // }
  }

  authLogoutUser() async {
    // GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
    // GraphQLClient _client = graphQLConfig.clientToQuery();
    // Mutations mutation = Mutations();
    // print(email);
    // print(password);
    // QueryResult result = await _client.mutate(MutationOptions(
    //     document: gql(
    //   mutation.loginUser(email, password),
    // )));
    // if (result.hasException) {
    //   print(result);
    //   OperationException? loginexception = result.exception;
    //   List<GraphQLError>? errors = loginexception?.graphqlErrors;
    //   String main_error = errors![0].message;
    //   return main_error;
    // } else {
    //   String token = result.data?['auth']['accessToken'];
    GraphQLConfiguration.removeToken();
    return true;
    // }
  }
}
