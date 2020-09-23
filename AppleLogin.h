#import <AuthenticationServices/AuthenticationServices.h>

typedef void (^SuccessBlock)(id);
typedef void (^ErrorBlock)(id);

@interface AppleLogin : NSObject<ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding>
  @property (nonatomic, copy) SuccessBlock successBlock;
  @property (nonatomic, copy) ErrorBlock errorBlock;
 - (instancetype) initWithWindow: (NSWindow*) window;
 - (void)initiateLoginProcess;
@end
