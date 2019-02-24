<template>
    <Text-List title="Tags" :new-item-link="newItemLink" :items-list="itemsList">
        <template v-slot:item="{item, index}">
            <router-link :to="showRouteFor(item)">{{titleFor(item)}}</router-link>
        </template>
    </Text-List>
</template>

<script>
import IndexTextListMixinBuilder from './mixins/index-text-list-mixin.js';

export default {
        name: 'Tags-Index',
        mixins: [IndexTextListMixinBuilder()],
        data() {
            return {
                newItemLink: {name: 'tagsNew'},
                modelPath: '/tags',
                showRouteName: 'tagsShow',
            }
        },
    };
</script>
