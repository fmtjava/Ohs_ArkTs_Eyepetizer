import { getORM, IBestORMInit } from '@ibestservices/ibest-orm';
import { WatchHistory } from '../db/WatchHistory';

export class OrmInitializer {
  static async init(context: object) {
    // 初始化 ORM，传入数据库配置
    await IBestORMInit(context, { name: 'eyepetizer.db' });
    // 应用启动时统一迁移所有表
    const orm = getORM();
    orm.migrate(WatchHistory);
  }
}