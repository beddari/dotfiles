export type Where = {
  /** zmx:<session>@<host> inside a zmx session, <user>@<host> outside one. */
  who: string
  dir: string
  branch: string
  status: string
}

/** One rate-limit window of the subscription, as the last API response reported it. */
export type Limit = { kind: string; percentUsed: number; resetsAt?: string }

declare module 'claude-code' {
  interface PluginState {
    where: { where: Where | null; limits: Limit[]; view: number; tick: number }
  }
}
