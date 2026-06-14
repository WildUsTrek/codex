#!/usr/bin/env node
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const root = path.resolve(__dirname, "..");

const DEFAULT_RUNTIME = path.join(root, "01_GIOCO_PRONTO_LOCAL_TEST", "index.html");
const DEFAULT_SUITE = path.join(root, "tests", "perla_regression_suite.json");

const CONTROL_WORDS = new Set([
  "if", "for", "while", "switch", "catch", "function", "return", "typeof",
  "new", "await", "async", "do", "else", "try", "class", "super"
]);

function parseArgs(argv) {
  const args = {
    runtime: DEFAULT_RUNTIME,
    suite: fs.existsSync(DEFAULT_SUITE) ? DEFAULT_SUITE : null,
    out: null,
    check: false,
    pretty: false,
    focus: []
  };
  for (let i = 2; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--runtime") args.runtime = path.resolve(argv[++i]);
    else if (arg === "--suite") args.suite = path.resolve(argv[++i]);
    else if (arg === "--out") args.out = path.resolve(argv[++i]);
    else if (arg === "--check") args.check = true;
    else if (arg === "--pretty") args.pretty = true;
    else if (arg === "--focus") args.focus.push(...String(argv[++i] || "").split(",").map(s => s.trim()).filter(Boolean));
    else if (arg === "--help" || arg === "-h") {
      printHelp();
      process.exit(0);
    } else {
      throw new Error(`Unknown argument: ${arg}`);
    }
  }
  return args;
}

function printHelp() {
  console.log(`PERLA1 runtime analyzer

Usage:
  node tools/perla_runtime_analyzer.mjs --check
  node tools/perla_runtime_analyzer.mjs --out report/RUNTIME_STRUCTURE_CURRENT.json --pretty

Options:
  --runtime <path>  Runtime HTML file. Defaults to active PERLA1 index.html.
  --suite <path>    Regression suite JSON. Defaults to tests/perla_regression_suite.json.
  --out <path>      Write JSON analysis to a file.
  --check           Fail on parse errors, missing required symbols, or suite violations.
  --focus <names>   Comma-separated symbols for focused dependency output.
  --pretty          Pretty-print JSON output.
`);
}

function lineStarts(text) {
  const starts = [0];
  for (let i = 0; i < text.length; i += 1) {
    if (text.charCodeAt(i) === 10) starts.push(i + 1);
  }
  return starts;
}

function lineOf(starts, index) {
  let lo = 0;
  let hi = starts.length - 1;
  while (lo <= hi) {
    const mid = (lo + hi) >> 1;
    if (starts[mid] <= index) lo = mid + 1;
    else hi = mid - 1;
  }
  return Math.max(1, hi + 1);
}

function extractInlineScripts(html) {
  const scripts = [];
  const regex = /<script\b([^>]*)>([\s\S]*?)<\/script>/gi;
  let match;
  const htmlLines = lineStarts(html);
  while ((match = regex.exec(html))) {
    const attrs = match[1] || "";
    if (/\bsrc\s*=/.test(attrs)) continue;
    const full = match[0];
    const openEnd = full.indexOf(">") + 1;
    const contentStart = match.index + openEnd;
    scripts.push({
      attrs,
      code: match[2] || "",
      htmlLineStart: lineOf(htmlLines, contentStart)
    });
  }
  return scripts;
}

