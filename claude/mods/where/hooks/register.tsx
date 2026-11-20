// The subscription meter is midudev's sub-meter 0.4.3, merged here so that
// one hook draws the whole row and the meter can make room for the rest:
// https://github.com/midudev/better-claude/tree/249f0f6/plugins/sub-meter
//
// MIT License, Copyright (c) 2026 Miguel Ángel Durán (midudev). Permission
// is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above
// copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED
// "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
// NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
// ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import { atom, read, update } from 'claude-code'
import type { EngineInterface, Register, RenderNode, RenderViewport, SessionRateLimit } from 'claude-code'

import type { Limit, Where } from '../types'

const where = atom({ plugin: 'where', key: 'where' } as const, null as Where | null)
const limits = atom({ plugin: 'where', key: 'limits' } as const, [] as Limit[])
const view = atom({ plugin: 'where', key: 'view' } as const, 0) // which window the rotating meter shows
const tick = atom({ plugin: 'where', key: 'tick' } as const, 0) // redraws the countdown

// Git can change under a running command or in another window; a timer
// catches what no hook sees.
const REFRESH_MS = 10000
const ANSI = /\x1b\[[0-9;]*m/g

const WINDOWS = ['five_hour', 'seven_day']
const LABELS: Record<string, string> = { five_hour: '5h', seven_day: 'week' }
const ROTATE_SECONDS = 8
const TICK_MS = 8000
const DISPLAYS = ['rotate', 'both', 'session', 'week']
const WINDOW_OF: Record<string, string> = { session: 'five_hour', week: 'seven_day' }
const CELLS = 10
const CYCLE_HINT = /\s*\([^()]+ to cycle\)/
const INTERRUPT_HINT = /\s*esc to interrupt/
// The terminal footer's row: two columns of padding at each end, the mode
// label at the left (`⏵⏵ accept edits on ·`, the longest but bypass's) and
// the hint after it, two columns at least between that and what is drawn here.
const FOOTER_PADDING = 4
const FOOTER_GAP = 2
const MODE_LABEL = 20
const SEPARATOR = ' · '
const BETWEEN = '  |  '
// Between the place and the meter, and between the parts of the place.
const GAP = '    '
const INSIDE = '  '
// Fixed widths, the widest each field gets: `week`, ` 100%`, ` ↻ 23h 59m`,
// and room for a git status of three marks.
const LABEL_WIDTH = 4
const USED_WIDTH = 5
const RESET_WIDTH = 10
const STATUS_WIDTH = 3
// The shortest a branch is cut to before the rest of the place gives way.
const MIN_BRANCH = 10

// The hint as last drawn on the terminal, in columns.
let hintWidth = 0
let lastHint = ''
let lastTidied = ''
let windowCount = 0
let lookTimer: { cancel: () => void } | undefined
let tickTimer: { cancel: () => void } | undefined
let rotateTimer: { cancel: () => void } | undefined

/** Runs a command and resolves its output, or '' when it fails or is missing. */
async function output ($: EngineInterface, argv: string[], cwd?: string) {
  try {
    // Unset, starship prints plain ANSI, not a shell's prompt escapes.
    const { exitCode, stdout } = await $.process.run(argv, {
      cwd,
      env: { STARSHIP_SHELL: '' },
      timeoutMs: 5000
    })
    return exitCode === 0 ? stdout.replace(ANSI, '').trim() : ''
  } catch {
    return ''
  }
}

/** "beddari/dotfiles", or "beddari/dotfiles/bin" below its root: the repository by its last two names. */
function dirOf (cwd: string, root: string, home: string) {
  if (root === '') return home !== '' && cwd.startsWith(home) ? '~' + cwd.slice(home.length) : cwd
  const name = root.split('/').slice(-2).join('/')
  return name + cwd.slice(root.length)
}

/** Reads where the session runs: zmx session or user, and host, repository, branch and status. */
async function look ($: EngineInterface) {
  const [cwd, session, user, home] = await Promise.all([
    $.session.cwd(),
    $.env.get('ZMX_SESSION'),
    $.env.get('USER'),
    $.env.get('HOME')
  ])
  const [host, root, branch, status] = await Promise.all([
    output($, ['uname', '-n']),
    output($, ['git', 'rev-parse', '--show-toplevel'], cwd),
    output($, ['starship', 'module', 'git_branch', '--path', cwd], cwd),
    output($, ['starship', 'module', 'git_status', '--path', cwd], cwd)
  ])
  const found: Where = {
    who: `${session ? `zmx:${session}` : user ?? ''}@${host.split('.')[0]}`,
    dir: dirOf(cwd, root, home ?? ''),
    branch,
    status
  }
  await update($, where, () => found)
}

/** The subscription windows the meter shows, in order, from what the engine measured. */
const windowsOf = (rateLimits: readonly SessionRateLimit[]): Limit[] =>
  WINDOWS.flatMap(kind => {
    const found = rateLimits.find(limit => limit.kind === kind)
    return found ? [{ kind, percentUsed: found.percentUsed, resetsAt: found.resetsAt }] : []
  })

/** Whether a drawing beneath shows nothing; the engine's own node draws only the modes, counted apart. */
function isBlank (node: RenderNode | undefined): boolean {
  if (node === undefined || node === null) return true
  if (typeof node === 'string') return node.trim() === ''
  if (node.type === 'engine') return true
  return (node.type === 'Box' || node.type === 'Text') && (node.children ?? []).every(isBlank)
}

/** Columns a text takes: one per character, none for a variation selector. */
const widthOf = (text: string) => [...text.replace(/[︎️]/g, '')].length

/** Columns a drawing beneath takes on one row; the engine's own node draws `modes`, joined by ` & `. */
function widthOfNode (node: RenderNode | undefined, modes: readonly string[]): number {
  if (node === undefined || node === null) return 0
  if (typeof node === 'string') return widthOf(node)
  if (node.type === 'engine') return widthOf(modes.join(' & '))
  return (node.children ?? []).reduce((sum, child) => sum + widthOfNode(child, modes), 0)
}

/** Columns the footer leaves at its right end on the terminal, beside the mode label and the hint; elsewhere, no limit. */
function roomOf (e: { surface: string; viewport?: RenderViewport }) {
  if (e.surface !== 'terminal' || e.viewport === undefined) return Infinity
  return e.viewport.columns - FOOTER_PADDING - FOOTER_GAP - MODE_LABEL - (hintWidth > 0 ? 1 + hintWidth : 0)
}

const colorFor = (percent: number) => (percent >= 90 ? 'error' : percent >= 75 ? 'warning' : 'success')

/** "42m", "3h 5m", "2d 4h": how long until the window resets. */
function until (ms: number) {
  const minutes = Math.max(1, Math.round(ms / 60000))
  if (minutes < 60) return `${minutes}m`
  const hours = Math.floor(minutes / 60)
  if (hours < 24) return `${hours}h ${minutes % 60}m`
  return `${Math.floor(hours / 24)}d ${hours % 24}h`
}

// When the reading this session shows was taken; the shared store carries the newest one of any session.
let seenAt = 0

/** Keeps the latest reading for the meter, and for the next session until a response reports again. */
async function remember ($: EngineInterface, found: Limit[]) {
  if (found.length === 0) return
  seenAt = await $.clock.now()
  windowCount = found.length
  await update($, limits, () => found)
  await $.store.set('limits', found)
  await $.store.set('at', seenAt) // after the limits, so a reader that sees the new time finds the new limits
}

/** Adopts the reading another session left in the shared store, when it is newer than ours. */
async function syncFromStore ($: EngineInterface) {
  const at = Number(await $.store.get('at')) || 0
  if (at <= seenAt) return
  const saved = await $.store.get('limits')
  if (!Array.isArray(saved)) return
  seenAt = at
  windowCount = saved.length
  await update($, limits, () => saved as Limit[])
}

// From the options and session.start: how often the meter takes turns, whether it does, and whether
// someone is at the session (a /clear keeps it; a mod loaded mid-session sees no session.start).
let rotateMs = ROTATE_SECONDS * 1000
let isRotating = true
let isInteractive = true

function stopTimers () {
  for (const timer of [lookTimer, tickTimer, rotateTimer]) timer?.cancel()
  lookTimer = tickTimer = rotateTimer = undefined
}

/** Reads where the session runs and the stored and current usage, and (with someone at the session) keeps both moving. */
async function begin ($: EngineInterface) {
  stopTimers()
  const [saved, storedAt, usage] = await Promise.all([
    $.store.get('limits'),
    $.store.get('at'),
    $.session.usage(),
    look($)
  ])
  if (Array.isArray(saved)) {
    windowCount = saved.length
    await update($, limits, () => saved as Limit[])
  }
  seenAt = Number(storedAt) || 0

  await remember($, windowsOf(usage.rateLimits))

  if (isInteractive) {
    lookTimer = $.clock.every(REFRESH_MS, () => void look($).catch(() => {}))
    // Another session's reading shows up within TICK_MS of being stored.
    tickTimer = $.clock.every(TICK_MS, () => {
      void syncFromStore($).catch(() => {}) // a failed read keeps the reading on screen
      if (windowCount > 0) void update($, tick, n => n + 1)
    })
    if (isRotating) {
      rotateTimer = $.clock.every(rotateMs, () => {
        if (windowCount >= 2) void update($, view, n => n + 1)
      })
    }
  }
}

/** The windows to draw: all of them, the one the rotation is on, or the one chosen. With fewer than two readings, whatever there is. */
function visible (all: Limit[], display: string, index: number): Limit[] {
  if (display === 'both' || all.length < 2) return all
  if (display === 'rotate') return all.slice(index % all.length, index % all.length + 1)
  return all.filter(limit => limit.kind === WINDOW_OF[display])
}

/** Cuts a text to a width from its end, marking the cut with an ellipsis. */
function cut (text: string, width: number) {
  const chars = [...text]
  return chars.length <= width ? text : chars.slice(0, Math.max(1, width - 1)).join('') + '…'
}

/**
 * The place to draw within a width: the branch cut from its end down to MIN_BRANCH, then the host
 * dropped, then the session or user, then the directory down to its last name, then the branch to
 * its first character. Each step only as far as needed, and no more than `most` steps; what is left
 * over is drawn whole.
 */
function placeOf (here: Where, max: number, most = Infinity) {
  const status = here.branch ? ' ' + here.status.padEnd(STATUS_WIDTH) : ''
  let { dir, branch, who } = here
  const width = () => widthOf(dir + (branch ? '@' + branch : '') + status + (who ? INSIDE + who : ''))
  const over = () => width() - max
  const steps = [
    () => { branch = cut(branch, Math.max(MIN_BRANCH, [...branch].length - over())) },
    () => { who = who.replace(/@[^@]*$/, '') },
    () => { who = '' },
    () => { dir = dir.split('/').filter(Boolean).pop() ?? dir },
    () => { branch = cut(here.branch, Math.max(2, [...branch].length - over())) }
  ]
  for (const step of steps.slice(0, most)) {
    if (over() <= 0) break
    step()
  }
  return { dir, branch: branch ? '@' + branch : '', status, who: who ? INSIDE + who : '', width: width() }
}

export const register: Register = (on, options) => {
  seenAt = 0
  windowCount = 0
  lastHint = ''
  lastTidied = ''
  const hideCycleHint = options.hideCycleHint !== false
  const hideInterruptHint = options.hideInterruptHint !== false
  const rotateSeconds = Number(options.rotateSeconds)
  rotateMs = (rotateSeconds > 0 ? rotateSeconds : ROTATE_SECONDS) * 1000
  const display = DISPLAYS.includes(String(options.display)) ? String(options.display) : 'rotate'
  isRotating = display === 'rotate'
  isInteractive = true
  const hidden = [...(hideCycleHint ? [CYCLE_HINT] : []), ...(hideInterruptHint ? [INTERRUPT_HINT] : [])]

  /** The hint line without the parts hidden, and without the empty parts they leave. */
  function tidy (hint: string) {
    if (!hidden.some(part => part.test(hint))) return hint
    return hidden
      .reduce((line, part) => line.replace(part, ' · '), hint)
      .split('·')
      .map(part => part.trim())
      .filter(Boolean)
      .join(' · ')
  }

  on('session.start', async ($, e, next) => {
    isInteractive = e.isInteractive
    await begin($)
    return next(e)
  })

  // A /clear ends the conversation, not the process: no session.start follows it, so the timers stay,
  // and the next tick adopts the stored reading again in the new session.
  on('session.end', ($, e, next) => {
    if (e.reason === 'clear') seenAt = 0
    else stopTimers()
    return next(e)
  })

  // The conversation a /clear starts holds none of the last one's values: the row is drawn again at once.
  on('classic.SessionStart', async ($, e, next) => {
    if (e.source === 'clear') await begin($).catch(() => {})
    return next(e)
  })

  on('session.measure', async ($, e, next) => {
    await remember($, windowsOf(e.rateLimits))
    return next(e)
  })

  // A command may switch the branch or change the tree.
  on('tool.call', async ($, e, next) => {
    const result = await next(e)
    void look($).catch(() => {})
    return result
  })

  // Bottom right of the prompt footer: where the session runs, the meter at the right edge, then what is
  // beneath (the engine's mode labels, another plugin's switch). The place reads repository, branch,
  // status, then the zmx session or user and host. Every field is padded to a fixed width, so that the
  // place keeps its column while the meter rotates and counts down. Where the row is short the meter
  // gives up its bar, then the time until the reset, then its label; the percentage and the place stay.
  on('ui.render', { component: 'SessionMode' }, async ($, e, next) => {
    const [here, all, beneath] = await Promise.all([read($, where), read($, limits), next(e)])
    const index = display === 'rotate' && all.length >= 2 ? await read($, view) : 0
    const shown = visible(all, display, index)
    if (here === null && shown.length === 0) return beneath
    // Subscribes this drawing to the countdown tick alongside reading the clock
    const [, now] = await Promise.all([read($, tick), $.clock.now()])
    const hasBeneath = e.props.modes.length > 0 || !isBlank(beneath)
    const { Box, Text } = $.ui.resolve(e)

    const windows = shown.map(limit => {
      const resetsIn = limit.resetsAt === undefined ? undefined : Date.parse(limit.resetsAt) - now
      const hasReset = resetsIn !== undefined && resetsIn <= 0
      const percent = hasReset ? 0 : limit.percentUsed
      const filled = Math.round((Math.min(Math.max(percent, 0), 100) / 100) * CELLS)
      const label = (LABELS[limit.kind] ?? limit.kind).padEnd(LABEL_WIDTH)
      const used = ` ${Math.round(percent)}%`.padStart(USED_WIDTH)
      const reset = (resetsIn !== undefined && !hasReset ? ` ↻ ${until(resetsIn)}` : '').padEnd(RESET_WIDTH)
      return { kind: limit.kind, label, percent, filled, used, reset, short: widthOf(label + used) }
    })
    const avail = roomOf(e) - (hasBeneath ? widthOfNode(beneath, e.props.modes) + SEPARATOR.length : 0)
    const between = (windows.length - 1) * BETWEEN.length
    const short = windows.reduce((sum, w) => sum + w.short, between)
    const used = windows.reduce((sum, w) => sum + widthOf(w.used), between)
    const bars = windows.length * (1 + CELLS)
    const resets = windows.length * RESET_WIDTH
    const forms = windows.length === 0 ? [] : [
      { hasBar: true, hasReset: true, hasLabel: true, width: short + bars + resets },
      { hasBar: false, hasReset: true, hasLabel: true, width: short + resets },
      { hasBar: false, hasReset: false, hasLabel: true, width: short },
      { hasBar: false, hasReset: false, hasLabel: false, width: used }
    ]
    // What gives way, in turn: the meter's bar, the branch down to MIN_BRANCH, the meter's reset time
    // and label, then the rest of the place. The percentage stays.
    const ladder: Array<[number, number]> = [[0, 0], [1, 0], [1, 1], [2, 1], [3, 1], [3, Infinity]]
    let fit = forms[forms.length - 1]
    let spot: ReturnType<typeof placeOf> | null = null
    for (const [form, most] of ladder) {
      fit = forms[form]
      const width = fit ? fit.width + GAP.length : 0
      spot = here === null ? null : placeOf(here, avail - width, most)
      if ((spot?.width ?? 0) + width <= avail) break
    }
    const place = spot === null ? null : (
      <Box flexDirection="row">
        <Text>{spot.dir}</Text>
        {spot.branch ? <Text dimColor>{spot.branch}</Text> : null}
        {spot.status ? <Text color="yellow">{spot.status}</Text> : null}
        {spot.who ? <Text dimColor>{spot.who}</Text> : null}
      </Box>
    )

    const meter = fit === undefined ? null : (
      <Box flexDirection="row">
        {windows.map((w, i) => (
          <Box flexDirection="row" key={w.kind}>
            {i > 0 ? <Text dimColor>{BETWEEN}</Text> : null}
            {fit.hasLabel ? <Text dimColor>{w.label}</Text> : null}
            {fit.hasBar ? <Text color={colorFor(w.percent)}>{' ' + '━'.repeat(w.filled)}</Text> : null}
            {fit.hasBar ? <Text dimColor>{'─'.repeat(CELLS - w.filled)}</Text> : null}
            <Text dimColor>{w.used}</Text>
            {fit.hasReset ? <Text dimColor>{w.reset}</Text> : null}
          </Box>
        ))}
      </Box>
    )

    return (
      <Box flexDirection="row">
        {place}
        {place && meter ? <Text>{GAP}</Text> : null}
        {meter}
        {(meter || place) && hasBeneath ? <Text dimColor>{SEPARATOR}</Text> : null}
        {beneath}
      </Box>
    )
  })

  // The engine draws the mode label itself; the hint line after it starts with "(shift+tab to cycle)",
  // and while Claude works holds "esc to interrupt". Its width tells the meter how much room is left.
  on('ui.render', { component: 'PromptHint' }, ($, e, next) => {
    if (e.props.hint !== lastHint) {
      lastHint = e.props.hint
      lastTidied = tidy(e.props.hint)
    }
    const hint = lastTidied
    if (e.surface === 'terminal') {
      const width = widthOf(hint)
      if (width !== hintWidth) {
        hintWidth = width
        $.ui.invalidate('ui.render')
      }
    }
    return hint === e.props.hint ? next(e) : next({ ...e, props: { ...e.props, hint } })
  })
}
