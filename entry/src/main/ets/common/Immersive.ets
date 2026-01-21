import window from '@ohos.window';
import { BusinessError } from '@ohos.base';
import { common } from '@kit.AbilityKit';

// 设置导航栏透明
export function hideNavBar(ctx: common.Context | undefined): void {
  // 1. 获取当前窗口
  window.getLastWindow(ctx, (err: BusinessError, win: window.Window) => {
    if (err.code) {
      console.error(`获取窗口失败：${err.message}`);
      return;
    }
    // 2. 设置导航区域隐藏
    win.setSpecificSystemBarEnabled('navigationIndicator', false).then(() => {
      console.info('Succeeded in setting the navigation indicator to be invisible.');
    }).catch((err: BusinessError) => {
      console.error(`Failed to set the navigation indicator to be invisible. Code is ${err.code}, message is ${err.message}`);
    });
  });
}

// 恢复默认导航栏
export function resetNavBar(ctx: common.Context | undefined) {
  // 1. 获取当前窗口
  window.getLastWindow(ctx, (err: BusinessError, win: window.Window) => {
    if (err.code) {
      console.error(`获取窗口失败：${err.message}`);
      return;
    }
    // 2. 设置导航区域隐藏
    win.setSpecificSystemBarEnabled('navigationIndicator', true).then(() => {
      console.info('Succeeded in setting the navigation indicator to be invisible.');
    }).catch((err: BusinessError) => {
      console.error(`Failed to set the navigation indicator to be invisible. Code is ${err.code}, message is ${err.message}`);
    });
  });
}