#import "AppleLogin.h"
@interface AppleLogin ()

@property (nonatomic, strong) NSWindow *window;
@end

@implementation AppleLogin
 -(id)initWithWindow:(NSWindow *)window
  {
      if(self = [super init]) {
        self.window = window;
      }
      return self;
  }

  - (void)initiateLoginProcess:(void (^)(NSDictionary *result))completionHandler errorHandler:(void (^)(NSError *error))errorHandler {
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

  #pragma Authorization Delegates

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    ASAuthorizationAppleIDCredential *appleIDCredential = [authorization credential];

    if(appleIDCredential) {
      NSLog(@"Successfully retrieved user credentials");

      NSString *idToken = [[NSString alloc]initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];

      NSString *email = [appleIDCredential valueForKey:@"email"] ?: @"";

      NSDictionary *fullName = [appleIDCredential valueForKeyPath:@"fullName"] ?: [[NSDictionary alloc] initWithObjectsAndKeys:
      @"", @"givenName", @"", @"familyName", nil];

      NSString *firstName = [fullName valueForKeyPath:@"givenName"] ?: @"";
      NSString *lastName = [fullName valueForKeyPath:@"familyName"] ?: @"";


      NSDictionary *userDetails = @{@"userIdentifier": [appleIDCredential user], @"firstName": firstName, @"lastName": lastName, @"email" : email, @"identityToken" : idToken};

      self.successBlock(userDetails);
    }
  }

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
      NSLog(@"Something went wrong: %@",error);
      self.errorBlock(error);
  }

  #pragma PresentationAnchorForAuthorizationController Delegate

  -(ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
    return self.window;
  }
@end
