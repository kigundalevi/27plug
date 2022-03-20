import 'dart:convert';
import 'dart:io';

import 'package:africanplug/config/base_functions.dart';
import 'package:africanplug/config/config.dart';
import 'package:africanplug/landing.dart';
import 'package:africanplug/main.dart';
import 'package:africanplug/models/location.dart';
import 'package:africanplug/models/user.dart';
import 'package:africanplug/models/video.dart';
import 'package:africanplug/op/mutations.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:africanplug/config/graphql_config.dart';
import 'package:http/http.dart' as http;
import "package:http_parser/http_parser.dart" show MediaType;

class UserController {
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

  Future<User> fetchChannelDetails(int userId) async {
    try {
      Loc location = await currentLocation();
      print(location);

      var user = appBox.get("user");

      var req = new http.MultipartRequest("POST", Uri.parse(BACKEND_URL));

      Map<String, String> headers = {
        "Accept": "*/*",
        "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location.live ? 'true' : 'false';
      req.fields['query'] = 'query{findUser(id:' +
          userId.toString() +
          ',ip:"' +
          location.ip +
          '",lat:"' +
          location.lat +
          '",lng:"' +
          location.lng +
          '",locationName:"' +
          location.name +
          '",locationLive:' +
          live +
          '){id,firstName,lastName,channelName,phoneNo,email,fbName,fbUrl,instagramName,instagramUrl,dpUrl,userType{name,id}}}';
      http.Response response = await http.Response.fromStream(await req.send());
      var resp = jsonDecode(response.body);

      var res = resp["data"];

      if (response.statusCode == 200) {
        String dp_url = txtDefaultDpUrl;
        if (res['findUser']["dpUrl"] != null &&
            res['findUser']["dpUrl"] != "") {
          dp_url = res['findUser']["dpUrl"];
        }

        return User(
          id: int.parse(res['findUser']['id']),
          first_name: res['findUser']['firstName'],
          last_name: res['findUser']['lastName'],
          channel_name: res['findUser']['channelName'],
          phone_no: res['findUser']['phoneNo'],
          email: res['findUser']['email'],
          fb_name: res['findUser']['fbName'],
          fb_url: res['findUser']['fbUrl'],
          instagram_name: res['findUser']['instagramName'],
          instagram_url: res['findUser']['instagramUrl'],
          dp_url: dp_url,
          user_type: res['findUser']['userType']['name'],
          user_type_id: int.parse(res['findUser']['userType']['id']),
        );
      } else {
        print(response.body);
        // print(response.);
        print(response.statusCode);
        return User(
          id: 1,
          first_name: "27Plug",
          last_name: "Guest",
          channel_name: "",
          email: "guest@27plug.app",
        );
      }
    } catch (e) {
      print(e);
      return User(
        id: 1,
        first_name: "27Plug",
        last_name: "Guest",
        channel_name: "",
        email: "guest@27plug.app",
      );
    }
  }

  Future<List<Video>?> fetchChannelVideos(int userId) async {
    try {
      Loc location = await currentLocation();
      var user = appBox.get("user");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            "Authorization": "Bearer " + user['token']
          },
        ),
      );

