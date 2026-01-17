import { Item } from "../model/Item";
import { BasicDataSource } from "./BasicDataSource";

export class DailyDataSource extends BasicDataSource<Item> {
  constructor(dataSource: Item[]) {
    super(dataSource);
  }
}