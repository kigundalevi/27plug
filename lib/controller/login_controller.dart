import 'dart:convert';

import 'package:africanplug/config/config.dart';
import 'package:africanplug/models/location.dart';
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
      Uri.parse('https://plug27.herokuapp.com/login'),
      body: json.encode(data),
      headers: {"Content-Type": "application/json"},
    );
    Map<String, dynamic> res =
        jsonDecode(response.body); // import 'dart:convert';
    print(res['access_token']);

    String token = res['access_token'];

    if (token != null) {
      GraphQLConfiguration.setToken(token);
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
