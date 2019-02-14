<template>
    <div class="image-show-text-list-container">
        <div class="image-show-text-list-heading">
            <h3 class="image-show-text-list-title">{{heading}}</h3>
            <div class="button-container">
                <button :disabled="isAddMode" @click="editItemsButtonAction">{{editButtonText}}</button>
                <button :disabled="isEditMode" @click="addItemsButtonAction">{{addButtonText}}</button>
                <button v-if="isAddMode" @click="saveAddItems">Save</button>
            </div>
        </div>
        <div v-if="isAddMode">
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
                <button v-if="isEditMode" @click="deleteItem(item, index)">Delete</button>
            </li>
        </ul>
    </div>
</template>

<script>
import { fetchJson } from '../request-helpers.js';

const MODE_ADD = 1;
const MODE_DEFAULT = 2;
const MODE_EDIT = 3;

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
            mode: MODE_DEFAULT,
        }
    },
    computed: {
        addButtonText(){
            return this.isAddMode ? 'Cancel' : 'Add';
        },
        editButtonText(){
            return this.isEditMode ? 'Cancel' : 'Edit';
        },
        isAddMode(){
            return this.mode === MODE_ADD;
        },
        isEditMode(){
            return this.mode === MODE_EDIT;
        },
        isDefaultMode(){
            return this.mode === MODE_DEFAULT;
        },
    },
    watch: {

    },
    methods: {
        idForItemToBeAdded(item, index){
            return `checkbox_${this.heading}_${index}_${item.id}`;
        },
        editItemsButtonAction(){
            if(this.isEditMode){
                this.mode = MODE_DEFAULT;
            }
            else{
                this.mode = MODE_EDIT;
            }
        },
        addItemsButtonAction(){
            if(this.isAddMode){
                this.mode = MODE_DEFAULT;
            }
            else{
                this.fetchAddItems();
            }
        },
        fetchAddItems(){
            fetchJson(this.unusedItemsApiUrl).then((items) => {
                this.itemsThatCanBeAdded = items;
                this.itemsThatCanBeAddedSelected = this.itemsThatCanBeAdded.map(()=>false);
                this.mode = MODE_ADD;
            });
        },
        saveAddItems(){
            console.log(this.itemsThatCanBeAddedSelected);
            this.mode = MODE_DEFAULT;
        },
        deleteItem(item, index){
            console.log(item);
        },
    }
}
</script>
