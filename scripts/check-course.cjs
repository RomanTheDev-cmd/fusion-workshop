const fs=require('node:fs'),vm=require('node:vm'),assert=require('node:assert/strict');
const ctx=vm.createContext({});vm.runInContext(fs.readFileSync('Resources/course.js','utf8')+';globalThis.data={COURSE,MODULES,SOURCES}',ctx);
const {COURSE,MODULES,SOURCES}=ctx.data;
assert.equal(COURSE.length,16);assert.equal(MODULES.length,4);assert.equal(COURSE.filter(x=>x.exam).length,4);
const required=['goal','prereq','concepts','questions','brief','reason','tools','steps','practice','independent','checks','errors','quiz','hard','summary','repeat','result','sources'];
for(const [i,l] of COURSE.entries()){
 assert.equal(l.id,i+1);for(const field of required)assert.ok(l[field]?.length,`Lesson ${l.id}: ${field}`);
 assert.ok(l.steps.length>=6);assert.ok(l.checks.length>=4);assert.equal(l.quiz.length,2);
 if(l.exam||l.module>=2){assert.equal(l.hints.length,2);assert.ok(l.partial.length>100);assert.ok(l.compare.length>100)}
 for(const q of l.quiz){assert.ok(q.q&&q.explain);assert.ok(q.answer>=0&&q.answer<q.options.length)}
 for(const id of l.sources)assert.ok(SOURCES.find(s=>s.id===id));
 assert.ok(JSON.stringify(l).length>3000,`Lesson ${l.id} is too thin`);
}
assert.ok(!/lorem ipsum|placeholder|урок будет добавлен|TODO/i.test(fs.readFileSync('Resources/course.js','utf8')));
assert.equal(60+2*2.4,64.8);assert.equal((6.6-6)/2,0.2999999999999998);
assert.ok(Math.abs(Math.sqrt(60**2-15**2)-58.09475019311125)<1e-9);
assert.ok(Math.abs(10+120*Math.cos(55*Math.PI/180)-78.82917236212554)<1e-9);
// Render every lesson with a minimal DOM adapter; fail on missing fields or broken routes.
const nodes=new Map();const node=selector=>{if(!nodes.has(selector))nodes.set(selector,{innerHTML:'',textContent:'',addEventListener(){}});return nodes.get(selector)};
ctx.window={nativeProgress:{lessons:{}},addEventListener(){},scrollTo(){}};
ctx.history={replaceState(){}};ctx.location={hash:'#lesson-1'};
ctx.document={title:'',querySelector:node,querySelectorAll(){return []}};
vm.runInContext(fs.readFileSync('Resources/app.js','utf8'),ctx);
for(const l of COURSE){ctx.location.hash='#lesson-'+l.id;vm.runInContext('render()',ctx);const html=node('#content').innerHTML;assert.ok(html.includes(l.title));assert.ok(!html.includes('undefined'));assert.ok(html.includes('textarea'));assert.ok(html.includes('data-check'));assert.ok(html.includes('data-answer'));}
const text=COURSE.map(l=>JSON.stringify(l)).join(' ');console.log(`PASS: ${COURSE.length} complete lessons, 4 assessments, 32 questions, all 16 screens render. Course text: ${text.length} characters.`);
