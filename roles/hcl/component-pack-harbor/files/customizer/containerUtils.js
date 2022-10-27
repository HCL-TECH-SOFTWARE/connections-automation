(function () {
  window.__containerUtils = {
    injectContainer: function(options) {
      // Options / Defaults
      const injectionId = options.injectionId || 0;
      const locator = options.payload.locator || '.lotusMain .lotusContent';
      const position = options.payload.position || 'first';
      const heading = options.payload.heading || '';
      const url = options.payload.url || '';
      const sandbox = options.payload.sandbox || '';
      const iframeContainerClass = options.payload.iframeContainerClass || 'iframeContainer';
      const iframeHeaderClass = options.payload.iframeHeaderClass || 'iframeHeader';
      const iframeHeaderTitleClass = options.payload.iframeHeaderTitleClass || 'iframeHeaderTitle';
      const iframeContentClass = options.payload.iframeContentClass || 'iframeContent';
      const headingVisible = heading.length > 0 ? '' : 'style=\'display: none;\'';

      let iframeProperties = '';
      if (options.payload.width) {
        iframeProperties += ` width='${options.payload.width}'`;
      }
      if (options.payload.height) {
        iframeProperties += ` height='${options.payload.height}'`;
      }

      function addIFrame() {
        var dropSpot = dojo.query(locator);

        var iframeWidget = `
          <div id='iframeContainer${injectionId}' class='${iframeContainerClass}'>
             <div id='iframeHeader${injectionId}' class='${iframeHeaderClass}' ${headingVisible}>
               <h2 id='iframeHeaderTitle${injectionId}' class='${iframeHeaderTitleClass}'>
                 <span class='iframeHeaderText'>${heading}</span>
               </h2>
             </div>
             <iframe id='iframeContent${injectionId}' class='${iframeContentClass}' src='${url}' sandbox='${sandbox}'${iframeProperties}>
             </iframe>
         </div>`;
        dojo.place(iframeWidget, dropSpot[0], position);
      };

      __customizer.addOnHashChangeCallback(function() {
        setTimeout(function() {
          var existingIframe = dojo.byId(`iframeContainer${injectionId}`);
          if (existingIframe) {
            dojo.destroy(existingIframe);
          }
          addIFrame();
        }, 1000);
      });

      __customizer.waitFor(addIFrame, locator);
    }
  }
})();
