<template>
    <main class="main container">
        <Resource-Header :title="pageTitle ? pageTitle : model.name" :editItemLink="editItemLink" :newItemLink="newItemLink" :description="model.description" />
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
            <button class="btn" :class="{'btn-outline-primary' : !isCurrentlyBatchSelect, 'btn-outline-secondary': isCurrentlyBatchSelect}" @click="toggleBatchSelect">{{isCurrentlyBatchSelect ? 'Cancel' : 'Batch edit'}}</button>
            <button class="btn btn-outline-primary" @click="batchSelectAll" v-if="isCurrentlyBatchSelect">{{anyItemsBatchSelected ? 'Deselect all' : 'Select all'}}</button>
            <div class="resource-buttons-container" v-if="isCurrentlyBatchSelect">
                <div v-if="enableBatchSelectImages" class="btn-group">
                    <button class="btn btn-primary" @click="setBatchResourceMode(1)" :class="buttonClassForResourceMode(1)">Add Albums</button>
                    <button class="btn btn-primary" @click="setBatchResourceMode(2)" :class="buttonClassForResourceMode(2)">Add Persons</button>
                    <button class="btn btn-outline-primary" @click="createResourceWithImages('albumsNew')" :disabled="!anyItemsBatchSelected">Create Album</button>
                    <button class="btn btn-outline-primary" @click="createResourceWithImages('personsNew')" :disabled="!anyItemsBatchSelected">Create Person</button>
                </div>
                <button class="btn btn-primary" @click="setBatchResourceMode(3)" :class="buttonClassForResourceMode(3)" v-if="enableBatchSelectAlbums">Add Tags</button>
            </div>  
            <div v-if="shouldShowBatchResources">
                <ul class="batch-resources-list">
                    <li v-for="(resource, index) in batchResourcesDisplayed" :key="resource.id">
                        <input type="checkbox" :id="idForBatchResource(resource, index)" v-model="batchResourcesSelected[index]" />
                        <label :for="idForBatchResource(resource, index)">{{resource.name}}</label>
                    </li>
                </ul>
                <button class="btn btn-outline-dark" v-if="batchResources.length > batchResourcesMoreLimit" @click="toggleDisplayMoreBatchResources">{{batchResourcesDisplayed.length < batchResources.length ? 'Show more' : 'Show less'}}</button>
                <button class="btn btn-success" :disabled="!anyBatchResourcesSelected || !anyItemsBatchSelected" @click="saveBatchSelected">Save</button>
            </div>
        </div>
        <ul class="thumbnail-list"  :class="{'batch-select': isCurrentlyBatchSelect}">
            <li v-for="(item, i) in filteredThumbnailList" :key="i" :class="{'batch-selected': isCurrentlyBatchSelect && batchSelectedItems[i]}" @click="batchSelectItem(item, i, $event)">
                <router-link :to="showRouteFor(item, model)" class="thumbnail-image-container" :event="thumbnailLinkEvent" :tag="isCurrentlyBatchSelect ? 'div' : 'a'">
                    <img :alt="altTextFor(item)" :src="thumbnailUrlFor(item)" />
                    <div v-if="isThumbnailFavorited(item)" class="heart"></div>
                </router-link>
                <h3 class="thumbnail-title" :class="{'default-title': !('name' in item), 'thumbnail-title-favorite': isThumbnailFavorited(item)}">
                    <router-link :to="showRouteFor(item, model)" :event="thumbnailLinkEvent" :tag="isCurrentlyBatchSelect ? 'span' : 'a'">{{titleFor(item)}}</router-link>
                </h3>
            </li>
        </ul>
        <infinite-loading @infinite="loadMoreThumbnails" spinner="waveDots" v-if="isInitialLoadComplete"></infinite-loading>
    </main>
</template>

<script>
import InfiniteLoading from 'vue-infinite-loading';
import vue from 'vue';

import ReasourceHeader from './resource-header.vue';

import { thumbnailUrlFor } from '../image.js';
import { API_URL_BASE } from '../request-helpers.js';

//amount of thumbnails to add each time vue infinite scroll is called
const THUMBNAIL_CHUNK_LENGTH = 60;

