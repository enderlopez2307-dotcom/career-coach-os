# Search Desk

A live, good-looking dashboard for your CareerCoachOS job search. It's a
private Claude artifact you open in your browser, like any web page. It has
four tabs:

- **Today:** your next moves as a checklist you can tick, Coach's read on
  where things stand, a few numbers at a glance, and the latest morning scan.
- **Pipeline:** every role as a card, with a journey through each round
  (the current one glows), the next step with a countdown, your contact, and
  links to your prep docs.
- **Prep:** what to focus on for the next round, a chart of your mock
  interview scores, your prep docs, and a "never say" list.
- **Market:** signals from the daily scan, each marked Confirmed, Reported
  or Unverified, so you know what's safe to repeat.

The design is called **Dawn**: a slowly drifting soft colour field behind
frosted glass panels, with a serif greeting that changes with the time of
day.

## How it works

The page and your data are kept apart:

- **The page** is a Claude artifact: an HTML file hosted privately on
  claude.ai. Only you can open the link unless you share it.
- **Your data** lives in the artifact's own small database, not in the page
  code. Claude reads and writes it with its artifact data tool, and you can
  tick moves off on the page, which saves straight away.

So Claude keeps it current during your CareerCoachOS chats, and you never
have to edit the page yourself.

**One thing to know:** the scheduled morning scan (`scripts/run-daily.sh`)
can't update the dashboard on its own. That run is locked down on purpose:
no connectors and no tools beyond reading the web and writing to `vault/`.
So the dashboard refreshes when you open a chat and ask for it. Start your
day with: **"update my Search Desk"**.

## What you need

- CareerCoachOS installed and working (see `INSTALL.md`).
- Claude Code in the Claude desktop app or on claude.ai, signed in to an
  account that can publish artifacts.
- At least a little in your vault: a Dashboard, one opportunity note, or a
  daily scan. The dashboard has designed empty states, so it works from day
  one, but it's more useful with something in it.

## Set it up (about 5 minutes)

Open Claude Code in your CareerCoachOS folder and paste this:

> Read `SEARCH-DESK.md`. Save the template at the bottom to a file in your
> scratchpad, publish it as an artifact titled "Search Desk" with the `db`
> capability (`capabilities: {"db": {}}`), then fill its database from my
> vault using the data model in that file. Use my first name from
> `config/profile.md` for `meta/summary.name`. Leave out my comp floor, my
> salary figures and anything private. Then save the artifact URL to memory
> so future chats keep it updated, and open it in my browser.

Claude will publish the page, fill it, and give you the link. Bookmark it.

### For Claude: the build steps

1. Save the HTML template below to a scratchpad file exactly as written.
2. Publish it with the Artifact tool: `capabilities: {"db": {}}`, a short
   description, and an icon such as `chart`.
3. Fill the database with one `batch` write (data model below). Sources, in
   order: `vault/Dashboard.md`, each `vault/Companies/*/* — *.md`
   opportunity note (stage, timeline, contacts), `vault/Outreach Drafts/_queue.md`
   (open items become actions), the newest `vault/Archive/Daily Scan/*.md`
   (signals, scan summary, coverage gaps), and any prep or mock-interview
   notes. Write the user's real facts only. Never invent numbers, contacts
   or dates.
4. Read one collection back (for example `actions`) to confirm the page can
   see it.
5. Save the URL and the data model to memory, with the rule: at the start of
   each session, read the newest daily scan and sync `meta/summary`,
   `signals` and `pipeline`. Read `actions` first, because the user may have
   ticked things off.
6. Give the user the link, and open it in their browser if the session can
   (`open <url>` on macOS).

## The data model

Everything is plain JSON documents. Dates are `YYYY-MM-DD`.

| Path | What it holds |
|---|---|
| `meta/summary` | `name` (first name for the greeting), `updatedAt`, `headline` (one line under the greeting), `read` (Coach's read, 2 to 4 sentences), `scanDate`, `scanNew` (number of new verified roles), `scanSummary`, `coverage` (what the last scan couldn't reach) |
| `meta/mocks` | `points`: a list of `{label, date, score}`, score out of 10 |
| `meta/prep` | `title`, `focus`: a list of `{title, items: [..]}`, `docs`: a list of `{label, url, note}` (https links only), `never`: a list of phrases to avoid |
| `pipeline/<id>` | `order`, `caseId` (short code like `ACME-PM`), `company`, `role`, `status` (`live`, `waiting`, `watch`, `closed` or `offer`), `score` (fit out of 10), `stages` (round names in order), `stageNotes` (who and when for each stage, same order), `stagesDone` (how many are finished), `roundsPassed`, `nextStep`, `nextDate`, `contact`, `timeline`: a list of `{date, text}` newest first, `links`: a list of `{label, url}` |
| `actions/<id>` | `order`, `title`, `detail`, `due` (a date) or `when` (free text like "Next week"), `tag` (usually the company), `done`. The page sets `done` and `doneAt` when you tick it |
| `signals/<id>` | `order`, `title`, `text`, `confidence` (`confirmed`, `reported` or `unverified`), `date` |

A role's journey shows `stages` top to bottom. The first `stagesDone`
stages show as finished, and the next one glows as current.

Due dates colour themselves: amber when they're 3 days away or less, red
once they're overdue.

### Example seed

