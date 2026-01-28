import { Bugly, BuglyBuilder, ModuleName } from 'bugly';
import { DeviceUtil } from '@pura/harmony-utils';
import nativeModule from 'libentry.so';

export class BuglyInitializer {
  static init(context: Context): void {
    const builder = new BuglyBuilder();
    builder.appId = nativeModule.getBuglyAppId();
    builder.appKey = nativeModule.getBuglyAppKey();
    builder.deviceId = DeviceUtil.getDeviceId();
    builder.platform = BuglyBuilder.PLATFORM_PRO;
    builder.enablePerfModules = ModuleName.AllModules;
    Bugly.init(context, builder);
  }
}