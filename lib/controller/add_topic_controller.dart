import 'package:africanplug/config/config.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/tag.dart';
import 'package:africanplug/op/mutations.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:africanplug/config/graphql_config.dart';

class AddTopicController {
  static String nameValidator(String input) {
    if (input.isEmpty) {
      return 'Name is required';
    }
    return '';
  }

  Future<VideoTag?> authAddTopic(String name, int user_id, Loc location) async {
    GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
    GraphQLClient _client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: HttpLink(REGISTER_URL),
    );
    Mutations mutations = Mutations();
    QueryResult result = await _client.mutate(MutationOptions(
        document: gql(
      mutations.addTopic(name, user_id, location.ip, location.lat, location.lng,
          location.name, location.live),
    )));
    print(result);
    if (result.hasException) {
      print(result);
      try {
        OperationException? registerexception = result.exception;
        List<GraphQLError>? errors = registerexception?.graphqlErrors;
        String main_error = errors![0].message;
        return null;
      } catch (error) {
        return null;
      }
    } else {
      var topic = result.data?['addTopic']['topic'];

      return VideoTag(
          id: int.parse(topic['id']),
          name: topic['name'],
          description: topic['description']);
    }
  }
}
