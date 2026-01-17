import { NewsItem } from '../model/News';
import { BasicDataSource } from './BasicDataSource';

export class NewsDataSource extends BasicDataSource<NewsItem> {
  constructor(dataSource: NewsItem[]) {
    super(dataSource);
  }
}