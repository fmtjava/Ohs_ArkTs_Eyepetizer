import { TopicItem } from '../model/Topic';
import { BasicDataSource } from './BasicDataSource';

export class TopicDataSource extends BasicDataSource<TopicItem> {
  constructor(dataSource: TopicItem[]) {
    super(dataSource);
  }
}