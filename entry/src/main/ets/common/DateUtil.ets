/**
 * 时间格式化工具类
 */
export class DateUtil {
  /**
   * 将时间戳（毫秒）格式化为日期时间字符串
   * 默认格式：yyyy/MM/dd HH:mm
   * @param milliseconds 13 位毫秒时间戳
   * @returns 如：2024/12/20 14:30:45
   */
  static formatTimestamp(milliseconds: number): string {
    if (milliseconds <= 0) {
      return '';
    }
    const date: Date = new Date(milliseconds);
    const year: number = date.getFullYear();
    const month: number = date.getMonth() + 1; // 0-11 → 1-12
    const day: number = date.getDate();
    const hours: number = date.getHours();
    const minutes: number = date.getMinutes();

    return `${year}/${DateUtil.padZero(month)}/${DateUtil.padZero(day)} ` +
      `${DateUtil.padZero(hours)}:${DateUtil.padZero(minutes)}`;
  }

  /**
   * 格式化时长（毫秒转 MM:SS）
   * @param milliseconds 毫秒数（13位毫秒数）
   * @returns 格式：03:00
   */
  static formatDuration(milliseconds: number): string {
    if (milliseconds < 0) {
      return '00:00';
    }

    // 将毫秒转换为秒
    const totalSeconds = Math.floor(milliseconds / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const secs = Math.floor(totalSeconds % 60);

    return `${DateUtil.padZero(minutes)}:${DateUtil.padZero(secs)}`;
  }

  /**
   * 补零函数
   * @param num 数字
   * @returns 补零后的字符串
   */
  private static padZero(num: number): string {
    return num.toString().padStart(2, '0');
  }
}