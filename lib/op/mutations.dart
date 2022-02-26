import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart';

class Mutations {
  String registerUser(
      String firstName, //
      String lastName, //
      bool isMale,
      String minYob, //
      String maxYob, //
      String phoneNo, //
      String email, //
      String password, //
      String ip,
      String lat,
      String lng,
      String location_name,
      bool location_live) {
    return """
      mutation{
      createUser(firstName:"$firstName",lastName:"$lastName",isMale:$isMale,email:"$email",password:"$password",phoneNo:"$phoneNo",minYob:"$minYob",maxYob:"$maxYob",ip:"$ip",locationName:"$location_name",lat:"$lat",lng:"$lng",locationLive:$location_live){
        user{
          id,
          email,
          password
        }
      }   
      }
    """;
  }

  String loginUser(String email, String password) {
    return """
      mutation{
      auth(email:"$email",password:"$password"){
        accessToken,
        refreshToken
      }
      }
    """;
  }

  String addTopic(String name, int user_id, String ip, String lat, String lng,
      String location_name, bool location_live) {
    return """
      mutation{
        addTopic(name:"$name",userId:$user_id,ip:"$ip",lat:"$lat",lng:"$lng",locationName:"$location_name",locationLive:$location_live){
          topic{
            id,
            name,
            description,
          }
        }
      }
    """;
  }

  String uploadVideo(
      File selectedVideo,
      // String selectedVideoName,
      File selectedThumbnail,
      // String selectedThumbnailName,
      String title,
      String description,
      String ip,
      String lat,
      String lng,
      String location_name,
      bool location_live) {
    var videoByteData = selectedVideo.readAsBytesSync();
    var thumbnailByteData = selectedThumbnail.readAsBytesSync();

    var multipartVideo = MultipartFile.fromBytes(
      'video_file',
      videoByteData,
      // filename: selectedVideoName,
      // contentType: MediaType("image", "jpg"),
    );
    var multipartThumbnail = MultipartFile.fromBytes(
      'thumbanail_file',
      thumbnailByteData,
      // filename: selectedThumbnailName,
      // contentType: MediaType("image", "jpg"),
    );

    return """ 
      mutation{
        addVideo(title:"$title",description:"$description",ip:"$ip",locationName:"$location_name",lat:"$lat",lng:"$lng",locationLive:$location_live)
        {title}
        }
    """;
  }
}
// mutation{
// createUser(firstName:"Main",lastName:"Plug",email:"plug@27plug.com",password:"MainPlug27",phoneNo:"+254753874632",minYob:"1990",maxYob:"2000",ip:"unknown",location_name:"n,k",lat:"1.3",lng:"4.5",location_live:false){
//         user{
//           email,
//           password
//         }
// }}  