      var req = new http.MultipartRequest("POST", Uri.parse(BACKEND_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location.live ? 'true' : 'false';
      req.fields['query'] = 'query{findUserVideos(id:' +
          userId.toString() +
          ',ip:"' +
          location.ip +
          '",lat:"' +
          location.lat +
          '",lng:"' +
          location.lng +
          '",locationName:"' +
          location.name +
          '",locationLive:' +
          live +
          '){id,name,url,thumbnailName,thumbnailUrl,title,description,durationMillisec,createdAt,deletedAt,uploader{firstName,dpUrl},views{id,viewer{id}},likes{id,liker{id}},comments{id,commenter{id}}}}';
      http.Response response = await http.Response.fromStream(await req.send());
      var resp = jsonDecode(response.body);

      List<Video> _channelVideos = [];

      if (response.statusCode == 200) {
        var videos = resp["data"]['findUserVideos'];

        videos.forEach((video) {
          if (video['deletedAt'] == null || video['deletedAt'] == "") {
            // print(video['title']);
            DateTime dateTimeCreatedAt = DateTime.parse(video['createdAt']);
            DateTime dateTimeNow = DateTime.now();
            final days_lapse = dateTimeNow.difference(dateTimeCreatedAt).inDays;
            String lapse = "Today";
            if (days_lapse < 1) {
              String lapse = "Today";
            } else if (days_lapse == 1) {
              lapse = "yesterday";
            } else {
              lapse = days_lapse.toString() + " days ago";
            }
            String views = video['views'].length.toString() + " views";

            _channelVideos.add(Video(
              id: int.parse(video['id']),
              title: video['title'].length > 20
                  ? video['title']
                      .replaceRange(20, video['title'].length, '...')
                  : video['title'],
              url: video['url'],
              description: video['description'],
              duration_millisec: video['durationMillisec'],
              name: video['name'],
              thumbnail_url: video['thumbnailUrl'],
              thumbnail_name: video['thumbnailName'],
              views: views.length > 12
                  ? views.replaceRange(9, views.length, '...')
                  : views,
              upload_lapse: lapse.length > 12
                  ? lapse.replaceRange(9, lapse.length, '...')
                  : lapse,
              uploaded_by: video['uploader']['firstName'].length > 20
                  ? video['uploader']['firstName'].replaceRange(
                      20, video['uploader']['firstName'].length, '...')
                  : video['uploader']['firstName'],
              uploader_channel_name: video['uploader']['channelName'] == null
                  ? null
                  : video['uploader']['channelName'].length > 20
                      ? video['uploader']['channelName'].replaceRange(
                          20, video['uploader']['channelName'].length, '...')
                      : video['uploader']['channelName'],
              uploader_dpurl: video['uploader']['dpUrl'],
            ));
          }
        });

        return _channelVideos;
      } else {
        print(response.body);
        // print(response.);
        print(response.statusCode);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Video>?> fetchLatestVideos(int userId) async {
    try {
      Loc location = await currentLocation();
      var user = appBox.get("user");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            // "Authorization": "Bearer " + user['token']
          },
        ),
      );

      var req = new http.MultipartRequest("POST", Uri.parse(REGISTER_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        // "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location.live ? 'true' : 'false';
      req.fields['query'] = """
query{
  listVideo(sortField:"created_at",order:"desc",limit:100){
    id,
    title,
    url,
    description,
    name,
    durationMillisec,
    createdAt,
    deletedAt,
    thumbnailUrl,
    thumbnailName,
    uploader{
      id,
      dpUrl,
      channelName,
      firstName,
      lastName,
      email,
      emailVerifiedAt,
      userType{
        id,
        name
      }
    },
    views{
      viewer{
        firstName
      }
    },
    comments{
      commenter{
        lastName
      }
    }
  }
}
""";
      http.Response response = await http.Response.fromStream(await req.send());
      var resp = jsonDecode(response.body);
      // print('---------BACKEND RESPONSE---------');
      // print(resp);

      List<Video> _latestVideos = [];

      if (response.statusCode == 200) {
        var videos = resp["data"]['listVideo'];

        videos.forEach((video) {
          if (video['deletedAt'] == null || video['deletedAt'] == "") {
            DateTime dateTimeCreatedAt = DateTime.parse(video['createdAt']);
            DateTime dateTimeNow = DateTime.now();
            final days_lapse = dateTimeNow.difference(dateTimeCreatedAt).inDays;
            String lapse = "Today";
            if (days_lapse < 1) {
              String lapse = "Today";
            } else if (days_lapse == 1) {
              lapse = "yesterday";
            } else {
              lapse = days_lapse.toString() + " days ago";
            }
            String views = video['views'].length.toString() + " views";

            _latestVideos.add(Video(
              id: int.parse(video['id']),
              title: video['title'].length > 20
                  ? video['title']
                      .replaceRange(20, video['title'].length, '...')
                  : video['title'],
              url: video['url'],
              description: video['description'],
              duration_millisec: video['durationMillisec'],
              name: video['name'],
              thumbnail_url: video['thumbnailUrl'],
              thumbnail_name: video['thumbnailName'],
              views: views.length > 12
                  ? views.replaceRange(9, views.length, '...')
                  : views,
              upload_lapse: lapse.length > 12
                  ? lapse.replaceRange(9, lapse.length, '...')
                  : lapse,
              uploaded_by: video['uploader']['firstName'].length > 20
                  ? video['uploader']['firstName'].replaceRange(
                      20, video['uploader']['firstName'].length, '...')
                  : video['uploader']['firstName'],
              uploader_channel_name: video['uploader']['channelName'] == null
                  ? null
                  : video['uploader']['channelName'].length > 20
                      ? video['uploader']['channelName'].replaceRange(
                          20, video['uploader']['channelName'].length, '...')
                      : video['uploader']['channelName'],
              uploader_dpurl: video['uploader']['dpUrl'],
            ));
          }
        });

        return _latestVideos;
      } else {
        print(response.body);
        try {
          var msg = jsonDecode(response.body)["msg"];
          if (msg == "Token has expired") {
            appBox.delete('user');
            appBox.delete('cached_location');
            GraphQLConfiguration.removeToken();
            // Navigator.pop(context);
            // Navigator.pushNamed(context, '/landing');
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => LandingScreen(),
            //     ),
            //     (route) => false);
          }
        } catch (e) {}
        // print(response.);
        print(response.statusCode);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Video>?> fetchTopVideos(int userId) async {
    try {
      Loc location = await currentLocation();
      var user = appBox.get("user");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            // "Authorization": "Bearer " + user['token']
          },
        ),
      );

      var req = new http.MultipartRequest("POST", Uri.parse(REGISTER_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        // "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location.live ? 'true' : 'false';
      req.fields['query'] = """
query{
  listTopVideos(limit:100){
    id,
    title,
    url,
    description,
    name,
    durationMillisec,
    createdAt,
    deletedAt,
    thumbnailUrl,
    thumbnailName,
    uploader{
      id,
      dpUrl,
      channelName,
      firstName,
      lastName,
      email,
      emailVerifiedAt,
      userType{
        id,
        name
      }
    },
    views{
      viewer{
        firstName
      }
    },
    comments{
      commenter{
        lastName
      }
    }
  }
}
""";
      http.Response response = await http.Response.fromStream(await req.send());
      var resp = jsonDecode(response.body);
      print('---BE RESPONSE---');
      print(resp);
      List<Video> _topVideos = [];

      if (response.statusCode == 200) {
        var videos = resp["data"]['listTopVideos'];

        videos.forEach((video) {
          if (video['deletedAt'] == null || video['deletedAt'] == "") {
            DateTime dateTimeCreatedAt = DateTime.parse(video['createdAt']);
            DateTime dateTimeNow = DateTime.now();
            final days_lapse = dateTimeNow.difference(dateTimeCreatedAt).inDays;
            String lapse = "Today";
            if (days_lapse < 1) {
              String lapse = "Today";
            } else if (days_lapse == 1) {
              lapse = "yesterday";
            } else {
              lapse = days_lapse.toString() + " days ago";
            }
            String views = video['views'].length.toString() + " views";

            _topVideos.add(Video(
              id: int.parse(video['id']),
              title: video['title'].length > 20
                  ? video['title']
                      .replaceRange(20, video['title'].length, '...')
                  : video['title'],
              url: video['url'],
              description: video['description'],
              duration_millisec: video['durationMillisec'],
              name: video['name'],
              thumbnail_url: video['thumbnailUrl'],
              thumbnail_name: video['thumbnailName'],
              views: views.length > 12
                  ? views.replaceRange(9, views.length, '...')
                  : views,
              upload_lapse: lapse.length > 12
                  ? lapse.replaceRange(9, lapse.length, '...')
                  : lapse,
              uploaded_by: video['uploader']['firstName'].length > 20
                  ? video['uploader']['firstName'].replaceRange(
                      20, video['uploader']['firstName'].length, '...')
                  : video['uploader']['firstName'],
              uploader_channel_name: video['uploader']['channelName'] == null
                  ? null
                  : video['uploader']['channelName'].length > 20
                      ? video['uploader']['channelName'].replaceRange(
                          20, video['uploader']['channelName'].length, '...')
                      : video['uploader']['channelName'],
              uploader_dpurl: video['uploader']['dpUrl'],
            ));
          }
        });

        return _topVideos;
      } else {
        print(response.body);
        try {
          var msg = jsonDecode(response.body)["msg"];
          if (msg == "Token has expired") {
            appBox.delete('user');
            appBox.delete('cached_location');
            GraphQLConfiguration.removeToken();
            // Navigator.pop(context);
            // Navigator.pushNamed(context, '/landing');
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => LandingScreen(),
            //     ),
            //     (route) => false);
          }
        } catch (e) {}
        // print(response.);
        print(response.statusCode);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<List<Video>?> fetchTrendingVideos(int userId) async {
    try {
      Loc location = await currentLocation();
      var user = appBox.get("user");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            // "Authorization": "Bearer " + user['token']
          },
        ),
      );

      var req = new http.MultipartRequest("POST", Uri.parse(REGISTER_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        // "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location.live ? 'true' : 'false';
      req.fields['query'] = """
query{
  listTrendingVideos(limit:100){
    id,
    title,
    url,
    description,
    name,
    durationMillisec,
    createdAt,
    deletedAt,
    thumbnailUrl,
    thumbnailName,
    uploader{
      id,
      dpUrl,
      channelName,
      firstName,
      lastName,
      email,
      emailVerifiedAt,
      userType{
        id,
        name
      }
    },
    views{
      viewer{
        firstName
      }
    },
    comments{
      commenter{
        lastName
      }
    }
  }
}
""";
      http.Response response = await http.Response.fromStream(await req.send());
      var resp = jsonDecode(response.body);

      List<Video> _trendingVideos = [];

      if (response.statusCode == 200) {
        var videos = resp["data"]['listTrendingVideos'];

        videos.forEach((video) {
          if (video['deletedAt'] == null || video['deletedAt'] == "") {
            DateTime dateTimeCreatedAt = DateTime.parse(video['createdAt']);
            DateTime dateTimeNow = DateTime.now();
            final days_lapse = dateTimeNow.difference(dateTimeCreatedAt).inDays;
            String lapse = "Today";
            if (days_lapse < 1) {
              String lapse = "Today";
            } else if (days_lapse == 1) {
              lapse = "yesterday";
            } else {
              lapse = days_lapse.toString() + " days ago";
            }
            String views = video['views'].length.toString() + " views";

            _trendingVideos.add(Video(
              id: int.parse(video['id']),
              title: video['title'].length > 20
                  ? video['title']
                      .replaceRange(20, video['title'].length, '...')
                  : video['title'],
              url: video['url'],
              description: video['description'],
              duration_millisec: video['durationMillisec'],
              name: video['name'],
              thumbnail_url: video['thumbnailUrl'],
              thumbnail_name: video['thumbnailName'],
              views: views.length > 12
                  ? views.replaceRange(9, views.length, '...')
                  : views,
              upload_lapse: lapse.length > 12
                  ? lapse.replaceRange(9, lapse.length, '...')
                  : lapse,
              uploaded_by: video['uploader']['firstName'].length > 20
                  ? video['uploader']['firstName'].replaceRange(
                      20, video['uploader']['firstName'].length, '...')
                  : video['uploader']['firstName'],
              uploader_channel_name: video['uploader']['channelName'] == null
                  ? null
                  : video['uploader']['channelName'].length > 20
                      ? video['uploader']['channelName'].replaceRange(
                          20, video['uploader']['channelName'].length, '...')
                      : video['uploader']['channelName'],
              uploader_dpurl: video['uploader']['dpUrl'],
            ));
          }
        });

        return _trendingVideos;
      } else {
        print(response.body);
        try {
          var msg = jsonDecode(response.body)["msg"];
          if (msg == "Token has expired") {
            appBox.delete('user');
            appBox.delete('cached_location');
            GraphQLConfiguration.removeToken();
            // Navigator.pop(context);
            // Navigator.pushNamed(context, '/landing');
            // Navigator.pushAndRemoveUntil(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => LandingScreen(),
            //     ),
            //     (route) => false);
          }
        } catch (e) {}
        // print(response.);
        print(response.statusCode);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<bool> addVideoView(int video_id) async {
    User current_user = currentUser();
    int user_id = current_user.id;
    Loc loc = await currentLocation();
    String lat = loc.lat;
    String lng = loc.lng;
    String ip = loc.ip;
    String locationName = loc.name;
    bool locationLive = loc.live;

//   String query = """
// mutation{
//   addVideoView(videoId:$video_id,userId:$user_id,lat:"$lat",lng:"$lng",ip:"$ip",locationName:"$locationName",locationLive:$locationLive){
//     ok
//   }
// }
// """;

    String query = """
mutation{
  addVideoView(videoId:$video_id,userId:$user_id,ip:"$ip",lat:"$lat",lng:"$lng",locationName:"$locationName",locationLive:$locationLive){
    ok
  }
}
""";

    // print(query);

    GraphQLConfiguration graphQLConfig = new GraphQLConfiguration();
    // GraphQLClient _client = graphQLConfig.clientToQuery();
    QueryResult result = await GraphQLClient(
      cache: GraphQLCache(),
      link: HttpLink("https://plug27.herokuapp.com/graphq"),
    ).mutate(MutationOptions(document: gql(query)));

    if (result.hasException) {
      print(result);
      try {
        OperationException? registerexception = result.exception;
        List<GraphQLError>? errors = registerexception?.graphqlErrors;
        String main_error = errors![0].message;
        print(main_error);
      } catch (error) {
        print('Invalid parameters');
      }
      return false;
    } else {
      return true;
    }
    // print("VIEW RESULT");
    // print(result);
  }

  Future<String?> userUpdateDisplayPicture(String dpUrl, String ip, String lat,
      String lng, String location_name, bool location_live) async {
    try {
      var user = appBox.get("user");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            "Authorization": "Bearer " + user['token']
          },
        ),
      );

      var req = new http.MultipartRequest("POST", Uri.parse(BACKEND_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location_live ? 'true' : 'false';
      req.fields['query'] = 'mutation{updateDisplayPicture(dpUrl:"' +
          dpUrl +
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
          '){user{id}}}';
      http.Response response = await http.Response.fromStream(await req.send());
      var res = jsonDecode(response.body);
      print(res);

      if (response.statusCode == 200) {
        return 'success';
      } else {
        print(response.body);
        // print(response.);
        print(response.statusCode);
        return 'Could not update picture. Try again later';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool?> deleteVideo(int videoId) async {
    try {
      Loc location = await currentLocation();
      var user = appBox.get("user");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            "Authorization": "Bearer " + user['token']
          },
        ),
      );

      var req = new http.MultipartRequest("POST", Uri.parse(BACKEND_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location.live ? 'true' : 'false';
      req.fields['query'] = 'mutation{deleteVideo(videoId:' +
          videoId.toString() +
          ',ip:"' +
          location.ip +
          '",lat:"' +
          location.lat +
          '",lng:"' +
          location.lng +
          '",locationName:"' +
          location.name +
          '",locationLive:' +
          live +
          '){ok}}';
      http.Response response = await http.Response.fromStream(await req.send());
      print("-----------DELETED VIDEO RESULT---------");
      var resp = jsonDecode(response.body);
      print(resp);

      if (response.statusCode == 200) {
        return true;
      } else {
        print(response.body);
        // print(response.);
        print(response.statusCode);
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> updateUserDetails(
      String _channelName,
      String _fbName,
      String _fbUrl,
      String _instagramName,
      String _instagramUrl,
      String _firstName,
      String _lastName,
      String _password,
      String _phoneNo,
      Loc location) async {
    try {
      var user = appBox.get("user");
      Dio dio = Dio(
        BaseOptions(
          contentType: 'multipart/form-data',
          headers: {
            "Accept": "*/*",
            "Authorization": "Bearer " + user['token']
          },
        ),
      );

      var req = new http.MultipartRequest("POST", Uri.parse(BACKEND_URL));
      Map<String, String> headers = {
        "Accept": "*/*",
        "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location.live ? 'true' : 'false';
      req.fields['query'] = 'mutation{updateUser(channelName:"' +
          _channelName +
          '",fbName:"' +
          _fbName +
          '",fbUrl:"' +
          _fbUrl +
          '",instagramName:"' +
          _instagramName +
          '",instagramUrl:"' +
          _instagramUrl +
          '",firstName:"' +
          _firstName +
          '",lastName:"' +
          _lastName +
          '",password:"' +
          _password +
          '",phoneNo:"' +
          _phoneNo +
          '",ip:"' +
          location.ip +
          '",lat:"' +
          location.lat +
          '",lng:"' +
          location.lng +
          '",locationName:"' +
          location.name +
          '",locationLive:' +
          live +
          '){user{id}}}';
      http.Response response = await http.Response.fromStream(await req.send());
      var res = jsonDecode(response.body);
      print(res);

      if (response.statusCode == 200) {
        return 'success';
      } else {
        print(response.body);
        // print(response.);
        print(response.statusCode);
        return 'Could not update details. Try again later';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> userUploadVideo(
      List<String> tags,
      String uploadedVideoUrl,
      String uploadedVideoName,
      String uploadedThumbnailUrl,
      String uploadedThumbnailName,
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
      var user = appBox.get("user");
      print(user['token']);
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
        "Authorization": "Bearer " + user['token']
      };

      req.headers.addAll(headers);
      String live = location_live ? 'true' : 'false';
      req.fields['query'] = 'mutation{addVideo(videoUrl:"' +
          uploadedVideoUrl +
          '",videoName:"' +
          uploadedVideoName +
          '",thumbnailUrl:"' +
          uploadedThumbnailUrl +
          '",thumbnailName:"' +
          uploadedThumbnailName +
          '",title:"' +
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

      // req.files.add(
      //     await http.MultipartFile.fromPath('video_file', selectedVideo.path!));

      // req.files.add(http.MultipartFile(
      //     'video_file',
      //     File(selectedVideo.path!).readAsBytes().asStream(),
      //     File(selectedVideo.path!).lengthSync(),
      //     filename: selectedVideo.path!.split("/").last));

      // req.files.add(await http.MultipartFile.fromPath(
      //     'thumbnail_file', selectedThumbnail.path!));

      // req.fields['video_file'] =
      //     await http.MultipartFile.fromPath('video_file', selectedVideo.path!)
      //         .toString();
      // req.fields['thumbnail_file'] =
      //     http.MultipartFile.fromPath('video_file', selectedThumbnail.path!)
      //         .toString();
      // var response = await req.send();
      http.Response response = await http.Response.fromStream(await req.send());
      var res = jsonDecode(response.body);
      print(res);

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

      // req.files.add(
      //     await http.MultipartFile.fromPath('video_file', selectedVideo.path!));

      // req.files.add(http.MultipartFile(
      //     'video_file',
      //     File(selectedVideo.path!).readAsBytes().asStream(),
      //     File(selectedVideo.path!).lengthSync(),
      //     filename: selectedVideo.path!.split("/").last));

      // req.files.add(await http.MultipartFile.fromPath(
      //     'thumbnail_file', selectedThumbnail.path!));

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
