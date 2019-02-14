<template>
    <div class="image-show-text-list-container">
        <h3 class="subsection-title">{{heading}}</h3>
        <ul class="image-show-text-list" v-if="items.length > 0">
            <li class="image-container" v-for="(item, index) in items" :key="item.id">
                <router-link :to="{name: itemRouteName, params: {id: item.id}}">{{item.name}}</router-link>
            </li>
        </ul>
    </div>
</template>

<script>
export default {
    name: 'Image-Items-List',
    props: {
        heading: {
            type: String,
            required: true,
        },
        itemRouteName: {
            type: String,
            required: true,
        },
        items: {
            type: Array,
            required: true,
        },
    },
    created(){
    },
    data() {
        return {
        }
    },
    computed: {

    },
    watch: {

    },
    methods: {
    }
}
</script>
