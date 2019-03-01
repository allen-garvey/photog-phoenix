import { fetchJson } from '../../request-helpers.js';

import FormSection from '../base/form-section.vue';
import FormInput from '../form-input.vue';

export function formMixinBuilder(){
    return {
        props:{
            putFlash: {
                type: Function,
                required: true,
            },
            sendJson: {
                type: Function,
                required: true,
            },
        },
        components: {
            'Form-Input': FormInput,
            'Form-Section': FormSection,
        },
        data() {
            return {
                isInitialLoadComplete: false,
                model: null,
                errors: {},
            }
        },
        created(){
            this.setup();
        },
        computed: {
            isEditForm(){
                return typeof this.modelId === 'number';
            },
            isCreateForm(){
                return !this.isEditForm;
            },
        },
        watch: {
            '$route'(to, from){
                this.setup();
            },
        },
        methods: {
            setup(){
                this.isInitialLoadComplete = false;
                this.errors = {};
                if(this.isEditForm){
                    this.loadModel().then((model)=>{
                        this.setupModel(model);
                        this.isInitialLoadComplete = true;
                    });
                }
                else{
                    this.model = null;
                    this.setupModel(null);
                    this.isInitialLoadComplete = true;
                }
            },
            loadModel(){
                const apiUrl = `${this.resourceApiUrlBase}/${this.modelId}`;
                return fetchJson(apiUrl).then((model)=>{
                    this.model = model;
                    return model;
                });
            },
        },
    };
}