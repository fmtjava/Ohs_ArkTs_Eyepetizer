import { getORM } from '@ibestservices/ibest-orm';
import { WatchHistory } from '../db/WatchHistory';
import { ItemData } from '../model/Item';

export class WatchHistoryVideoModel {
  private orm = getORM();

  getVideoList(): ItemData[] {
    const watchList = this.orm.query(WatchHistory).find();
    const itemList: ItemData[] = watchList.map((value: WatchHistory) => JSON.parse(value.content || '') as ItemData)
    return itemList;
  }

  deleteVideo(videoId: number) {
    this.orm.query(WatchHistory)
      .where({ videoId: videoId })
      .delete()
  }
}