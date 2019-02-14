<template>
    <div class="image-show-text-list-container">
        <h3 class="subsection-title">{{heading}}</h3>
        <div>
            <button @click="addItemsButtonAction">{{addButtonText}}</button>
            <button v-if="showAddItems" @click="saveAddItems">Save</button>
        </div>
        <div v-if="showAddItems">
            <ul class="image-show-add-items-list">
                <li v-for="(item, index) in itemsThatCanBeAdded" :key="index">
                    <input type="checkbox" :id="idForItemToBeAdded(item, index)" v-model="itemsThatCanBeAddedSelected[index]" />
                    <label :for="idForItemToBeAdded(item, index)">{{item.name}}</label>
                </li>
            </ul>
        </div>
        <ul class="image-show-text-list" v-if="items.length > 0">
            <li class="image-container" v-for="(item, index) in items" :key="item.id">
                <router-link :to="{name: itemRouteName, params: {id: item.id}}">{{item.name}}</router-link>
            </li>
        </ul>
    </div>
</template>

<script>
import { fetchJson } from '../request-helpers.js';

export default {
    name: 'Image-Items-List',
    props: {
        csrfToken: {
            type: String,
            required: true,
        },
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
        unusedItemsApiUrl: {
            type: String,
            required: true,
        },
    },
    created(){
    },
    data() {
        return {
            itemsThatCanBeAdded: [],
            itemsThatCanBeAddedSelected: [],
            showAddItems: false,
        }
    },
    computed: {
        addButtonText(){
            return this.showAddItems ? 'Cancel' : 'Add';
        },
    },
    watch: {

    },
    methods: {
        idForItemToBeAdded(item, index){
            return `checkbox_${this.heading}_${index}_${item.id}`;
        },
        addItemsButtonAction(){
            if(this.showAddItems){
                this.showAddItems = false;
            }
            else{
                this.fetchAddItems();
            }
        },
        fetchAddItems(){
            fetchJson(this.unusedItemsApiUrl).then((items) => {
                this.itemsThatCanBeAdded = items;
                this.itemsThatCanBeAddedSelected = this.itemsThatCanBeAdded.map(()=>false);
                this.showAddItems = true;
            });
        },
        saveAddItems(){
            console.log(this.itemsThatCanBeAddedSelected);
            this.showAddItems = false;
        },
    }
}
</script>
