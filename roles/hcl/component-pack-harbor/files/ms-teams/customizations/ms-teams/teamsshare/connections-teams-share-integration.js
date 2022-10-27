// ==UserScript==
// @name         MS Teams Launcher
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  try to take over the world!
// @author       You
// @match        https://cdemo1.cnx.cwp.pnp-hcl.com/*
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    /* 
     * Define the messages that should be added to the MS Teams Share dialog. This will be
     * put in as the prewritten message that is provided in the share textbox.
     *
     * The individual messages are defined as a string that can contain
     * - plain text
     * - simple html elements, e.g. <br> for a line break
     * - the following placeholders, written as: {PLACEHOLDER}
     *   - PAGE_TITLE = The title of the website, which is displayed within the browser's tab
     *   - PAGE_HREF  = The url of the website, which is displayed within the browser's search bar
     */
    // Default message displayed if no specific message is defined
    let TEAMS_SHARE_MESSAGE_DEFAULT = 'Shared from HCL Connections <br/> [{PAGE_TITLE}] - {PAGE_HREF}';

    // Message for the Files > File preview share 
    let TEAMS_SHARE_MESSAGE_FILES_FILE_PREVIEW = 'File shared from HCL Connections: <br/> [{PAGE_TITLE}] - {PAGE_HREF}';

    let nls = {};

    try {
        function _log(msg) {
            if (dojo.config.isDebug) {
                console.log('teams-share-integration: ' + JSON.stringify(msg));
            }
        }

        // find current path to fetch resources from there
        var scripts = document.getElementsByTagName("script"),
            src = scripts[scripts.length - 1].src;
        var url = new URL(src);
        var context = url.pathname;
        if (context.lastIndexOf('/') > 0) {
            context = context.substring(0, context.lastIndexOf('/'));
        }
        // contains the dynamic path to the connections-teams-share-integration.js script in order to deferred load more resources from there.
        var TEAMS_INTEGRATION_CONTEXT = context;
        _log('script path: ' + TEAMS_INTEGRATION_CONTEXT);

        var waitFor = function (callback, elXpath, waitTime, elXpathRoot, maxInter) {
            if (!elXpathRoot) {
                var elXpathRoot = dojo.body();
            }
            if (!maxInter) {
                var maxInter = 10000; // number of intervals before expiring
            }
            if (!waitTime) {
                var waitTime = 1; // 1000=1 second
            }
            if (!elXpath) {
                return;
            }
            var waitInter = 0; // current interval
            var intId = setInterval(function () {
                if (++waitInter < maxInter && (!dojo.query(elXpath, elXpathRoot).length)) {
                    return;
                }

                clearInterval(intId);
                if (waitInter >= maxInter) {
                } else {
                    callback();
                }
            }, waitTime);
        };

        var _isVisualUpdateApplied;
        // check if visual update is applied
        var isVisualUpdateApplied = function () {
            if (_isVisualUpdateApplied) {
                return _isVisualUpdateApplied;
            }

            _isVisualUpdateApplied = false;
            var ss = document.styleSheets;
            for (var i = 0, max = ss.length; i < max; i++) {
                if (ss[i].href && ss[i].href.indexOf('global.css') > 0) {
                    _isVisualUpdateApplied = true;
                    break;
                }
            }
            return _isVisualUpdateApplied;
        }

        function _getTranslatedText(translateKey, text) {
            var translatedText = translate(translateKey);

            if (translatedText) {
                text = translatedText;
            }

            return text;
        }

        function _getPreparedMessage(msg, appType) {

            // translate message
            msg = _getTranslatedText('teamshare.' + appType + '.message', msg);

            // replace PAGE_TITLE if present
            var pageTitle = document.title;
            if (msg.indexOf('{PAGE_TITLE}') >= 0) {
                msg = msg.replace('{PAGE_TITLE}', pageTitle);

            }
            return msg;
        }

        function _getPreparedTeamsShareHtml(message) {
            var _linkHtml = '<div class="teams-share-button" data-preview="true"></div>';
            if (!message) {
                return _linkHtml;
            }

            if (message.indexOf('{PAGE_HREF}' >= 0)) {
                // remove href string from message string and add url to link
                var currentUrl = window.location.href;
                _linkHtml = '<div class="teams-share-button" data-msg-text="" data-href="' + currentUrl + '" data-preview="true"></div>';
            } else {
                _linkHtml = '<div class="teams-share-button" data-msg-text="" data-preview="true"></div>';
            }

            return _linkHtml;
        }

        function _insertMessageToTeamsHtml(message,elem){
            var teams_share_button= elem.querySelector(".teams-share-button");

            if (message.indexOf('{PAGE_HREF}' >= 0)) {
                message = message.replace('{PAGE_HREF}', '');
            } 
            teams_share_button.setAttribute("data-msg-text",message);
        }

        var createTeamsShareHtml = function () {
            var elem, menuLink, teamsShareHtml, message;
            var teamsShareActionTitle = _getTranslatedText('teamshare.action.title', 'Share to Microsoft Teams');

            var el = document.querySelector(".ics-viewer-toolbar");
            // if viewer toolbar is files preview, add teams share action in toolbar
            if (el && !el.querySelector(".teams-share-button")) {
                // generated message
                message = _getPreparedMessage(TEAMS_SHARE_MESSAGE_FILES_FILE_PREVIEW, "files");
                teamsShareHtml = _getPreparedTeamsShareHtml(message);

                // create and add element
                elem = document.querySelector(".ics-viewer-toolbar");
                menuLink = document.createElement('li');
                menuLink.id = 'teams-share-button-files';
                menuLink.classList.add('ics-viewer-action');
                if (isVisualUpdateApplied()) {
                    menuLink.classList.add('va');
                }
                menuLink.title = teamsShareActionTitle;
                menuLink.innerHTML = teamsShareHtml;
                var secondMenuLink;
                if (el.querySelector(".ics-viewer-action-upload")) {
                    secondMenuLink = elem.querySelectorAll('li')[1];
                } else {
                    secondMenuLink = elem.querySelectorAll('li')[0];
                }
                elem.insertBefore(menuLink, secondMenuLink);
                _insertMessageToTeamsHtml(message,elem);
            }
            // if normal cnx ui, add teams share action next to search 
            else if (!document.querySelector("#teams-share-button-wrapper")) {
                // generated message
                message = _getPreparedMessage(TEAMS_SHARE_MESSAGE_DEFAULT, "default");
                teamsShareHtml = _getPreparedTeamsShareHtml(message);

                // create and add element
                elem = document.querySelector('body');
                menuLink = document.createElement('div');
                menuLink.id = 'teams-share-button-wrapper';
                if (isVisualUpdateApplied()) {
                    menuLink.classList.add('va');
                }
                menuLink.title = teamsShareActionTitle;
                menuLink.innerHTML = teamsShareHtml;
                elem.appendChild(menuLink);
                _insertMessageToTeamsHtml(message,elem);
            }
        }

        function updateTeamsShareClickAction(link, type) {
            // update onclick event
            var shareButton;
            if (!type) {
                shareButton = document.querySelector('#teams-share-button-wrapper .teams-share-button');
            } else if (type === 'files') {
                shareButton = document.querySelector('#teams-share-button-files .teams-share-button');
            }

            shareButton.onclick = function (e) {
                e.preventDefault();
                e.stopPropagation();
                return link += "&s=" + Date.now(),
                    window.open(link, "ms-teams-share-popup", "width=700,height=600"),
                    !1;
            }
        }

        function updateTeamsShareContext(type) {
            var message;
            if (!type) {
                message = _getPreparedMessage(TEAMS_SHARE_MESSAGE_DEFAULT, "default");
            } else if (type === 'files') {
                message = _getPreparedMessage(TEAMS_SHARE_MESSAGE_FILES_FILE_PREVIEW, "files");
            } else {
                message = _getPreparedMessage(TEAMS_SHARE_MESSAGE_DEFAULT, "default");
            }
            // remove page href from string if present
            message = message.replace('{PAGE_HREF}', '');

            var currentUrl = window.location.href;
            _log("updateTeamsShareContext - update share context to: " + JSON.stringify({ message, currentUrl }));
            var shareLink;
            if (!type) {
                shareLink = document.querySelector('#teams-share-button-wrapper .teams-share-button a');
            } else if (type === 'files') {
                shareLink = document.querySelector('#teams-share-button-files .teams-share-button a');
            }

            if (!shareLink) return;
            // update href and msgText elements in link URL
            var _link = shareLink.href;
            _log("updateTeamsShareContext - old link: " + _link);
            _link = _link.replace(/(href=).*?(&)/, '$1' + encodeURIComponent(currentUrl) + '$2');
            _link = _link.replace(/(msgText=).*?(&)/, '$1' + encodeURIComponent(message) + '$2');
            _log("updateTeamsShareContext - new link: " + _link);
            shareLink.href = _link;

            updateTeamsShareClickAction(_link, type);
        }

        function addTeamsShareStyleRules() {
         var teams_button_default='#teams-share-button-wrapper { position: fixed; display: block; width: 33px; height: 33px; right: 50px; top: 70px; z-index:900; }',
           
         teams_button_Va= '#teams-share-button-wrapper.va { width: 40px; height: 40px; top: 58px; right: 70px; } ';
        
         if(dojo.locale === "ar" || dojo.locale === "ur" || dojo.locale === "he" || dojo.locale === "fa" || dojo.locale === "ku"){
            teams_button_default='#teams-share-button-wrapper { position: fixed; display: block; width: 33px; height: 33px; left: 50px; top: 70px; z-index:900; }';
           
            teams_button_Va= '#teams-share-button-wrapper.va { width: 40px; height: 40px; top: 61px; left: 20px; } ';
        }

            var css = '' +
                // styles for integration next to search
                // share wrapper styles (outter div)
                teams_button_default +
                // button div styles
                '#teams-share-button-wrapper .teams-share-button { height: 35px; width: 35px; background: #ffffff; border-radius: 50%; } ' +
                '#teams-share-button-wrapper .teams-share-button:hover { border: 1px solid #4178be; position: relative; top: -1px; left: -1px; } ' +
                // icon styles
                '.teams-share-button img { height: 32px; width: 32px; padding: 1px; cursor: pointer; }' 

                // style updates for visual update styling
                 + teams_button_Va +
                '#teams-share-button-wrapper.va .teams-share-button { height: 33px; width: 33px; border: rgb(225 227 229) solid 1px; box-shadow: rgba(0, 0, 0, 0.2) 0px 1px 3px 0px; } ' +
                '#teams-share-button-wrapper.va .teams-share-button img { height: 31px; width: 31px; }' +
                '#teams-share-button-wrapper.va .teams-share-button:hover { border: 1px solid #3C6DF0; top: 0px; left: 0px; } ' +

                // styles for integration in files preview toolbar
                '#teams-share-button-files { top: -4px; } ' +
                '#teams-share-button-files .teams-share-button { height: 35px; width: 35px; } ' +
                '#teams-share-button-files .teams-share-button img { height: 35px; width: 35px; padding: 1px; cursor: pointer; }';

            var head = document.head || document.getElementsByTagName('head')[0];
            var style = document.createElement('style');

            head.appendChild(style);

            style.type = 'text/css';
            if (style.styleSheet) {
                // This is required for IE8 and below.
                style.styleSheet.cssText = css;
            } else {
                style.appendChild(document.createTextNode(css));
            }
        }

        function addTeamsShareLauncherScript() {
            // load teams launcher script, connecting the dom node
            var launcherScript = document.createElement('script');
            launcherScript.src = 'https://teams.microsoft.com/share/launcher.js';
            launcherScript.async = 'true';
            launcherScript.defer = 'true';
            document.head.appendChild(launcherScript);
            // wait for teams script to render dom node (.teams-share-button a img)
        }

        function filesDOMObserver(anchor) {
            var el = document.querySelector(".ics-viewer-toolbar");
            if (!el.querySelector(".teams-share-button a")) {
                createTeamsShareHtml();
                if (anchor) {
                    el.querySelector(".teams-share-button").appendChild(anchor);
                }
            }
            return;
        }

        function onTitleChange() {
            waitFor(function () {
                var anchorDOM = document.querySelector("#teams-share-button-wrapper .teams-share-button a");
                var el = anchorDOM.cloneNode(true);
                filesDOMObserver(el);
                updateTeamsShareContext('files');
            }, '.ics-viewer-toolbar');
            updateTeamsShareContext();
        }

        function loadTeamsShare() {
            // wait until search action is rendered
            waitFor(function () {
                // add css for teams integration
                addTeamsShareStyleRules();
                // add share action wrapper to UI
                createTeamsShareHtml();
                // load teams launcher script - this will add Teams launcher logic to the previously added UI element
                addTeamsShareLauncherScript();

                // wait for teams launcher to be prepared
                waitFor(function () {
                    _log('dom node rendered');

                    // replace onclick logic to ensure it works together with cnx JS
                    var hrefElem = el.querySelector('.teams-share-button a');
                    updateTeamsShareClickAction(hrefElem.href, null);

                    // listen to changes of page title and url hash
                    window.addEventListener("hashchange", function () {
                        updateTeamsShareContext();
                    }, true);
                    new MutationObserver(onTitleChange).observe(
                        document.querySelector('title'),
                        { subtree: true, characterData: true, childList: true }
                    );
                }, '#teams-share-button-wrapper .teams-share-button a img');
            }, '.icSearchPaneButton');

            waitFor(function () {
                filesDOMObserver();
            }, '.ics-viewer-toolbar');
        }

        var translate = function (translateKey, replacements) {
            if (nls && nls[translateKey]) {
                var translation = nls[translateKey];
                // if replacements given, process them
                if (replacements) {
                    for (key in replacements) {
                        if (translation.indexOf('{{' + key + '}}') >= 0) {
                            translation = translation.replace('{{' + key + '}}', replacements[key]);
                        }
                    }
                }
                return translation;
            }
            return "";
        };

        var getNls = function (cb) {
            _log('>', 'util.getNls');
            var locale = dojo.locale;
            if (locale.length > 2 && locale != "pt-br" && locale != "zh-tw") {
                locale = locale.substring(0, 2);
            }
            if (locale == null || locale === '') {
                _log('< no locale found, use default "en".', 'util.getNls');
                locale = 'en';
            }
            // The parameters to pass to xhrGet, the url, how to handle it, and the callbacks.
            var xhrArgs = {
                url: TEAMS_INTEGRATION_CONTEXT + '/nls/locale_' + locale + '.json',
                handleAs: 'json',
                load: function (data) {
                    _log('< data: "' + data + '"', 'util.getNls');
                    cb(null, data);
                },
                error: function (data) {
                    _log('< error - nls error: "' + data + '"', 'util.getNls');
                    cb(data);
                },
                withCredentials: true
            };

            // Call the asynchronous xhrGet
            dojo.xhrGet(xhrArgs);
        };

        // fetch translation strings, then render teams share integration
        getNls(function (err, data) {
            if (err) {
                try {
                    _log('Error retrieving nls: "' + JSON.stringify(err) + '"', 'ui.init');
                } catch (e) { }
                loadTeamsShare();
            }
            if (data) {
                _log('retrieved nls data: "' + JSON.stringify(data) + '"', 'ui.init');
                nls = data;
                loadTeamsShare();
            }
        });

        window.onscroll = function () {
                document.querySelector("#teams-share-button-wrapper").style.top = document.querySelector(".icSearchPaneButton").offsetTop+"px";
        }

        waitFor(function(){
           
            waitFor(function(){

                document.querySelector("#teams-share-button-wrapper").style.top = document.querySelector(".icSearchPaneButton").offsetTop+"px";

            },"#teams-share-button-wrapper");

        },".icSearchPaneButton");

    } catch (e) {
        console.log(e);
    }

})();