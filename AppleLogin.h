#import <AuthenticationServices/AuthenticationServices.h>

@interface AppleLogin : NSObject<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
 - (instancetype) initWithWindow: (NSWindow*) window;
  - (void)initiateLoginProcess;//:(void (^)(NSDictionary *result))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;
@end
