import { Item } from "../model/Item";
import { BasicDataSource } from "./BasicDataSource";

export class FollowHorizontalDataSource extends BasicDataSource<Item> {
  constructor(dataSource: Item[]) {
    super(dataSource);
  }
}