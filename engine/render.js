#!/usr/bin/env node
// Render an episode's scene.html to MP4 (video only).
// usage: node engine/render.js episodes/<name> [--preview t1,t2,...]
// The scene page must define window.render(t) and may read window.__DATA__.
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');
const { spawn, execFileSync } = require('child_process');

const epDir = path.resolve(process.argv[2] || '');
const epName = path.basename(epDir);
const ep = JSON.parse(fs.readFileSync(path.join(epDir, 'episode.json'), 'utf8'));
const { width, height, fps } = ep.format;
const data = ep.data ? JSON.parse(fs.readFileSync(path.join(epDir, ep.data), 'utf8')) : null;
const root = path.resolve(__dirname, '..');
const work = path.join(root, '.cache', epName, 'video');
fs.mkdirSync(work, { recursive: true });

async function openPage(browser) {
  const page = await browser.newPage({ viewport: { width, height } });
  await page.addInitScript(d => { window.__DATA__ = d; }, data);
  await page.goto('file://' + path.join(epDir, ep.scene));
  await page.evaluate(() => document.fonts.ready);
  return page;
}

async function renderChunk(browser, i, t0, t1) {
  const out = path.join(work, `chunk${String(i).padStart(2, '0')}.mp4`);
  const tmp = out.replace(/\.mp4$/, '.tmp.mp4');
  const page = await openPage(browser);
  const ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(fps), '-c:v', 'mjpeg', '-i', '-',
    '-c:v', 'libx264', '-preset', 'veryfast', '-crf', '18', '-pix_fmt', 'yuv420p', '-r', String(fps), tmp], { stdio: ['pipe', 'inherit', 'inherit'] });
  const n = Math.round((t1 - t0) * fps);
  for (let f = 0; f < n; f++) {
    await page.evaluate(t => window.render(t), t0 + f / fps);
    const buf = await page.screenshot({ type: 'jpeg', quality: 92 });
    if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
  }
  ff.stdin.end();
  const code = await new Promise(r => ff.on('close', r));
  await page.close();
  if (code !== 0) throw new Error(`ffmpeg failed on chunk ${i}`);
  fs.renameSync(tmp, out);
  console.log(`  chunk ${i}: ${t0}s–${t1}s, ${n} frames`);
  return out;
}

(async () => {
  const browser = await chromium.launch();
  const previewArg = process.argv.indexOf('--preview');
  if (previewArg > 0) {
    const times = process.argv[previewArg + 1].split(',').map(Number);
    const dir = path.join(root, 'renders', epName, 'preview');
    fs.mkdirSync(dir, { recursive: true });
    const page = await openPage(browser);
    for (const t of times) {
      await page.evaluate(t => window.render(t), t);
      await page.screenshot({ path: path.join(dir, `t${t}.jpg`), type: 'jpeg', quality: 85 });
    }
    console.log(`preview frames → ${dir}`);
    await browser.close();
    return;
  }
  const chunks = ep.chunks || [[0, ep.duration]];
  console.log(`rendering ${epName}: ${chunks.length} chunks in parallel`);
  const files = await Promise.all(chunks.map(([a, b], i) => renderChunk(browser, i, a, b)));
  await browser.close();
  const list = path.join(work, 'list.txt');
  fs.writeFileSync(list, files.map(f => `file '${f}'`).join('\n') + '\n');
  const out = path.join(work, 'video.mp4');
  execFileSync('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'concat', '-safe', '0', '-i', list, '-c', 'copy', out]);
  console.log(`video → ${out}`);
})().catch(e => { console.error(e); process.exit(1); });