//thumbnail filtering
const PERSON_FILTER_MODE_ALL = 1;
const PERSON_FILTER_MODE_NO_PERSONS = 2;
const PERSON_FILTER_MODE_HAS_PERSONS = 3;

const ALBUM_FILTER_MODE_ALL = 1;
const ALBUM_FILTER_MODE_NO_ALBUMS = 2;
const ALBUM_FILTER_MODE_HAS_ALBUMS = 3;

//thumbnail batch select
const BATCH_RESOURCE_MODE_NONE = 0;
const BATCH_RESOURCE_MODE_ALBUMS = 1;
const BATCH_RESOURCE_MODE_PERSONS = 2;
const BATCH_RESOURCE_MODE_TAGS = 3;

export default {
    name: 'Thumbnail-List',
    props: {
        putFlash: {
            type: Function,
            required: true,
        },
        sendJson: {
            type: Function,
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
        newItemLink: {
            type: Object,
        },
        editItemLink: {
            type: Object,
        },
        pageTitle: {
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
            default: false,
        },
        enableBatchSelectAlbums: {
            type: Boolean,
            default: false,
        },
    },
    components: {
        'Resource-Header': ReasourceHeader,
        InfiniteLoading,
    },
    created(){
        this.setup();
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
            batchResources: [],
            batchResourcesSelected: [],
            batchSelectResourceMode: BATCH_RESOURCE_MODE_NONE,
            shouldShowAllBatchResources: false,
            batchResourcesMoreLimit: 8,
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
        filteredThumbnailList(){
            return this.thumbnailList.filter((item)=>{
                return this.shouldShowItem(item);
            });
        },
        thumbnailListSelectedItems(){
            return this.filteredThumbnailList.filter((item, i) => this.batchSelectedItems[i]);
        },
        //so thumbnail links are disabled when we are in batch select mode
        thumbnailLinkEvent(){
            return this.isCurrentlyBatchSelect ? '' : 'click';
        },
        shouldShowBatchResources(){
            return this.batchSelectResourceMode !== BATCH_RESOURCE_MODE_NONE;
        },
        anyItemsBatchSelected(){
            return this.batchSelectedItems.some((isSelected)=>isSelected);
        },
        anyBatchResourcesSelected(){
            return this.batchResourcesSelected.some((isSelected)=>isSelected);
        },
        batchResourcesDisplayed(){
            if(this.shouldShowAllBatchResources){
                return this.batchResources;
            }
            return this.batchResources.slice(0, this.batchResourcesMoreLimit);
        },
    },
    watch: {
        '$route'(to, from){
            this.setup();
        },
    },
    methods: {
        setup(){
            this.isInitialLoadComplete = false;
            this.model = [];
            this.albumFilterMode = ALBUM_FILTER_MODE_ALL;
            this.personFilterMode = PERSON_FILTER_MODE_ALL;
            this.isCurrentlyBatchSelect = false;
            this.batchSelectedItems = [];
            this.previouslySelectedBatchItemIndex = 0;
            this.batchResources = [];
            this.batchResourcesSelected = [];
            this.batchSelectResourceMode = BATCH_RESOURCE_MODE_NONE;
            this.shouldShowAllBatchResources = false;
            
            this.loadModel().then(()=>{
                this.isInitialLoadComplete = true;
            });
        },
        loadModel(){
            this.thumbnailList = [];
            return this.getModel(this.apiPath).then((items)=>{
                this.modelLoaded(items);
            });
        },
        modelLoaded(items){
            this.model = items;
            this.thumbnailList = this.thumnailListSource.slice(0, THUMBNAIL_CHUNK_LENGTH);
        },
        refreshModel(){
            return this.getModel(this.apiPath, true).then((items)=>{
                this.modelLoaded(items);
            });
        },
        loadMoreThumbnails($state){
            this.thumbnailList = this.thumnailListSource.slice(0, this.thumbnailList.length + THUMBNAIL_CHUNK_LENGTH);
            if(this.thumbnailList.length === this.thumnailListSource.length){
                $state.complete();
            }
            else{
                $state.loaded();
            }
        },
        imageFor(item){
            if('cover_image' in item){
                return item.cover_image;
            }
            return item;
        },
        isThumbnailFavorited(item){
            //don't show favorite heart for cover image
            if('cover_image' in item){
                return false;
            }
            return this.imageFor(item).is_favorite;
        },
        thumbnailUrlFor(item){
            return thumbnailUrlFor(this.imageFor(item).mini_thumbnail_path);
        },
        titleFor(item){
            if('name' in item){
                return item.name;
            }
            return `${item.creation_time.formatted.us_date} ${item.creation_time.formatted.time}`;
        },
        altTextFor(item){
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
            this.batchSelectResourceMode = BATCH_RESOURCE_MODE_NONE;
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
        idForBatchResource(item, index){
            return `batch_resource_id_${item.id}_${index}`;
        },
        setBatchResourceMode(newResourceMode){
            if(this.batchSelectResourceMode === newResourceMode){
                return;
            }
            this.batchSelectResourceMode = newResourceMode;
            if(newResourceMode === BATCH_RESOURCE_MODE_NONE){
                return;
            }
            let apiUrl = '/albums?excerpt=true';
            if(newResourceMode === BATCH_RESOURCE_MODE_PERSONS){
                apiUrl = '/persons?excerpt=true';
            }
            else if(newResourceMode === BATCH_RESOURCE_MODE_TAGS){
                //no need for tags excerpt, since tags already only returns name and id
                apiUrl = '/tags?sort=newest';
            }

            this.getModel(apiUrl).then((data)=>{
                this.batchResources = data;
                this.batchResourcesSelected = this.batchResources.map(()=>false);
            });

        },
        buttonClassForResourceMode(resourceMode){
            return resourceMode === this.batchSelectResourceMode ? 'btn-primary' : 'btn-secondary';
        },
        toggleDisplayMoreBatchResources(){
            this.shouldShowAllBatchResources = !this.shouldShowAllBatchResources;
        },
        saveBatchSelected(){
            //default is album_images
            let apiUrl = `${API_URL_BASE}/album_images`;
            let resourcesKey = 'album_ids';
            let thumbnailsKey = 'image_ids';

            if(this.batchSelectResourceMode === BATCH_RESOURCE_MODE_PERSONS){
                apiUrl = `${API_URL_BASE}/person_images`;
                resourcesKey = 'person_ids';
            }
            else if(this.batchSelectResourceMode === BATCH_RESOURCE_MODE_TAGS){
                apiUrl = `${API_URL_BASE}/album_tags`;
                resourcesKey = 'tag_ids';
                thumbnailsKey = 'album_ids';
            }
            const data = {};
            data[thumbnailsKey] = this.thumbnailListSelectedItems.map((item)=>item.id);
            data[resourcesKey] = this.batchResources.filter((item, i)=>this.batchResourcesSelected[i]).map((item)=>item.id);

            this.sendJson(apiUrl, 'POST', data).then((response)=>{
                const hasAtLeastOneThingSucceeded = response.data && response.data.length > 0;
                const hasErrors = response.error && response.error.length > 0;
                //don't do anything unless at 1 thing succeeded
                if(hasAtLeastOneThingSucceeded){
                    this.toggleBatchSelect();
                    //model has to be refreshed or image details pages will show old data
                    this.refreshModel();
                }
                //show flash message based on results
                if(hasAtLeastOneThingSucceeded && hasErrors){
                    this.putFlash('Some updates succeeded and some failed', 'warning');
                }
                else if(hasAtLeastOneThingSucceeded){
                    this.putFlash('All updates successful', 'info');
                }
                else{
                    this.putFlash('All updates failed', 'danger');
                }

            });
        },
        createSuccessRedirectForCurrentPath(){
            //save current route name in variable, otherwise need to use iife
            //to create successRedirect
            const currentRoute = this.$router.currentRoute;
            const currentRouteName = currentRoute.name;
            const params = {};
            for(const param in currentRoute.params){
                params[param] = currentRoute.params[param];
            }
            return (id) => {
                return {
                    name: currentRouteName,
                    params,
                };
            };
        },
        createResourceWithImages(pathName){
            const selectedImages = this.thumbnailListSelectedItems;
            const successRedirect = this.createSuccessRedirectForCurrentPath();
            this.$router.push({name: pathName, params: {images: selectedImages, successRedirect}});
        },
    }
}
</script>
