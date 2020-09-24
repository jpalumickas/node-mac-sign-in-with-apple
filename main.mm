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

    for (NSString* key in result) {
      NSString *value = result[key];
      if(value != nil && [value length] > 0) {
        std::string napiKey = std::string([key UTF8String]);
        Napi::Value napiValue = Napi::Value::From(env, [[NSString stringWithFormat:@"%@", value] UTF8String]);
        obj.Set(napiKey, napiValue);
      }
    }

    deferred.Resolve(obj);
  } errorHandler:^(NSError * _Nonnull error) {
    Napi::Object errorObj = Napi::Object::New(env);

    errorObj.Set("code", Napi::Value::From(env, error.code));
    errorObj.Set("message", Napi::Value::From(env, [error.description UTF8String]));
    for (NSString* key in error.userInfo) {
      NSString *value = error.userInfo[key];
      std::string napiKey = std::string([key UTF8String]);
      Napi::Value napiValue = Napi::Value::From(env, [[NSString stringWithFormat:@"%@", value] UTF8String]);
      errorObj.Set(napiKey, napiValue);
    }

    deferred.Reject(errorObj);
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
