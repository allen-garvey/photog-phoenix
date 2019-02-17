<template>
    <div>
        <Photog-Header/>
        <Flash-Alert ref="flashAlert"/>
        <router-view :get-model="get" :put-flash="putFlash" ref="routerView" :get-exif="getExif" :csrf-token="csrfToken"/>
        <Photog-Footer/>
    </div>
</template>

<script>
import PhotogHeader from './header.vue'
import PhotogFooter from './footer.vue'
import FlashAlert from './flash-alert.vue';
import CacheUtil from '../cache-util.js'

const API_URL_BASE = '/api';

export default {
    name: 'Photog-App',
    props: {
        csrfToken: {
            type: String,
            required: true,
        },
    },
    components: {
        'Photog-Header': PhotogHeader,
        'Photog-Footer': PhotogFooter,
        'Flash-Alert': FlashAlert,
    },
    data() {
        return {
            cache: new Map(),
            exifCache: new Map(),
        }
    },
    computed: {

    },
    created() {
        window.addEventListener('keyup', (e)=>{
            const routerView = this.$refs.routerView;
            switch(e.keyCode){
                //arrow left
                case 37:
                    if(routerView.keyLeftAction){
                        routerView.keyLeftAction();
                    }
                    break;
                //arrow right
                case 39:
                    if(routerView.keyRightAction){
                        routerView.keyRightAction();
                    }
                    break;
            }
        });
    },
    methods: {
        get(modelPath, forceRefresh=false){
            const apiUrl = API_URL_BASE + modelPath;
            return CacheUtil.fetchIntoCache(apiUrl, this.cache, apiUrl, forceRefresh);
        },
        getExif(imageId){
            const apiUrl = `${API_URL_BASE}/images/${imageId}/exif`;
            return CacheUtil.fetchIntoCache(apiUrl, this.exifCache, imageId);
        },
        putFlash(message, type){
            const flashAlert = this.$refs.flashAlert;
            flashAlert.putFlash(message, type);
            flashAlert.$el.scrollIntoView({behavior: 'smooth', block: 'end'});
        },
    }
}
</script>
