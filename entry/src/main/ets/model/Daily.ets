import { Issue } from "./Issue";

export interface Daily {
  issueList: Issue[]
  nextPageUrl: string
}