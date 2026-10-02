import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const here = path.dirname(fileURLToPath(import.meta.url));
const repo = path.resolve(here, '../..');
const archive = path.resolve(process.argv[2] || path.join(repo, '.local/github-issues'));
const git = args => execFileSync('git', args, { cwd: repo, encoding: 'utf8', windowsHide: true, maxBuffer: 32 * 1024 * 1024 }).trim();
const head = git(['rev-parse', 'HEAD']);
const overrides = JSON.parse(await fs.readFile(path.join(here, 'assessments.json'), 'utf8'));
const index = JSON.parse(await fs.readFile(path.join(archive, 'index.json'), 'utf8'));
const manifest = JSON.parse(await fs.readFile(path.join(archive, 'manifest.json'), 'utf8'));
if (!manifest.issues_complete || index.length !== manifest.issues || new Set(index.map(issue => issue.number)).size !== index.length) throw new Error('A complete, unique issue index is required.');
const subjects = git(['log', '--format=%H%x09%s']).split('\n');
const history = new Map();
for (const subject of subjects) {
  const [hash, title] = subject.split('\t');
  for (const match of title.matchAll(/#(\d+)/g)) {
    const number = Number(match[1]);
    if (!history.has(number)) history.set(number, []);
    history.get(number).push({ commit: hash, subject: title });
  }
}
function firstPass(issue) {
  if (issue.labels.some(label => ['website', 'factorcode.org', 'mason', 'release'].includes(label))) return { status: 'needs-infrastructure-verification', reason: 'Check the currently deployed service/build/release state; source history alone cannot prove this report resolved.' };
  if (issue.labels.some(label => ['performance', 'too-slow', 'optimization', 'benchmarks'].includes(label))) return { status: 'needs-benchmark', reason: 'Re-run the workload on current code and compare measurements; no performance closure is inferred from the report age or commit subjects.' };
  if (issue.labels.some(label => ['macOS', 'linux', 'unix', 'windows', 'arm', 'ios', 'gtk', 'cocoa', 'x11', 'virtualized'].includes(label))) return { status: 'needs-platform-reproduction', reason: 'Re-run the described scenario on its named platform/architecture; this first pass does not establish it fixed or still broken.' };
  if (issue.labels.some(label => ['future', 'feature', 'jellyfish', 'bikeshed', 'rename', 'porting'].includes(label))) return { status: 'needs-code-review', reason: 'Compare the requested API/design/feature with current code and document acceptance criteria; implementation status is unverified.' };
  return { status: 'needs-reproduction', reason: 'Re-run the original reproduction or inspect the requested behavior on current code. This first pass makes no completion claim.' };
}
const rows = [];
for (const issue of index) {
  const stored = JSON.parse(await fs.readFile(path.join(archive, issue.file.replace('.md', '.json')), 'utf8'));
  const assessment = issue.state === 'closed' ? { status: 'closed-on-github', reason: 'Already closed on GitHub; this triage does not claim independently verified implementation correctness.', close: false } : { ...firstPass(issue), ...overrides[issue.number] };
  const commits = (assessment.commits || []).map(short => {
    const hash = git(['rev-parse', `${short}^{commit}`]);
    git(['merge-base', '--is-ancestor', hash, head]);
    return hash;
  });
  for (const file of assessment.files || []) await fs.access(path.join(repo, file));
  if (assessment.close && (assessment.status !== 'verified-fixed' || !assessment.validation || !assessment.files?.length || !stored.comments_complete)) throw new Error(`Insufficient closure evidence or incomplete discussion on #${issue.number}.`);
  rows.push({ number: issue.number, title: issue.title, github_state: issue.state, github_state_reason: stored.issue.state_reason, labels: issue.labels, updated_at: issue.updated_at, url: issue.url, status: assessment.status, close: Boolean(assessment.close), reason: assessment.reason, evidence_commits: commits, evidence_files: assessment.files || [], validation: assessment.validation || null, comment_history_complete: stored.comments_complete, review_depth: assessment.close ? 'description, complete discussion, source, and validation' : overrides[issue.number] ? 'targeted source/history assessment; see stated limitations' : 'title/description/history screen; completion unverified', history_references: (history.get(issue.number) || []).slice(0, 5) });
}
for (const number of Object.keys(overrides)) if (!rows.some(row => row.number === Number(number) && row.github_state === 'open')) throw new Error(`Assessment #${number} is not an open issue in this snapshot.`);
const open = rows.filter(row => row.github_state === 'open');
const close = open.filter(row => row.close);
const counts = {};
for (const row of open) counts[row.status] = (counts[row.status] || 0) + 1;
const clean = text => String(text ?? '').replace(/[\t\r\n]/g, ' ').trim();
const md = text => clean(text).replaceAll('|', '\\|');
const issueLink = row => `[#${row.number}](${row.url})`;
const evidence = row => [...row.evidence_commits.map(hash => `[${hash.slice(0, 10)}](https://github.com/factor/factor/commit/${hash})`), ...row.evidence_files.map(file => `[${file}](../../${file})`)].join('; ') || 'Original issue; further verification required.';
const table = list => '| Issue | Title | Assessment | Evidence / next action |\n| --- | --- | --- | --- |\n' + list.map(row => `| ${issueLink(row)} | ${md(row.title)} | ${row.status} | ${md(row.reason)} ${evidence(row)} |`).join('\n') + '\n';
await fs.writeFile(path.join(here, 'issues.json'), `{"snapshot_at":${JSON.stringify(new Date().toISOString())},"source_head":${JSON.stringify(head)},"repository":"factor/factor","issues":[\n${rows.map(row => JSON.stringify(row)).join(',\n')}\n]}\n`);
await fs.writeFile(path.join(here, 'issues.tsv'), ['number\tgithub_state\tgithub_state_reason\tassessment\tclose\tlabels\ttitle\treason\tissue_url\tevidence_commits\tevidence_files', ...rows.map(row => [row.number, row.github_state, row.github_state_reason, row.status, row.close, row.labels.join(','), row.title, row.reason, row.url, row.evidence_commits.join(',') || '-', row.evidence_files.join(',') || '-'].map(clean).join('\t'))].join('\n') + '\n');
await fs.writeFile(path.join(here, 'open-issues.md'), '# Open issue first-pass triage\n\nA complete inventory, not a claim that every reproduction has been executed. See [method and validation](README.md).\n\n' + table(open));
for (const label of ['ui', 'ui-text']) await fs.writeFile(path.join(here, `${label}.md`), `# ${label} triage\n\n` + table(open.filter(row => row.labels.includes(label))));
await fs.writeFile(path.join(here, 'closing-references.txt'), close.map(row => `Fixes #${row.number}`).join('\n') + '\n');
const readme = `# Factor issue triage — 2026-10-01\n\nThe repository contains ${rows.length} issues in this snapshot: ${open.length} open and ${rows.length - open.length} already closed. Every open report received a first-pass title/description/history screen. Targeted source checks and executable regressions support ${close.length} closure references below. The remaining reports retain an explicit verification step; their age or a matching commit title is never treated as proof of completion.\n\nSource checkout: [${head.slice(0, 10)}](https://github.com/factor/factor/commit/${head}). Pull requests are excluded. The local descriptions/index were checked against GitHub's total issue count. Full comment history is required for every closure below; general inventory rows state whether their discussion has been archived completely.\n\n## Inventory\n\n- [All ${rows.length} issue assessments (TSV)](issues.tsv) and [JSON](issues.json), including original GitHub closure reasons.\n- [All ${open.length} open issues](open-issues.md).\n- [UI issues (${open.filter(row => row.labels.includes('ui')).length})](ui.md) and [UI text issues (${open.filter(row => row.labels.includes('ui-text')).length})](ui-text.md).\n- [Manual assessments](assessments.json); [original regressions](verify.factor) and [validation](validation.json); [six UI fixes runner](verify-ui.factor) and [validation](validation-ui.json).\n\nThe 1,556 existing GitHub closures are recorded as \`closed-on-github\`, not reclassified as independently verified fixes. This avoids treating declined proposals and duplicates as completed implementations.\n\n## Open issue classifications\n\n| Assessment | Count |\n| --- | --- |\n${Object.entries(counts).sort().map(([status, count]) => `| ${status} | ${count} |`).join('\n')}\n\n\`verified-fixed\` means the cited code satisfies the original report and full discussion, with executable regression evidence or an explicitly accepted documentation resolution. \`implemented-unverified\` records relevant implementation without claiming the original runtime scenario was checked. \`partial\` leaves additional symptoms, checklist items or platforms open. Other statuses identify the next reproduction, measurement, source review or deployed-service check.\n\n## Verified closure references\n\n${table(close)}\n## Remaining small candidates\n\n- #2309: verify resource-path strings and restart targets in Edit menus.\n- #1697: reproduce preferred editor dimensions with row/column restrictions.\n- #1295: clean up GTK2 metadata containing GTK3 declarations and verify the bindings on Linux.\n\n## Scope and validation\n\nThe validation record covers Windows x86-64. Native Linux/macOS/32-bit scenarios are retained for their own environments unless an existing recorded result directly covers the report. Related commits can be partial or reverted; the inventory preserves those distinctions. Runtime changes are not made by this triage commit.\n\nThe local archive lives at \`.local/github-issues/\` and is excluded through \`.git/info/exclude\`. It contains issue bodies, metadata, readable discussions and resumable download caches. GitHub API authentication was rejected during this pass; public issue-page data supplements comments. The archive manifest is authoritative about whether the entire discussion download has completed.\n\nRegenerate the inventory from the archive:\n\n\`node .github/issue-triage/generate.mjs\`\n\nRun closure verification:\n\n\`.\\factor.com -no-user-init .github/issue-triage/verify.factor\`\n\nThe companion commits include only the validated \`Fixes #…\` references. GitHub applies those references when the commit reaches the repository's default branch. A local commit does not change live GitHub issue state.\n`;
await fs.writeFile(path.join(here, 'README.md'), readme);
console.log(JSON.stringify({ issues: rows.length, open: open.length, closed: rows.length - open.length, verified_closures: close.map(row => row.number), classifications: counts }, null, 2));
