document.addEventListener('DOMContentLoaded', function() {
    var unfollowButtons = document.querySelectorAll('.unfollow-btn');
    unfollowButtons.forEach(function(button) {
        button.addEventListener('click', function(event) {
            event.preventDefault();
            var idArtiste = this.getAttribute('data-id');
            fetch('/unfollow', {
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
                    button.classList.add('btn-danger');
                    button.innerText= 'Unfollowed!';
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