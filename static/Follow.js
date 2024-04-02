document.addEventListener('DOMContentLoaded', function() {
    var followButtons = document.querySelectorAll('.follow-btn');
    followButtons.forEach(function(button) {
        button.addEventListener('click', function(event) {
            event.preventDefault();
            var idArtiste = this.getAttribute('data-id');
            fetch('/follow', {
                method: 'POST',
                body: JSON.stringify({ id_artiste: idArtiste }),
                headers: {
                    'Content-Type': 'application/json',

                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Probleme fetch ' + response.statusText);
                }
                return response.json();
            })
            .then(data => {
                if (data.success) {

                   button.classList.remove('btn-primary');
                    button.classList.add('btn-success');
                    button.innerText= 'Followed!';
                    button.disable();
                } else {
                    console.error('Unfollow failed:', data.error);
                    alert('Failed to unfollow: ' + data.error);
                }
            })
            .catch(error => {
                console.error('Error:', error);
            });
        });
    });
});