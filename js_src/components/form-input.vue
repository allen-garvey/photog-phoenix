<template>
    <div class="form-group">
        <label :for="id">{{label}}</label>
        <input :id="id" class="form-control" :type="inputType" v-model="value" />
        <Form-Field-Errors :errors="errors" />
    </div>
</template>

<script>
import FormFieldErrors from './form-field-errors.vue';

export default {
    name: 'Form-Input',
    props: {
        id: {
            type: String,
            required: true,
        },
        inputType: {
            type: String,
            default: 'text',
        },
        label: {
            type: String,
            required: true,
        },
        errors: {
            type: Array
        },
    },
    components: {
        'Form-Field-Errors': FormFieldErrors,
    },
    data() {
        return {
            value: '',
        }
    },
    watch: {
        value(newValue){
            this.$emit('input', newValue);
        },
    },
}
</script>

