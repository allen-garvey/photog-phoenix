export function getOptionalParams(routeParams, optionalParams){
    const props = {};
    for(const param of optionalParams){
        if(param in routeParams){
            props[param] = routeParams[param];
        }
    }
    return props;
}