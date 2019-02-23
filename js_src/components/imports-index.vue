<template>
    <main class="main container">
        <Resource-Header title="Imports" :editItemLink="editItemLink" :newItemLink="newItemLink" />
        <ul class="text-list">
            <li v-for="(item, i) in thumbnailList" :key="i">
                <router-link :to="showRouteFor(item)">
                    {{titleFor(item)}}
                    <ul class="imports-index-mini-thumbnail-list">
                        <li v-for="image in item.images" :key="image.id">
                            <img :src="thumbnailUrlFor(image)"/>
                        </li>
                    </ul>
                </router-link>
            </li>
        </ul>
    </main>
</template>

<script>
import { thumbnailUrlFor } from '../image.js';
import textListBuilder from './components-base/text-list-base.js';

const component = textListBuilder();

component.methods.titleFor = function(item){
    return `${item.name} (${item.images_count})`;
};

component.methods.thumbnailUrlFor = function(image){
    return thumbnailUrlFor(image.mini_thumbnail_path);
};

export default component;
</script>
