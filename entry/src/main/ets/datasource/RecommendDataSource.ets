import { RecommendItem } from '../model/Recommend';
import { BasicDataSource } from './BasicDataSource';

export class RecommendDataSource extends BasicDataSource<RecommendItem> {
  constructor(dataSource: RecommendItem[]) {
    super(dataSource);
  }
}