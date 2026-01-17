import { AxiosResponse } from '@ohos/axios';
import { RELATED_VIDEO } from '../api/Apis';
import { get } from '../common/http';
import { Issue } from '../model/Issue';
import { Item, ItemData } from '../model/Item';
import { getORM } from '@ibestservices/ibest-orm';
import { WatchHistory } from '../db/WatchHistory';

export class VideoDetailViewModel {
  private orm = getORM();

  async loadRelateVideoData(id: number): Promise<Item[]> {
    const response: AxiosResponse<string> = await get(`${RELATED_VIDEO}?id=${id}`);
    const issue: Issue = JSON.parse(response.data);
    const itemList = issue.itemList;
    return itemList
  }

  saveVideo(itemData: ItemData): void {
    try {
      // 查询是否已存在
      const existing = this.orm.query(WatchHistory).where({ videoId: itemData.id }).first();
      if (!existing) {
        const watchHistory = new WatchHistory();
        watchHistory.videoId = itemData.id;
        watchHistory.content = JSON.stringify(itemData);
        const result = this.orm.insert(watchHistory);
        console.log('插入成功，ID:', result);
      }
    } catch (error) {
      console.error('saveVideo 错误: ' + JSON.stringify(error));
    }
  }
}