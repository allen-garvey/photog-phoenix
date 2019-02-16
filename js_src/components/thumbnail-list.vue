<template>
    <main class="main container">
        <h2 v-if="model.name">{{model.name}}</h2>
        <div class="thumbnail-filter-controls-container">
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
        <ul class="thumbnail-list"  v-infinite-scroll="loadMoreThumbnails" infinite-scroll-distance="40" infinite-scroll-disabled="isInfiniteScrollDisabled" @mousedown="dragSelectMultipleStart" @mouseup="dragSelectMultipleEnd" @mouseleave="dragSelectMultipleEnd" @mousemove="dragSelectMultipleMouseMove">
            <div class="drag-select-overlay" v-if="isCurrentlyDragSelecting" :style="{height: dragOverlayHeight, width: dragOverlayWidth, left: dragOverlayLeft, top: dragOverlayTop}"></div>
            <li v-for="(item, i) in filteredThumbnailList" :key="i" @mouseenter="listItemMouseEnter(item, i)" :class="{'drag-selected': dragSelectedItems[i]}">
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
import vue from 'vue';

//amount of thumbnails to add each time vue infinite scroll is called
const THUMBNAIL_CHUNK_LENGTH = 60;

const PERSON_FILTER_MODE_ALL = 1;
const PERSON_FILTER_MODE_NO_PERSONS = 2;
const PERSON_FILTER_MODE_HAS_PERSONS = 3;

const ALBUM_FILTER_MODE_ALL = 1;
const ALBUM_FILTER_MODE_NO_ALBUMS = 2;
const ALBUM_FILTER_MODE_HAS_ALBUMS = 3;

//subtract a certain amount of pixels from drag overlay
//otherwise it interferes with mounse enter/leave events on list items
const DRAG_OVERLAY_WHITESPACE = 4;

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
        enableDragSelectMultiple: {
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
            //following used for drag select multiple items
            isCurrentlyDragSelecting: false,
            dragSelectStartCoordinate: null,
            dragSelectCurrentCoordinate: null,
            dragSelectedItems: [],
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
        dragOverlayTop(){
            if(!this.isCurrentlyDragSelecting){
                return 0;
            }
            return `${Math.min(this.dragSelectStartCoordinate.y, this.dragSelectCurrentCoordinate.y) - DRAG_OVERLAY_WHITESPACE}px`;
        },
        dragOverlayLeft(){
            if(!this.isCurrentlyDragSelecting){
                return 0;
            }
            return `${Math.min(this.dragSelectStartCoordinate.x, this.dragSelectCurrentCoordinate.x) - DRAG_OVERLAY_WHITESPACE}px`;
        },
        dragOverlayHeight(){
            if(!this.isCurrentlyDragSelecting){
                return 0;
            }
            return `${Math.abs(this.dragSelectStartCoordinate.y - this.dragSelectCurrentCoordinate.y) - DRAG_OVERLAY_WHITESPACE}px`;
        },
        dragOverlayWidth(){
            if(!this.isCurrentlyDragSelecting){
                return 0;
            }
            return `${Math.abs(this.dragSelectStartCoordinate.x - this.dragSelectCurrentCoordinate.x) - DRAG_OVERLAY_WHITESPACE}px`;
        },
    },
    watch: {
        '$route'(to, from){
            this.loadModel(this.apiPath);
        },
        filteredThumbnailList(){
            this.resetDragSelectedItems();
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
        dragSelectMultipleStart(event){
            if(!this.enableDragSelectMultiple){
                return;
            }
            const coordinate = {
                x: event.pageX,
                y: event.pageY,
            };
            this.dragSelectStartCoordinate = coordinate;
            this.dragSelectCurrentCoordinate = coordinate;
            this.resetDragSelectedItems();
            this.isCurrentlyDragSelecting = true;
        },
        dragSelectMultipleMouseMove(event){
            if(!this.isCurrentlyDragSelecting){
                return;
            }
            this.dragSelectCurrentCoordinate = {
                x: event.pageX,
                y: event.pageY,
            };
        },
        dragSelectMultipleEnd(event){
            if(!this.isCurrentlyDragSelecting){
                return;
            }
            this.isCurrentlyDragSelecting = false;
        },
        resetDragSelectedItems(){
            this.dragSelectedItems = this.filteredThumbnailList.map(()=>false);
        },
        listItemMouseEnter(item, index){
            if(this.isCurrentlyDragSelecting){
                console.log('drag entered');
                vue.set(this.dragSelectedItems, index, !this.dragSelectedItems[index]);
            }
        },
    }
}
</script>
