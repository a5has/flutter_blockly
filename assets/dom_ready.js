(function() {
  function checkReady() {
    const blocklyEditor = document.querySelector('#blocklyEditor');
    const flutterWebView = window.FlutterWebView;
    const blocklyEditorDefined = typeof editor !== 'undefined' && editor !== null;
    
    if (blocklyEditor && flutterWebView && blocklyEditorDefined) {
      flutterWebView.postMessage(JSON.stringify({event: 'domReady', data: true}));
      return true;
    }
    return false;
  }
  
  function startChecking() {
    // Try immediate check first
    if (checkReady()) return;
    
    // Set up MutationObserver to watch for elements being added
    var observer = new MutationObserver(() => {
      if (checkReady()) {
        observer.disconnect();
        observer = null;
      }
    });
    
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
    
    // Also listen for load event in case elements exist but DOM isn't ready
    window.addEventListener('load', () => {
      if (checkReady()) {
        observer.disconnect();
        observer = null;
      }
    });
    
    // Fallback timeout after 10 seconds
    setTimeout(() => {
      if (observer !== null) {
        observer.disconnect();
        observer = null;
        if (!checkReady() && window.FlutterWebView) {
          window.FlutterWebView.postMessage(JSON.stringify({
            event: 'onError', 
            data: 'Timeout waiting for Blockly elements to be ready'
          }));
        }
      }
    }, 10000);
  }
  
  // Wait for DOM to be at least interactive before starting
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', startChecking);
  } else {
    startChecking();
  }
})();
