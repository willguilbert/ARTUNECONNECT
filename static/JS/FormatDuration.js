 /*
  Fonction qui manipule une string duration et qui la transforme pour obtenir la string mais en minutes et secondes
  conventionnelles.
  param (String) duration
  returns string en minutes et secondes
   */

function formatDuration(duration) {

  let minutes = Math.floor(duration);
  let fractionalMinutes = duration - minutes;
  let seconds = Math.round(fractionalMinutes * 60);

  if (seconds === 60) {
    minutes += 1;
    seconds = 0;
  }

  const secondsString = seconds < 10 ? '0' + seconds : seconds;
  return minutes + ":" + secondsString;
}

document.querySelectorAll('.album-duration').forEach((element) => {
  const duration = parseFloat(element.textContent);
  element.textContent = formatDuration(duration);
});