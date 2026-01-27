import media from '@ohos.multimedia.media';
import image from '@ohos.multimedia.image';

// 获取视频封面的工具类
export class VideoThumbnailExtractor {
  /**
   * 从视频 URI 获取封面
   * @param videoUri 视频文件 URI
   * @param timeUs 提取时间点（微秒）
   * @returns Promise<image.PixelMap>
   */
  static async getThumbnailFromUri(videoUri: string, width: number, height: number,
    timeUs: number = 0): Promise<image.PixelMap | null> {
    try {
      // 创建AVMetadataExtractor对象
      const metadataExtractor = await media.createAVMetadataExtractor();
      const headers: Record<string, string> = {
        "User-Agent": "Mozilla/5.0 (HarmonyOS; Device Model) AppleWebKit/537.36 (KHTML, like Gecko) Version/1.0"
      };
      // 设置在线媒体链接
      metadataExtractor.setUrlSource(videoUri, headers);

      // 获取视频原生宽高
      const metadata = await metadataExtractor.fetchMetadata();
      const originalWidth = metadata.videoWidth;
      const originalHeight = metadata.videoHeight;

      if (originalWidth && originalHeight) {
        // 接口入参声明。
        const queryOption: media.AVImageQueryOptions = media.AVImageQueryOptions.AV_IMAGE_QUERY_PREVIOUS_SYNC;
        const param: media.PixelMapParams = {
          width: parseInt(originalWidth),
          height: parseInt(originalHeight)
        }
        // 获取视频缩略图（promise模式）
        const pixelMap: image.PixelMap = await metadataExtractor.fetchFrameByTime(timeUs, queryOption, param);
        await metadataExtractor.release();
        return pixelMap;
      }
      return null;
    } catch (error) {
      console.error(`从 URI 获取视频封面失败: ${JSON.stringify(error)}`);
      return null;
    }
  }
}