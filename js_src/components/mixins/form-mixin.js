import FormSection from '../base/form-section.vue';
import FormInput from '../form-input.vue';

export function formMixinBuilder(){
    return {
        components: {
            'Form-Input': FormInput,
            'Form-Section': FormSection,
        },
    };
}