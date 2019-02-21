<template>
    <main class="main container" v-if="isInitialLoadComplete">
        <div>
            <h1>{{headingText}}</h1>
        </div>
        <div>
            <div class="form-group">
                <label :for="idForField('name')">Name</label>
                <input :id="idForField('name')" class="form-control" type="text" v-model="album.name" />
                <Form-Field-Errors :errors="errors.name" />
            </div>

            <div class="form-group">
                <label :for="idForField('description')">Description</label>
                <textarea :id="idForField('description')" class="form-control" v-model="album.description" rows="4"></textarea>
                <Form-Field-Errors :errors="errors.description" />
            </div>
            
            <div class="form-group" v-if="shouldShowCoverImageInput">
                <label :for="idForField('cover_image_id')">Cover image id</label>
                <input :id="idForField('cover_image_id')" class="form-control" type="number" v-model.number="album.cover_image_id" />
                <Form-Field-Errors :errors="[errors['cover_image'], errors['cover_image_id']]" />
            </div>

            <!-- thumbnail radio buttons based on: https://stackoverflow.com/questions/17541614/use-images-instead-of-radio-buttons -->
            <fieldset class="form-group thumbnail-radio-container" v-if="!shouldShowCoverImageInput">
                <legend>Cover Image</legend>
                <label v-for="image in imagesInAlbum" :key="image.id">
                    <input type="radio" v-model="album.cover_image_id" :value="image.id">
                    <img :src="thumbnailUrlFor(image)" />
                </label>
                <Form-Field-Errors :errors="[errors['cover_image'], errors['cover_image_id']]" />
            </fieldset>

            <div class="spread-content">
                <router-link :to="backLink" class="btn btn-outline-dark">Cancel</router-link>
                <button class="btn btn-success" @click="save()">Save</button>
            </div>
        </div>
    </main>
</template>

<script>
import vue from 'vue';
import FormFieldErrors from './form-field-errors.vue';

import { fetchJson } from '../request-helpers.js';
import { thumbnailUrlFor } from '../image.js';
import { toApiResource } from '../form-helpers.js';

export default {
    name: 'Album-Form',
    props: {
        csrfToken: {
            type: String,
            required: true,
        },
        putFlash: {
            type: Function,
            required: true,
        },
        sendJson: {
            type: Function,
            required: true,
        },
        albumId: {
            type: Number,
        },
        //for when creating an album with images
        images: {
            type: Array
        },
    },
    components: {
        'Form-Field-Errors': FormFieldErrors,
    },
    created(){
        this.setup();
    },
    data() {
        return {
            isInitialLoadComplete: false,
            //album is for our edits, model is the immutable album response from the api
            album: {},
            model: null,
            errors: {},
        }
    },
    computed: {
        isEditForm(){
            return typeof this.albumId === 'number';
        },
        isCreateForm(){
            return !this.isEditForm;
        },
        headingText(){
            if(this.isEditForm){
                return `Edit ${this.model.name}`;
            }
            return 'New Album';
        },
        shouldShowCoverImageInput(){
            return this.imagesInAlbum.length === 0;
        },
        imagesInAlbum(){
            if(this.isEditForm){
                return this.model.images;
            }
            else if(this.isCreateForm && this.images){
                return this.images;
            }
            return [];
        },
        backLink(){
            if(this.isEditForm){
                return {name: 'albumsShow', params: {id: this.albumId}};
            }
            return {name: 'albumsIndex'};
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
            this.errors = {};
            if(this.isEditForm){
                this.loadModel().then((album)=>{
                    this.album = {
                        id: album.id,
                        name: album.name,
                        description: album.description,
                        cover_image_id: album.cover_image.id,
                    };
                    this.isInitialLoadComplete = true;
                });
            }
            else{
                this.model = null;
                this.album = {};
                this.isInitialLoadComplete = true;
            }
        },
        loadModel(){
            const apiUrl = `/api/albums/${this.albumId}`;
            return fetchJson(apiUrl).then((album)=>{
                this.model = album;
                return album;
            });
        },
        idForField(fieldName){
            return `id_album_${fieldName}_input`;
        },
        save(){
            let apiUrl = `/api/albums`;
            let apiMethod = 'POST';
            if(this.isEditForm){
                apiUrl = `${apiUrl}/${this.albumId}`;
                apiMethod = 'PATCH';
            }
            const resource = {album: toApiResource(this.album)};

            this.sendJson(apiUrl, this.csrfToken, apiMethod, resource).then((response)=>{
                if(response.errors){
                    this.errors = response.errors;
                }
                else{
                    this.$router.push({name: 'albumsShow', params: {id: response.data.id}});
                }
            });
        },
        thumbnailUrlFor(image){
            return thumbnailUrlFor(image.mini_thumbnail_path);
        },
    }
}
</script>
