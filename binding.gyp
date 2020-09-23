{
  "targets": [{
    "target_name": "main",
    "sources": [ ],
    "conditions": [
      ['OS=="mac"', {
        "sources": [
          "main.mm",
          "AppleLogin.h",
          "AppleLogin.m"
        ],
      }]
    ],
    'include_dirs': [
      "<!@(node -p \"require('node-addon-api').include\")"
    ],
    'libraries': [],
    'dependencies': [
      "<!(node -p \"require('node-addon-api').gyp\")"
    ],
    'defines': [ 'NAPI_DISABLE_CPP_EXCEPTIONS' ],
    "xcode_settings": {
      "OTHER_CPLUSPLUSFLAGS": ["-std=c++14", "-stdlib=libc++", "-mmacosx-version-min=10.15"],
      "OTHER_LDFLAGS": ["-framework CoreFoundation -framework AppKit -framework AuthenticationServices"]
    }
  }]
}
