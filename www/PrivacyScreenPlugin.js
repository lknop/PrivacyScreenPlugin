function PrivacyScreen() {}
               
PrivacyScreen.prototype.hidePrivacyScreen = function(successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "PrivacyScreenPlugin", "hidePrivacyScreen", []);
};
               
PrivacyScreen.prototype.showPrivacyScreen = function(successCallback, errorCallback) {
    cordova.exec(successCallback, errorCallback, "PrivacyScreenPlugin", "showPrivacyScreen", []);
};
               
PrivacyScreen.install = function() {
    if (!window.plugins) {
        window.plugins = {};
    }
               
    window.plugins.privacyscreen = new PrivacyScreen();
    return window.plugins.privacyscreen;
};
               
cordova.addConstructor(PrivacyScreen.install);