<template>
    <Form-Section :heading="headingText" :back-link="backLink" :save="save" v-if="isInitialLoadComplete">
        <template v-slot:inputs>
            <Form-Input :id="idForField('name')" label="Name" v-model="person.name" :errors="errors.name" />

            <Cover-Image-Form-Input :id="idForField('cover_image_id')" :errors="[errors.cover_image, errors.cover_image_id]" :images="imagesInModel" v-model="person.cover_image_id" />
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
    name: 'Person-Form',
    props: {
        modelId: {
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
        headingText(){
            if(this.isEditForm){
                return `Edit ${this.model.name}`;
            }
            return 'New Person';
        },
        backLink(){
            if(this.isEditForm){
                return {name: 'personsShow', params: {id: this.modelId}};
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
            const apiUrl = `/api/persons/${this.modelId}`;
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
                apiUrl = `${apiUrl}/${this.modelId}`;
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
                    const modelId = response.data.id;
                    const redirectPath = this.successRedirect ? this.successRedirect(modelId) : {name: 'personsShow', params: {id: modelId}};
                    redirectPath.params.flashMessage = [`${data.person.name} ${this.isEditForm ? 'updated' : 'created'}`, 'info'];
                    this.$router.push(redirectPath);
                }
            });
        },
    }
}
</script>
