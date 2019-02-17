<template>
    <main class="main container">
        <h2 v-if="model.name">{{model.name}}</h2>
        <div class="thumbnail-filter-controls-container" :class="{invisible: isCurrentlyBatchSelect}">
            <fieldset v-if="enableHasAlbumFilter">
                <legend>Album</legend>
                <label for="album_filter_mode_all">All</label>
                <input id="album_filter_mode_all" type="radio" value="1" v-model="albumFilterMode" />
                
                <label for="album_filter_mode_no_albums">Uncategorized</label>
                <input id="album_filter_mode_no_albums" type="radio" value="2" v-model="albumFilterMode" />
                
                <label for="album_filter_mode_has_albums">Categorized</label>
                <input id="album_filter_mode_has_albums" type="radio" value="3" v-model="albumFilterMode" />
            </fieldset>
            <fieldset v-if="enableHasPersonFilter">
                <legend>Person</legend>
                <label for="persons_filter_mode_all">All</label>
                <input id="persons_filter_mode_all" type="radio" value="1" v-model="personFilterMode" />
                
                <label for="persons_filter_mode_no_persons">Uncategorized</label>
                <input id="persons_filter_mode_no_persons" type="radio" value="2" v-model="personFilterMode" />
                
                <label for="persons_filter_mode_has_persons">Categorized</label>
                <input id="persons_filter_mode_has_persons" type="radio" value="3" v-model="personFilterMode" />
            </fieldset>
        </div>
        <div class="thumbnail-batch-select-container" v-if="enableBatchSelectImages || enableBatchSelectAlbums">
            <button class="btn" :class="{'btn-primary' : !isCurrentlyBatchSelect, 'btn-outline-secondary': isCurrentlyBatchSelect}" @click="toggleBatchSelect">{{isCurrentlyBatchSelect ? 'Cancel' : 'Batch select'}}</button>
            <button class="btn btn-outline-primary" @click="batchSelectAll" v-if="isCurrentlyBatchSelect">{{anyItemsBatchSelected ? 'Deselect all' : 'Select all'}}</button>
        </div>
        <ul class="thumbnail-list"  v-infinite-scroll="loadMoreThumbnails" infinite-scroll-distance="40" infinite-scroll-disabled="isInfiniteScrollDisabled" :class="{'batch-select': isCurrentlyBatchSelect}">
            <li v-for="(item, i) in filteredThumbnailList" :key="i" :class="{'batch-selected': isCurrentlyBatchSelect && batchSelectedItems[i]}" @click="batchSelectItem(item, i, $event)">
                <router-link :to="showRouteFor(item)" class="thumbnail-image-container" :event="thumbnailLinkEvent" :tag="isCurrentlyBatchSelect ? 'div' : 'a'">
                    <img :alt="altTextFor(item)" :src="thumbnailUrlFor(item)" />
                    <div v-if="isThumbnailFavorited(item)" class="heart"></div>
                </router-link>
                <h3 class="thumbnail-title" :class="{'default-title': !('name' in item)}">
                    <router-link :to="showRouteFor(item)" :event="thumbnailLinkEvent" :tag="isCurrentlyBatchSelect ? 'span' : 'a'">{{titleFor(item)}}</router-link>
                </h3>
            </li>
        </ul>
    </main>
</template>

<script>
import infiniteScroll from 'vue-infinite-scroll';
import vue from 'vue';

//amount of thumbnails to add each time vue infinite scroll is called
const THUMBNAIL_CHUNK_LENGTH = 60;

const PERSON_FILTER_MODE_ALL = 1;
const PERSON_FILTER_MODE_NO_PERSONS = 2;
const PERSON_FILTER_MODE_HAS_PERSONS = 3;

