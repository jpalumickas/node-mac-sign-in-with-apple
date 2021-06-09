#import "AppleLogin.h"

@interface AppleLogin ()

@property (nonatomic, strong) NSWindow *window;
@end

@implementation AppleLogin
 -(id)initWithWindow:(NSWindow *)window {
    if(self = [super init]) {
      self.window = window;
    }
    return self;
  }

  - (void)initiateLoginProcess:(void (^)(NSDictionary<NSString *, NSString *> *result))completionHandler errorHandler:(void (^)(NSError *error))errorHandler {
    self.successBlock = completionHandler;
    self.errorBlock = errorHandler;

    ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc]init];
    ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
    request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

    ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc]initWithAuthorizationRequests:@[request]];
    authorizationController.delegate = self;
    authorizationController.presentationContextProvider = self;

    [authorizationController performRequests];
  }

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    ASAuthorizationAppleIDCredential *appleIDCredential = [authorization credential];

    if(appleIDCredential) {
      NSString *idToken = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
      NSString *code = [[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding];

      NSPersonNameComponents *fullName = appleIDCredential.fullName;
      NSDictionary *userDetails = @{
        @"firstName": fullName.givenName ?: @"",
        @"middleName": fullName.middleName ?: @"",
        @"lastName": fullName.familyName ?: @"",
        @"email" : appleIDCredential.email ?: @"",
        @"idToken" : idToken,
        @"code" : code,
      };

      self.successBlock(userDetails);
    }
  }

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
    self.errorBlock(error);
  }

  -(ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
    return self.window;
  }
@end
