(function () {
  window.__customizer = {
    /*
     * Utility function to let us wait for a specific element of the page to load...
     */
    waitFor: function(callback, elXpath, maxInter, waitTime) {
      if (!maxInter) var maxInter = 300;  // number of intervals before expiring
      if (!waitTime) var waitTime = 100;  // 1000=1 second
      var waitInter = 0;  // current interval
      var intId = setInterval( function() {
        if (++waitInter >= maxInter) return;
        if (typeof(dojo) == "undefined") return;
        if (!dojo.query(elXpath, dojo.body()).length) return;
        clearInterval(intId);
        if (waitInter < maxInter) {
          callback();
        }
      }, waitTime);
    },

    /*
     * Queue of callbacks for the onHashChange event
     */
    onHashChangeQueue: [],

    /*
     * window.onhashchange handler
     */
    handleOnHashChange: function() {
      for(var i = 0; i < this.onHashChangeQueue.length; i++) {
        this.onHashChangeQueue[i]();
      }
    },

    /*
     * Utility function to add to the onHashChange callback queue
     */
    addOnHashChangeCallback: function(callback) {
      this.onHashChangeQueue.push(callback);
      window.onhashchange = this.handleOnHashChange;
    }

  };

})();
