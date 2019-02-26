import FormInput from '../form-input.vue';

export function formMixinBuilder(){
    return {
        components: {
            'Form-Input': FormInput,
        },
    };
}