function sibuCallback(actionName, args) {
    var callback = actionName + "SibuCallback";
    console.debug(callback);
    if(typeof window[callback] === "function") {
        window[callback](args);
    }
}