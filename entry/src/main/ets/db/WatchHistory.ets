import { Table, Column, PrimaryKey, CreatedAt, UpdatedAt } from '@ibestservices/ibest-orm';

@Table()
export class WatchHistory {
  @PrimaryKey()
  id?: number;
  @Column()
  videoId?: number;
  @Column()
  content?: string;
  @CreatedAt() // 自动记录创建时间
  createdAt?: string;
  @UpdatedAt() // 自动记录更新时间
  updatedAt?: string;
}