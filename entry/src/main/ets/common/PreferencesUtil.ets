import preferences from '@ohos.data.preferences';
import { common } from '@kit.AbilityKit';

/**
 * Preferences 工具类
 * 用于存储和读取应用的轻量级数据（键值对）
 */
export class PreferencesUtil {
  // 存储文件名，可以按需修改成你的业务名称
  private static readonly PREFERENCES_NAME: string = 'app_preferences';

  /**
   * 获取 Preferences 实例
   * @param context 应用上下文
   * @returns Preferences 实例
   */
  private static async getPreferences(context: common.UIAbilityContext): Promise<preferences.Preferences> {
    if (!context) {
      const error = new Error('Context is null or undefined');
      console.error('PreferencesUtil getPreferences: ' + error.message);
      throw error;
    }
    try {
      // 为了简单起见，每次直接获取，不做静态缓存
      const pref = await preferences.getPreferences(context, PreferencesUtil.PREFERENCES_NAME);
      if (!pref) {
        throw new Error('Failed to get Preferences instance');
      }
      return pref;
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : JSON.stringify(error);
      throw new Error(errorMsg);
    }
  }

  /**
   * 存储字符串数据
   * @param context 应用上下文
   * @param key 键
   * @param value 值
   */
  static async putString(context: common.UIAbilityContext, key: string, value: string): Promise<void> {
    try {
      const dataPreferences = await PreferencesUtil.getPreferences(context);
      await dataPreferences.put(key, value);
      await dataPreferences.flush();
    } catch (error) {
      console.error('PreferencesUtil putString error: ' + JSON.stringify(error));
    }
  }

  /**
   * 读取字符串数据
   * @param context 应用上下文
   * @param key 键
   * @param defaultValue 默认值
   * @returns 字符串值
   */
  static async getString(context: common.UIAbilityContext, key: string, defaultValue: string = ''): Promise<string> {
    try {
      const dataPreferences = await PreferencesUtil.getPreferences(context);
      return await dataPreferences.get(key, defaultValue) as string;
    } catch (error) {
      console.error('PreferencesUtil getString error: ' + JSON.stringify(error));
      return defaultValue;
    }
  }

  /**
   * 存储数字数据（如整型计数等）
   * @param context 应用上下文
   * @param key 键
   * @param value 值
   */
  static async putNumber(context: common.UIAbilityContext, key: string, value: number): Promise<void> {
    try {
      const dataPreferences = await PreferencesUtil.getPreferences(context);
      await dataPreferences.put(key, value);
      await dataPreferences.flush();
    } catch (error) {
      console.error('PreferencesUtil putNumber error: ' + JSON.stringify(error));
    }
  }

  /**
   * 读取数字数据
   * @param context 应用上下文
   * @param key 键
   * @param defaultValue 默认值
   * @returns 数字值
   */
  static async getNumber(context: common.UIAbilityContext, key: string, defaultValue: number = 0): Promise<number> {
    try {
      const dataPreferences = await PreferencesUtil.getPreferences(context);
      return await dataPreferences.get(key, defaultValue) as number;
    } catch (error) {
      console.error('PreferencesUtil getNumber error: ' + JSON.stringify(error));
      return defaultValue;
    }
  }  /**
   * 存储布尔值数据
   * @param context 应用上下文
   * @param key 键
   * @param value 值
   */
  static async putBoolean(context: common.UIAbilityContext, key: string, value: boolean): Promise<void> {
    try {
      const dataPreferences = await PreferencesUtil.getPreferences(context);
      await dataPreferences.put(key, value);
      await dataPreferences.flush();
    } catch (error) {
      console.error('PreferencesUtil putBoolean error: ' + JSON.stringify(error));
    }
  }  /**
   * 读取布尔值数据
   * @param context 应用上下文
   * @param key 键
   * @param defaultValue 默认值
   * @returns 布尔值
   */
  static async getBoolean(context: common.UIAbilityContext, key: string,
    defaultValue: boolean = false): Promise<boolean> {
    try {
      const dataPreferences = await PreferencesUtil.getPreferences(context);
      return await dataPreferences.get(key, defaultValue) as boolean;
    } catch (error) {
      console.error('PreferencesUtil getBoolean error: ' + JSON.stringify(error));
      return defaultValue;
    }
  }
}
