<template>
    <main class="main container">
        <Resource-Header :title="title" :editItemLink="editItemLink" :newItemLink="newItemLink" />
        <ul class="text-list" v-infinite-scroll="showMoreItems" infinite-scroll-distance="40" infinite-scroll-disabled="isInfiniteScrollDisabled">
            <li v-for="(item, i) in itemsListExcerpt" :key="i">
                <slot name="item" :item="item" :index="i"></slot>
            </li>
        </ul>
    </main>
</template>

<script>
import infiniteScroll from 'vue-infinite-scroll';
import ReasourceHeader from '../resource-header.vue';

//number of items to show each time infinite scroll is called
const ITEM_CHUNK_LENGTH = 20;

export default {
        name: 'Text-List',
        props: {
            title: {
                type: String,
                required: true,
            },
            itemsList: {
                type: Array,
                required: true,
            },
            newItemLink: {
                type: Object,
            },
            editItemLink: {
                type: Object,
            },
        },
        components: {
            'Resource-Header': ReasourceHeader,
        },
        directives: {
            infiniteScroll,
        },
        data(){
            return {
                itemsListExcerptLength: ITEM_CHUNK_LENGTH,
            };
        },
        computed: {
            itemsListExcerpt(){
                return this.itemsList.slice(0, this.itemsListExcerptLength);
            },
            isInfiniteScrollDisabled(){
               return this.itemsListExcerptLength >= this.itemsList.length;
            },
        },
        watch: {
        '$route'(to, from){
            //reset itemsListExcerptLength
            this.itemsListExcerptLength = ITEM_CHUNK_LENGTH;
        },
    },
        methods: {
            showMoreItems(){
                this.itemsListExcerptLength += ITEM_CHUNK_LENGTH;
            },
        },
    };
</script>