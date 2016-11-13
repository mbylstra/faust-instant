module Components.Main.Constants exposing (..)

-------------------------------------------------------------------------------
import FirebaseAuth
-------------------------------------------------------------------------------

defaultBufferSize : Int
defaultBufferSize = 512

sampleRate : Float
sampleRate = 44100.0

firebaseConfig : FirebaseAuth.Config
firebaseConfig =
  { apiKey = "AIzaSyDZmUzh7NIrLj82ourEnI1E4fffa1Zk2EE"
  , authDomain = "faust-instant.firebaseapp.com"
  , databaseURL = "https://faust-instant.firebaseio.com"
  }

theDemoProgramKey : String
theDemoProgramKey = "-KQDwqxuFDy1R8R2-5De"