import ThumbnailList from './components/thumbnail-list.vue'
import TagsIndex from './components/tags-index.vue'
import ImportsIndex from './components/imports-index.vue';
import ImageDetail from './components/image-detail.vue'
import AlbumForm from './components/album-form.vue';
import PersonForm from './components/person-form.vue';
import TagForm from './components/tag-form.vue';

export default {
    mode: 'history',
    routes: [
        { 
            path: '/', 
            name: 'home',
            redirect: '/albums' 
        },
        { 
            path: '/tags',
            name: 'tagsIndex', 
            component: TagsIndex,
            props: {
                itemShowRouteName: 'tagsShow',
                itemsListKey: null,
                newItemLink: {name: 'tagsNew'},
            },
        },
        { 
            path: '/imports',
            name: 'importsIndex', 
            component: ImportsIndex,
            props: {
                itemShowRouteName: 'importsShow',
                itemsListKey: null,
            },
        },
        { 
            path: '/albums',
            name: 'albumsIndex', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: route.path,
                    enableBatchSelectAlbums: true,
                    newItemLink: {name: 'albumsNew'},
                    showRouteFor: (item)=>{
                        return {
                            name: 'albumsShow',
                            params: {
                                id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        { 
            path: '/persons',
            name: 'personsIndex', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: route.path,
                    newItemLink: {name: 'personsNew'},
                    showRouteFor: (item)=>{
                        return {
                            name: 'personsShow',
                            params: {
                                id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        { 
            path: '/images',
            name: 'imagesIndex', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: route.path,
                    enableHasAlbumFilter: true,
                    enableHasPersonFilter: true,
                    enableBatchSelectImages: true,
                    showRouteFor: (item)=>{
                        return {
                            name: 'imagesShow',
                            params: {
                                id: item.id,
                                image_id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        { 
            path: '/images/favorites',
            name: 'imageFavoritesIndex', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: '/images/?favorites=true',
                    enableHasAlbumFilter: true,
                    enableHasPersonFilter: true,
                    enableBatchSelectImages: true,
                    showRouteFor: (item)=>{
                        return {
                            name: 'imagesShow',
                            params: {
                                id: item.id,
                                image_id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        { 
            path: '/images/uncategorized',
            name: 'imagesNotInAlbumIndex', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: '/images/?in_album=false',
                    enableHasPersonFilter: true,
                    enableBatchSelectImages: true,
                    showRouteFor: (item)=>{
                        return {
                            name: 'imagesShow',
                            params: {
                                id: item.id,
                                image_id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        //new route has to be before show route
        { 
            path: '/albums/new',
            name: 'albumsNew', 
            component: AlbumForm,
            props: (route) => {
                const optionalParams = ['images', 'successRedirect'];
                const props = {};
                for(const param of optionalParams){
                    if(param in route.params){
                        props[param] = route.params[param];
                    }
                }
                return props;
            },
        },
        { 
            path: '/albums/:id/edit',
            name: 'albumsEdit', 
            component: AlbumForm,
            props: (route) => {
                return {
                    albumId: parseInt(route.params.id),
                }; 
            },
        },
        { 
            path: '/albums/:id',
            name: 'albumsShow', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: route.path,
                    itemsListKey: 'images',
                    enableHasPersonFilter: true,
                    enableBatchSelectImages: true,
                    editItemLink: {name: 'albumsEdit', id: route.params.id},
                    showRouteFor: (item)=>{
                        return {
                            name: 'albumImagesShow',
                            params: {
                                album_id: route.params.id,
                                image_id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        //new route has to be before show route
        { 
            path: '/persons/new',
            name: 'personsNew', 
            component: PersonForm,
            props: (route) => {
                const optionalParams = ['images', 'successRedirect'];
                const props = {};
                for(const param of optionalParams){
                    if(param in route.params){
                        props[param] = route.params[param];
                    }
                }
                return props;
            },
        },
        { 
            path: '/persons/:id/edit',
            name: 'personsEdit', 
            component: PersonForm,
            props: (route) => {
                return {
                    personId: parseInt(route.params.id),
                }; 
            },
        },
        { 
            path: '/persons/:id',
            name: 'personsShow', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: route.path,
                    itemsListKey: 'images',
                    enableHasAlbumFilter: true,
                    enableBatchSelectImages: true,
                    editItemLink: {name: 'personsEdit', id: route.params.id},
                    showRouteFor: (item)=>{
                        return {
                            name: 'personImagesShow',
                            params: {
                                person_id: route.params.id,
                                image_id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        //new route has to be before show route
        { 
            path: '/tags/new',
            name: 'tagsNew', 
            component: TagForm,
            props: (route) => {
                return {
                }; 
            },
        },
        { 
            path: '/tags/:id/edit',
            name: 'tagsEdit', 
            component: TagForm,
            props: (route) => {
                return {
                    tagId: parseInt(route.params.id),
                }; 
            },
        },
        { 
            path: '/tags/:id',
            name: 'tagsShow', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: route.path,
                    itemsListKey: 'albums',
                    enableBatchSelectAlbums: true,
                    editItemLink: {name: 'tagsEdit', id: route.params.id},
                    showRouteFor: (item)=>{
                        return {
                            name: 'albumsShow',
                            params: {
                                id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        { 
            path: '/imports/:id',
            name: 'importsShow', 
            component: ThumbnailList,
            props: (route) => {
                return {
                    apiPath: route.path,
                    itemsListKey: 'images',
                    enableHasAlbumFilter: true,
                    enableHasPersonFilter: true,
                    enableBatchSelectImages: true,
                    showRouteFor: (item)=>{
                        return {
                            name: 'importImagesShow',
                            params: {
                                import_id: route.params.id,
                                image_id: item.id,
                            },
                        };
                    },
                }; 
            },
        },
        { 
            path: '/images/:id',
            name: 'imagesShow', 
            component: ImageDetail,
            props: (route) => {
                return {
                    modelApiPath: `/images/${route.params.id}`,
                    imageId: parseInt(route.params.id),
                }; 
            },
        },
        { 
            path: '/albums/:album_id/images/:image_id',
            name: 'albumImagesShow', 
            component: ImageDetail,
            props: (route) => {
                return {
                    modelApiPath: `/albums/${route.params.album_id}`,
                    imageId: parseInt(route.params.image_id),
                    parent: {
                        parentRouteName: 'albumsShow',
                        showRouteFor: (item)=>{
                            return {
                                name: 'albumImagesShow',
                                params: {
                                    album_id: route.params.album_id,
                                    image_id: item.id,
                                },
                            };
                        },
                    },
                }; 
            },
        },
        { 
            path: '/persons/:person_id/images/:image_id',
            name: 'personImagesShow', 
            component: ImageDetail,
            props: (route) => {
                return {
                    modelApiPath: `/persons/${route.params.person_id}`,
                    imageId: parseInt(route.params.image_id),
                    parent: {
                        parentRouteName: 'personsShow',
                        showRouteFor: (item)=>{
                            return {
                                name: 'personImagesShow',
                                params: {
                                    person_id: route.params.person_id,
                                    image_id: item.id,
                                },
                            };
                        },
                    },
                }; 
            },
        },
        { 
            path: '/imports/:import_id/images/:image_id',
            name: 'importImagesShow', 
            component: ImageDetail,
            props: (route) => {
                return {
                    modelApiPath: `/imports/${route.params.import_id}`,
                    imageId: parseInt(route.params.image_id),
                    parent: {
                        parentRouteName: 'importsShow',
                        showRouteFor: (item)=>{
                            return {
                                name: 'importImagesShow',
                                params: {
                                    import_id: route.params.import_id,
                                    image_id: item.id,
                                },
                            };
                        },
                    },
                }; 
            },
        },
    ],
};