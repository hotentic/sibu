function sibuCallback(actionName, args) {
    var callback = actionName + "SibuCallback";
    console.log(callback);
    if(typeof window[callback] === "function") {
        window[callback](args);
    }
}