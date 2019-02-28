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
            isCreateForm(){
                return !this.isEditForm;
            },
        },
        watch: {
            '$route'(to, from){
                this.setup();
            },
        },
    };
}