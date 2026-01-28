#include "napi/native_api.h"
#include <string>

static std::string BUGLY_APPID = "17a836a117";
static std::string BUGLY_APPKEY = "dd9b0dbe-5d8d-4e6c-a0a2-168ec0621b4b";
static std::string SPARK_API_PASSWORD = "DoCBjyODmXmuLjjkLLBY:tWGmRRiQffYWACxMvjxf";
static std::string ALI_YUN_API_PASSWORD = "sk-fdaea273c883498c8ab7cf047e22fcd8";

static napi_value NAPI_Global_getBuglyAppId(napi_env env, napi_callback_info info) {
    napi_value buglyAppId;
    napi_create_string_utf8(env, BUGLY_APPID.c_str(), NAPI_AUTO_LENGTH, &buglyAppId);
    return buglyAppId;
}

static napi_value NAPI_Global_getBuglyAppKey(napi_env env, napi_callback_info info) {
    napi_value buglyAppKey;
    napi_create_string_utf8(env, BUGLY_APPKEY.c_str(), NAPI_AUTO_LENGTH, &buglyAppKey);
    return buglyAppKey;
}
static napi_value NAPI_Global_getSparkAPIPassword(napi_env env, napi_callback_info info) {
    napi_value sparkApiPassword;
    napi_create_string_utf8(env, SPARK_API_PASSWORD.c_str(), NAPI_AUTO_LENGTH, &sparkApiPassword);
    return sparkApiPassword;
}
static napi_value NAPI_Global_getAliYunAPIPassword(napi_env env, napi_callback_info info) {
    napi_value aliYunApiPassword;
    napi_create_string_utf8(env, ALI_YUN_API_PASSWORD.c_str(), NAPI_AUTO_LENGTH, &aliYunApiPassword);
    return aliYunApiPassword;
}

EXTERN_C_START static napi_value Init(napi_env env, napi_value exports) {
    napi_property_descriptor desc[] = {
        {"getBuglyAppId", nullptr, NAPI_Global_getBuglyAppId, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getBuglyAppKey", nullptr, NAPI_Global_getBuglyAppKey, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getSparkAPIPassword", nullptr, NAPI_Global_getSparkAPIPassword, nullptr, nullptr, nullptr, napi_default,
         nullptr},
        {"getAliYunAPIPassword", nullptr, NAPI_Global_getAliYunAPIPassword, nullptr, nullptr, nullptr, napi_default,
         nullptr}};
    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    return exports;
}
EXTERN_C_END

static napi_module demoModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "entry",
    .nm_priv = ((void *)0),
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterEntryModule(void) { napi_module_register(&demoModule); }
