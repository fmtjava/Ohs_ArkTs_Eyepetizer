import display from '@ohos.display';

export async function getScreenWidth(): Promise<number> {
  const defaultDisplay = await display.getDefaultDisplay();
  // 这里的 width 是物理像素宽度
  return defaultDisplay.width;
}