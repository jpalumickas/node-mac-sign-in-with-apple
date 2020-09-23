#import "AppleLogin.h"
@interface AppleLogin ()

@property (nonatomic, strong) NSWindow *window;
@end

@implementation AppleLogin
 -(id)initWithWindow:(NSWindow *)window
  {
      NSLog(@"Initializing AppleLogin: %@", window);
      if(self = [super init]) {
        NSLog(@"Assigning self main");
          self.window = window;
      }
      return self;
  }

  - (void)initiateLoginProcess {

      NSLog(@"PROCESS INITIATED");
      // self.successBlock = completionHandler;
      // self.errorBlock = errorHandler;

      ASAuthorizationAppleIDProvider *appleIDProvider = [[ASAuthorizationAppleIDProvider alloc]init];
      NSLog(@"Apple ID provider INITIATED");
      ASAuthorizationAppleIDRequest *request = [appleIDProvider createRequest];
      NSLog(@"Request INITIATED");
      request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];

      ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc]initWithAuthorizationRequests:@[request]];
      NSLog(@"AuthorizationController INITIATED");
      authorizationController.delegate = self;
      authorizationController.presentationContextProvider = self;
      NSLog(@"Calling to perform request");
      [authorizationController performRequests];
  }

  #pragma Authorization Delegates

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization {
    NSLog(@"authorizationController called");
      ASAuthorizationAppleIDCredential *appleIDCredential = [authorization credential];

    if(appleIDCredential) {
      NSLog(@"appleIDCredential exists");
      NSString *idToken = [[NSString alloc]initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];

      NSString *email = [appleIDCredential valueForKey:@"email"] ?: @"";

      NSDictionary *fullName = [appleIDCredential valueForKeyPath:@"fullName"] ?: [[NSDictionary alloc] initWithObjectsAndKeys:
      @"", @"givenName", @"", @"familyName", nil];

      NSString *firstName = [fullName valueForKeyPath:@"givenName"] ?: @"";
      NSString *lastName = [fullName valueForKeyPath:@"familyName"] ?: @"";


      NSDictionary *userDetails = @{@"userIdentifier": [appleIDCredential user], @"firstName": firstName, @"lastName": lastName, @"email" : email, @"identityToken" : idToken};

      NSLog(@"VIETA LOGIN - idToken %s firstname %s lasname %s email %s", idToken, firstName, lastName, email);

      // self.successBlock(userDetails);
    }
  }

  - (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error {
      NSLog(@"----------------------------%@",error);
      // self.errorBlock(error);
  }

  #pragma PresentationAnchorForAuthorizationController Delegate

  -(ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller {
      NSLog(@"----------------------------WINDOW");
      return self.window;
  }
@end
