//@! utility function to safely use a component
function withComponent(componentId, container, args, fn) {
    var object = componentId.createObject(container, args);
    try {
        fn(object);
    } finally {
        object.destroy();
    }
}
