import 'package:africanplug/config/config.dart';
import "package:flutter/material.dart";
import "package:graphql_flutter/graphql_flutter.dart";

class GraphQLConfiguration {
  // final String url;
  // GraphQLConfiguration({required this.url});

  static Link? link;
  static String sessionToken = '';
  static HttpLink httpLink = HttpLink(BACKEND_URL);
  static HttpLink registerLink = HttpLink(REGISTER_URL);

  static void setToken(String token) {
    GraphQLConfiguration.sessionToken = token;
    AuthLink alink = AuthLink(getToken: () async => 'Bearer ' + token);
    GraphQLConfiguration.link = alink.concat(GraphQLConfiguration.httpLink);
  }

  static void removeToken() {
    GraphQLConfiguration.link = null;
  }

  static String getToken() {
    return sessionToken;
  }

  static getLink({bool register = false}) {
    if (register == null || register == false) {
      return GraphQLConfiguration.link;
      // return GraphQLConfiguration.link != null
      //     ? GraphQLConfiguration.link
      //     : GraphQLConfiguration.httpLink;
    } else {
      return GraphQLConfiguration.registerLink;
      // return GraphQLConfiguration.link != null
      //     ? GraphQLConfiguration.link
      //     : GraphQLConfiguration.registerLink;
    }
  }

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: getLink(),
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  GraphQLClient clientToQuery({bool register = false}) {
    return GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: getLink(register: register),
    );
  }
}
