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