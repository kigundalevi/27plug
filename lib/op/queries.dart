class Queries {
  String getAllVideos() {
    return r"""
      """;
  }

  String geVideoByID(int id) {
    return """
      """;
  }

  String getAllTags() {
    return """
    query{
      listTopic(sortField:"created_at",order:"desc"){
        id,
        name,
        description
      }
    }
    """;
  }
}
