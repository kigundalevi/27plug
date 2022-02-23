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
      createUser(firstName:"$firstName",lastName:"$lastName",isMale:$isMale,email:"$email",password:"$password",phoneNo:"$phoneNo",minYob:"$minYob",maxYob:"$maxYob",ip:"$ip",locationName:"$location_name",lat:"$lat",lng:"$lng",locationLive:$location_live,){
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

  String addVideo(String name, String startDateTime, String finishDateTime,
      String place, String leaderName) {
    return """ 
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