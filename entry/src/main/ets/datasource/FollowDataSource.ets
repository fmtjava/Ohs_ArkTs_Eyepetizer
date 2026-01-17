import { Item } from "../model/Item";
import { BasicDataSource } from "./BasicDataSource";

export class FollowDataSource extends BasicDataSource<Item> {
  constructor(dataSource: Item[]) {
    super(dataSource);
  }
}