function maskCode(code) {
  let out = "";
  let i = 0;
  while (i < code.length) {
    const ch = code[i];
    const next = code[i + 1];
    if (ch === "/" && next === "/") {
      out += "  ";
      i += 2;
      while (i < code.length && code[i] !== "\n") {
        out += " ";
        i += 1;
      }
      continue;
    }
    if (ch === "/" && next === "*") {
      out += "  ";
      i += 2;
      while (i < code.length) {
        if (code[i] === "*" && code[i + 1] === "/") {
          out += "  ";
          i += 2;
          break;
        }
        out += code[i] === "\n" ? "\n" : " ";
        i += 1;
      }
      continue;
    }
    if (ch === "\"" || ch === "'" || ch === "`") {
      const quote = ch;
      out += " ";
      i += 1;
      while (i < code.length) {
        const c = code[i];
        if (c === "\\") {
          out += code[i] === "\n" ? "\n" : " ";
          if (i + 1 < code.length) out += code[i + 1] === "\n" ? "\n" : " ";
          i += 2;
          continue;
        }
        out += c === "\n" ? "\n" : " ";
        i += 1;
        if (c === quote) break;
      }
      continue;
    }
    out += ch;
    i += 1;
  }
  return out;
}

function findMatchingBrace(masked, openIndex) {
  let depth = 0;
  for (let i = openIndex; i < masked.length; i += 1) {
    if (masked[i] === "{") depth += 1;
    else if (masked[i] === "}") {
      depth -= 1;
      if (depth === 0) return i;
    }
  }
  return -1;
}

function addFunction(functions, byName, candidate, masked, starts) {
  const openBrace = masked.indexOf("{", candidate.matchEnd);
  if (openBrace < 0) return;
  const closeBrace = findMatchingBrace(masked, openBrace);
  if (closeBrace < 0) return;
  const startLine = lineOf(starts, candidate.start);
  const endLine = lineOf(starts, closeBrace);
  const item = {
    name: candidate.name,
    kind: candidate.kind,
    start: candidate.start,
    end: closeBrace,
    startLine,
    endLine,
    lines: endLine - startLine + 1,
    block: classifyBlock(candidate.name)
  };
  if (!byName.has(item.name)) {
    byName.set(item.name, item);
    functions.push(item);
  }
}

