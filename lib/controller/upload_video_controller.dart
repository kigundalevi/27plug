import 'dart:convert';
import 'dart:io';

import 'package:africanplug/config/config.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/op/mutations.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:http/http.dart' as http;
import "package:http_parser/http_parser.dart" show MediaType;

class UploadVideoController {
  static String titleValidator(String input) {
    if (input.isEmpty) {
      return 'Title is required';
    }
    return '';
  }

  static String descriptionValidator(String input) {
    if (input.isEmpty) {
      return 'Description is required';
    }
    return '';
  }

  Future<String?> userUploadVideo(
      List<String> tags,
      PlatformFile selectedVideo,
      PlatformFile selectedThumbnail,
      String title,
      String description,
      int duration,
      String ip,
      String lat,
      String lng,
      String location_name,
      bool location_live) async {
    try {
      //   GraphQLConfiguration graphQLConfig = GraphQLConfiguration();
      //   GraphQLClient _client = graphQLConfig.clientToQuery();

      //   List<int> videoBytes = File(selectedVideo.path!).readAsBytesSync();
      //   String base64Video = base64Encode(videoBytes);

      //   List<int> thumbnailBytes =
      //       File(selectedThumbnail.path!).readAsBytesSync();
      //   String base64Thumbnail = base64Encode(thumbnailBytes);

      //   final videoFile = http.MultipartFile.fromBytes(
      //     "video_file",
      //     videoBytes,
      //     filename: selectedVideo.name,
      //     // contentType: MediaType("text", "plain"),
      //   );

      //   final thumbnailFile = http.MultipartFile.fromBytes(
      //     "thumbnail_file",
      //     thumbnailBytes,
      //     filename: selectedThumbnail.name,
      //     // contentType: MediaType("text", "plain"),
      //   );

      //   final opts = MutationOptions(
      //     document: gql("""
      //   mutation{
      //     addVideo(title:"$title",description:"$description",ip:"$ip",locationName:"$location_name",lat:"$lat",lng:"$lng",locationLive:$location_live)
      //     {title}
      //     }
      // """),
      //   );
      print("Uploading video");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            "Authorization": "Bearer " + GraphQLConfiguration.sessionToken
          },
        ),
      );
      // dio.options.headers['content-Type'] = 'application/json';
      // dio.options.headers["authorization"] =
      //     "token ${GraphQLConfiguration.sessionToken}";

      // String live = location_live ? 'true' : 'false';
      // String query = 'mutation{addVideo(title:"' +
      //     title +
      //     '",description:"' +
      //     description +
      //     '",ip:"' +
      //     ip +
      //     '",lat:"' +
      //     lat +
      //     '",lng:"' +
      //     lng +
      //     '",locationName:"' +
      //     location_name +
      //     '",locationLive:' +
      //     live +
      //     '){video{id}}}';
      // FormData data = FormData.fromMap({
      //   "query": query,
      //   "video_file": await MultipartFile.fromFile(selectedVideo.path!,
      //       filename: selectedVideo.path!.split('/').last),
      //   "thumbnail_file": await MultipartFile.fromFile(selectedThumbnail.path!,
      //       filename: selectedThumbnail.path!.split('/').last),
      // });
      // var response = await dio.post(BACKEND_URL, data: data);
      // print(response);

      var req = new http.MultipartRequest("POST", Uri.parse(BACKEND_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        "Authorization": "Bearer " + GraphQLConfiguration.sessionToken
      };

      req.headers.addAll(headers);
      String live = location_live ? 'true' : 'false';
      req.fields['query'] = 'mutation{addVideo(title:"' +
          title +
          '",description:"' +
          description +
          '",duration:' +
          duration.toString() +
          ',ip:"' +
          ip +
          '",lat:"' +
          lat +
          '",lng:"' +
          lng +
          '",locationName:"' +
          location_name +
          '",locationLive:' +
          live +
          '){video{id}}}';

      // mutation{addVideo(title:"sfdd",description:"zcd",ip:"0.0.0.0",lat:"0.0",lng:"0.0",locationName:"kenya",locationLive:false){title}}

      // {query: mutation{addVideo(title:"sdcdscdsc",description:"cdcc",ip:"197.237.28.26",lat:"37.4216572",lng:"-122.0842089",locationName:"Nairobi Province,Kenya",locationLive:true){id,title}}, video_file: Instance of 'Future<MultipartFile>', thumbnail_file: Instance of 'Future<MultipartFile>'}

      req.files.add(
          await http.MultipartFile.fromPath('video_file', selectedVideo.path!));

      // req.files.add(http.MultipartFile(
      //     'video_file',
      //     File(selectedVideo.path!).readAsBytes().asStream(),
      //     File(selectedVideo.path!).lengthSync(),
      //     filename: selectedVideo.path!.split("/").last));

      req.files.add(await http.MultipartFile.fromPath(
          'thumbnail_file', selectedThumbnail.path!));

      // req.fields['video_file'] =
      //     await http.MultipartFile.fromPath('video_file', selectedVideo.path!)
      //         .toString();
      // req.fields['thumbnail_file'] =
      //     http.MultipartFile.fromPath('video_file', selectedThumbnail.path!)
      //         .toString();
      // var response = await req.send();
      http.Response response = await http.Response.fromStream(await req.send());
      var res = jsonDecode(response.body);
      // print(res['data']['addVideo']['video']['id']);

      if (response.statusCode == 200) {
        int video_id = int.parse(res['data']['addVideo']['video']['id']);

        GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
        GraphQLClient _client = GraphQLClient(
          cache: GraphQLCache(),
          link: HttpLink(REGISTER_URL),
        );

        tags.forEach((tag) async {
          String query = """
                        mutation{
                          addVideoTopic(topicName:"$tag",videoId:$video_id){
                            ok
                          }
                        }
                        """;

          QueryResult result =
              await _client.mutate(MutationOptions(document: gql(query)));
          print(result);
          // _allTags.add(VideoTag(
          //     id: int.parse(tag['id']),
          //     name: tag['name'],
          //     description: tag['description']));
        });

        return 'success';
      } else {
        print(response.body);
        // print(response.);
        print(response.statusCode);
        return 'Could not upload video. Try again later';
      }
    } catch (e) {
      print(e.toString());
      return e.toString();
    }

    httpPost() async {
      final _authority = "plug27.herokuapp.com";
      final _path = "/graphql";
      final _params = {
        "Token": GraphQLConfiguration.sessionToken,
        "Bearer": GraphQLConfiguration.sessionToken
      };
      final _uri = Uri.https(_authority, _path, _params);
      //   http.MultipartRequest request = await http.MultipartRequest("POST", _uri);

      //   request.fields['query'] = """
      //   mutation{
      //     addVideo(title:"$title",description:"$description",ip:"$ip",locationName:"$location_name",lat:"$lat",lng:"$lng",locationLive:$location_live)
      //     {
      //       id,
      //       title}
      //     }
      // """;
      //   request.files.add(videoFile);
      //   request.files.add(thumbnailFile);

      //   request.send().then((response) {
      //     if (response.statusCode == 200) {
      //       print(response);
      //       return 'success';
      //     } else {
      //       return 'Could not upload video. Try again later';
      //     }
      //   });

      var req = new http.MultipartRequest(
          "POST", Uri.parse("https://plug27.herokuapp.com/graphql"));
      Map<String, String> headers = {
        "Accept": "*/*",
        "Authorization": "Bearer " + GraphQLConfiguration.sessionToken
      };

      req.headers.addAll(headers);
      String live = location_live ? 'true' : 'false';
      req.fields['query'] = 'mutation{addVideo(title:"' +
          title +
          '",description:"' +
          description +
          '",ip:"' +
          ip +
          '",lat:"' +
          lat +
          '",lng:"' +
          lng +
          '",locationName:"' +
          location_name +
          '",locationLive:' +
          live +
          '){title}}';

      // mutation{addVideo(title:"sfdd",description:"zcd",ip:"0.0.0.0",lat:"0.0",lng:"0.0",locationName:"kenya",locationLive:false){title}}

      // {query: mutation{addVideo(title:"sdcdscdsc",description:"cdcc",ip:"197.237.28.26",lat:"37.4216572",lng:"-122.0842089",locationName:"Nairobi Province,Kenya",locationLive:true){id,title}}, video_file: Instance of 'Future<MultipartFile>', thumbnail_file: Instance of 'Future<MultipartFile>'}

      req.files.add(
          await http.MultipartFile.fromPath('video_file', selectedVideo.path!));

      // req.files.add(http.MultipartFile(
      //     'video_file',
      //     File(selectedVideo.path!).readAsBytes().asStream(),
      //     File(selectedVideo.path!).lengthSync(),
      //     filename: selectedVideo.path!.split("/").last));

      req.files.add(await http.MultipartFile.fromPath(
          'thumbnail_file', selectedThumbnail.path!));

      // req.fields['video_file'] =
      //     await http.MultipartFile.fromPath('video_file', selectedVideo.path!)
      //         .toString();
      // req.fields['thumbnail_file'] =
      //     http.MultipartFile.fromPath('video_file', selectedThumbnail.path!)
      //         .toString();
      var response = await req.send();
    }
  }
}
