export interface Item {
  type: string
  data: ItemData
}

export interface ItemData {
  id: number
  text?: string
  cover?: Cover
  author?: Author
  duration?: number
  title?: string
  category?: string
  header?: Header
  itemList?: Item[]
  width?: number
  height?: number
  urls?: string[]
  description?: string
  owner?: Owner
  consumption?: Consumption
  playUrl?: string
}

export interface Header {
  icon: string
  title: string
  description: string
}

export interface Owner {
  avatar: string
  nickname: string
}

export interface Consumption {
  collectionCount: number
  shareCount: number
  replyCount: number
}

export interface Author {
  icon: string
  name: string
  description: string
  latestReleaseTime: number
}

export interface Cover {
  feed: string
  blurred: string
  detail: string
}

