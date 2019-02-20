<template>
    <main class="main container" v-if="isInitialLoadComplete">
        <div>
            <h1>{{headingText}}</h1>
        </div>
        <div>
            <div class="form-group">
                <label :for="idForField('name')">Name</label>
                <input :id="idForField('name')" class="form-control" type="text" v-model="person.name" />
                <Form-Field-Errors :errors="errors.name" />
            </div>
            
            <div class="form-group" v-if="shouldShowCoverImageInput">
                <label :for="idForField('cover_image_id')">Cover image id</label>
                <input :id="idForField('cover_image_id')" class="form-control" type="number" v-model.number="person.cover_image_id" />
                <Form-Field-Errors :errors="[errors['cover_image'], errors['cover_image_id']]" />
            </div>

            <!-- thumbnail radio buttons based on: https://stackoverflow.com/questions/17541614/use-images-instead-of-radio-buttons -->
            <fieldset class="form-group thumbnail-radio-container" v-if="!shouldShowCoverImageInput">
                <legend>Cover Image</legend>
                <label v-for="image in model.images" :key="image.id">
                    <input type="radio" v-model="person.cover_image_id" :value="image.id">
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

import { fetchJson, sendJson } from '../request-helpers.js';
import { thumbnailUrlFor } from '../image.js';
import { toApiResource } from '../form-helpers.js';

export default {
    name: 'Person-Form',
    props: {
        csrfToken: {
            type: String,
            required: true,
        },
        putFlash: {
            type: Function,
            required: true,
        },
        personId: {
            type: Number,
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
            //person is for our edits, model is the immutable person response from the api
            person: {},
            model: null,
            errors: {},
        }
    },
    computed: {
        isEditForm(){
            return typeof this.personId === 'number';
        },
        isCreateForm(){
            return !this.isEditForm;
        },
        headingText(){
            if(this.isEditForm){
                return `Edit ${this.model.name}`;
            }
            return 'New Person';
        },
        shouldShowCoverImageInput(){
            return this.isCreateForm || this.model.images.length === 0;
        },
        backLink(){
            if(this.isEditForm){
                return {name: 'personsShow', params: {id: this.personId}};
            }
            return {name: 'personsIndex'};
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
                this.loadModel().then((person)=>{
                    this.person = {
                        id: person.id,
                        name: person.name,
                        cover_image_id: person.cover_image.id,
                    };
                    this.isInitialLoadComplete = true;
                });
            }
            else{
                this.model = null;
                this.person = {};
                this.isInitialLoadComplete = true;
            }
        },
        loadModel(){
            const apiUrl = `/api/persons/${this.personId}`;
            return fetchJson(apiUrl).then((person)=>{
                this.model = person;
                return person;
            });
        },
        idForField(fieldName){
            return `id_person_${fieldName}_input`;
        },
        save(){
            let apiUrl = `/api/persons`;
            let apiMethod = 'POST';
            if(this.isEditForm){
                apiUrl = `${apiUrl}/${this.personId}`;
                apiMethod = 'PATCH';
            }
            const resource = {person: toApiResource(this.person)};

            sendJson(apiUrl, this.csrfToken, apiMethod, resource).then((response)=>{
                if(response.errors){
                    this.errors = response.errors;
                }
                else{
                    this.$router.push({name: 'personsShow', params: {id: response.data.id}});
                }
            });
        },
        thumbnailUrlFor(image){
            return thumbnailUrlFor(image.mini_thumbnail_path);
        },
    }
}
</script>
