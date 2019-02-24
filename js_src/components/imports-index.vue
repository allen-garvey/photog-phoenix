<template>
    <Text-List title="Imports" :items-list="itemsList">
        <template v-slot:item="{item, index}">
            <router-link :to="showRouteFor(item)" class="imports-index-item-link">
                {{titleFor(item)}}
                <ul class="imports-index-mini-thumbnail-list">
                    <li v-for="image in item.images" :key="image.id">
                        <img :src="thumbnailUrlFor(image)"/>
                    </li>
                </ul>
            </router-link>
        </template>
    </Text-List>
</template>

<script>
import { thumbnailUrlFor } from '../image.js';
import TextList from './base/text-list.vue';

export default {
        name: 'Imports-Index',
        props: {
            getModel: {
                type: Function,
                required: true,
            },
        },
        components: {
            'Text-List': TextList,
        },
        created(){
            this.setup();
        },
        data() {
            return {
                modelPath: '/imports',
                showRouteName: 'importsShow',
                model: [],
                //need this property or there will be errors when we switch routes and new models haven't been loaded yet
                isLoadingModel: true,
            }
        },
        computed: {
            itemsList(){
                if(this.isLoadingModel){
                    return [];
                }
                return this.model;
            },
        },
        watch: {
            '$route'(to, from){
                this.setup();
            }
        },
        methods: {
            setup(){
                this.isLoadingModel = true;
                this.getModel(this.modelPath).then((itemsJson)=>{
                    this.model = itemsJson;
                    this.isLoadingModel = false;
                });
            },
            showRouteFor(item){
                return {
                    name: this.showRouteName,
                    params: {
                        id: item.id,
                    },
                };
            },
            titleFor(item){
                return item.name;
            },
            thumbnailUrlFor(image){
                return thumbnailUrlFor(image.mini_thumbnail_path);
            },
        }
    };
</script>
