<template>
    <Form-Section :heading="headingText" :back-link="backLink" :save="save" v-if="isInitialLoadComplete">
        <template v-slot:inputs>
            <Form-Input :id="idForField('name')" label="Name" v-model="album.name" :errors="errors.name" />

            <Form-Input :id="idForField('description')" label="Description" v-model="album.description" :errors="errors.description" input-type="textarea" :textarea-rows="4" />

            <Cover-Image-Form-Input :id="idForField('cover_image_id')" :errors="[errors.cover_image, errors.cover_image_id]" :images="imagesInModel" v-model="album.cover_image_id" />
        </template>
    </Form-Section>
</template>

<script>
import vue from 'vue';

import { formMixinBuilder } from './mixins/form-mixin.js';
import { albumAndPersonFormMixinBuilder } from './mixins/album-and-person-form-mixin.js';
import { thumbnailUrlFor } from '../image.js';
import { toApiResource } from '../form-helpers.js';

export default {
    name: 'Album-Form',
    props: {
        modelId: {
            type: Number,
        },
    },
    mixins: [formMixinBuilder(), albumAndPersonFormMixinBuilder()],
    data() {
        return {
            //album is for our edits, model is the immutable album response from the api
            album: {},
            resourceApiUrlBase: '/api/albums',
        }
    },
    computed: {
        headingText(){
            if(this.isEditForm){
                return `Edit ${this.model.name}`;
            }
            return 'New Album';
        },
        backLink(){
            if(this.isEditForm){
                return {name: 'albumsShow', params: {id: this.modelId}};
            }
            return {name: 'albumsIndex'};
        },
    },
    methods: {
        setupModel(album=null){
            //edit form
            if(album){
                this.album = {
                    id: album.id,
                    name: album.name,
                    description: album.description,
                    cover_image_id: album.cover_image.id,
                };
            }
            //new form
            else{
                const album = {};
                if(this.images){
                    album['cover_image_id'] = this.images[0].id;
                }
                this.album = album;
            }
        },
        idForField(fieldName){
            return `id_album_${fieldName}_input`;
        },
        getResourceForSave(){
            const data = {album: toApiResource(this.album)};
            if(this.isCreateForm && this.images){
                data['image_ids'] = this.images.map(image => image.id);
            }
            return data;
        },
        saveSuccessful(album){
            const modelId = album.id;
            const redirectPath = this.successRedirect ? this.successRedirect(modelId) : {name: 'albumsShow', params: {id: modelId}};
            redirectPath.params.flashMessage = [`${album.name} ${this.isEditForm ? 'updated' : 'created'}`, 'info'];
            this.$router.push(redirectPath);
        },
    }
}
</script>
