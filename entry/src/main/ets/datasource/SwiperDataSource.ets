import { Item } from "../model/Item";
import { BasicDataSource } from "./BasicDataSource";

export class SwiperDataSource extends BasicDataSource<Item> {
  constructor(dataSource: Item[]) {
    super(dataSource);
  }
}