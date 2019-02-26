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
                <label v-for="image in imagesInModel" :key="image.id">
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

import { formMixinBuilder } from './mixins/form-mixin.js';
import { albumAndPersonFormMixinBuilder } from './mixins/album-and-person-form-mixin.js';
import { fetchJson } from '../request-helpers.js';
import { thumbnailUrlFor } from '../image.js';
import { toApiResource } from '../form-helpers.js';

export default {
    name: 'Person-Form',
    props: {
        personId: {
            type: Number,
        },
    },
    mixins: [formMixinBuilder(), albumAndPersonFormMixinBuilder()],
    data() {
        return {
            //person is for our edits, model is the immutable person response from the api
            person: {},
        }
    },
    computed: {
        isEditForm(){
            return typeof this.personId === 'number';
        },
        headingText(){
            if(this.isEditForm){
                return `Edit ${this.model.name}`;
            }
            return 'New Person';
        },
        backLink(){
            if(this.isEditForm){
                return {name: 'personsShow', params: {id: this.personId}};
            }
            return {name: 'personsIndex'};
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
                const person = {};
                if(this.images){
                    person['cover_image_id'] = this.images[0].id;
                }
                this.person = person;
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
            const data = {person: toApiResource(this.person)};
            if(this.isCreateForm && this.images){
                data['image_ids'] = this.images.map(image => image.id);
            }

            this.sendJson(apiUrl, apiMethod, data).then((response)=>{
                if(response.errors){
                    this.errors = response.errors;
                }
                else{
                    const personId = response.data.id;
                    const redirectPath = this.successRedirect ? this.successRedirect(personId) : {name: 'personsShow', params: {id: personId}};
                    redirectPath.params.flashMessage = [`${data.person.name} created`, 'info'];
                    this.$router.push(redirectPath);
                }
            });
        },
    }
}
</script>
