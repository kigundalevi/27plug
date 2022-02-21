import 'package:africanplug/models/location.dart';
import 'package:africanplug/op/mutations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:africanplug/config/graphql_config.dart';

class RegisterController {
  static String firstNameValidator(String input) {
    if (input.isEmpty) {
      return 'FirstName cannot be empty';
    }
    return '';
  }

  static String lastNameValidator(String input) {
    if (input.isEmpty) {
      return 'LastName cannot be empty';
    }
    return '';
  }

  static String emailValidator(String input) {
    if (input.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!input.contains('@')) {
      return "Provide a valid email";
    }
    return '';
  }

  static String passwordValidator(String input) {
    if (input.isEmpty) {
      return 'Password cannot be empty';
    }
    if (input.length < 6) {
      return 'Password is too short';
    }
    return '';
  }

  static String passwordConfirmationValidator(String input) {
    if (input.isEmpty) {
      return 'Password Confirmation cannot be empty';
    }
    if (input.length < 6) {
      return 'Password Confirmation is too short';
    }
    return '';
  }

  Future<String?> authRegisterUser(
      String _registerFirstName,
      String _registerLastName,
      int minAge,
      int maxAge,
      String _registerPhoneNo,
      String _registerEmail,
      String _registerPassword,
      Loc location) async {
    GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
    GraphQLClient _client = graphQLConfig.clientToQuery(register: true);
    Mutations mutation = Mutations();

    Mutations queryMutation = Mutations();
    DateTime now = new DateTime.now();
    int currentYear = now.year;
    int minYob = currentYear - minAge;
    int maxYob = currentYear - maxAge;
    QueryResult result = await _client.mutate(MutationOptions(
        document: gql(
      queryMutation.registerUser(
          _registerFirstName,
          _registerLastName,
          minYob.toString(),
          maxYob.toString(),
          _registerPhoneNo,
          _registerEmail,
          _registerPassword,
          location.ip,
          location.lat,
          location.lng,
          location.name,
          location.live),
    )));
    if (result.hasException) {
      print(result.exception);
      return 'Error registering user';
    } else {
      String token = result.data?['register']['accessToken'];
      //login user
      GraphQLConfiguration.setToken(token);
      print('register' + token);

      return null;
    }
  }
}