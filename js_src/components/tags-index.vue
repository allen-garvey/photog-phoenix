<template>
    <Text-List title="Tags" :new-item-link="newItemLink" :items-list="itemsList">
        <template v-slot:item="{item, index}">
            <router-link :to="showRouteFor(item)">{{titleFor(item)}}</router-link>
        </template>
    </Text-List>
</template>

<script>
import TextList from './base/text-list.vue';

export default {
        name: 'Tags-Index',
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
                newItemLink: {name: 'tagsNew'},
                modelPath: '/tags',
                showRouteName: 'tagsShow',
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
        }
    };
</script>
