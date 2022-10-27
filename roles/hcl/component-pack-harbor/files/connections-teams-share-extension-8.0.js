function openShareExtension() {   
  let shareUrl = `https://teams.microsoft.com/share?href=${window.location.href}&referrer=${window.location.host}&s=${Date.now()}`;
  shareUrl = shareUrl.replace(/(href=).*?(&)/, '$1' + encodeURIComponent(window.location.href) + '$2');
  window.open(shareUrl, '_blank', 'width=700,height=600');        
}