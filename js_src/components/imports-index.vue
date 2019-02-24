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
import IndexTextListMixinBuilder from './mixins/index-text-list-mixin.js';

export default {
        name: 'Imports-Index',
        mixins: [IndexTextListMixinBuilder()],
        data() {
            return {
                modelPath: '/imports',
                showRouteName: 'importsShow',
            }
        },
        methods: {
            titleFor(item){
                return `${item.name} (${item.images_count})`;
            },
            thumbnailUrlFor(image){
                return thumbnailUrlFor(image.mini_thumbnail_path);
            },
        }
    };
</script>
