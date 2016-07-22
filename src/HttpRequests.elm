import Http exposing (Request, string)

saveUserRequest : Request
saveUserRequest =
    { verb = "PUT"
    , headers = []
    , url = "https://faust-instant.firebaseio.com/users.json"
    , body = (string """{ "sortBy": "coolness", "take": 10 }""")
    }
