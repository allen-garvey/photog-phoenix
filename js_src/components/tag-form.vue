<template>
    <Form-Section :heading="headingText" :back-link="backLink" :save="save" v-if="isInitialLoadComplete">
        <template v-slot:inputs>
            <Form-Input :id="idForField('name')" label="Name" v-model="tag.name" :errors="errors.name" />
        </template>
    </Form-Section>
</template>

<script>
import { formMixinBuilder } from './mixins/form-mixin.js';

import { toApiResource } from '../form-helpers.js';

export default {
    name: 'Tag-Form',
    props: {
        modelId: {
            type: Number,
        },
    },
    mixins: [formMixinBuilder()],
    data() {
        return {
            //tag is for our edits, model is the immutable album response from the api
            tag: {},
            resourceApiUrlBase: '/api/tags',
        }
    },
    computed: {
        headingText(){
            if(this.isEditForm){
                return `Edit ${this.model.name}`;
            }
            return 'New Tag';
        },
        backLink(){
            if(this.isEditForm){
                return {name: 'tagsShow', params: {id: this.modelId}};
            }
            return {name: 'tagsIndex'};
        },
    },
    methods: {
        setupModel(tag=null){
            //edit form
            if(tag){
                this.tag = {
                    id: tag.id,
                    name: tag.name,
                };
            }
            //new form
            else{
                this.tag = {};
            }
        },
        idForField(fieldName){
            return `id_tag_${fieldName}_input`;
        },
        save(){
            let apiUrl = `/api/tags`;
            let apiMethod = 'POST';
            if(this.isEditForm){
                apiUrl = `${apiUrl}/${this.modelId}`;
                apiMethod = 'PATCH';
            }
            const resource = {tag: toApiResource(this.tag)};

            this.sendJson(apiUrl, apiMethod, resource).then((response)=>{
                if(response.errors){
                    this.errors = response.errors;
                }
                else{
                    const flashMessage = [`${response.data.name} ${this.isEditForm ? 'updated' : 'created'}`, 'info'];
                    this.$router.push({
                        name: 'tagsShow', 
                        params: {
                            id: response.data.id,
                            flashMessage: flashMessage
                        }
                    });
                }
            });
        },
    }
}
</script>
