<template>
    <main class="main container" v-if="isModelLoaded">
        <div class="album-image-show-header" v-if="parent">
            <router-link :to="{name: parent.parentRouteName, params: {id: model.id}}">Back to {{model.name}}</router-link>
            <div class="album-image-nav">
                <router-link :to="parent.showRouteFor(previousImage)" v-if="previousImage">Previous</router-link>
                <div v-if="!previousImage"></div>
                <router-link :to="parent.showRouteFor(nextImage)" v-if="nextImage">Next</router-link>
            </div>
            <div class="album-image-nav-previews">
                <ul class="image-preview-list" v-scroll-to-selected-item="'.current-image'">
                    <li :class="{'current-image': image.id === imageId}" v-for="(image, i) in model.images" :key="i">
                        <router-link :to="parent.showRouteFor(image)" class="preview-container">
                            <img :src="thumbnailUrlFor(image.mini_thumbnail_path)">
                        </router-link>
                    </li>
                </ul>
            </div>
        </div>
        <div class="image-show-thumbnail-container">
            <a :href="masterUrl">
                <img :src="thumbnailUrlFor(image.thumbnail_path)"/>
            </a>
        </div>
        <div class="image-show-link-container">
            <a :href="masterUrl">View full-size</a>
        </div>
        <div class="image-show-info-section">
            <h3 class="image-info-section-heading">Info</h3>
            <dl>
                <dt>Date Taken</dt>
                <dd>{{image.creation_time.formatted.us_date}} {{image.creation_time.formatted.time}}</dd>
                <dt>Favorite</dt>
                <dd>{{image.is_favorite ? 'true' : 'false'}}</dd>
            </dl>
        </div>
        <div class="image-show-info-section" v-if="imageExif">
            <h3 class="image-info-section-heading">Exif</h3>
                <template v-for="sectionKey in Object.keys(imageExif).sort()">
                    <h4 :key="sectionKey+'_heading'" class="image-exif-heading">{{formatExifPropertyName(sectionKey)}}</h4>
                    <dl :key="sectionKey+'_list'">
                        <template v-for="sectionPropertyKey in Object.keys(imageExif[sectionKey]).sort()">
                            <dt :key="`${sectionKey}_${sectionPropertyKey}_dt`" v-if="imageExif[sectionKey][sectionPropertyKey]">{{formatExifPropertyName(sectionPropertyKey)}}</dt>
                            <dd :key="`${sectionKey}_${sectionPropertyKey}_dd`" v-if="imageExif[sectionKey][sectionPropertyKey]">{{imageExif[sectionKey][sectionPropertyKey]}}</dd>
                        </template>
                    </dl>
                </template>
        </div>
        <div class="image-show-text-list-container" v-if="image.albums && image.albums.length > 0">
            <h3 class="subsection-title">Albums</h3>
            <ul class="image-show-text-list">
                <li class="image-container" v-for="album in image.albums" :key="album.id">
                    <router-link :to="{name: 'albumsShow', params: {id: album.id}}">{{album.name}}</router-link>
                </li>
            </ul>
        </div>
        <div class="image-show-text-list-container" v-if="image.persons && image.persons.length > 0">
            <h3 class="subsection-title">Persons</h3>
            <ul class="image-show-text-list">
                <li class="image-container" v-for="person in image.persons" :key="person.id">
                    <router-link :to="{name: 'personsShow', params: {id: person.id}}">{{person.name}}</router-link>
                </li>
            </ul>
        </div>
    </main>
</template>

<script>
//from: https://stackoverflow.com/questions/1026069/how-do-i-make-the-first-letter-of-a-string-uppercase-in-javascript
function capitalizeFirstLetter(string){
    return string.charAt(0).toUpperCase() + string.slice(1);
}


export default {
    name: 'Image-Detail',
    props: {
        getModel: {
            type: Function,
            required: true,
        },
        getExif: {
            type: Function,
            required: true,
        },
        modelApiPath: {
            type: String,
            required: true,
        },
        imageId: {
            type: Number,
            required: true,
        },
        parent: {
            type: Object,
        },
    },
    directives: {
        scrollToSelectedItem: {
            inserted(el, binding){
                const selectedItemSelector = binding.value;
                const currentItem = el.querySelector(selectedItemSelector);
                if(currentItem){
                    currentItem.scrollIntoView({behavior: 'instant'});
                }
            },
        },
    },
    created(){
        //initial setup of items, since $route watch method won't be called on initial load
        this.loadModel(this.modelApiPath);
    },
    data() {
        return {
            model: null,
            imageModel: null, //for when the model is the parent of the image
            modelIndex: -1, //when model is parent, the index of the current image in the image array
            imageExif: null,
        }
    },
    computed: {
        isModelLoaded: function(){
            return this.model && this.image;
        },
        masterUrl: function(){
            return this.generateImageUrl(this.image.master_path);
        },
        image: function(){
            if(this.parent){
                return this.imageModel;
            }
            return this.model;
        },
        previousImage: function(){
            if(!this.parent || this.modelIndex < 0 || this.modelIndex === 0){
                return null;
            }
            return this.model.images[this.modelIndex-1];
        },
        nextImage: function(){
            if(!this.parent || this.modelIndex < 0 || this.model.images.length <= this.modelIndex){
                return null;
            }
            return this.model.images[this.modelIndex+1];
        },
    },
    watch: {
        '$route'(to, from){
            this.loadModel(this.modelApiPath);
        }
    },
    methods: {
        loadModel: function(modelPath){
            this.imageModel = null;
            this.modelIndex = -1;

            this.imageExif = null;

            this.getModel(modelPath).then((itemsJson)=>{
                this.model = itemsJson;
                
                //if parent, lookup image in parent images
                if(this.parent){
                    const imageId = this.imageId;
                    for(let i=0;i<this.model.images.length;i++){
                        const image = this.model.images[i];
                        if(image.id === imageId){
                            this.imageModel = image;
                            this.modelIndex = i;
                            break;
                        }
                    }
                }
            });

            this.getExif(this.imageId).then((imageExif)=>{
                this.imageExif = imageExif.exif;
            });
        },
        thumbnailUrlFor: function(thumbnailPath){
            return `/media/thumbnails/${encodeURI(thumbnailPath)}`;
        },
        generateImageUrl: function(rawUrl){
            return `/media/images/${encodeURI(rawUrl)}`;
        },
        keyLeftAction(){
            if(this.previousImage){
                this.$router.push(this.parent.showRouteFor(this.previousImage));
            }
        },
        keyRightAction(){
            if(this.nextImage){
                this.$router.push(this.parent.showRouteFor(this.nextImage));
            }
        },
        formatExifPropertyName(s){
            return capitalizeFirstLetter(s).replace(/_/g, ' ');
        }
    }
}
</script>
