import ReasourceHeader from '../resource-header.vue';

export default function textListBuilder(options){
    return {
        name: 'Text-List',
        props: {
            getModel: {
                type: Function,
                required: true,
            },
            itemShowRouteName: {
                type: String,
                required: true,
            },
            itemsListKey: {
                type: String,
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
        created(){
            //initial setup of items, since $route watch method won't be called on initial load
            this.loadModel(this.$route.path);
        },
        data() {
            return {
                model: [],
                //need this property or there will be errors when we switch routes and new models haven't been loaded yet
                isLoadingModel: true,
            }
        },
        computed: {
            thumbnailList: function(){
                if(this.isLoadingModel){
                    return [];
                }
                if(this.itemsListKey){
                    return this.model[this.itemsListKey];
                }
                return this.model;
            },
        },
        watch: {
            '$route'(to, from){
                this.loadModel(to.path);
            }
        },
        methods: {
            loadModel: function(modelPath){
                this.isLoadingModel = true;
                this.getModel(modelPath).then((itemsJson)=>{
                    this.model = itemsJson;
                    this.isLoadingModel = false;
                });
            },
            showRouteFor: function(item){
                return {
                    name: this.itemShowRouteName,
                    params: {
                        id: item.id,
                    },
                };
            },
            titleFor(item){
                return item.name;
            },
        }
    };
}