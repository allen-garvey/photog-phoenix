<template>
    <main class="main container">
        <Resource-Header title="Tags" :editItemLink="editItemLink" :newItemLink="newItemLink" />
        <ul class="text-list">
            <li v-for="(item, i) in thumbnailList" :key="i">
                <router-link :to="showRouteFor(item)">
                    {{titleFor(item)}}
                </router-link>
            </li>
        </ul>
    </main>
</template>

<script>
import textListBuilder from './components-base/text-list-base.js';

const component = textListBuilder();

export default component;
</script>
