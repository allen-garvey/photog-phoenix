<template>
    <main class="main container" v-if="isInitialLoadComplete">
        <div>
            <h1>{{headingText}}</h1>
        </div>
        <div>
            <div class="form-group">
                <label :for="idForField('name')">Name</label>
                <input :id="idForField('name')" class="form-control" type="text" v-model="album.name" />
            </div>

            <div class="form-group">
                <label :for="idForField('description')">Description</label>
                <textarea :id="idForField('description')" class="form-control" v-model="album.description" rows="4"></textarea>
            </div>

            <div class="form-group">
                <label :for="idForField('cover_image_id')">Cover image id</label>
                <input :id="idForField('cover_image_id')" class="form-control" type="number" v-model.number="album.cover_image_id" />
            </div>

            <div>
                <button class="btn btn-success" @click="save()">Save</button>
            </div>
        </div>
    </main>
</template>

<script>
import vue from 'vue';

import { fetchJson, sendJson } from '../request-helpers.js';

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
        albumId: {
            type: Number,
        },
    },
    components: {
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
    },
    watch: {
        '$route'(to, from){
            this.setup();
        },
    },
    methods: {
        setup(){
            this.isInitialLoadComplete = false;
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
        //returns null for empty strings or other values that should be null
        //when sending to api
        nullifyValue(value){
            if(value === '' || value === undefined){
                return null;
            }
            return value;
        },
        toApiResource(item){
            const resource = {};
            for(const key in item){
                const resourceKeyName = key;
                resource[resourceKeyName] = this.nullifyValue(item[key]);
            }

            return resource;
        },
        save(){
            let apiUrl = `/api/albums`;
            let apiMethod = 'POST';
            if(this.isEditForm){
                apiUrl = `${apiUrl}/${this.albumId}`;
                apiMethod = 'PATCH';
            }
            const resource = {album: this.toApiResource(this.album)};

            sendJson(apiUrl, this.csrfToken, apiMethod, resource).then((response)=>{
                console.log(response);
                if(response.error){

                }
                else{
                    this.$router.push({name: 'albumsShow', params: {id: response.data.id}});
                }
            });
        },
    }
}
</script>