function findFunctions(masked, starts) {
  const functions = [];
  const byName = new Map();
  const patterns = [
    { kind: "declaration", regex: /\bfunction\s+([A-Za-z_$][\w$]*)\s*\([^)]*\)\s*\{/g },
    { kind: "assigned-function", regex: /\b(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=\s*function\b[^{]*\{/g },
    { kind: "assigned-arrow", regex: /\b(?:const|let|var)\s+([A-Za-z_$][\w$]*)\s*=\s*(?:async\s*)?(?:\([^)]*\)|[A-Za-z_$][\w$]*)\s*=>\s*\{/g },
    { kind: "property-function", regex: /\b([A-Za-z_$][\w$]*)\s*:\s*function\b[^{]*\{/g }
  ];
  for (const pattern of patterns) {
    let match;
    while ((match = pattern.regex.exec(masked))) {
      addFunction(functions, byName, {
        name: match[1],
        kind: pattern.kind,
        start: match.index,
        matchEnd: pattern.regex.lastIndex - 1
      }, masked, starts);
    }
  }
  return functions.sort((a, b) => a.start - b.start);
}

function classifyBlock(name) {
  const n = name.toLowerCase();
  if (n === "drawworld" || n === "gameloop") return "renderer";
  if (n.includes("roof") || n.includes("eave") || n.includes("gable") || n.includes("soffit")) return "roof-system";
  if (n.includes("rain") || n.includes("weather") || n.includes("cloud") || n.includes("skybox")) return "weather-rain";
  if (n.includes("sprite") || n.includes("shadow")) return "sprites";
  if (n.includes("render")) return "renderer";
  if (n.includes("minimap")) return "minimap";
  if (n.includes("asset") || n.includes("tex") || n.includes("load")) return "asset-loading";
  if (n.includes("debug") || n.includes("summary") || n.includes("download") || n.includes("stats")) return "debug-api";
  if (n.includes("world") || n.includes("map") || n.includes("cell") || n.includes("owner")) return "world-data";
  if (n.includes("floor") || n.includes("ceiling") || n.includes("cover")) return "floor-ceiling";
  if (n.includes("wall") || n.includes("ray")) return "wallcasting";
  return "uncategorized";
}

function summarizeFocusGraph(focusGraph) {
  const summary = {};
  for (const [name, data] of Object.entries(focusGraph)) {
    summary[name] = {
      found: !!data.function,
      block: data.function?.block || null,
      startLine: data.function?.startLine || null,
      lines: data.function?.lines || null,
      calls: (data.calls || []).slice(0, 12).map(call => `${call.name}(${call.count})`),
      calledBy: (data.calledBy || []).slice(0, 12).map(call => `${call.name}(${call.count})`)
    };
  }
  return summary;
}

function findGlobals(masked, starts) {
  const globals = [];
  const seen = new Set();
  const regex = /\b(?:const|let|var)\s+([A-Za-z_$][\w$]*)/g;
  let match;
  while ((match = regex.exec(masked))) {
    if (seen.has(match[1])) continue;
    seen.add(match[1]);
    globals.push({
      name: match[1],
      line: lineOf(starts, match.index),
      block: classifyBlock(match[1])
    });
  }
  return globals;
}

function buildGraph(masked, functions, focusSymbols) {
  const known = new Set(functions.map(fn => fn.name));
  const byName = new Map(functions.map(fn => [fn.name, fn]));
  const graph = {};
  const reverse = {};
  const focus = new Set(focusSymbols);
  for (const fn of functions) {
    const body = masked.slice(fn.start, fn.end + 1);
    const calls = new Map();
    const regex = /\b([A-Za-z_$][\w$]*)\s*\(/g;
    let match;
    while ((match = regex.exec(body))) {
      const name = match[1];
      if (CONTROL_WORDS.has(name) || name === fn.name) continue;
      if (!known.has(name)) continue;
      calls.set(name, (calls.get(name) || 0) + 1);
    }
    const localCalls = [...calls.entries()]
      .sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0]))
      .map(([name, count]) => ({ name, count, block: byName.get(name)?.block || "unknown" }));
    graph[fn.name] = { block: fn.block, lines: fn.lines, localCalls };
    for (const call of localCalls) {
      if (!reverse[call.name]) reverse[call.name] = [];
      reverse[call.name].push({ name: fn.name, block: fn.block, count: call.count });
    }
  }
  const focusGraph = {};
  for (const name of focus) {
    focusGraph[name] = {
      function: byName.get(name) || null,
      calls: graph[name]?.localCalls || [],
      calledBy: (reverse[name] || []).sort((a, b) => b.count - a.count || a.name.localeCompare(b.name))
    };
  }
  return { graph, reverse, focusGraph };
}

function summarizeByBlock(items) {
  const byBlock = {};
  for (const item of items) {
    if (!byBlock[item.block]) byBlock[item.block] = { count: 0, lines: 0, symbols: [] };
    byBlock[item.block].count += 1;
    byBlock[item.block].lines += item.lines || 0;
    byBlock[item.block].symbols.push(item.name);
  }
  for (const block of Object.values(byBlock)) {
    block.symbols = block.symbols.slice(0, 40);
  }
  return byBlock;
}

function runChecks({ html, code, parseOk, parseError, functions, suite, buildId }) {
  const failures = [];
  const warnings = [];
  if (!parseOk) failures.push({ type: "parse", message: parseError });
  if (!suite) return { ok: failures.length === 0, failures, warnings };

  if (suite.requiredBuildId && buildId !== suite.requiredBuildId) {
    failures.push({ type: "build-id", message: `Expected ${suite.requiredBuildId}, found ${buildId || "null"}` });
  }
  for (const symbol of suite.requiredSymbols || []) {
    if (!html.includes(symbol) && !code.includes(symbol)) {
      failures.push({ type: "missing-symbol", symbol });
    }
  }
  for (const symbol of suite.forbiddenSymbols || []) {
    if (html.includes(symbol) || code.includes(symbol)) {
      failures.push({ type: "forbidden-symbol", symbol });
    }
  }
  if (suite.minimumFunctionCount && functions.length < suite.minimumFunctionCount) {
    failures.push({ type: "function-count", message: `Expected at least ${suite.minimumFunctionCount}, found ${functions.length}` });
  }
  for (const name of suite.requiredFunctions || []) {
    if (!functions.some(fn => fn.name === name)) {
      failures.push({ type: "missing-function", symbol: name });
    }
  }
  if (suite.warnFunctionLines) {
    for (const fn of functions) {
      if (fn.lines > suite.warnFunctionLines) {
        warnings.push({ type: "large-function", symbol: fn.name, lines: fn.lines, block: fn.block, startLine: fn.startLine });
      }
    }
  }
  return { ok: failures.length === 0, failures, warnings: warnings.slice(0, 80) };
}

function loadSuite(suitePath) {
  if (!suitePath) return null;
  return JSON.parse(fs.readFileSync(suitePath, "utf8"));
}

function main() {
  const args = parseArgs(process.argv);
  const html = fs.readFileSync(args.runtime, "utf8");
  const scripts = extractInlineScripts(html);
  const code = scripts.map(s => s.code).join("\n");
  const starts = lineStarts(code);
  const masked = maskCode(code);
  const buildId = (html.match(/const\s+PERLA_BUILD_ID\s*=\s*['"]([^'"]+)['"]/) || [])[1] || null;

  let parseOk = true;
  let parseError = null;
  try {
    new Function(code);
  } catch (error) {
    parseOk = false;
    parseError = error && (error.stack || error.message) || String(error);
  }

  const suite = loadSuite(args.suite);
  const suiteFocus = suite?.focusSymbols || [];
  const focusSymbols = [...new Set([...suiteFocus, ...args.focus])];
  const functions = findFunctions(masked, starts);
  const globals = findGlobals(masked, starts);
  const { graph, focusGraph } = buildGraph(masked, functions, focusSymbols);
  const checks = runChecks({ html, code, parseOk, parseError, functions, suite, buildId });
  const topFunctions = [...functions]
    .sort((a, b) => b.lines - a.lines)
    .slice(0, 40)
    .map(({ name, kind, startLine, endLine, lines, block }) => ({ name, kind, startLine, endLine, lines, block }));

  const analysis = {
    metadata: {
      generatedAt: new Date().toISOString(),
      runtimePath: path.relative(root, args.runtime).replaceAll("\\", "/"),
      suitePath: args.suite ? path.relative(root, args.suite).replaceAll("\\", "/") : null,
      htmlBytes: html.length,
      scriptCount: scripts.length,
      codeLines: code.split(/\r?\n/).length,
      buildId,
      parseOk
    },
    checks,
    scripts: scripts.map((s, index) => ({ index, htmlLineStart: s.htmlLineStart, codeLines: s.code.split(/\r?\n/).length })),
    counts: {
      functions: functions.length,
      globals: globals.length,
      blocks: Object.keys(summarizeByBlock(functions)).length
    },
    functionsByBlock: summarizeByBlock(functions),
    globalsByBlock: summarizeByBlock(globals.map(g => ({ ...g, lines: 0 }))),
    topFunctions,
    focusGraph,
    dependencyGraph: graph
  };

  const json = JSON.stringify(analysis, null, args.pretty ? 2 : 0);
  if (args.out) {
    fs.mkdirSync(path.dirname(args.out), { recursive: true });
    fs.writeFileSync(args.out, `${json}\n`);
  }
  if (!args.out || args.check) {
    const summary = {
      ok: checks.ok,
      buildId,
      parseOk,
      functions: functions.length,
      globals: globals.length,
      failures: checks.failures,
      warnings: checks.warnings.slice(0, 10),
      topFunctions: topFunctions.slice(0, 10),
      focusGraph: summarizeFocusGraph(focusGraph)
    };
    console.log(JSON.stringify(summary, null, 2));
  }
  if (args.check && !checks.ok) process.exit(1);
}

main();
