currentDealVersion = "3.1.9";

function noteOldVersion(version) {
  if (version != currentDealVersion) {
     element = document.getElementById("versionWarning");
     if (element != null) {
       element.innerHTML = "This is not the current version of Deal.  " +
                           "The current version of Deal is " + currentDealVersion + 
                           " which can be found at " + 
                           "<a href='http://bridge.thomasoandrews.com/deal/'>the main Deal site.</a>";
       element.style.display = "block";
     }
  }
}

function noteOldVersion(version) {
  if (version != currentDealVersion) {
     element = document.getElementByID("versionWarning");
     if (element != null) {
       element.innerHTML = "This is not the current version of Deal.  The current version of Deal is Deal " + currentDealVersion + " which can be found at <a href='http://bridge.thomasoandrews.com//deal/'>the make Deal site.</a>";
     }
  }
}
