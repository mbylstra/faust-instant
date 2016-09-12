var _mbylstra$elmmidi$Native_Midi = function() {

  var NativeScheduler = _elm_lang$core$Native_Scheduler;
  var Nothing = _elm_lang$core$Maybe$Nothing;
  var Just = _elm_lang$core$Maybe$Just;

  var firebaseApp = null;
  var globalUser = null;

  function nullableToMaybe(v) {
    return v == null ? Nothing : Just(v);
  }

  function initializeSdk(config) {
    if (typeof(firebase) !== "undefined") {
      if (firebaseApp == null) {
        console.log("firebase not yet initalised. initialising");
        firebaseApp = firebase.initializeApp(config);
      } else {
        console.log("firebase already initialised");
      }
    } else {
      throw "FirebaseSdkNotAvailable";
    }

  }

  function authProviderSignIn(config, providerUnion) {

    return NativeScheduler.nativeBinding(function(callback) {

      try {
        initializeSdk(config);
        var provider;
        switch (providerUnion.ctor) {
          case 'Github':
            provider = new firebase.auth.GithubAuthProvider();
            break;
          case 'Facebook':
            provider = new firebase.auth.FacebookAuthProvider();
            break;
          case 'Twitter':
            provider = new firebase.auth.TwitterAuthProvider();
            break;
          case 'Google':
            provider = new firebase.auth.GoogleAuthProvider();
            break;
        }

        firebase.auth().signInWithPopup(provider).then(function(result) {
          var token = result.credential.accessToken;
          globalUser = result.user;
          globalUser.getToken().then(function(token) {
            return callback(NativeScheduler.succeed({
              uid: globalUser.uid,
              token: token,
              photoURL: nullableToMaybe(globalUser.photoURL),
              //displayName: nullableToMaybe(user.displayName),
              displayName: globalUser.displayName,
            }));
          });
        }).catch(function(error) {

          var errorCtor;

          switch (error.code) {
            case "auth/account-exists-with-different-credential":
              errorCtor = "AccountExistsWithDifferentCredential";
              break;
            case "auth/auth-domain-config-required":
              errorCtor = "AccountExistsWithDifferentCredential";
              break;
            case "auth/cancelled-popup-request":
              errorCtor = "CancelledPopupRequest";
              break;
            case "auth/operation-not-allowed":
              errorCtor = "OperationNotAllowed";
              break;
            case "auth/operation-not-supported-in-this-environment":
              errorCtor = "OperationNotSupportedInThisEnvironment";
              break;
            case "auth/popup-blocked":
              errorCtor = "PopupBlocked";
              break;
            case "auth/popup-closed-by-user":
              errorCtor = "PopupClosedByUser";
              break;
            case "auth/unauthorized-domain":
              errorCtor = "UnauthorizedDomain";
              break;
          }
          var errorMessage = error.message;

          //TODO: this is relevant for matching existing accounts
          // The email of the user's account used.
          // var email = error.email;
          // The firebase.auth.AuthCredential type that was used.
          // var credential = error.credential;
          //
          return callback(NativeScheduler.fail({
            ctor: errorCtor,
            $0: error.message
          }));
        });
      } catch (errorCtor) {
        return callback(NativeScheduler.fail({
          ctor: errorCtor,
          $0: errorCtor
        }));
      }

    });
  }

  function getCurrentUser(config) {
    return NativeScheduler.nativeBinding(function(callback) {
      try {

        initializeSdk(config);

        //TODO: this should really be a subscription!
        firebase.auth().onAuthStateChanged(function(user) {
          if (user) {
            globalUser = user;
            name = globalUser.displayName;
            globalUser.getToken().then(function(token) {
              return callback(NativeScheduler.succeed(
                Just({
                  uid: globalUser.uid,
                  token: token,
                  photoURL: nullableToMaybe(globalUser.photoURL),
                  displayName: globalUser.displayName,
                })
              ));
            });
          } else {
            return callback(NativeScheduler.succeed(Nothing));
          }
        });
      } catch (errorCtor) {
        return callback(NativeScheduler.fail({
          ctor: errorCtor,
          $0: errorCtor
        }));
      }
    });
  }

  function updateUserProfile(config, rawProfileJson) {
    // console.log('config:', config);
    // console.log('profile:', profile);

    return NativeScheduler.nativeBinding(function(callback) {

      initializeSdk(config);
      // console.log("expected: {displayName: nullable string, photoURL: nullable string}");
      // console.log('profile:', profile);
      // var profile = { displayName: "Jane Q. User", photoURL: "https://avatars.githubusercontent.com/u/702885?v=3" }
      // console.log('profile:', profile);
      //
      var profile = JSON.parse(rawProfileJson);

      if (globalUser != null) {
        globalUser.updateProfile(profile)
        .then(function() {
          console.log('updated sucess!')
          return callback(NativeScheduler.succeed());
        }, function(error) {
          console.log('updated error!', error)
          return callback(NativeScheduler.fail());
        });
      } else {
        console.log('global user is null');
        return callback(NativeScheduler.fail());
      }
    });
  }

  function signOut(config) {
    return NativeScheduler.nativeBinding(function(callback) {

      initializeSdk(config);

      firebase.auth().signOut().then(function() {
        globalUser = null;
        return callback(NativeScheduler.succeed(true));
      });
    });
  }

  return {
    authProviderSignIn: F2(authProviderSignIn),
    getCurrentUser: getCurrentUser,
    updateUserProfile: F2(updateUserProfile),
    signOut: signOut
  }

}();