These are made-up examples to show the shape. Replace them with your own
data.

```json
{
  "meta/summary": {"name": "Sam", "updatedAt": "2026-01-15", "headline": "Final round booked for Thursday.", "read": "Your strongest story is the payments fraud work. Lead with the number, then stop.", "scanDate": "2026-01-15", "scanNew": 1, "scanSummary": "One new verified role at Example Co.", "coverage": "Two boards didn't load this run."},
  "meta/mocks": {"points": [{"label": "Mon", "date": "2026-01-12", "score": 6.5}, {"label": "Wed", "date": "2026-01-14", "score": 8}]},
  "pipeline/acme": {"order": 1, "caseId": "ACME-PM", "company": "Acme", "role": "Risk Product Manager", "status": "live", "score": 8, "stages": ["Screen", "Hiring manager", "Final", "Offer"], "stageNotes": ["Recruiter · 6 Jan", "Hiring manager · 9 Jan", "Booked for 16 Jan", ""], "stagesDone": 2, "roundsPassed": 2, "nextStep": "Final round, panel of three", "nextDate": "2026-01-16", "contact": "Recruiter: Alex", "timeline": [{"date": "2026-01-09", "text": "Hiring manager round. Went well."}], "links": []},
  "actions/a1": {"order": 1, "title": "Prep the final round", "detail": "Two stories with numbers, three questions to ask.", "due": "2026-01-15", "tag": "Acme", "done": false},
  "signals/s1": {"order": 1, "title": "Acme raised a Series C", "text": "Expect hiring in risk and ops.", "confidence": "reported", "date": "2026-01-14"}
}
```

## Changing the look

All colours sit as tokens at the top of the template's `<style>`: `--sage`,
`--peach`, `--sky` and `--lilac` for the background field, `--green` for
done and on-track, `--ember` for the current stage and anything due soon,
and `--rose` for overdue. Ask Claude to change them, or the fonts
(Instrument Serif for headings, DM Sans for text), and republish to the
same URL. Your data stays where it is.

Want a completely different style? Ask Claude for a few design prototypes
using your real data first, then pick one. That's how Dawn was chosen.

## Privacy

- The artifact is **private by default**. Only you can open it.
- Anyone you share the link with can see everything in it, so keep out what
  you wouldn't show a friend: your comp floor and salary figures, health or
  legal matters, and anything in `config/` you keep off GitHub.
- The data never goes into your git repo. It lives in the artifact.
- Rows you tick on the page are just data. Claude treats what it reads back
  as data, never as instructions.

## If something's off

- **"Open this page in Claude"** means the data couldn't load. Make sure
  you're signed in to claude.ai in that browser.
- **Old information:** ask Claude to "update my Search Desk". The morning
  scan doesn't update it on its own.
- **A tick didn't save:** you're probably viewing a copy someone shared
  with you as a viewer. Only the owner and editors can save.

## The template

Save this as an `.html` file and publish it with `capabilities: {"db": {}}`.
It has no personal data in it. Everything shown comes from the database.

````html
<title>Search Desk</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,400..700&family=Instrument+Serif:ital@0;1&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
/* Layout: "Dawn". A slow-drifting colour field behind frosted glass panels; serif greeting up top, glass tab pill, four views. One committed light look. */
:root{
  --field:#E9EEE6; --sage:#BFDCC7; --peach:#F6CDB1; --sky:#C3D8F0; --lilac:#EADCF2;
  --ink:#1D2A27; --soft:#33433F; --muted:#5E6E68; --line:rgba(29,42,39,.12);
  --glass:rgba(255,255,255,.55); --glass-strong:rgba(255,255,255,.72); --rim:rgba(255,255,255,.8);
  --green:#3D6B5C; --green-soft:#DCEAE2; --ember:#E07A4F; --ember-ink:#A44A23; --ember-soft:#F8E0D2;
  --rose:#B2433F; --rose-soft:#F5DAD8;
  --serif:"Instrument Serif", "Iowan Old Style", Georgia, serif;
  --sans:"DM Sans", "Helvetica Neue", "Segoe UI", system-ui, sans-serif;
  --mono:"IBM Plex Mono", ui-monospace, Menlo, monospace;
  color-scheme:light;
}
*{box-sizing:border-box}
body{background:var(--field);color:var(--ink);font-family:var(--sans);font-size:15.5px;line-height:1.5;-webkit-font-smoothing:antialiased}
.mesh{position:fixed;inset:-20%;z-index:0;pointer-events:none;background:
  radial-gradient(40% 35% at 18% 22%,var(--sage) 0%,transparent 70%),
  radial-gradient(35% 40% at 82% 18%,var(--peach) 0%,transparent 70%),
  radial-gradient(45% 40% at 62% 88%,var(--sky) 0%,transparent 70%),
  radial-gradient(30% 30% at 12% 86%,var(--lilac) 0%,transparent 70%);
  filter:blur(10px);animation:drift 26s ease-in-out infinite alternate}
