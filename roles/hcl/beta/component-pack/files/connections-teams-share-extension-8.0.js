function openShareExtension() {
  let shareUrl =  "https://teams.microsoft.com/share?href=" + window.location.href + "&referrer=" +  window.location.host;
  window.open(shareUrl,'_blank', 'width=700,height=600'); 
}

