import { fetchJson } from './request-helpers.js';

function fetchIntoCache(url, cacheMap, mapId){
    if(cacheMap.has(mapId)){
        return new Promise((resolve)=>{
            resolve(cacheMap.get(mapId));
        });
    }
    return fetchJson(url).then((data)=>{
        cacheMap.set(mapId, data);
        return data;
    });
}



export default {
    fetchIntoCache,
};