@keyframes drift{0%{transform:translate(0,0) rotate(0)}50%{transform:translate(3%,-2%) rotate(3deg)}100%{transform:translate(-2%,3%) rotate(-2deg)}}
.wrap{position:relative;z-index:1;max-width:1140px;margin:0 auto;padding-inline:20px;padding-block:34px 60px}
a{color:var(--green)}
.eyebrow{font-family:var(--mono);font-size:12px;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);display:flex;flex-wrap:wrap;gap:6px 14px}
.eyebrow .live{display:inline-flex;align-items:center;gap:7px}
.eyebrow .live i{width:7px;height:7px;border-radius:50%;background:var(--green);box-shadow:0 0 0 3px rgba(61,107,92,.18)}
h1.hello{font:400 clamp(42px,7.4vw,88px)/1 var(--serif);letter-spacing:-.015em;margin:10px 0 0;text-wrap:balance}
h1.hello em{color:var(--green)}
.lede{max-width:62ch;font-size:17.5px;line-height:1.55;color:var(--soft);margin:14px 0 26px;text-wrap:pretty}
h2{font:400 30px/1.1 var(--serif);margin:0 0 14px;letter-spacing:-.005em}
h3{margin:0}
.glass{background:var(--glass);backdrop-filter:blur(18px) saturate(1.2);-webkit-backdrop-filter:blur(18px) saturate(1.2);border:1px solid var(--rim);border-radius:24px;padding:22px;box-shadow:0 22px 44px -30px rgba(30,50,45,.5);min-width:0}

