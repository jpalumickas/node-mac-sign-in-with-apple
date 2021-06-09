#import <AuthenticationServices/AuthenticationServices.h>
#import "./AppleLogin.h"

#include <map>
#include <napi.h>

using namespace Napi;

ThreadSafeFunction tsfn;

static NSWindow *windowFromBuffer(const Napi::Buffer<uint8_t> &buffer) {
  auto data = (NSView **)buffer.Data();
  auto view = data[0];
  return view.window;
}

Value SignInWithApple( const CallbackInfo& info )
{
  Napi::Env env = info.Env();

  if (info.Length() != 2) {
    Error::New(info.Env(), "Wrong number of arguments")
        .ThrowAsJavaScriptException();
  }

  tsfn = ThreadSafeFunction::New(env, info[0].As<Function>(),
      "Thread Safe Function", 0, 1, [](Napi::Env) {});

  Napi::Buffer<uint8_t> buffer = info[1].As<Napi::Buffer<uint8_t>>();
  NSWindow *win = windowFromBuffer(buffer);

  AppleLogin *appleLogin = [[AppleLogin alloc] initWithWindow:win];

  auto callback = [](Napi::Env env, Function jsCallback, std::map<std::string, std::string> *values) {
    Napi::Object obj = Napi::Object::New(env);

    for (auto const& v : (*values)) {
      obj.Set(v.first, Napi::Value::From(env, v.second));
    }

    jsCallback.Call({Value::From(env, obj)});

    delete values;
  };

  [appleLogin initiateLoginProcess:^(NSDictionary * _Nonnull result) {
    std::map<std::string, std::string> *values = new std::map<std::string, std::string>();
    (*values)["is_error"] = "false";

    for (NSString* key in result) {
      NSString *value = result[key];
      if (value != nil && [value length] > 0) {
        std::string stringKey = std::string([key UTF8String]);
        std::string stringValue = std::string([[NSString stringWithFormat:@"%@", value] UTF8String]);
        (*values)[stringKey] = stringValue;
      }
    }

    napi_status status = tsfn.BlockingCall(values, callback);
    if (status != napi_ok) {
      NSLog(@"Error occured when running callback on the event loop.\n");
    }

    tsfn.Release();
  } errorHandler:^(NSError * _Nonnull error) {
    std::map<std::string, std::string> *values = new std::map<std::string, std::string>();
    (*values)["is_error"] = "true";
    (*values)["code"] = std::string([[@(error.code) stringValue] UTF8String]);
    (*values)["message"] = std::string([error.description UTF8String]);

    napi_status status = tsfn.BlockingCall(values, callback);
    if (status != napi_ok) {
      NSLog(@"Error occured when running callback on the event loop.\n");
    }

    tsfn.Release();
  }];

  return Napi::Boolean::New(env, true);
}

Object Init(Env env, Object exports) {
  exports.Set(String::New(env, "signInWithApple"),
              Function::New(env, SignInWithApple));

  return exports;
}

NODE_API_MODULE(main, Init)
