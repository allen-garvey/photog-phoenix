<template>
<div class="thumbnail-filter-controls-container">
    <fieldset v-if="enableAlbumFilter">
        <legend>Album</legend>
        <label for="album_filter_mode_all">All</label>
        <input id="album_filter_mode_all" type="radio" value="1" v-model="albumFilterMode" />
        
        <label for="album_filter_mode_no_albums">Uncategorized</label>
        <input id="album_filter_mode_no_albums" type="radio" value="2" v-model="albumFilterMode" />
        
        <label for="album_filter_mode_has_albums">Categorized</label>
        <input id="album_filter_mode_has_albums" type="radio" value="3" v-model="albumFilterMode" />
    </fieldset>
    <fieldset v-if="enablePersonFilter">
        <legend>Person</legend>
        <label for="persons_filter_mode_all">All</label>
        <input id="persons_filter_mode_all" type="radio" value="1" v-model="personFilterMode" />
        
        <label for="persons_filter_mode_no_persons">Uncategorized</label>
        <input id="persons_filter_mode_no_persons" type="radio" value="2" v-model="personFilterMode" />
        
        <label for="persons_filter_mode_has_persons">Categorized</label>
        <input id="persons_filter_mode_has_persons" type="radio" value="3" v-model="personFilterMode" />
    </fieldset>
</div>
</template>

<script>
export default {
    name: 'Thumbnail-Filter-Controls',
    props: {
        albumFilterMode: {
            type: Number,
            required: true,
        },
        enableAlbumFilter: {
            type: Boolean,
            default: false,
        },
        personFilterMode: {
            type: Number,
            required: true,
        },
        enablePersonFilter: {
            type: Boolean,
            default: false,
        },
    },
    methods: {
        albumFilterModeChanged(e){
            this.$emit('albumFilterModeChanged', e.target.value);
        },
        personFilterModeChanged(e){
            this.$emit('personFilterModeChanged', e.target.value);
        },
    },
}
</script>