const ALBUM_FILTER_MODE_ALL = 1;
const ALBUM_FILTER_MODE_NO_ALBUMS = 2;
const ALBUM_FILTER_MODE_HAS_ALBUMS = 3;

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
        enableHasAlbumFilter: {
            type: Boolean,
            default: false,
        },
        enableHasPersonFilter: {
            type: Boolean,
            default: false,
        },
        //batchSelectImages and batchSelectAlbums
        //are mutually exclusive
        enableBatchSelectImages: {
            type: Boolean,
            default: true,
        },
        enableBatchSelectAlbums: {
            type: Boolean,
            default: true,
        },
    },
    directives: {
        infiniteScroll,
    },
    components: {
    },
    created(){
        //initial setup of items, since $route watch method won't be called on initial load
        this.loadModel(this.apiPath).then(()=>{
            this.isInitialLoadComplete = true;
        });
    },
    data() {
        return {
            isInitialLoadComplete: false,
            model: [],
            thumbnailList: [],
            albumFilterMode: ALBUM_FILTER_MODE_ALL,
            personFilterMode: PERSON_FILTER_MODE_ALL,
            //following used for batch select multiple items
            isCurrentlyBatchSelect: false,
            batchSelectedItems: [],
            previouslySelectedBatchItemIndex: 0,
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
            return !this.isInitialLoadComplete && this.thumbnailList.length === this.thumnailListSource.length;
        },
        filteredThumbnailList(){
            return this.thumbnailList.filter((item)=>{
                return this.shouldShowItem(item);
            });
        },
        //so thumbnail links are disabled when we are in batch select mode
        thumbnailLinkEvent(){
            return this.isCurrentlyBatchSelect ? '' : 'click';
        },
        anyItemsBatchSelected(){
            return this.batchSelectedItems.some((isSelected)=>isSelected);
        },
    },
    watch: {
        '$route'(to, from){
            this.loadModel(this.apiPath);
        },
    },
    methods: {
        loadModel: function(modelPath){
            this.thumbnailList = [];
            return this.getModel(modelPath).then((itemsJson)=>{
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
        shouldShowItem(item){
            let albumValidation = true;
            if(this.albumFilterMode == ALBUM_FILTER_MODE_NO_ALBUMS){
                albumValidation = !item.albums || item.albums.length === 0;
            }
            else if(this.albumFilterMode == ALBUM_FILTER_MODE_HAS_ALBUMS){
                albumValidation = item.albums && item.albums.length > 0;
            }

            let personValidation = true;
            if(this.personFilterMode == PERSON_FILTER_MODE_NO_PERSONS){
                personValidation = !item.persons || item.persons.length === 0;
            }
            else if(this.personFilterMode == PERSON_FILTER_MODE_HAS_PERSONS){
                personValidation = item.persons && item.persons.length > 0;
            }

            return albumValidation && personValidation;
        },
        toggleBatchSelect(){
            this.isCurrentlyBatchSelect = !this.isCurrentlyBatchSelect;
            if(this.isCurrentlyBatchSelect){
                this.batchSelectedItems = this.filteredThumbnailList.map(()=>false);
                this.previouslySelectedBatchItemIndex = 0;
            }
        },
        batchSelectItem(item, i, event){
            if(!this.isCurrentlyBatchSelect){
                return;
            }
            //if shift key is enabled, select all in range
            if(event.shiftKey){
                let startIndex = this.previouslySelectedBatchItemIndex;
                let endIndex = i;
                if(startIndex > endIndex){
                    const temp = startIndex;
                    startIndex = endIndex;
                    endIndex = temp;
                }
                //for loop is inclusive
                for(let index=startIndex;index<=endIndex;index++){
                    vue.set(this.batchSelectedItems, index, true);
                }
            }
            else{
                vue.set(this.batchSelectedItems, i, !this.batchSelectedItems[i]);
            }
            this.previouslySelectedBatchItemIndex = i;
        },
        batchSelectAll(){
            const anySelected = this.anyItemsBatchSelected;
            this.batchSelectedItems = this.batchSelectedItems.map((isSelected)=>!anySelected);
        },
    }
}
</script>
