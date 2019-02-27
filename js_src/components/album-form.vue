<template>
    <Form-Section :heading="headingText" :back-link="backLink" :save="save" v-if="isInitialLoadComplete">
        <template v-slot:inputs>
            <Form-Input :id="idForField('name')" label="Name" v-model="album.name" :errors="errors.name" />

            <Form-Input :id="idForField('description')" label="Description" v-model="album.description" :errors="errors.description" input-type="textarea" :textarea-rows="4" />

            <Form-Input :id="idForField('cover_image_id')" label="Cover image id" v-model="album.cover_image_id" :errors="[errors.cover_image, errors.cover_image_id]" input-type="number" v-if="shouldShowCoverImageInput" />

            <!-- thumbnail radio buttons based on: https://stackoverflow.com/questions/17541614/use-images-instead-of-radio-buttons -->
            <fieldset class="form-group thumbnail-radio-container" v-if="!shouldShowCoverImageInput">
                <legend>Cover Image</legend>
                <label v-for="image in imagesInModel" :key="image.id">
                    <input type="radio" v-model="album.cover_image_id" :value="image.id">
                    <img :src="thumbnailUrlFor(image)" />
                </label>
                <Form-Field-Errors :errors="[errors['cover_image'], errors['cover_image_id']]" />
            </fieldset>
        </template>
    </Form-Section>
</template>

<script>
import vue from 'vue';

import { formMixinBuilder } from './mixins/form-mixin.js';
import { albumAndPersonFormMixinBuilder } from './mixins/album-and-person-form-mixin.js';
import { fetchJson } from '../request-helpers.js';
import { thumbnailUrlFor } from '../image.js';
import { toApiResource } from '../form-helpers.js';

export default {
    name: 'Album-Form',
    props: {
        albumId: {
            type: Number,
        },
    },
    mixins: [formMixinBuilder(), albumAndPersonFormMixinBuilder()],
    data() {
        return {
            //album is for our edits, model is the immutable album response from the api
            album: {},
        }
    },
    computed: {
        isEditForm(){
            return typeof this.albumId === 'number';
        },
        headingText(){
            if(this.isEditForm){
                return `Edit ${this.model.name}`;
            }
            return 'New Album';
        },
        backLink(){
            if(this.isEditForm){
                return {name: 'albumsShow', params: {id: this.albumId}};
            }
            return {name: 'albumsIndex'};
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
                const album = {};
                if(this.images){
                    album['cover_image_id'] = this.images[0].id;
                }
                this.album = album;
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
            const data = {album: toApiResource(this.album)};

            if(this.isCreateForm && this.images){
                data['image_ids'] = this.images.map(image => image.id);
            }

            this.sendJson(apiUrl, apiMethod, data).then((response)=>{
                if(response.errors){
                    this.errors = response.errors;
                }
                else{
                    const albumId = response.data.id;
                    const redirectPath = this.successRedirect ? this.successRedirect(albumId) : {name: 'albumsShow', params: {id: albumId}};
                    redirectPath.params.flashMessage = [`${data.album.name} created`, 'info'];
                    this.$router.push(redirectPath);
                }
            });
        },
    }
}
</script>
