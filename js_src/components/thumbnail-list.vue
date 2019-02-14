<template>
    <main class="main container">
        <h2 v-if="model.name">{{model.name}}</h2>
        <ul class="thumbnail-list"  v-infinite-scroll="loadMoreThumbnails" infinite-scroll-distance="40" infinite-scroll-disabled="isInfiniteScrollDisabled">
            <li v-for="(item, i) in thumbnailList" :key="i">
                <router-link :to="showRouteFor(item)" class="thumbnail-image-container">
                    <img :alt="altTextFor(item)" :src="thumbnailUrlFor(item)" />
                    <div v-if="isThumbnailFavorited(item)" class="heart"></div>
                </router-link>
                <h3 class="thumbnail-title" :class="{'default-title': !('name' in item)}"><router-link :to="showRouteFor(item)">{{titleFor(item)}}</router-link></h3>
            </li>
        </ul>
    </main>
</template>

<script>
import infiniteScroll from 'vue-infinite-scroll';

//amount of thumbnails to add each time vue infinite scroll is called
const THUMBNAIL_CHUNK_LENGTH = 60;

export default {
    name: 'Thumbnail-List',
    props: {
        csrfToken: {
            type: String,
            required: true,
        },
        getModel: {
            type: Function,
            required: true,
        },
        apiPath: {
            type: String,
            required: true,
        },
        showRouteFor: {
            type: Function,
            required: true,
        },
        itemsListKey: {
            type: String,
        },
    },
    directives: {
        infiniteScroll,
    },
    components: {
    },
    created(){
        //initial setup of items, since $route watch method won't be called on initial load
        this.loadModel(this.apiPath);
    },
    data() {
        return {
            model: [],
            thumbnailList: [],
        }
    },
    computed: {
        thumnailListSource(){
            //this might happen when vue changed but model not yet loaded
            if(this.itemsListKey && !this.model[this.itemsListKey]){
                return [];
            }
            if(this.itemsListKey){
                return this.model[this.itemsListKey];
            }
            return this.model;

        },
        isInfiniteScrollDisabled(){
            return this.thumbnailList.length === this.thumnailListSource.length;
        },
    },
    watch: {
        '$route'(to, from){
            this.loadModel(this.apiPath);
        }
    },
    methods: {
        loadModel: function(modelPath){
            this.thumbnailList = [];
            this.getModel(modelPath).then((itemsJson)=>{
                this.model = itemsJson;
                this.thumbnailList = this.thumnailListSource.slice(0, THUMBNAIL_CHUNK_LENGTH);
            });
        },
        loadMoreThumbnails(){
            this.thumbnailList = this.thumnailListSource.slice(0, this.thumbnailList.length + THUMBNAIL_CHUNK_LENGTH);
        },
        imageFor: function(item){
            if('cover_image' in item){
                return item.cover_image;
            }
            return item;
        },
        isThumbnailFavorited: function(item){
            //don't show favorite heart for cover image
            if('cover_image' in item){
                return false;
            }
            return this.imageFor(item).is_favorite;
        },
        thumbnailUrlFor: function(item){
            return `/media/thumbnails/${encodeURI(this.imageFor(item).mini_thumbnail_path)}`;
        },
        titleFor: function(item){
            if('name' in item){
                return item.name;
            }
            return `${item.creation_time.formatted.us_date} ${item.creation_time.formatted.time}`;
        },
        altTextFor: function(item){
            if('name' in item){
                return `Thumbnail for ${item.name}`;
            }
            return `Thumbnail for image taken on ${item.creation_time.formatted.us_date}`;
        },
    }
}
</script>
