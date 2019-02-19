<template>
    <div class="container">
        <div class="alert" :class="`alert-${alertClass}`">{{alertText}}</div>
    </div>
</template>

<script>
//note that you can't use v-if when not alertText or scrollIntoView won't work

export default {
    name: 'Flash-Alert',
    props: {
    },
    data() {
        return {
            alertClass: 'info',
            alertText: '',
        }
    },
    watch: {
        '$route'(to, from){
            this.alertText = '';
        },
    },
    computed: {

    },
    methods: {
        putFlash(message, type='info'){
            this.alertText = message;
            this.alertClass = type;
        },
    }
}
</script>
