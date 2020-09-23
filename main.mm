#import <AuthenticationServices/AuthenticationServices.h>
#import "./AppleLogin.h"
#include <napi.h>

Napi::ThreadSafeFunction ts_fn;

static NSWindow *windowFromBuffer(const Napi::Buffer<uint8_t> &buffer) {
  auto data = (NSView **)buffer.Data();
  auto view = data[0];
  return view.window;
}

Napi::Promise SignInWithApple(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Promise::Deferred deferred = Napi::Promise::Deferred::New(env);

  if (info.Length() < 1) {
    Napi::Error::New(info.Env(), "Wrong number of arguments")
        .ThrowAsJavaScriptException();
  }

  Napi::Buffer<uint8_t> buffer = info[0].As<Napi::Buffer<uint8_t>>();
  if (buffer.Length() != 8) {
    Napi::Error::New(info.Env(), "Pointer buffer is invalid")
        .ThrowAsJavaScriptException();
  }

  NSWindow *win = windowFromBuffer(buffer);

  AppleLogin *appleLogin = [[AppleLogin alloc] initWithWindow:win];

  NSDictionary *result = [appleLogin initiateLoginProcess:^(NSDictionary * _Nonnull result) {
    Napi::Object obj = Napi::Object::New(env);
    obj.Set("idToken",
                std::string([result objectForKey:@"identityToken"]
                                ? [[result objectForKey:@"identityToken"] UTF8String]
                                : ""));

    obj.Set("firstName",
                std::string([result objectForKey:@"firstName"]
                                ? [[result objectForKey:@"firstName"] UTF8String]
                                : ""));
    obj.Set("lastName",
                std::string([result objectForKey:@"lastName"]
                                ? [[result objectForKey:@"lastName"] UTF8String]
                                : ""));
    obj.Set("email",
                std::string([result objectForKey:@"email"]
                                ? [[result objectForKey:@"email"] UTF8String]
                                : ""));
    deferred.Resolve(obj);
  } errorHandler:^(NSError * _Nonnull error) {
    // NSString *nsErr = error.localizedDescription;
    NSString *nsErr = [NSString stringWithFormat:@"%@", error];
    std::string errMsg = std::string([nsErr UTF8String]);

    Napi::Error::New(info.Env(), errMsg).ThrowAsJavaScriptException();
  }];

  return deferred.Promise();
}

// Initializes all functions exposed to JS.
Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "signInWithApple"),
              Napi::Function::New(env, SignInWithApple));



  return exports;
}

NODE_API_MODULE(main, Init)