/* tabs */
.tabs{position:sticky;top:calc(env(safe-area-inset-top,0px) + 10px);z-index:5;display:inline-flex;gap:2px;padding:5px;border-radius:999px;background:rgba(255,255,255,.5);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border:1px solid var(--rim);margin-bottom:24px;max-width:100%;overflow-x:auto;scrollbar-width:none}
.tabs::-webkit-scrollbar{display:none}
.pillbg{position:absolute;top:5px;bottom:5px;left:0;width:0;border-radius:999px;background:#fff;box-shadow:0 6px 16px -8px rgba(30,50,45,.45);transition:transform .45s cubic-bezier(.2,.85,.25,1),width .45s cubic-bezier(.2,.85,.25,1)}
.tab{position:relative;z-index:1;appearance:none;border:0;background:none;font:600 14.5px var(--sans);color:var(--muted);padding:9px 18px;border-radius:999px;cursor:pointer;white-space:nowrap;transition:color .25s}
.tab[aria-selected="true"]{color:var(--ink)}
.tab .n{font-family:var(--mono);font-size:11.5px;margin-left:6px;opacity:.7}
:focus-visible{outline:2px solid var(--green);outline-offset:3px;border-radius:10px}
.panel{animation:rise .5s cubic-bezier(.2,.85,.25,1) both}
@keyframes rise{from{opacity:.35;transform:translateY(10px)}to{opacity:1;transform:none}}
.panel .glass{animation:rise .55s cubic-bezier(.2,.85,.25,1) both}
.panel .glass:nth-child(2){animation-delay:.06s}.panel .glass:nth-child(3){animation-delay:.12s}

.cols{display:grid;grid-template-columns:minmax(0,1.25fr) minmax(0,1fr);gap:18px;align-items:start}
@media (max-width:860px){.cols{grid-template-columns:minmax(0,1fr)}}
.col{display:flex;flex-direction:column;gap:18px;min-width:0}

/* chips */
.chip{display:inline-flex;align-items:center;gap:6px;font-size:12.5px;font-weight:600;padding:4px 10px;border-radius:999px;background:var(--green-soft);color:var(--green);white-space:nowrap}
.chip.ember{background:var(--ember-soft);color:var(--ember-ink)}
.chip.rose{background:var(--rose-soft);color:var(--rose)}
.chip.plain{background:rgba(255,255,255,.7);color:var(--soft)}
.chip.mono{font-family:var(--mono);font-weight:500}

/* moves */
.moves{list-style:none;margin:0;padding:0;display:flex;flex-direction:column;gap:10px}
.mv{position:relative;display:grid;grid-template-columns:30px minmax(0,1fr) auto;gap:2px 12px;align-items:start;padding:14px;border-radius:16px;background:rgba(255,255,255,.62);transition:transform .25s ease,background .25s}
.mv:hover{transform:translateX(4px);background:rgba(255,255,255,.8)}
.mv input{position:absolute;opacity:0;width:1px;height:1px}
.mv .box{width:24px;height:24px;border-radius:50%;border:1.5px solid rgba(61,107,92,.55);display:grid;place-items:center;cursor:pointer;transition:background .25s,border-color .25s,transform .25s}
.mv .box:hover{transform:scale(1.08)}
.mv .box svg{width:13px;height:13px;stroke:#fff;stroke-width:3;fill:none;stroke-dasharray:20;stroke-dashoffset:20;transition:stroke-dashoffset .35s ease .05s}
.mv.done .box{background:var(--green);border-color:var(--green)}
.mv.done .box svg{stroke-dashoffset:0}
.mv .t{font-weight:600;cursor:pointer}
.mv.done .t{color:var(--muted);text-decoration:line-through}
.mv .g{grid-column:2;font-size:13px;color:var(--muted)}
.mv .d{grid-column:2/4;font-size:14px;color:var(--soft);margin-top:4px}
.mv .when{justify-self:end}

/* glance */
.glance{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:10px}
.stat{background:rgba(255,255,255,.6);border-radius:16px;padding:14px}
.stat .v{font:400 40px/1 var(--serif);font-variant-numeric:tabular-nums}
.stat .k{font-size:12.5px;color:var(--muted);margin-top:6px}
.quote{font:italic 400 clamp(21px,2.4vw,25px)/1.3 var(--serif);margin:0;color:#24322E;text-wrap:pretty}
.spark{width:100%;height:auto;display:block;margin-top:12px}
.cap{font-size:13px;color:var(--muted);margin-top:4px}

/* cases */
.cases{display:grid;gap:18px}
.case-head{display:flex;flex-wrap:wrap;gap:10px 18px;justify-content:space-between;align-items:flex-start}
.case-head h3{font:400 34px/1.05 var(--serif)}
.case-head .role{color:var(--soft);margin-top:4px}
.caseid{font-family:var(--mono);font-size:11.5px;letter-spacing:.06em;color:var(--muted)}
.case-body{display:grid;grid-template-columns:minmax(0,1fr) minmax(0,1.1fr);gap:22px;margin-top:18px}
@media (max-width:760px){.case-body{grid-template-columns:minmax(0,1fr)}}
.journey{position:relative;padding-left:28px;margin:0;list-style:none}
.journey li{position:relative;padding:4px 0 16px}
.journey li:last-child{padding-bottom:2px}
.journey li::after{content:"";position:absolute;left:-21px;top:22px;bottom:-4px;width:2px;background:rgba(61,107,92,.18)}
.journey li:last-child::after{display:none}
.journey li.d::after{background:var(--green)}
.journey li::before{content:"";position:absolute;left:-28px;top:6px;width:16px;height:16px;border-radius:50%;background:var(--field);border:2px solid rgba(61,107,92,.35);box-sizing:border-box}
.journey li.d::before{background:var(--green);border-color:var(--green)}
.journey li.c::before{background:#fff;border-color:var(--ember);box-shadow:0 0 0 6px rgba(224,122,79,.18),0 0 18px rgba(224,122,79,.55);animation:glow 2.6s ease-in-out infinite}
@keyframes glow{50%{box-shadow:0 0 0 10px rgba(224,122,79,.07),0 0 26px rgba(224,122,79,.8)}}
.journey .n{font-weight:600}
.journey li.c .n{color:var(--ember-ink)}
.journey li:not(.d):not(.c) .n{color:var(--muted);font-weight:500}
.nextbox{background:rgba(255,255,255,.66);border-radius:16px;padding:14px 16px}
.lbl{font-size:11.5px;letter-spacing:.09em;text-transform:uppercase;color:var(--muted);font-weight:600}
.nextbox .t{font-weight:600;font-size:16px;margin-top:4px}
.nextbox .c{color:var(--soft);font-size:14px;margin-top:6px}
.nextbox .row{display:flex;justify-content:space-between;gap:10px;align-items:flex-start}
.links{display:flex;flex-wrap:wrap;gap:8px;margin-top:12px}
.btn{display:inline-flex;align-items:center;gap:6px;padding:8px 14px;border-radius:999px;background:rgba(255,255,255,.75);color:var(--ink);text-decoration:none;font-weight:600;font-size:13.5px;border:1px solid var(--rim);transition:background .2s,transform .2s}
.btn:hover{background:#fff;transform:translateY(-1px)}
details.tl{margin-top:14px;border-top:1px solid var(--line)}
details.tl summary{list-style:none;cursor:pointer;padding-top:12px;font-weight:600;font-size:14px;color:var(--soft);display:flex;justify-content:space-between}
details.tl summary::-webkit-details-marker{display:none}
details.tl summary span:last-child{transition:transform .25s}
details.tl[open] summary span:last-child{transform:rotate(90deg)}
.events{list-style:none;margin:10px 0 0;padding:0;display:flex;flex-direction:column;gap:10px}
.ev{display:grid;grid-template-columns:72px minmax(0,1fr);gap:12px;font-size:14.5px}
.ev .w{font-family:var(--mono);font-size:12.5px;color:var(--muted);padding-top:2px}

/* prep */
.focus{display:flex;flex-direction:column;gap:18px}
.focus h3{font:400 22px var(--serif);margin-bottom:6px}
.focus ul{margin:0;padding-left:18px;color:var(--soft)}
.focus li{margin:5px 0}
.docs{list-style:none;margin:0;padding:0;display:flex;flex-direction:column;gap:10px}
.docs a{display:block;padding:14px 16px;border-radius:16px;background:rgba(255,255,255,.62);text-decoration:none;color:var(--ink);transition:transform .2s,background .2s}
.docs a:hover{transform:translateX(4px);background:rgba(255,255,255,.85)}
.docs .n{font-weight:600}.docs .s{font-size:13.5px;color:var(--muted)}
.never{margin:0;padding-left:18px;color:var(--soft)}
.never li{margin:5px 0}
.chart{width:100%;height:auto;display:block}

/* market */
.sigs{list-style:none;margin:0;padding:0;display:flex;flex-direction:column;gap:10px}
.sig{display:grid;grid-template-columns:minmax(0,1fr) auto;gap:4px 14px;padding:14px 16px;border-radius:16px;background:rgba(255,255,255,.62)}
.sig .t{font-weight:600}.sig .s{grid-column:1/3;font-size:14px;color:var(--soft)}

.empty{text-align:center;padding:48px 20px}
.empty h2{font-size:34px}
.empty p{color:var(--soft);max-width:48ch;margin:0 auto}
footer{margin-top:34px;font-size:13px;color:var(--muted)}
@media (prefers-reduced-motion:reduce){*,*::before,*::after{animation:none!important;transition:none!important}}
</style>

<div class="mesh" aria-hidden="true"></div>
<div class="wrap">
  <div class="eyebrow"><span>CareerCoachOS · Search Desk</span><span class="live" id="stamp"><i></i>Connecting</span></div>
  <h1 class="hello" id="hello">Hello.</h1>
  <p class="lede" id="lede">Your pipeline, next moves and prep, in one place.</p>

  <nav class="tabs" role="tablist" aria-label="Sections" id="tabs">
    <span class="pillbg" id="pillbg"></span>
    <button class="tab" role="tab" id="tab-today" data-tab="today">Today</button>
    <button class="tab" role="tab" id="tab-pipeline" data-tab="pipeline">Pipeline<span class="n" id="c-pipeline"></span></button>
    <button class="tab" role="tab" id="tab-prep" data-tab="prep">Prep</button>
    <button class="tab" role="tab" id="tab-market" data-tab="market">Market<span class="n" id="c-market"></span></button>
  </nav>

  <main id="view" aria-live="polite"><div class="glass empty"><h2>Loading your search</h2><p>Your pipeline, next moves and prep notes appear here in a moment.</p></div></main>

  <footer>Coach updates this page in your CareerCoachOS chats. Ticking a move off saves it straight away.</footer>
</div>

<script>
(function(){
  var S={connecting:true,meta:null,pipeline:[],actions:[],signals:[],mocks:null,prep:null,tab:"today",db:null,writable:true,loaded:false};
  var TABS=["today","pipeline","prep","market"];
  try{var h=(location.hash||"").slice(1);if(TABS.indexOf(h)>-1)S.tab=h;else{var m=localStorage.getItem("desk.tab");if(TABS.indexOf(m)>-1)S.tab=m;}}catch(e){}

  function el(tag,attrs,kids){var n=document.createElement(tag);if(attrs)for(var k in attrs){var v=attrs[k];if(v==null||v===false)continue;
      if(k==="class")n.className=v;else if(k==="text")n.textContent=v;else if(k.slice(0,2)==="on")n.addEventListener(k.slice(2),v);else n.setAttribute(k,v===true?"":v);}
    (kids||[]).forEach(function(c){if(c==null)return;n.appendChild(typeof c==="string"?document.createTextNode(c):c);});return n;}
  function svg(tag,attrs){var n=document.createElementNS("http://www.w3.org/2000/svg",tag);for(var k in attrs)n.setAttribute(k,attrs[k]);return n;}
  function safeUrl(u){return typeof u==="string"&&/^https:\/\//i.test(u)?u:null;}
  function str(v){return typeof v==="string"?v:(v==null?"":String(v));}
  function arr(v){return Array.isArray(v)?v:[];}
  var MON=["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],DAY=["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
  function parseDay(s){if(typeof s!=="string")return null;var m=s.match(/^(\d{4})-(\d{2})-(\d{2})/);return m?new Date(+m[1],+m[2]-1,+m[3]):null;}
  function fmtDay(s){var d=parseDay(s);return d?d.getDate()+" "+MON[d.getMonth()]:str(s);}
  function fmtDue(s){var d=parseDay(s);return d?DAY[d.getDay()]+" "+d.getDate()+" "+MON[d.getMonth()]:str(s);}
  function daysUntil(s){var d=parseDay(s);if(!d)return null;var t=new Date();t.setHours(0,0,0,0);return Math.round((d-t)/86400000);}
  function dueChip(s){var n=daysUntil(s);if(n==null)return null;
    if(n<0)return el("span",{class:"chip rose",text:(-n)+(n===-1?" day":" days")+" overdue"});
    if(n===0)return el("span",{class:"chip ember",text:"Today"});
    if(n===1)return el("span",{class:"chip ember",text:"Tomorrow"});
    if(n<=3)return el("span",{class:"chip ember",text:"In "+n+" days"});
    return el("span",{class:"chip plain",text:fmtDue(s)});}
  var STATUS={live:["In process",""],waiting:["Waiting on them","ember"],watch:["Watching","plain"],closed:["Closed","rose"],offer:["Offer","" ]};

  function greet(){var h=new Date().getHours();var g=h<5?"Still up":h<12?"Good morning":h<18?"Good afternoon":"Good evening";
    var name=str(S.meta&&S.meta.name).trim();var e=document.getElementById("hello");
    if(!name){e.textContent=g+".";return;}e.textContent=g+", ";e.appendChild(el("em",{text:name+"."}));}
  greet();

  function header(){var m=S.meta||{};greet();var st=document.getElementById("stamp");st.textContent="";st.appendChild(el("i"));
    st.appendChild(document.createTextNode(!S.db?(S.connecting?"Connecting":"Open in Claude to load your data"):(m.updatedAt?"Updated "+fmtDay(m.updatedAt):"Live")));
    if(m.headline)document.getElementById("lede").textContent=m.headline;
    var p=S.pipeline.filter(function(c){return c.status!=="closed";}).length;
    document.getElementById("c-pipeline").textContent=p?String(p):"";
    document.getElementById("c-market").textContent=S.signals.length?String(S.signals.length):"";}

  function movePill(){var t=document.querySelector('.tab[aria-selected="true"]'),b=document.getElementById("pillbg");if(!t)return;
    b.style.width=t.offsetWidth+"px";b.style.transform="translateX("+t.offsetLeft+"px)";}
  function setTab(t){S.tab=t;try{localStorage.setItem("desk.tab",t);}catch(e){}
    TABS.forEach(function(x){document.getElementById("tab-"+x).setAttribute("aria-selected",x===t?"true":"false");});movePill();render();}

  function emptyGlass(title,body){return el("div",{class:"glass empty"},[el("h2",{text:title}),el("p",{text:body})]);}
  function sparkline(points,W,H){var v=points.map(function(p){return +p.score||0;}),P=7;
    var s=svg("svg",{viewBox:"0 0 "+W+" "+H,class:"spark",role:"img","aria-label":"Mock scores "+v.join(", ")+" out of 10"});if(v.length<2)return s;
    var x=function(i){return P+i*(W-2*P)/(v.length-1);},y=function(n){return H-P-(n/10)*(H-2*P);};
    var d=v.map(function(n,i){return (i?"L":"M")+x(i).toFixed(1)+" "+y(n).toFixed(1);}).join(" ");
    s.appendChild(svg("path",{d:d+" L"+x(v.length-1)+" "+(H-P)+" L"+x(0)+" "+(H-P)+" Z",fill:"rgba(61,107,92,.12)"}));
    s.appendChild(svg("path",{d:d,fill:"none",stroke:"#3D6B5C","stroke-width":"2.5","stroke-linejoin":"round","stroke-linecap":"round"}));
    s.appendChild(svg("circle",{cx:x(v.length-1),cy:y(v[v.length-1]),r:"5.5",fill:"#E07A4F"}));return s;}

  /* Today */
  function moveRow(a){var done=!!a.done,id="mv-"+a._id;var li=el("li",{class:"mv"+(done?" done":"")});
    var input=el("input",{type:"checkbox",id:id});input.checked=done;input.disabled=!S.writable;
    input.addEventListener("change",function(){toggle(a,input.checked,li);});
    var box=el("label",{class:"box",for:id,title:done?"Mark as not done":"Mark as done"});var s=svg("svg",{viewBox:"0 0 16 16","aria-hidden":"true"});s.appendChild(svg("path",{d:"M3 8.5l3.2 3L13 4.5"}));box.appendChild(s);
    li.appendChild(input);li.appendChild(box);li.appendChild(el("label",{class:"t",for:id,text:str(a.title)}));
    li.appendChild(el("div",{class:"when"},[done?el("span",{class:"chip",text:"Done"}):(a.due?dueChip(a.due):el("span",{class:"chip plain",text:str(a.when||"When it happens")}))]));
    if(a.tag)li.appendChild(el("div",{class:"g",text:str(a.tag)}));
    if(a.detail)li.appendChild(el("div",{class:"d",text:str(a.detail)}));return li;}
  function toggle(a,val,li){if(!S.db)return;li.classList.toggle("done",val);
    S.db.collection("actions").doc(a._id).update({done:val,doneAt:val?new Date().toISOString().slice(0,10):null}).catch(function(e){li.classList.toggle("done",!val);if(e&&e.code==="invalid_argument"){S.writable=false;render();}});}
  function viewToday(){var m=S.meta||{};var acts=S.actions.slice().sort(function(a,b){return ((a.done?1:0)-(b.done?1:0))||((a.order||0)-(b.order||0));});
    var open=acts.filter(function(a){return !a.done;});var pts=arr(S.mocks&&S.mocks.points);
    var live=S.pipeline.filter(function(c){return c.status==="live"||c.status==="waiting";}).length;
    var rounds=S.pipeline.reduce(function(n,c){return n+(+c.roundsPassed||0);},0);
    var left=el("div",{class:"col"},[el("section",{class:"glass"},[el("h2",{text:"Next moves"}),
      acts.length?el("ul",{class:"moves"},acts.map(moveRow)):el("p",{class:"cap",text:"No moves yet. Ask Coach to plan your week."})])]);
    var right=el("div",{class:"col"},[
      m.read?el("section",{class:"glass"},[el("div",{class:"lbl",text:"Coach's read"}),el("p",{class:"quote",style:"margin-top:8px",text:"“"+str(m.read)+"”"}),
        pts.length?sparkline(pts,320,64):null,pts.length?el("div",{class:"cap",text:"Mock scores: "+pts.map(function(p){return p.score;}).join(" → ")}):null]):null,
      el("section",{class:"glass"},[el("h2",{text:"At a glance"}),el("div",{class:"glance"},[
        el("div",{class:"stat"},[el("div",{class:"v",text:String(live)}),el("div",{class:"k",text:"Live threads"})]),
        el("div",{class:"stat"},[el("div",{class:"v",text:String(rounds)}),el("div",{class:"k",text:"Rounds passed"})]),
        el("div",{class:"stat"},[el("div",{class:"v",text:String(open.length)}),el("div",{class:"k",text:"Open moves"})])])]),
      m.scanSummary?el("section",{class:"glass"},[el("div",{class:"lbl",text:"Morning scan"+(m.scanDate?" · "+fmtDay(m.scanDate):"")}),el("p",{style:"margin:8px 0 0;color:var(--soft)",text:str(m.scanSummary)})]):null]);
    return el("div",{class:"cols"},[left,right]);}

  /* Pipeline */
  function caseCard(c){var st=STATUS[c.status]||[str(c.status),"plain"];var stages=arr(c.stages),done=+c.stagesDone||0;
    var head=el("div",{class:"case-head"},[el("div",{},[el("div",{class:"caseid",text:str(c.caseId)}),el("h3",{text:str(c.company)}),el("div",{class:"role",text:str(c.role)})]),
      el("div",{style:"display:flex;gap:8px;flex-wrap:wrap"},[el("span",{class:"chip "+st[1],text:st[0]}),c.score!=null?el("span",{class:"chip mono plain",text:"Fit "+str(c.score)+"/10"}):null])]);
    var notes=arr(c.stageNotes);
    var journey=el("ol",{class:"journey","aria-label":"Stages"},stages.map(function(s,i){var cls=i<done?"d":(i===done&&c.status!=="closed"?"c":"");
      return el("li",{class:cls},[el("div",{class:"n",text:str(s)}),notes[i]?el("div",{class:"cap",style:"margin:0",text:str(notes[i])}):null]);}));
    var links=arr(c.links).filter(function(l){return safeUrl(l.url);});
    var right=el("div",{},[c.nextStep?el("div",{class:"nextbox"},[el("div",{class:"row"},[el("div",{class:"lbl",text:"Next step"}),c.nextDate?dueChip(c.nextDate):null]),
        el("div",{class:"t",text:str(c.nextStep)}),c.contact?el("div",{class:"c",text:str(c.contact)}):null]):null,
      links.length?el("div",{class:"links"},links.map(function(l){return el("a",{class:"btn",href:safeUrl(l.url),target:"_blank",rel:"noopener"},[str(l.label)+" ↗"]);})):null]);
    var evs=arr(c.timeline);
    var tl=evs.length?el("details",{class:"tl"},[el("summary",{},[el("span",{text:"Timeline · "+evs.length}),el("span",{"aria-hidden":"true",text:"›"})]),
      el("ul",{class:"events"},evs.map(function(e){return el("li",{class:"ev"},[el("div",{class:"w",text:fmtDay(e.date)}),el("div",{text:str(e.text)})]);}))]):null;
    return el("article",{class:"glass"},[head,el("div",{class:"case-body"},[journey,right]),tl]);}
  function viewPipeline(){var list=S.pipeline.slice().sort(function(a,b){return (a.order||0)-(b.order||0);});
    return list.length?el("div",{class:"cases"},list.map(caseCard)):emptyGlass("No live cases yet","Coach adds roles here as they come in.");}

  /* Prep */
  function chart(points){var W=520,H=200,L=30,R=18,T=24,B=36;var v=points.map(function(p){return +p.score||0;});
    var s=svg("svg",{viewBox:"0 0 "+W+" "+H,class:"chart",role:"img","aria-label":"Mock interview scores over time"});
    var y=function(n){return T+(1-n/10)*(H-T-B);},x=function(i){return L+(v.length<2?0:i*(W-L-R)/(v.length-1));};
    [0,5,10].forEach(function(g){s.appendChild(svg("line",{x1:L,x2:W-R,y1:y(g),y2:y(g),stroke:"rgba(29,42,39,.12)"}));
      var t=svg("text",{x:L-8,y:y(g)+4,"text-anchor":"end","font-size":"11",fill:"#5E6E68","font-family":"IBM Plex Mono, monospace"});t.textContent=String(g);s.appendChild(t);});
    if(v.length>1){var d=v.map(function(n,i){return (i?"L":"M")+x(i).toFixed(1)+" "+y(n).toFixed(1);}).join(" ");
      s.appendChild(svg("path",{d:d+" L"+x(v.length-1)+" "+y(0)+" L"+x(0)+" "+y(0)+" Z",fill:"rgba(61,107,92,.12)"}));
      s.appendChild(svg("path",{d:d,fill:"none",stroke:"#3D6B5C","stroke-width":"2.5","stroke-linejoin":"round"}));}
    points.forEach(function(p,i){var last=i===v.length-1;s.appendChild(svg("circle",{cx:x(i),cy:y(v[i]),r:last?"6":"4.5",fill:last?"#E07A4F":"#fff",stroke:last?"#E07A4F":"#3D6B5C","stroke-width":"2"}));
      var vt=svg("text",{x:x(i),y:y(v[i])-12,"text-anchor":"middle","font-size":"13",fill:"#1D2A27","font-family":"DM Sans, sans-serif","font-weight":"600"});vt.textContent=String(v[i]);s.appendChild(vt);
      var lt=svg("text",{x:x(i),y:H-12,"text-anchor":v.length>1&&i===0?"start":(v.length>1&&last?"end":"middle"),"font-size":"11.5",fill:"#5E6E68","font-family":"DM Sans, sans-serif"});lt.textContent=str(p.label);s.appendChild(lt);});
    return s;}
  function viewPrep(){var p=S.prep||{};var focus=arr(p.focus),docs=arr(p.docs).filter(function(d){return safeUrl(d.url);}),pts=arr(S.mocks&&S.mocks.points),nv=arr(p.never);
    if(!focus.length&&!docs.length&&!pts.length)return emptyGlass("No prep yet","Coach adds your next round's focus here.");
    var left=el("div",{class:"col"},[focus.length?el("section",{class:"glass"},[el("h2",{text:str(p.title||"Focus for the next round")}),
        el("div",{class:"focus"},focus.map(function(f){return el("div",{},[el("h3",{text:str(f.title)}),el("ul",{},arr(f.items).map(function(i){return el("li",{text:str(i)});}))]);}))]):null,
      pts.length?el("section",{class:"glass"},[el("h2",{text:"Mock interviews"}),chart(pts)]):null]);
    var right=el("div",{class:"col"},[docs.length?el("section",{class:"glass"},[el("h2",{text:"Prep docs"}),el("ul",{class:"docs"},docs.map(function(d){return el("li",{},[el("a",{href:safeUrl(d.url),target:"_blank",rel:"noopener"},[el("div",{class:"n",text:str(d.label)+" ↗"}),d.note?el("div",{class:"s",text:str(d.note)}):null])]);}))]):null,
      nv.length?el("section",{class:"glass"},[el("h2",{text:"Never say"}),el("ul",{class:"never"},nv.map(function(n){return el("li",{text:str(n)});}))]):null]);
    return el("div",{class:"cols"},[left,right]);}

  /* Market */
  var CONF={confirmed:["Confirmed",""],reported:["Reported","plain"],unverified:["Unverified","ember"]};
  function viewMarket(){var m=S.meta||{};if(!S.signals.length)return emptyGlass("No signals yet","The morning scan's market notes appear here.");
    var list=S.signals.slice().sort(function(a,b){return (a.order||0)-(b.order||0);});
    return el("div",{class:"cols"},[el("section",{class:"glass"},[el("h2",{text:"Market signals"}),el("ul",{class:"sigs"},list.map(function(s){var c=CONF[s.confidence]||[str(s.confidence),"plain"];
        return el("li",{class:"sig"},[el("div",{class:"t",text:str(s.title)}),el("span",{class:"chip "+c[1],text:c[0]}),el("div",{class:"s",text:str(s.text)+(s.date?" · "+fmtDay(s.date):"")})]);}))]),
      el("div",{class:"col"},[m.scanSummary?el("section",{class:"glass"},[el("div",{class:"lbl",text:"Morning scan"}),el("p",{style:"margin:8px 0 0;color:var(--soft)",text:str(m.scanSummary)})]):null,
        m.coverage?el("section",{class:"glass"},[el("div",{class:"lbl",text:"Not reached last scan"}),el("p",{style:"margin:8px 0 0;color:var(--soft)",text:str(m.coverage)})]):null])]);}

  function render(){var v=document.getElementById("view");v.textContent="";header();
    if(!S.db&&S.connecting){v.appendChild(emptyGlass("Loading your search","One moment."));return;}
    if(!S.db){v.appendChild(emptyGlass("Open this page in Claude","Your search data loads when you're signed in to Claude."));return;}
    if(!S.loaded){v.appendChild(emptyGlass("Loading your search","One moment."));return;}
    var node=S.tab==="pipeline"?viewPipeline():S.tab==="prep"?viewPrep():S.tab==="market"?viewMarket():viewToday();
    v.appendChild(el("div",{class:"panel",role:"tabpanel","aria-labelledby":"tab-"+S.tab},[node]));}

  var tabs=document.getElementById("tabs");
  tabs.addEventListener("click",function(e){var b=e.target.closest(".tab");if(b)setTab(b.getAttribute("data-tab"));});
  tabs.addEventListener("keydown",function(e){if(e.key!=="ArrowRight"&&e.key!=="ArrowLeft")return;var i=(TABS.indexOf(S.tab)+(e.key==="ArrowRight"?1:-1)+TABS.length)%TABS.length;setTab(TABS[i]);document.getElementById("tab-"+TABS[i]).focus();});
  TABS.forEach(function(x){document.getElementById("tab-"+x).setAttribute("aria-selected",x===S.tab?"true":"false");});
  window.addEventListener("resize",movePill);requestAnimationFrame(movePill);if(document.fonts&&document.fonts.ready)document.fonts.ready.then(movePill);

  function start(){if(!window.claude||!window.claude.use){S.connecting=false;render();return;}
    window.claude.use("db").then(function(db){S.connecting=false;S.db=db;if(!db){render();return;}
      var pending=4;function ready(){pending--;if(pending<=0)S.loaded=true;render();}
      function list(name){var first=true;db.collection(name).onSnapshot(function(snap){S[name]=snap.docs.map(function(d){var o=Object.assign({},d.data());o._id=d.id;return o;});if(first){first=false;ready();}else render();},function(){if(first){first=false;ready();}});}
      list("pipeline");list("actions");list("signals");
      var firstMeta=true;db.collection("meta").onSnapshot(function(snap){S.meta=null;S.mocks=null;S.prep=null;snap.docs.forEach(function(d){var o=d.data()||{};if(d.id==="summary")S.meta=o;if(d.id==="mocks")S.mocks=o;if(d.id==="prep")S.prep=o;});
        if(firstMeta){firstMeta=false;ready();}else render();},function(){if(firstMeta){firstMeta=false;ready();}});
      render();}).catch(function(){S.connecting=false;S.db=null;render();});}
  render();start();
})();
</script>
````
