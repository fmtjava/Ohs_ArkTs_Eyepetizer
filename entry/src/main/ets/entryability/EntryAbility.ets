import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { getORM, IBestORMInit } from '@ibestservices/ibest-orm';
import { Bugly, BuglyBuilder, ModuleName } from 'bugly';
import { DeviceUtil } from '@pura/harmony-utils';
import { WatchHistory } from '../db/WatchHistory';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private initBugly(context: Context): void {
    const builder = new BuglyBuilder();
    builder.appId = '17a836a117';
    builder.appKey = 'dd9b0dbe-5d8d-4e6c-a0a2-168ec0621b4b';
    builder.deviceId = DeviceUtil.getDeviceId();
    builder.platform = BuglyBuilder.PLATFORM_PRO;
    builder.enablePerfModules = ModuleName.AllModules;
    Bugly.init(context, builder);
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  async onWindowStageCreate(windowStage: window.WindowStage): Promise<void> {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    // 初始化 ORM，传入数据库配置
    await IBestORMInit(this.context, { name: 'eyepetizer.db' });
    // 应用启动时统一迁移所有表
    const orm = getORM();
    orm.migrate(WatchHistory);

    // 初始化 Bugly
    this.initBugly(this.context);

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}