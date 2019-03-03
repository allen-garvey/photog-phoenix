<template>
    <Text-List title="Imports" :items-list="itemsList" :enable-infinite-scroll="enableInfiniteScroll" :infinite-scroll-callback="loadMoreItems">
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
import IndexTextListMixinBuilder from './mixins/index-text-list-mixin.js';

export default {
        name: 'Imports-Index',
        mixins: [IndexTextListMixinBuilder()],
        data() {
            return {
                modelPath: '/imports/?limit=20',
                showRouteName: 'importsShow',
                areAllItemsLoaded: false,
            }
        },
        computed: {
            enableInfiniteScroll(){
                return this.isInitialLoadComplete && !this.areAllItemsLoaded;
            },
        },
        methods: {
            titleFor(item){
                return `${item.name} (${item.images_count})`;
            },
            thumbnailUrlFor(image){
                return thumbnailUrlFor(image.mini_thumbnail_path);
            },
            //to make the code a bit easier, there are only 2 states for the infinite scroll
            //at first load we only load the most recent imports, but if you scroll down we just load everything
            //instead of incremental loads with offsets
            loadMoreItems(){
                //need this check because for some reason infinite scroll is never disabled
                if(!this.enableInfiniteScroll){
                    return;
                }
                //set all items to loaded here instead of in promises success
                //because otherwise this method could get called multiple times
                this.areAllItemsLoaded = true;
                this.getModel('/imports').then((itemsJson)=>{
                    this.model = itemsJson;
                });
            },
        }
    };
</script>
