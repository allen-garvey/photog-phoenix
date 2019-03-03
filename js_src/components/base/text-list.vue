<template>
    <main class="main container">
        <Resource-Header :title="title" :editItemLink="editItemLink" :newItemLink="newItemLink" />
        <ul class="text-list" v-infinite-scroll="infiniteScrollCallback" infinite-scroll-distance="40" :infinite-scroll-disabled="!enableInfiniteScroll">
            <li v-for="(item, i) in itemsList" :key="i">
                <slot name="item" :item="item" :index="i"></slot>
            </li>
        </ul>
    </main>
</template>

<script>
import infiniteScroll from 'vue-infinite-scroll';
import ReasourceHeader from '../resource-header.vue';

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
            enableInfiniteScroll: {
                type: Boolean,
                default: false,
            },
            infiniteScrollCallback: {
                type: Function,
                default: () =>{},
            },
        },
        components: {
            'Resource-Header': ReasourceHeader,
        },
        directives: {
            infiniteScroll,
        },
    };
</script>