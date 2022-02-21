class Mutations {
  String registerUser(
      String firstName, //
      String lastName, //
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
      createUser(firstName:"$firstName",lastName:"$lastName",email:"$email",password:"$password",phoneNo:"$phoneNo",minYob:"$minYob",maxYob:"$maxYob",ip:"$ip",location_name:"$location_name",lat:"$lat",lng:"$lng",location_live:"$location_live",){
        user{
          email,
          password
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
