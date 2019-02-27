import { thumbnailUrlFor } from '../../image.js';
import CoverImageFormInput from '../cover-image-form-input.vue';
import FormFieldErrors from '../form-field-errors.vue';

export function albumAndPersonFormMixinBuilder(){
    return {
        props: {
            putFlash: {
                type: Function,
                required: true,
            },
            sendJson: {
                type: Function,
                required: true,
            },
            //for when creating a resource with images
            images: {
                type: Array
            },
            successRedirect: {
                type: Function
            },
        },
        components: {
            'Form-Field-Errors': FormFieldErrors,
            'Cover-Image-Form-Input': CoverImageFormInput,
        },
        created(){
            this.setup();
        },
        data() {
            return {
                isInitialLoadComplete: false,
                model: null,
                errors: {},
            }
        },
        computed: {
            isCreateForm(){
                return !this.isEditForm;
            },
            shouldShowCoverImageInput(){
                return this.imagesInModel.length === 0;
            },
            imagesInModel(){
                if(this.isEditForm){
                    return this.model.images;
                }
                else if(this.isCreateForm && this.images){
                    return this.images;
                }
                return [];
            },
        },
        watch: {
            '$route'(to, from){
                this.setup();
            },
        },
        methods: {
            thumbnailUrlFor(image){
                return thumbnailUrlFor(image.mini_thumbnail_path);
            },
        },
    };
}