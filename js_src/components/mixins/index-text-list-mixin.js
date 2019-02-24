import TextList from '../base/text-list.vue';

export default function mixinBuilder(){
    return {
        props: {
            getModel: {
                type: Function,
                required: true,
            },
        },
        components: {
            'Text-List': TextList,
        },
        created(){
            this.setup();
        },
        data() {
            return {
                model: [],
                //need this property or there will be errors when we switch routes and new models haven't been loaded yet
                isLoadingModel: true,
            }
        },
        computed: {
            itemsList(){
                if(this.isLoadingModel){
                    return [];
                }
                return this.model;
            },
        },
        watch: {
            '$route'(to, from){
                this.setup();
            }
        },
        methods: {
            setup(){
                this.isLoadingModel = true;
                this.getModel(this.modelPath).then((itemsJson)=>{
                    this.model = itemsJson;
                    this.isLoadingModel = false;
                });
            },
            showRouteFor(item){
                return {
                    name: this.showRouteName,
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