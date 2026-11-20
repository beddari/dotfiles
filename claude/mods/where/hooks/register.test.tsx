// Mod tests, run against the engine itself: `claude plugin test .`
import { expect, mock, test } from 'claude-code/testing'
import type { Engine } from 'claude-code/testing'
import type { On, SessionRateLimit } from 'claude-code'

const NOW = Date.parse('2026-10-12T10:00:00Z')
const at = (ms: number) => new Date(NOW + ms).toISOString()
const HOUR = 3_600_000
const LIMITS: SessionRateLimit[] = [
  { kind: 'five_hour', percentUsed: 58, resetsAt: at(2 * HOUR + 10 * 60_000) },
  { kind: 'seven_day', percentUsed: 23.5, resetsAt: at(76 * HOUR) }
]

/** Everything beneath the mod: clock, store, usage, a zmx session in a git checkout, the engine's drawing. */
function world (on: On, env: Record<string, string> = { ZMX_SESSION: 'test', USER: 'me', HOME: '/Users/me' }, branch = 'main') {
  const clock = mock.clock(on, { now: NOW })
  const store: Record<string, unknown> = {}
  on('store.get', ($, e) => ({ value: store[e.key] }))
  on('store.set', ($, e) => {
    store[e.key] = JSON.parse(JSON.stringify(e.value))
    return { value: undefined }
  })
  on('env.get', ($, e) => ({ value: env[e.name] }))
  on('session.cwd', () => ({ value: '/Users/me/kode/beddari/dotfiles' }))
  on('process.run', ($, e) => {
    const out: Record<string, string> = {
      uname: 'jubilato.local\n',
      git: '/Users/me/kode/beddari/dotfiles\n',
      git_branch: `\x1b[35m${branch}\x1b[0m `,
      git_status: '\x1b[33m!?\x1b[0m '
    }
    const key = e.argv[0] === 'starship' ? String(e.argv[2]) : String(e.argv[0])
    return { value: { exitCode: 0, stdout: out[key] ?? '', stderr: '', isStdoutTruncated: false, isStderrTruncated: false } }
  })
  on('session.start', ($, e) => ({ cwd: e.cwd }))
  on('session.end', ($, e) => ({ sessionId: e.sessionId }))
  on('classic.SessionStart', () => ({}))
  on('session.usage', () => ({ value: { startedAt: NOW, context: { window: 200_000 }, rateLimits: LIMITS } as never }))
  on('session.measure', ($, e) => ({ changed: e.changed }))
  on('ui.render', ($, e) => {
    const { Text } = $.ui.resolve(e)
    if ('hint' in e.props) return <Text>{e.props.hint}</Text>
    return { type: 'engine', ref: 0 } as const
  })
  return { clock, store }
}

const startSession = ($: Engine) => $.session.start({ cwd: '/Users/me/kode/beddari/dotfiles', surface: 'terminal', isInteractive: true })
const footer = ($: Engine, columns?: number) =>
  $.ui.mount({ plugin: 'where', surface: 'terminal', component: 'SessionMode', props: { modes: [] }, viewport: columns === undefined ? undefined : { columns, rows: 30 } })

test('shows the repository, branch, status and zmx, then the meter', async ($, on) => {
  world(on)
  await startSession($)
  const ui = await footer($, 200)
  expect(await ui.find({ type: 'Text', text: '5h  ' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: ' 58%' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: '  zmx:test@jubilato' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: 'beddari/dotfiles' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: '@main' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: ' !? ' })).toBeDefined()
})

test('outside zmx it shows user@host', async ($, on) => {
  world(on, { USER: 'me', HOME: '/Users/me' })
  await startSession($)
  const ui = await footer($, 200)
  expect(await ui.find({ type: 'Text', text: 'beddari/dotfiles' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: '  me@jubilato' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: /^zmx:/ })).toBeUndefined()
})

test('the place keeps its width whichever window the meter shows', async ($, on) => {
  const w = world(on)
  await startSession($)
  const first = await footer($, 200)
  const five = await first.find({ type: 'Text', text: '5h  ' })
  await w.clock.advance(8000)
  const second = await footer($, 200)
  expect(five).toBeDefined()
  expect(await second.find({ type: 'Text', text: 'week' })).toBeDefined()
  expect(await second.find({ type: 'Text', text: '  24%' })).toBeDefined()
})

test('a narrow row drops the bar before the place', async ($, on) => {
  world(on)
  await startSession($)
  const ui = await footer($, 90)
  expect(await ui.find({ type: 'Text', text: ' ━━━━━━' })).toBeUndefined()
  expect(await ui.find({ type: 'Text', text: ' 58%' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: 'beddari/dotfiles' })).toBeDefined()
})

test('a very narrow row keeps the percentage', async ($, on) => {
  world(on)
  await startSession($)
  const ui = await footer($, 60)
  expect(await ui.find({ type: 'Text', text: '  58%' })).toBeDefined()
  expect(await ui.find({ type: 'Text', text: 'beddari/dotfiles' })).toBeDefined()
})

const LONG = 'feature/a-very-long-name-feature-25'

/** The row as one line of text, in the order drawn. */
async function line (ui: Awaited<ReturnType<typeof footer>>) {
  return (await ui.find({ type: 'Box' }))?.text ?? ''
}

test('a short row cuts the branch from its end first', async ($, on) => {
  world(on, undefined, LONG)
  await startSession($)
  const text = await line(await footer($, 100))
  expect(text).toContain('beddari/dotfiles@feature/a')
  expect(text).toContain('…')
  expect(text).toContain('zmx:test@jubilato')
  expect(text).toContain('58%')
})

test('a narrower row drops the host, then the session, then shortens the directory', async ($, on) => {
  world(on, undefined, LONG)
  await startSession($)
  const text = await line(await footer($, 72))
  expect(text).toContain('58%')
  expect(text).not.toContain('jubilato')
})
