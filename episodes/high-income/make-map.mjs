// Builds the hook world map (merged into data.json as "map"). Run outside the repo deps:
//   npm i world-atlas@2 topojson-client@3 d3-geo@3 && node make-map.mjs
// Natural Earth via world-atlas (public domain); 110m outlines, 50m centroids for tiny islands; Equal Earth projection.
import fs from 'fs';
import {feature} from 'topojson-client';
import {geoPath,geoEqualEarth} from 'd3-geo';
const load=n=>{const t=JSON.parse(fs.readFileSync(`node_modules/world-atlas/countries-${n}.json`));const fc=feature(t,t.objects.countries);fc.features=fc.features.filter(f=>f.id!=='010'&&f.id);return fc};
const f110=load('110m'), f50=load('50m');
const W=1000,H=520, proj=geoEqualEarth().fitSize([W,H],f50), path=geoPath(proj).digits(0);
const out={w:W,h:H,paths:{},dots:{}};
for(const f of f110.features){out.paths[f.id]=(out.paths[f.id]||'')+path(f)}
const tiny={ATG:'028',MLT:'470',BRB:'052',KNA:'659',SYC:'690',TTO:'780',PLW:'585',ASM:'016',NRU:'520',LCA:'662',SGP:'702',HKG:'344',MAC:'446',BHR:'048'};
for(const [iso,id] of Object.entries(tiny)){const f=f50.features.find(x=>x.id===id);if(f)out.dots[id]=path.centroid(f).map(v=>+v.toFixed(0));else console.log('no50',iso)}
console.log(Object.keys(out.paths).length,'paths',JSON.stringify(out).length,'bytes');
fs.writeFileSync('map.json',JSON.stringify(out));
out.focus=proj([120,24]).map(v=>+v.toFixed(0));
fs.writeFileSync('map.json',JSON.stringify(out));
const crossed={ATG:'028',MLT:'470',PRT:'620',KOR:'410',SVN:'705',BRB:'052',OMN:'512',KNA:'659',CZE:'203',HUN:'348',SYC:'690',SVK:'703',TTO:'780',HRV:'191',EST:'233',GNQ:'226',LVA:'428',LTU:'440',LBY:'434',POL:'616',CHL:'152',URY:'858',VEN:'862',ARG:'032',BRA:'076',RUS:'643',KAZ:'398',PLW:'585',PAN:'591',ASM:'016',CRI:'188',ROU:'642',NRU:'520',BGR:'100',GUY:'328',MEX:'484',LCA:'662',TUR:'792'};
for(const [iso,id] of Object.entries(crossed)) if(!out.paths[id]&&!out.dots[id]) console.log('NONE',iso);
console.log('focus',out.focus);
