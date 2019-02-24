<template>
    <main class="main container">
        <Resource-Header :title="title" :editItemLink="editItemLink" :newItemLink="newItemLink" />
        <ul class="text-list">
            <li v-for="(item, i) in itemsList" :key="i">
                <slot name="item" :item="item" :index="i"></slot>
            </li>
        </ul>
    </main>
</template>

<script>
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
        },
        components: {
            'Resource-Header': ReasourceHeader,
        },
    };
</script>